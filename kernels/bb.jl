using CUDA
using CUDASIMDTypes
using IndexSpaces

@enum CHORDTag CplxTag BeamTag DishTag FreqTag PolrTag TimeTag

const Cplx = Index{Physics,CplxTag}
const Beam = Index{Physics,BeamTag}
const Dish = Index{Physics,DishTag}
const Freq = Index{Physics,FreqTag}
const Polr = Index{Physics,PolrTag}
const Time = Index{Physics,TimeTag}

const σ = trailing_zeros(128)

function make_bb_kernel()
    # Machine indices
    simd = SIMD(:simd, 1, 32)
    thread = Thread(:thread, 1, 32)
    warp = Warp(:warp, 1, 32)
    block = Block(:block, 1, 1024)
    shared = Shared(:shared, 1, 131072)
    memory = Memory(:memory, 1, 2^32)

    loopT1 = Loop(:T1, 128, 256)
    loopT2 = Loop(:T2, 32, 4)
    loopT3 = Loop(:T3, 8, 4)

    loopD = Loop(:D, 4, 8)

    loopB = Loop(:B, 8, 2)

    # Physics indices
    int4value = IntValue(:intvalue, 1, 4)
    int8value = IntValue(:intvalue, 1, 8)
    int16value = IntValue(:intvalue, 1, 16)
    int32value = IntValue(:intvalue, 1, 32)
    cplx = Cplx(:cplx, 1, 2)
    beam = Beam(:beam, 1, 96)
    dish = Dish(:dish, 1, 512)
    freq = Freq(:freq, 1, 16)
    polr = Polr(:polr, 1, 2)
    time = Time(:time, 1, 32768)

    dish0 = Dish(:dish, 1, 2)
    dish01 = Dish(:dish, 1, 4)
    dish1 = Dish(:dish, 2, 2)
    dish1etc = Dish(:dish, 2, 256)
    dish2 = Dish(:dish, 4, 2)
    dish23 = Dish(:dish, 4, 4)
    dish234 = Dish(:dish, 4, 8)
    dish2etc = Dish(:dish, 4, 128)
    dish34 = Dish(:dish, 8, 4)
    dish456 = Dish(:dish, 16, 8)
    dish5 = Dish(:dish, 32, 2)
    dish56 = Dish(:dish, 32, 4)
    dish6 = Dish(:dish, 64, 2)
    dish78 = Dish(:dish, 128, 4)

    beam0 = Beam(:beam, 1, 2)
    beam01 = Beam(:beam, 1, 4)
    beam012 = Beam(:beam, 1, 8)
    beam1 = Beam(:beam, 2, 2)
    beam12 = Beam(:beam, 2, 4)
    beam2 = Beam(:beam, 4, 2)
    beam23456 = Beam(:beam, 4, 24)
    beam3 = Beam(:beam, 8, 2)
    beam456 = Beam(:beam, 16, 6)

    time0 = Time(:time, 1, 2)
    time01 = Time(:time, 1, 4)
    time012 = Time(:time, 1, 8)
    time01234 = Time(:time, 1, 32)
    time1 = Time(:time, 2, 2)
    time12 = Time(:time, 2, 4)
    time2 = Time(:time, 4, 2)
    time234 = Time(:time, 4, 8)
    time2etc = Time(:time, 4, 8192)
    time34 = Time(:time, 8, 4)
    time56 = Time(:time, 32, 4)
    time7etc = Time(:time, 128, 256)

    # Physics quantities
    E = Quantity(:E, [cplx, dish, freq, polr, time, int4value])
    A = Quantity(:A, [cplx, beam, dish, freq, polr, int8value])
    J = Quantity(:J, [cplx, beam, freq, polr, time, int4value])

    # Memory layouts

    # E-matrix layout

    layout_E_memory = Layout(
        Dict(
            int4value => SIMD(:simd, 1, 4),
            cplx => SIMD(:simd, 4, 2),
            dish01 => SIMD(:simd, 4 * 2, 4),
            dish2etc => Memory(:memory, 1, 128),
            freq => Memory(:memory, 128, 16),
            polr => Memory(:memory, 128 * 16, 2),
            time => Memory(:memory, 128 * 16 * 2, 32768),
        ),
    )

    # A-matrix layout

    layout_A_memory = Layout(
        Dict(
            int8value => SIMD(:simd, 1, 8),
            cplx => SIMD(:simd, 8, 2),
            dish0 => SIMD(:simd, 8 * 2, 2),
            dish1etc => Memory(:memory, 1, 256),
            beam => Memory(:memory, 256, 96),
            polr => Memory(:memory, 256 * 96, 2),
            freq => Memory(:memory, 256 * 96 * 2, 16),
        ),
    )

    # s layout

    layout_s_global = Layout(
        Dict(
            int32value => SIMD(:simd, 1, 32),
            beam => Memory(:memory, 1, 96),
            polr => Memory(:memory, 96, 2),
            freq => Memory(:memory, 96 * 2, 16),
        ),
    )

    # J-matrix layout

    layout_J_memory = Layout(
        Dict(
            int4value => SIMD(:simd, 1, 4),
            cplx => SIMD(:simd, 4, 2),
            time01 => Memory(:memory, 1, 4),
            time2etc => Memory(:memory, 4, 8192),
            polr => Memory(:memory, 4 * 8192, 2),
            freq => Memory(:memory, 4 * 8192 * 2, 16),
            beam => Memory(:memory, 4 * 8192 * 2 * 16, 96),
        ),
    )

    # Shared memory layouts

    # E-matrix layout

    layout_E_shared = Layout(
        Dict(
            int4value => SIMD(:simd, 1, 4),
            cplx => SIMD(:simd, 4, 2),
            dish01 => SIMD(:simd, 4 * 2, 4),
            dish2etc => Shared(:shared, 1, 128),
            time01234 => Shared(:shared, 129, 32),
            time56 => loopT2,
            time7etc => loopT1,
            polr => Block(:block, 1, 2),
            freq => Block(:block, 2, 16),
        ),
    )

    # Ju layout

    layout_Ju_shared = Layout(
        Dict(
            int16value => SIMD(:simd, 1, 16),
            cplx => SIMD(:simd, 16, 2),
            beam => Shared(:shared, 1, 96),
            time01234 => Shared(:shared, 96, 32),
            time56 => loopT2,
            time7etc => loopT1,
            dish78 => Shared(:shared, 96 * 32, 4),
            polr => Block(:block, 1, 2),
            freq => Block(:block, 2, 16),
        ),
    )

    # Register layouts

    # E-matrix layout

    layout_E_registers = Layout(
        Dict(
            int4value => SIMD(:simd, 1, 4),
            cplx => SIMD(:simd, 4, 2),
            dish01 => SIMD(:simd, 4 * 2, 4),
            dish23 => Register(:dish, 4, 4),
            dish456 => Thread(:thread, 1, 8),
            dish78 => Warp(:warp, 1, 4),
            time01 => Thread(:thread, 8, 4),
            time234 => Warp(:warp, 4, 8),
            time56 => loopT2,
            time7etc => loopT1,
            polr => Block(:block, 1, 2),
            freq => Block(:block, 2, 16),
        ),
    )

    # A-matrix layout

    layout_A_registers = Layout(
        Dict(
            int8value => SIMD(:simd, 1, 8),
            cplx => Register(:cplx, 1, 2),
            dish01 => SIMD(:simd, 8, 4), # mma input 01
            dish234 => Register(:dish, 4, 8),
            dish56 => Thread(:thread, 1, 4), # mma input 23
            dish78 => Warp(:warp, 1, 4),
            beam012 => Thread(:thread, 4, 8), # mma output 012
            beam3 => Register(:beam, 8, 2),
            beam456 => Warp(:warp, 4, 6), # since Wb = 6
            polr => Block(:block, 1, 2),
            freq => Block(:block, 2, 16),
        ),
    )

    # J-matrix layout

    # Section 5, eqn. (24)
    layout_J_registers = Layout(
        Dict(
            int32value => SIMD(:simd, 1, 32),
            cplx => Register(:cplx, 1, 2),
            time012 => Thread(:thread, 1, 8),
            time34 => Register(:time, 8, 4),
            time56 => loopT2,
            time7etc => loopT1,
            beam01 => Thread(:thread, 8, 4),
            beam23456 => Warp(:warp, 1, 24),
            polr => Block(:block, 1, 2),
            freq => Block(:block, 2, 16),
        ),
    )

    # s layout

    layout_s_registers = Layout(
        Dict(
            int32value => SIMD(:simd, 1, 32),
            beam01 => Thread(:thread, 8, 4),
            beam23456 => Warp(:warp, 1, 24),
            polr => Block(:block, 1, 2),
            freq => Block(:block, 2, 16),
        ),
    )

    # Generate code

    emitter = Emitter()

    let
        layout_A0_registers = Layout(
            Dict(
                int8value => SIMD(:simd, 1, 8),
                cplx => SIMD(:simd, 8, 2),
                dish0 => SIMD(:simd, 16, 2),
                dish1 => Register(:cplx, 1, 2),
                dish2 => Register(:dish, 4, 2),
                dish34 => Thread(:thread, 2, 4),
                dish5 => Thread(:thread, 1, 2),
                dish6 => Register(:dish, 8, 2),
                dish78 => Warp(:warp, 1, 4),
                beam0 => Register(:dish, 16, 2),
                beam12 => Thread(:thread, 8, 4),
                beam3 => Register(:beam, 8, 2),
                beam456 => Warp(:warp, 4, 6), # since Wb = 6
                polr => Block(:block, 1, 2),
                freq => Block(:block, 2, 16),
            ),
        )

        load!(emitter, :s => layout_s_registers, :s_memory => layout_s_global)

        load!(emitter, :A0 => layout_A0_registers, :A_memory => layout_A_memory)
        permute!(emitter, :A1, :A0, Register(:cplx, 1, 2), SIMD(:simd, 16, 2))
        permute!(emitter, :A2, :A1, Register(:cplx, 1, 2), SIMD(:simd, 8, 2))
        permute!(emitter, :A3, :A2, Register(:dish, 8, 2), Thread(:thread, 2, 2))
        permute!(emitter, :A, :A3, Register(:dish, 16, 2), Thread(:thread, 4, 2))
        @assert emitter.environment[:A] == layout_A_registers
    end

    loop!(emitter, Time(:time, 128, 256) => loopT1) do emitter
        loop!(emitter, Time(:time, 32, 4) => loopT2) do emitter

            # Step 1: transferring global memory to shared memory
            block!(emitter) do emitter
                load!(emitter, :E => layout_E_registers, :E_memory => layout_E_memory)
                store!(emitter, :E_shared => layout_E_shared, :E)
                nothing
            end
            sync_threads!(emitter)

            # Step 2: matrix multiplication
            unrolled_loop!(emitter, Time(:time, 8, 4) => loopT3) do emitter
                unrolled_loop!(emitter, Beam(:beam, 8, 2) => loopB) do emitter
                    select!(emitter, :AselB, :A, Register(:beam, 8, 2) => loopB)

                    layout_Jureim_registers = Layout(
                        Dict(
                            int32value => SIMD(:simd, 1, 32),
                            dish78 => Warp(:warp, 1, 4),
                            time0 => Register(:time, 1, 2), # mma spectator 0
                            time12 => Thread(:thread, 1, 4),# mma spectator 12
                            time34 => loopT3,
                            time56 => loopT2,
                            time7etc => loopT1,
                            beam012 => Thread(:thread, 4, 8),# mma output 012
                            beam3 => loopB,
                            beam456 => Warp(:warp, 4, 6), # since Wb = 6
                            polr => Block(:block, 1, 2),
                            freq => Block(:block, 2, 16),
                        ),
                    )

                    apply!(emitter, :Jurepos, layout_Jureim_registers, Int32(0))
                    apply!(emitter, :Jureneg, layout_Jureim_registers, Int32(0))
                    apply!(emitter, :Juim, layout_Jureim_registers, Int32(0))

                    unrolled_loop!(emitter, Dish(:dish, 4, 8) => loopD) do emitter
                        select!(emitter, :AselBD, :AselB, Register(:dish, 4, 8) => loopD)
                        split!(emitter, [:Aim, :Are], :AselBD, cplx)

                        layout_E0_registers = Layout(
                            Dict(
                                int4value => SIMD(:simd, 1, 4),
                                cplx => SIMD(:simd, 4, 2),
                                dish01 => SIMD(:simd, 8, 4),
                                dish234 => loopD,
                                dish56 => Thread(:thread, 1, 4),
                                dish78 => Warp(:warp, 1, 4), # since Wd = 4
                                time012 => Thread(:thread, 4, 8),
                                time34 => loopT3,
                                time56 => loopT2,
                                time7etc => loopT1,
                                polr => Block(:block, 1, 2),
                                freq => Block(:block, 2, 16),
                            ),
                        )

                        load!(emitter, :E0 => layout_E0_registers, :E_shared => layout_E_shared)

                        # TODO: Don't undo offset encoding, don't shift right; fold this into a fixup after multiplying by A
                        widen!(emitter, :E1, :E0, SIMD(:simd, 4, 2) => Register(:cplx, 1, 2))
                        #TODO @assert env[:E2] == map_E_registers_multiply

                        split!(emitter, [:E1re, :E1im], :E1, cplx)

                        mma_row_col_m8n8k16_s8!(
                            emitter,
                            :Jurepos,
                            :Are => ([beam0, beam1, beam2], [dish0, dish1, dish5, dish6]),
                            :E1re => ([dish0, dish1, dish5, dish6], [time0, time1, time2]),
                            :Jurepos => ([beam0, beam1, beam2], [time0, time1, time2]),
                        )
                        mma_row_col_m8n8k16_s8!(
                            emitter,
                            :Jureneg,
                            :Aim => ([beam0, beam1, beam2], [dish0, dish1, dish5, dish6]),
                            :E1im => ([dish0, dish1, dish5, dish6], [time0, time1, time2]),
                            :Jureneg => ([beam0, beam1, beam2], [time0, time1, time2]),
                        )
                        mma_row_col_m8n8k16_s8!(
                            emitter,
                            :Juim,
                            :Are => ([beam0, beam1, beam2], [dish0, dish1, dish5, dish6]),
                            :E1im => ([dish0, dish1, dish5, dish6], [time0, time1, time2]),
                            :Juim => ([beam0, beam1, beam2], [time0, time1, time2]),
                        )
                        mma_row_col_m8n8k16_s8!(
                            emitter,
                            :Juim,
                            :Aim => ([beam0, beam1, beam2], [dish0, dish1, dish5, dish6]),
                            :E1re => ([dish0, dish1, dish5, dish6], [time0, time1, time2]),
                            :Juim => ([beam0, beam1, beam2], [time0, time1, time2]),
                        )

                        nothing
                    end

                    apply!(emitter, :Jure, [:Jurepos, :Jureneg], (Jurepos, Jureneg) -> :($Jurepos - $Jureneg))
                    merge!(emitter, :Ju, [:Juim, :Jure], cplx => Register(:cplx, 1, 2))

                    # TODO: Break ties to even?
                    @assert σ ≥ 1
                    apply!(emitter, :Ju, [:Ju], Ju -> :(($Ju + $(Int32(1 << (σ - 1)))) >> $(UInt32(σ))))

                    # Note: `cvs_pack_s16` saturates, so we don't need to clamp
                    # apply!(emitter, :Ju, :Ju, Ju -> :(clamp($Ju, (-Int32(0x7fff)):(+Int32(0x7fff)))))
                    narrow!(emitter, :Ju, :Ju, Register(:cplx, 1, 2) => SIMD(:simd, 16, 2))

                    store!(emitter, :Ju_shared => layout_Ju_shared, :Ju)

                    nothing
                end

                nothing
            end
            sync_threads!(emitter)

            # Step 3: reduce and quantize

            layout_Ju_registers = Layout(
                Dict(
                    int16value => SIMD(:simd, 1, 16),
                    cplx => SIMD(:simd, 16, 2),
                    dish78 => Register(:dish, 128, 4),
                    beam01 => Thread(:thread, 8, 4),
                    beam23456 => Warp(:warp, 1, 24),
                    time012 => Thread(:thread, 1, 8),
                    time34 => Register(:time, 8, 4),
                    time56 => loopT2,
                    time7etc => loopT1,
                    polr => Block(:block, 1, 2),
                    freq => Block(:block, 2, 16),
                ),
            )

            load!(emitter, :Ju => layout_Ju_registers, :Ju_shared => layout_Ju_shared)
            widen!(emitter, :Ju, :Ju, SIMD(:simd, 16, 2) => Register(:cplx, 1, 2))
            split!(emitter, [:Julo, :Juhi], :Ju, Dish(:dish, 128, 2))
            #TODO use add_sat
            apply!(emitter, :Ju, [:Julo, :Juhi], (Julo, Juhi) -> :($Julo + $Juhi))
            split!(emitter, [:Julo, :Juhi], :Ju, Dish(:dish, 256, 2))
            #TODO use add_sat
            apply!(emitter, :J, [:Julo, :Juhi], (Julo, Juhi) -> :($Julo + $Juhi))
            @assert emitter.environment[:J] == layout_J_registers

            apply!(emitter, :J, [:J, :s], (J, s) -> :(($J + (Int32(1) << ($s % UInt32 - 0x1))) >> ($s % UInt32)))

            # TODO: Try this: Shift values left by 4, rely on saturation when converting, then shift right and mask (doesn't work)
            # TODO: Try this: Pack to Int16, the clamp, then pack to Int8 (doesn't work, no efficient 16-bit clamp)
            apply!(emitter, :J, [:J], J -> :(clamp($J, (-Int32(0x7)):(+Int32(0x7)))))
            narrow3!(
                emitter,
                :J,
                :J,
                Register(:cplx, 1, 2) => SIMD(:simd, 4, 2),
                Register(:time, 8, 2) => SIMD(:simd, 8, 2),
                Register(:time, 16, 2) => SIMD(:simd, 16, 2),
            )

            #TODO    # Section 5, eqn. (26)
            #TODO    map_J3_registers = let
            #TODO        b = -1
            #TODO        Layout(
            #TODO            Int32,
            #TODO            Dict(
            #TODO                Cplx(0) => SIMD(2),
            #TODO                Time(0) => Thread(0),
            #TODO                Time(1) => Thread(1),
            #TODO                Time(2) => Thread(2),
            #TODO                Time(3) => SIMD(3),
            #TODO                Time(4) => SIMD(4),
            #TODO                Time(5) => LoopT1(0),
            #TODO                Time(6) => LoopT1(1),
            #TODO                [Time(t) => LoopT(t - 7) for t in 7:(ceil(Int, log2(T)) - 1)]...,
            #TODO                Beam(0) => Thread(3),
            #TODO                Beam(1) => Thread(4),
            #TODO                Beam(2) => Warp(0),
            #TODO                Beam(3) => Warp(1),
            #TODO                (@CHORDARR Beam(4) => Warp(2))...,
            #TODO                (@CHORDARR Beam(5) => Warp(3))...,
            #TODO                (@CHORDARR Beam(6) => Warp(4))...,
            #TODO                (@CHORDARR Polr(0) => Block(b += 1))...,
            #TODO                (@PATHFINDERARR Polr(0) => Register(5))...,
            #TODO                [Freq(f) => Block(b += 1) for f in 0:(ceil(Int, log2(F)) - 1)]...,
            #TODO            ),
            #TODO        )
            #TODO    end
            #TODO    @assert env[:J3] == map_J3_registers

            unselect!(emitter, :Jper, :J, loopT2 => Register(:time, 32, 4))

            nothing
        end

        nothing
    end

    stmts = clean_code(
        quote
            $(emitter.initializations...)
            $(emitter.statements...)
        end,
    )

    return stmts
end

const cacheline_size = 128

# TODO: make these const
E_shared_type = Int4x8    # TODO: determine automatically
E_shared_offset = 0
E_shared_size = 129 * 32  # TODO: calculate automatically

Ju_shared_type = Int16x2        # TODO: determine automatically
Ju_shared_offset = (E_shared_offset + E_shared_size + cacheline_size - 1) & -cacheline_size
Ju_shared_size = 96 * 32 * 4    # TODO: calculate automatically

total_shared_size = (Ju_shared_offset + Ju_shared_size + cacheline_size - 1) & -cacheline_size
shmem_bytes = sizeof(UInt32) * total_shared_size

bb_kernel = make_bb_kernel()
println(bb_kernel)

@eval function bb(A_memory, E_memory, s_memory, J_memory)
    E_shared = @cuDynamicSharedMem($E_shared_type, $E_shared_size, $(sizeof(UInt32) * E_shared_offset))
    Ju_shared = @cuDynamicSharedMem($Ju_shared_type, $Ju_shared_size, $(sizeof(UInt32) * Ju_shared_offset))
    $bb_kernel
    return nothing
end

# @eval function bb(A_memory, E_memory, s_memory, J_memory)
#     E_shared = Array{$E_shared_type}(undef, $E_shared_size)
#     # Ju_shared = Array{$Ju_shared_type}(undef, $Ju_shared_size)
#     $bb_kernel
#     return nothing
# end

function main()
    println("CHORD 8-bit baseband beamformer")
    println("J[t,p,f,b] = s[b,p,f] Σ[d] A[d,b,p,f] E[d,p,f,t]")

    # println(bb_kernel)

    println(" Allocate input data...")

    A_memory = zeros(Int8x4, 256 * 96 * 2 * 16) #TODO: calculate automatically
    E_memory = zeros(Int4x8, 128 * 16 * 2 * 32768) #TODO: calculate automatically
    s_memory = zeros(Int32, 96 * 2 * 16) #TODO: calculate automatically
    J_memory = zeros(Int4x8, 4 * 8192 * 2 * 16 * 96)#TODO: calculate automatically

    # bb(A_memory, E_memory, s_memory, J_memory)

    if CUDA.functional()
        println(" Copy data from CPU to GPU...")
        A_memory = CuArray(A_memory)
        E_memory = CuArray(E_memory)
        s_memory = CuArray(s_memory)
        J_memory = CuArray(J_memory)

        println(" Compile kernel...")
        nthreads = 32
        nwarps = 24                     # TODO
        nblocks = 32                    # TODO
        # @assert shmem_bytes ≤ 99 * 1024 # NVIDIA A10/A40 have 99 kB shared memory

        blocks_per_sm = 1       # TODO
        kernel = @cuda launch = false minthreads = nthreads * nwarps blocks_per_sm = blocks_per_sm bb(
            A_memory, E_memory, s_memory, J_memory
        )

        println(" Running kernel...")
        attributes(kernel.fun)[CUDA.CU_FUNC_ATTRIBUTE_MAX_DYNAMIC_SHARED_SIZE_BYTES] = shmem_bytes
        kernel(A_memory, E_memory, s_memory, J_memory; threads=(nthreads, nwarps), blocks=nblocks, shmem=shmem_bytes)
        synchronize()

        println(" Copy data back from GPU to CPU...")
        A_memory = Array(A_memory)
        E_memory = Array(E_memory)
        s_memory = Array(s_memory)
        J_memory = Array(J_memory)
    end

    println("Done.")
    return nothing
end

@device_code_warntype main()
