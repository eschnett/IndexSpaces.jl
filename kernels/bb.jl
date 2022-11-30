using CUDA
using CUDASIMDTypes
using IndexSpaces
using Random

shift(x::Number, s) = (x + (1 << (s - 1))) >> s
shift(x::Complex, s) = Complex(shift(x.re, s), shift(x.im, s))
Base.clamp(x::Complex, a, b) = Complex(clamp(x.re, a, b), clamp(x.im, a, b))
Base.clamp(x::Complex, ab::UnitRange) = clamp(x, ab.start, ab.stop)

@enum CHORDTag CplxTag BeamTag DishTag FreqTag PolrTag TimeTag

const Cplx = Index{Physics,CplxTag}
const Beam = Index{Physics,BeamTag}
const Dish = Index{Physics,DishTag}
const Freq = Index{Physics,FreqTag}
const Polr = Index{Physics,PolrTag}
const Time = Index{Physics,TimeTag}

# Problem size

# # Full CHORD
# const C = 2
# const T = 32768
# const D = 512
# const B = 96
# const P = 2
# const F = 16

# Testing
const C = 2
const T = 32768
const D = 512
const B = 128
const P = 2
const F = 16

const σ = trailing_zeros(D ÷ 4) - 4

function make_bb_kernel()
    # Machine indices
    simd = SIMD(:simd, 1, 32)
    thread = Thread(:thread, 1, 32)
    warp = Warp(:warp, 1, 32)
    block = Block(:block, 1, 1024)
    shared = Shared(:shared, 1, 131072)
    memory = Memory(:memory, 1, 2^32)

    loopT3 = Loop(:T3, 8, 4)
    loopT2 = Loop(:T2, 32, 4)
    loopT1 = Loop(:T1, 128, T ÷ 128)

    loopD = Loop(:D, 4, 8)

    loopB = Loop(:B, 8, 2)

    # Physics indices
    int4value = IntValue(:intvalue, 1, 4)
    int8value = IntValue(:intvalue, 1, 8)
    int16value = IntValue(:intvalue, 1, 16)
    int32value = IntValue(:intvalue, 1, 32)
    cplx = Cplx(:cplx, 1, C)
    beam = Beam(:beam, 1, B)
    dish = Dish(:dish, 1, D)
    freq = Freq(:freq, 1, F)
    polr = Polr(:polr, 1, P)
    time = Time(:time, 1, T)

    dish0 = Dish(:dish, 1, 2)
    dish01 = Dish(:dish, 1, 4)
    dish1 = Dish(:dish, 2, 2)
    dish1etc = Dish(:dish, 2, D ÷ 2)
    dish2 = Dish(:dish, 4, 2)
    dish23 = Dish(:dish, 4, 4)
    dish234 = Dish(:dish, 4, 8)
    dish2etc = Dish(:dish, 4, D ÷ 4)
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
    beam23456 = Beam(:beam, 4, B ÷ 4)
    beam3 = Beam(:beam, 8, 2)
    beam456 = Beam(:beam, 16, B ÷ 16)

    time0 = Time(:time, 1, 2)
    time01 = Time(:time, 1, 4)
    time012 = Time(:time, 1, 8)
    time01234 = Time(:time, 1, 32)
    time1 = Time(:time, 2, 2)
    time12 = Time(:time, 2, 4)
    time2 = Time(:time, 4, 2)
    time234 = Time(:time, 4, 8)
    time2etc = Time(:time, 4, T ÷ 4)
    time34 = Time(:time, 8, 4)
    time56 = Time(:time, 32, 4)
    time7etc = Time(:time, 128, T ÷ 128)

    # # Physics quantities
    # E = Quantity(:E, [cplx, dish, freq, polr, time, int4value])
    # A = Quantity(:A, [cplx, beam, dish, freq, polr, int8value])
    # J = Quantity(:J, [cplx, beam, freq, polr, time, int4value])

    # Memory layouts

    # E-matrix layout

    layout_E_memory = Layout(
        Dict(
            int4value => SIMD(:simd, 1, 4),
            cplx => SIMD(:simd, 4, 2),
            dish01 => SIMD(:simd, 4 * 2, 4),
            dish2etc => Memory(:memory, 1, D ÷ 4),
            freq => Memory(:memory, D ÷ 4, F),
            polr => Memory(:memory, (D ÷ 4) * F, P),
            time => Memory(:memory, (D ÷ 4) * F * P, T),
        ),
    )

    # A-matrix layout

    layout_A_memory = Layout(
        Dict(
            int8value => SIMD(:simd, 1, 8),
            cplx => SIMD(:simd, 8, 2),
            dish0 => SIMD(:simd, 8 * 2, 2),
            dish1etc => Memory(:memory, 1, D ÷ 2),
            beam => Memory(:memory, D ÷ 2, B),
            polr => Memory(:memory, (D ÷ 2) * B, P),
            freq => Memory(:memory, (D ÷ 2) * B * P, F),
        ),
    )

    # s layout

    layout_s_global = Layout(
        Dict(
            int32value => SIMD(:simd, 1, 32),
            beam => Memory(:memory, 1, B),
            polr => Memory(:memory, B, P),
            freq => Memory(:memory, B * P, F),
        ),
    )

    # J-matrix layout

    layout_J_memory = Layout(
        Dict(
            int4value => SIMD(:simd, 1, 4),
            cplx => SIMD(:simd, 4, 2),
            time01 => SIMD(:simd, 8, 4),
            time2etc => Memory(:memory, 1, T ÷ 4),
            polr => Memory(:memory, T ÷ 4, P),
            freq => Memory(:memory, (T ÷ 4) * P, F),
            beam => Memory(:memory, (T ÷ 4) * P * F, B),
        ),
    )

    # Shared memory layouts

    # E-matrix layout

    layout_E_shared = Layout(
        Dict(
            int4value => SIMD(:simd, 1, 4),
            cplx => SIMD(:simd, 4, 2),
            dish01 => SIMD(:simd, 4 * 2, 4),
            dish2etc => Shared(:shared, 1, D ÷ 4),
            time01234 => Shared(:shared, (D ÷ 4) + 1, 32),
            time56 => loopT2,
            time7etc => loopT1,
            polr => Block(:block, 1, P),
            freq => Block(:block, P, F),
        ),
    )

    # Ju layout

    layout_Ju_shared = Layout(
        Dict(
            int16value => SIMD(:simd, 1, 16),
            cplx => SIMD(:simd, 16, 2),
            beam => Shared(:shared, 1, B),
            time01234 => Shared(:shared, B, 32),
            time56 => loopT2,
            time7etc => loopT1,
            dish78 => Shared(:shared, B * 32, 4),
            polr => Block(:block, 1, P),
            freq => Block(:block, P, F),
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
            polr => Block(:block, 1, P),
            freq => Block(:block, P, F),
        ),
    )

    # A-matrix layout

    layout_A_registers = Layout(
        Dict(
            int8value => SIMD(:simd, 1, 8),
            cplx => Register(:cplx, 1, C),
            dish01 => SIMD(:simd, 8, 4), # mma input 01
            dish234 => Register(:dish, 4, 8),
            dish56 => Thread(:thread, 1, 4), # mma input 23
            dish78 => Warp(:warp, 1, 4),
            beam012 => Thread(:thread, 4, 8), # mma output 012
            beam3 => Register(:beam, 8, 2),
            beam456 => Warp(:warp, 4, B ÷ 16), # since Wb = 6
            polr => Block(:block, 1, P),
            freq => Block(:block, P, F),
        ),
    )

    # J-matrix layout

    # Section 5, eqn. (24)
    layout_J_registers = Layout(
        Dict(
            int32value => SIMD(:simd, 1, 32),
            cplx => Register(:cplx, 1, C),
            time012 => Thread(:thread, 1, 8),
            time34 => Register(:time, 8, 4),
            time56 => loopT2,
            time7etc => loopT1,
            beam01 => Thread(:thread, 8, 4),
            beam23456 => Warp(:warp, 1, B ÷ 4),
            polr => Block(:block, 1, P),
            freq => Block(:block, P, F),
        ),
    )

    # s layout

    layout_s_registers = Layout(
        Dict(
            int32value => SIMD(:simd, 1, 32),
            beam01 => Thread(:thread, 8, 4),
            beam23456 => Warp(:warp, 1, B ÷ 4),
            polr => Block(:block, 1, P),
            freq => Block(:block, P, F),
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
                dish1 => Register(:cplx, 1, C),
                dish2 => Register(:dish, 4, 2),
                dish34 => Thread(:thread, 2, 4),
                dish5 => Thread(:thread, 1, 2),
                dish6 => Register(:dish, 8, 2),
                dish78 => Warp(:warp, 1, 4),
                beam0 => Register(:dish, 16, 2),
                beam12 => Thread(:thread, 8, 4),
                beam3 => Register(:beam, 8, 2),
                beam456 => Warp(:warp, 4, B ÷ 16), # since Wb = 6
                polr => Block(:block, 1, P),
                freq => Block(:block, P, F),
            ),
        )

        load!(emitter, :s => layout_s_registers, :s_memory => layout_s_global)

        load!(emitter, :A => layout_A0_registers, :A_memory => layout_A_memory; align=16)
        permute!(emitter, :A, :A, Register(:cplx, 1, C), SIMD(:simd, 16, 2))
        permute!(emitter, :A, :A, Register(:cplx, 1, C), SIMD(:simd, 8, 2))
        permute!(emitter, :A, :A, Register(:dish, 8, 2), Thread(:thread, 2, 2))
        permute!(emitter, :A, :A, Register(:dish, 16, 2), Thread(:thread, 4, 2))
        @assert emitter.environment[:A] == layout_A_registers
    end

    loop!(emitter, Time(:time, loopT1.offset, loopT1.length) => loopT1) do emitter
        loop!(emitter, Time(:time, loopT2.offset, loopT2.length) => loopT2) do emitter

            # Step 1: transferring global memory to shared memory
            block!(emitter) do emitter
                load!(emitter, :E => layout_E_registers, :E_memory => layout_E_memory; align=16)
                store!(emitter, :E_shared => layout_E_shared, :E)
                nothing
            end
            sync_threads!(emitter)

            # Step 2: matrix multiplication
            unrolled_loop!(emitter, Time(:time, loopT3.offset, loopT3.length) => loopT3) do emitter
                unrolled_loop!(emitter, Beam(:beam, loopB.offset, loopB.length) => loopB) do emitter
                    select!(emitter, :AselB, :A, Register(:beam, loopB.offset, loopB.length) => loopB)

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
                            beam456 => Warp(:warp, 4, B ÷ 16), # since Wb = 6
                            polr => Block(:block, 1, P),
                            freq => Block(:block, P, F),
                        ),
                    )

                    apply!(emitter, :Jurepos, layout_Jureim_registers, Int32(0))
                    apply!(emitter, :Jureneg, layout_Jureim_registers, Int32(0))
                    apply!(emitter, :Juim, layout_Jureim_registers, Int32(0))

                    unrolled_loop!(emitter, Dish(:dish, loopD.offset, loopD.length) => loopD) do emitter
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
                                polr => Block(:block, 1, P),
                                freq => Block(:block, P, F),
                            ),
                        )

                        load!(emitter, :E0 => layout_E0_registers, :E_shared => layout_E_shared)

                        # TODO: Don't undo offset encoding, don't shift right; fold this into a fixup after multiplying by A
                        widen!(emitter, :E1, :E0, SIMD(:simd, 4, 2) => Register(:cplx, 1, C))

                        split!(emitter, [:E1im, :E1re], :E1, cplx)

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
                    merge!(emitter, :Ju, [:Juim, :Jure], cplx => Register(:cplx, 1, C))

                    # TODO: Break ties to even?
                    @assert σ ≥ 1
                    apply!(emitter, :Ju, [:Ju], Ju -> :(($Ju + $(Int32(1 << (σ - 1)))) >> $(UInt32(σ))))

                    # Note: `cvs_pack_s16` saturates, so we don't need to clamp
                    # apply!(emitter, :Ju, :Ju, Ju -> :(clamp($Ju, (-Int32(0x7fff)):(+Int32(0x7fff)))))
                    narrow!(emitter, :Ju, :Ju, Register(:cplx, 1, C) => SIMD(:simd, 16, 2))

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
                    beam23456 => Warp(:warp, 1, B ÷ 4),
                    time012 => Thread(:thread, 1, 8),
                    time34 => Register(:time, 8, 4),
                    time56 => loopT2,
                    time7etc => loopT1,
                    polr => Block(:block, 1, P),
                    freq => Block(:block, P, F),
                ),
            )

            load!(emitter, :Ju => layout_Ju_registers, :Ju_shared => layout_Ju_shared)
            widen!(emitter, :Ju, :Ju, SIMD(:simd, 16, 2) => Register(:cplx, 1, C))
            split!(emitter, [:Julo, :Juhi], :Ju, Dish(:dish, 128, 2))
            # TODO use add_sat
            apply!(emitter, :Ju, [:Julo, :Juhi], (Julo, Juhi) -> :($Julo + $Juhi))
            split!(emitter, [:Julo, :Juhi], :Ju, Dish(:dish, 256, 2))
            # TODO use add_sat
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
                Register(:cplx, 1, C) => SIMD(:simd, 4, 2),
                Register(:time, 8, 2) => SIMD(:simd, 8, 2),
                Register(:time, 16, 2) => SIMD(:simd, 16, 2),
            )

            unselect!(emitter, :Jper, :J, loopT2 => Register(:time, loopT2.offset, loopT2.length))

            nothing
        end

        permute!(emitter, :Jper, :Jper, Register(:time, 32, 2), SIMD(:simd, 8, 2))
        permute!(emitter, :Jper, :Jper, Register(:time, 32, 2), Thread(:thread, 1, 2))
        permute!(emitter, :Jper, :Jper, Register(:time, 32, 2), SIMD(:simd, 8, 2))
        permute!(emitter, :Jper, :Jper, Register(:time, 64, 2), Thread(:thread, 2, 2))
        permute!(emitter, :Jper, :Jper, Register(:time, 64, 2), SIMD(:simd, 16, 2))
        permute!(emitter, :Jper, :Jper, Register(:time, 32, 2), Thread(:thread, 4, 2))
        permute!(emitter, :Jper, :Jper, Register(:time, 64, 2), Thread(:thread, 1, 2))

        store!(emitter, :J_memory => layout_J_memory, :Jper; align=16)

        nothing
    end

    stmts = clean_code(
        quote
            @inbounds begin
                $(emitter.init_statements...)
                $(emitter.statements...)
            end
        end,
    )

    return stmts
end

const cacheline_length = 32     # counting in UInt32

# TODO: make these const
E_shared_type = Int4x8    # TODO: determine automatically
E_shared_offset = 0
E_shared_length = (D ÷ 4 + 1) * 32  # TODO: calculate automatically

Ju_shared_type = Int16x2        # TODO: determine automatically
Ju_shared_offset = (E_shared_offset + E_shared_length + cacheline_length - 1) & -cacheline_length
Ju_shared_length = B * 32 * 4    # TODO: calculate automatically

total_shared_length = (Ju_shared_offset + Ju_shared_length + cacheline_length - 1) & -cacheline_length
shmem_bytes = sizeof(UInt32) * total_shared_length

println("[Creating bb kernel...]")
bb_kernel = make_bb_kernel()
println("[Done creating bb kernel]")

@eval function bb(A_memory, E_memory, s_memory, J_memory)
    E_shared = @cuDynamicSharedMem($E_shared_type, $E_shared_length, $(sizeof(UInt32) * E_shared_offset))
    Ju_shared = @cuDynamicSharedMem($Ju_shared_type, $Ju_shared_length, $(sizeof(UInt32) * Ju_shared_offset))
    $bb_kernel
    return nothing
end

function main(; compile_only::Bool=false)
    if !compile_only
        println("CHORD 8-bit baseband beamformer")
        println("J[t,p,f,b] = s[b,p,f] Σ[d] A[d,b,p,f] E[d,p,f,t]")
    end

    if !compile_only
        println("Compiling kernel...")
    end
    nthreads = 32
    nwarps = B ÷ 4              # TODO: calculate automatically
    nblocks = P * F             # TODO: calculate automatically
    # @assert shmem_bytes ≤ 99 * 1024 # NVIDIA A10/A40 have 99 kB shared memory

    blocks_per_sm = 1           # TODO: calculate automatically
    kernel = @cuda launch = false minthreads = nthreads * nwarps blocks_per_sm = blocks_per_sm bb(
        CUDA.zeros(Int8x4, 0), CUDA.zeros(Int4x8, 0), CUDA.zeros(Int32, 0), CUDA.zeros(Int4x8, 0)
    )

    if compile_only
        return nothing
    end

    open("output/bb.jl", "w") do fh
        println(fh, bb_kernel)
    end
    kernel_name = let
        line = filter(line -> match(r"\.globl", line) ≠ nothing, readlines("output/bb.ptx"))[begin]
        match(r"\.globl\s+(\S+)", line).captures[1]
    end
    open("output/bb.yaml", "w") do fh
        print(
            fh,
            """
    --- !<tag:chord-observatory.ca/x-engine/kernel-description-1.0.0>
    kernel-description:
      name: "bb"
      description: "baseband beamformer"
      design-parameters:
        number-of-beams: $B
        number-of-complex-components: $C
        number-of-dishes: $D
        number-of-frequencies: $F
        number-of-polarizations: $P
        number-of-timesamples: $T
        shift-parameter-σ: $σ
      compile-parameters:
        minthreads: $(nthreads * nwarps)
        blocks_per_sm: $blocks_per_sm
      call-parameters:
        threads: [$nthreads, $nwarps]
        blocks: [$nblocks]
        shmem: $shmem_bytes
      kernel-name: "$kernel_name"
      kernel-arguments:
        - name: "A"
          intent: in
          type: Int8
          indices: [C, D, B, P, F]
          shape: [$C, $D, $B, $P, $F]
          strides: [1, $C, $(C*D), $(C*D*B), $(C*D*B*P)]
        - name: "E"
          intent: in
          type: Int4
          indices: [C, D, F, P, T]
          shape: [$C, $D, $F, $P, $T]
          strides: [1, $C, $(C*D), $(C*D*F), $(C*D*F*P)]
        - name: "s"
          intent: in
          type: Int32
          indices: [B, P, F]
          shape: [$B, $P, $F]
          strides: [1, $B, $(B*P)]
        - name: "J"
          intent: out
          type: Int4
          indices: [C, T, P, F, B]
          shape: [$C, $T, $P, $F, $B]
          strides: [1, $C, $(C*T), $(C*T*P), $(C*T*P*F)]
    ...
    """,
        )
    end

    println("Allocating input data...")

    # TODO: determine types and sizes automatically
    A_memory = Array{Int8x4}(undef, (D ÷ 2) * B * P * F)
    E_memory = Array{Int4x8}(undef, (D ÷ 4) * F * P * T)
    s_memory = Array{Int32}(undef, B * P * F)
    J_wanted = Array{Int4x8}(undef, (T ÷ 4) * P * F * B)

    println("Setting up input data...")
    map!(i -> zero(Int8x4), A_memory, A_memory)
    map!(i -> zero(Int4x8), E_memory, E_memory)
    map!(i -> Int32(1), s_memory, s_memory)
    map!(i -> zero(Int4x8), J_wanted, J_wanted)
    # map!(i -> rand(Int8x4), A_memory, A_memory)
    # map!(i -> rand(Int4x8), E_memory, E_memory)
    # map!(i -> rand(Int32(1):Int32(10)), s_memory, s_memory)

    input = :random
    if input == :zero
        # do nothing
    elseif input == :random
        Random.seed!(0)

        # Choose all s
        s_memory .= rand(1:10, F * P * B)

        # Choose A and E
        for iter in 1:1000
            freq = 0
            polr = 0
            time = 0
            dish = 0
            beam = 0
            Eval = 0
            Aval = 0
            sval = 0
            Jval = 0
            while true
                freq = rand(0:(F - 1))
                polr = rand(0:(P - 1))
                time = rand(0:(T - 1))
                dish = rand(0:(D - 1))
                beam = rand(0:(B - 1))
                Eval = rand(-7:7) + im * rand(-7:7)
                Aval = rand(-127:127) + im * rand(-127:127)
                sval = s_memory[(freq * P + polr) * B + beam + 1]
                Juval = Aval * Eval
                Juval = shift(Juval, σ)
                @assert max(abs(Juval.re), abs(Juval.im)) ≤ 32767
                Jval = Juval
                Jval = shift(Jval, sval)
                min(abs(Jval.re), abs(Jval.im)) > 0 && max(abs(Jval.re), abs(Jval.im)) ≤ 15 && break
            end
            println("    freq=$freq polr=$polr time=$time dish=$dish beam=$beam Eval=$Eval Aval=$Aval sval=$sval Jval=$Jval")
            A_memory[(((freq * P + polr) * B + beam) * D + dish) ÷ 2 + 1] += if dish % 2 == 0
                Int8x4(Aval.im, Aval.re, 0, 0)
            elseif dish % 2 == 1
                Int8x4(0, 0, Aval.im, Aval.re)
            else
                @assert false
            end
            E_memory[(((time * P + polr) * F + freq) * D + dish) ÷ 4 + 1] += if dish % 4 == 0
                Int4x8(Eval.im, Eval.re, 0, 0, 0, 0, 0, 0)
            elseif dish % 4 == 1
                Int4x8(0, 0, Eval.im, Eval.re, 0, 0, 0, 0)
            elseif dish % 4 == 2
                Int4x8(0, 0, 0, 0, Eval.im, Eval.re, 0, 0)
            elseif dish % 4 == 3
                Int4x8(0, 0, 0, 0, 0, 0, Eval.im, Eval.re)
            else
                @assert false
            end
        end

    else
        @assert false
    end

    println("Evaluating kernel on CPU...")
    Threads.@threads for b in 0:(B - 1)
        for f in 0:(F - 1), p in 0:(P - 1), t in 0:(T - 1)
            s = s_memory[(f * P + p) * B + b + 1]
            Ju = 0 + 0im
            for d in 0:(D - 1)
                A = Complex{Int}(reverse(reinterpret(NTuple{2,Int8}, A_memory)[((f * P + p) * B + b) * D + d + 1])...)
                E = Complex{Int}(
                    reverse(convert(NTuple{2,Int8}, reinterpret(Int4x2, E_memory)[((t * P + p) * F + f) * D + d + 1]))...
                )
                Ju += A * E
            end
            Ju = shift(Ju, σ)
            @assert max(abs(Ju.re), abs(Ju.im)) ≤ 32767
            J = Ju
            J = shift(J, s)
            reinterpret(Int4x2, J_wanted)[((b * F + f) * P + p) * T + t + 1] = Int4x2(
                Int32(clamp(J.im, -7:+7)), Int32(clamp(J.re, -7:+7))
            )
        end
    end

    println("Copying data from CPU to GPU...")
    A_cuda = CuArray(A_memory)
    E_cuda = CuArray(E_memory)
    s_cuda = CuArray(s_memory)
    J_cuda = CUDA.fill(Int4x8(-8, -8, -8, -8, -8, -8, -8, -8), (T ÷ 4) * P * F * B)

    println("Running kernel...")
    attributes(kernel.fun)[CUDA.CU_FUNC_ATTRIBUTE_MAX_DYNAMIC_SHARED_SIZE_BYTES] = shmem_bytes
    kernel(A_cuda, E_cuda, s_cuda, J_cuda; threads=(nthreads, nwarps), blocks=nblocks, shmem=shmem_bytes)
    synchronize()

    println("Copying data back from GPU to CPU...")
    J_memory = Array(J_cuda)

    println("Checking results...")

    error_count = 0
    checked_J = falses(B, T, P, F)
    for f in 0:(F - 1), p in 0:(P - 1), t in 0:4:(T - 1), b in 0:(B - 1)
        @assert !any(checked_J[b + 1, (t + 1):(t + 4), p + 1, f + 1])
        checked_J[b + 1, (t + 1):(t + 4), p + 1, f + 1] .= true
        J = J_memory[(((b * F + f) * P + p) * T + t) ÷ 4 + 1]
        Jwant = J_wanted[(((b * F + f) * P + p) * T + t) ÷ 4 + 1]
        if J ≠ Jwant
            if error_count ≤ 100
                println("    ERROR: freq=$f polr=$p time=$t beam=$b J=$J Jwant=$Jwant")
            end
            error_count += 1
        end
    end
    @assert all(checked_J)
    println("    J: $error_count errors found")

    println("Done.")
    return nothing
end

if CUDA.functional()
    open("output/bb.ptx", "w") do fh
        redirect_stdout(fh) do
            @device_code_ptx main(; compile_only=true)
        end
    end
    open("output/bb.sass", "w") do fh
        redirect_stdout(fh) do
            @device_code_sass main(compile_only=true)
        end
    end
    main()
end
