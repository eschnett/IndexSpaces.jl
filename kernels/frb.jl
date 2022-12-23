# CHORD FRB beamformer
# <CHORD_FRB_beamformer.pdf>

using CUDA
using CUDASIMDTypes
using IndexSpaces
# using Random

idiv(i::Integer, j::Integer) = (@assert iszero(i % j); i ÷ j)
# shift(x::Number, s) = (@assert s ≥ 1; (x + (1 << (s - 1))) >> s)
# shift(x::Complex, s) = Complex(shift(x.re, s), shift(x.im, s))
# Base.clamp(x::Complex, a, b) = Complex(clamp(x.re, a, b), clamp(x.im, a, b))
# Base.clamp(x::Complex, ab::UnitRange) = clamp(x, ab.start, ab.stop)

# CHORD Setup

# Compile-time constants (section 4.4)

# Full CHORD
const sampling_time = 27.3
const C = 2
const T = 2064
const D = 512
const M = 24
const N = 24
const P = 2
const F₀ = 256
const F = 256

const Touter = 48
const Tinner = 4
const Tds = 40                  # downsampling factor

const W = 24                    # number of warps
const B = 1                     # number of blocks per SM

# Derived compile-time parameters (section 4.4)
const Mpad = nextpow(2, M)
const Npad = nextpow(2, N)

# Freg2 layout

const Mt = idiv(32, Npad)
const Mw = gcd(idiv(M, Mt), W)
const Tw = idiv(W, Mw)
const Mr = idiv(M, Mt * Mw)
const Tr = idiv(Touter, 2 * Tw)

# Fsh1 layout
const ΣF1 = D == 64 ? 260 : 257

# Fsh2 layout
const ΣF2 = 32 * (M + 1) + Mt

# Registers/thread

const RF1 = (D + W - 1) ÷ W
const RF2 = Mr * Tr

# Shared memory bytes

const Fsh1_shmem_bytes = idiv(D * ΣF1, 4)
const Fsh2_shmem_bytes = 4 * N * ΣF2

# Machine setup

const num_simd_bits = 32
const num_threads = 32
const num_warps = W
const num_blocks = F # ???
const num_blocks_per_sm = B

# TODO ... more here ...

# CHORD indices

@enum CHORDTag CplxTag DishTag DishMTag DishNTag BeamPTag BeamQTag FreqTag PolrTag TimeTag

const Cplx = Index{Physics,CplxTag}
const Dish = Index{Physics,DishTag}
const DishM = Index{Physics,DishMTag}
const DishN = Index{Physics,DishNTag}
const BeamP = Index{Physics,BeamPTag}
const BeamQ = Index{Physics,BeamQTag}
const Freq = Index{Physics,FreqTag}
const Polr = Index{Physics,PolrTag}
const Time = Index{Physics,TimeTag}

# const int4value = IntValue(:intvalue, 1, 4)
# const float16value = FloatValue(:floatvalue, 1, 16)

# Layouts

const layout_E_memory = Layout(
    Dict(
        IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
        Cplx(:cplx, 1, C) => SIMD(:simd, 4, 2),
        Dish(:dish, 1, 4) => SIMD(:simd, 8, 4),
        Dish(:dish, 4, idiv(D, 4)) => Memory(:memory, 1, idiv(D, 4)),
        Freq(:freq, 1, F) => Memory(:memory, idiv(D, 4), F),
        Polr(:polr, 1, P) => Memory(:memory, idiv(D, 4) * F, P),
        Time(:time, 1, T) => Memory(:memory, idiv(D, 4) * F * P, T),
    ),
)

const layout_S_memory = Layout(Dict(IntValue(:intvalue, 1, 32) => SIMD(:simd, 1, 32), Dish(:dish, 1, D) => Memory(:memory, 1, D)))

const layout_W_memory = Layout(
    Dict(
        FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
        Cplx(:cplx, 1, C) => SIMD(:simd, 16, 2),
        # TODO: Improve layout
        # TODO: Only store DishN(1..N); zero DishN(N..Npad) while loading
        DishM(:dishM, 1, M) => Memory(:memory, 1, M),
        DishN(:dishN, 1, Npad) => Memory(:memory, M, Npad),
        Freq(:freq, 1, F) => Memory(:memory, M * Npad, F),
        Polr(:polr, 1, P) => Memory(:memory, M * Npad * F, P),
    ),
)

# Section 4.5, eqns. (54)+, (61)+
const layout_Fsh1_shared = Layout(
    Dict(
        IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
        Cplx(:cplx, 1, C) => SIMD(:simd, 16, 2),
        Dish(:dish, 1, 8) => Shared(:shared, 32, 8),
        Dish(:dish, 8, idiv(D, 8)) => Shared(:shared, ΣF1, idiv(D, 8)),
        Freq(:freq, 1, F) => Block(:block, 1, F),
        Polr(:polr, 1, P) => SIMD(:simd, 4, 2),
        Time(:time, 1, idiv(Touter, 2)) => Shared(:shared, 1, idiv(Touter, 2)),
        Time(:time, idiv(Touter, 2), 2) => SIMD(:simd, 8, 2),
        Time(:time, Touter, idiv(T, Touter)) => Loop(:T1, Touter, idiv(T, Touter)),
    ),
)

const layout_Fsh2_gridding_shared = Layout(
    Dict(
        IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
        Cplx(:cplx, 1, C) => SIMD(:simd, 16, 2),
        Freq(:freq, 1, F) => Block(:block, 1, F),
        Polr(:polr, 1, P) => SIMD(:simd, 4, 2),
        Time(:time, 1, idiv(Touter, 2)) => Shared(:shared, 1, idiv(Touter, 2)),
        Time(:time, idiv(Touter, 2), 2) => SIMD(:simd, 8, 2),
        Time(:time, Touter, idiv(T, Touter)) => Loop(:T1, Touter, idiv(T, Touter)),
    ),
)

# Section 4.5, eqns. (67)+
const layout_Fsh2_shared = Layout(
    Dict(
        IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
        Cplx(:cplx, 1, C) => SIMD(:simd, 16, 2),
        DishM(:dishM, 1, M) => Shared(:shared, 33, M),
        DishN(:dishN, 1, N) => Shared(:shared, ΣF2, N),
        Freq(:freq, 1, F) => Block(:block, 1, F),
        Polr(:polr, 1, P) => SIMD(:simd, 4, 2),
        Time(:time, 1, idiv(Touter, 2)) => Shared(:shared, 1, idiv(Touter, 2)),
        Time(:time, idiv(Touter, 2), 2) => SIMD(:simd, 8, 2),
        Time(:time, Touter, idiv(T, Touter)) => Loop(:T1, Touter, idiv(T, Touter)),
    ),
)

# TODO ... more here ...

# Machine indices

# const simd = SIMD(:simd, 1, num_simd_bits)
# const thread = Thread(:thread, 1, num_threads)
# const warp = Warp(:warp, 1, num_warps)
# const block = Block(:block, 1, num_blocks)
# const shared = Shared(:shared, 1, 99 * 1024)
# const memory = Memory(:memory, 1, 2^32)

const shmem_bytes = max(Fsh1_shmem_bytes, Fsh2_shmem_bytes)

const kernel_setup = KernelSetup(num_threads, num_warps, num_blocks, num_blocks_per_sm, shmem_bytes)

# Generate Code

# Copying global memory to shared memory (Fsh1) (section 4.6)
function copy_global_memory_to_Fsh1!(emitter)
    # Eqn. (90)
    layout_E_registers = Layout(
        Dict(
            IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
            Cplx(:cplx, 1, C) => SIMD(:simd, 4, 2),
            Dish(:dish, 1, 4) => SIMD(:simd, 8, 4),
            Dish(:dish, 4, 4) => Register(:dish, 4, 4),
            Dish(:dish, 16, 16) => Thread(:thread, 1, 16),
            Dish(:dish, 256, idiv(D, 256)) => Register(:dish, 256, idiv(D, 256)),
            Freq(:freq, 1, F) => Block(:block, 1, F),
            Polr(:polr, 1, P) => Thread(:thread, 16, 2),
            Time(:time, 1, idiv(Touter, 2)) => Warp(:warp, 1, W),
            Time(:time, idiv(Touter, 2), 2) => Register(:time, idiv(Touter, 2), 2),
            Time(:time, Touter, idiv(T, Touter)) => Loop(:T1, Touter, idiv(T, Touter)),
        ),
    )
    load!(emitter, :E => layout_E_registers, :E_memory => layout_E_memory; align=16)
    # Swap polr0, dish3
    permute!(emitter, :E, :E, Polr(:polr, 1, P), Dish(:dish, 8, 2))
    # E -> F shuffle
    # 1. swap polr0, cplx0
    # 2. swap timehi, dish0
    # 3. swap cplx0, dish1
    permute!(emitter, :E, :E, Polr(:polr, 1, P), Cplx(:cplx, 1, C))
    permute!(emitter, :E, :E, Time(:time, idiv(Touter, 2), 2), Dish(:dish, 1, 2))
    permute!(emitter, :E, :E, Cplx(:cplx, 1, C), Dish(:dish, 2, 2))
    store!(emitter, :Fsh1_shared => layout_Fsh1_shared, :E)
    return nothing
end

# Reading shared memory (Fsh1) into registers (Freg1) (section 4.7)
function read_Fsh1!(emitter)
    layout_Freg1_registers = Layout(
        Dict(
            IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
            Cplx(:cplx, 1, C) => SIMD(:simd, 16, 2),
            Dish(:dish, 1, W) => Warp(:warp, 1, W),
            Dish(:dish, W, RF1) => Register(:dish, W, RF1),
            Freq(:freq, 1, F) => Block(:block, 1, F),
            Polr(:polr, 1, 2) => SIMD(:simd, 4, 2),
            Time(:time, 1, idiv(Touter, 2)) => Thread(:thread, 1, idiv(Touter, 2)),
            Time(:time, idiv(Touter, 2), 2) => SIMD(:simd, 8, 2),
            Time(:time, Touter, idiv(T, Touter)) => Loop(:T1, Touter, idiv(T, Touter)),
        ),
    )
    # This loads garbage for threadidx ≥ idiv(Touter, 2)
    load!(emitter, :Freg1 => layout_Freg1_registers, :Fsh1_shared => layout_Fsh1_shared)
    return nothing
end

# Writing shared memory (Fsh2) from registers (Freg1) (section 4.8)
function write_Fsh2!(emitter)
    broadcast!(emitter, :sd, :S, Register(:sd, 1, idiv(M * N, W)) => Thread(:thread, 1, idiv(M * N, W)))
    for i in 0:(RF1 - 1)
        store!(emitter, :Fsh2_shared => layout_Fsh2_gridding_shared, :Freg1; offset=Symbol(:sd_sd, "$i"))
    end
    apply!(emitter, :Freg1_zero, [:Freg1], (Freg1,) -> :(zero($Freg1)))
    for i in RF1:(idiv(M * N, W) - 1)
        store!(emitter, :Fsh2_shared => layout_Fsh2_gridding_shared, :Freg1_zero; offset=Symbol(:sd_sd, "$i"))
    end

    return nothing
end

# Reading shared memory (Fsh2) into registers (Freg2) (section 4.9)
function read_Fsh2!(emitter)
    # Section 4.9, eqn. (99)+
    @assert Mw * Tw == W
    ν = trailing_zeros(Npad)
    νm = max(0, 5 - ν)
    νn = max(0, ν - 3)
    @assert νm + νn == 2
    @assert 2 * (1 << νn) == idiv(Npad, 4)
    layout_Freg2_registers = Layout(
        Dict(
            IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
            Cplx(:cplx, 1, C) => SIMD(:simd, 16, 2),
            DishM(:dishM, 1, 1 << νm) => Thread(:thread, 8, 1 << νm),
            DishM(:dishM, Mt, Mw) => Warp(:warp, 1, Mw),
            DishM(:dishM, Mt * Mw, idiv(M, Mt * Mw)) => Register(:dishM, Mt * Mw, Mr),
            DishN(:dishN, 1, 2) => Thread(:thread, 4, 2),
            DishN(:dishN, 2, 1 << νn) => Thread(:thread, 8 * (1 << νm), 1 << νn),
            DishN(:dishN, idiv(Npad, 4), 4) => Thread(:thread, 1, 4),
            Freq(:freq, 1, F) => Block(:block, 1, F),
            Polr(:polr, 1, P) => SIMD(:simd, 4, 2),
            Time(:time, 1, Tw) => Warp(:warp, Mw, Tw),
            Time(:time, Tw, idiv(Touter, 2 * Tw)) => Register(:time, Tw, Tr),
            Time(:time, idiv(Touter, 2), 2) => SIMD(:simd, 8, 2),
            Time(:time, Touter, idiv(T, Touter)) => Loop(:T1, Touter, idiv(T, Touter)),
        ),
    )
    load!(emitter, :E => layout_Freg2_registers, :Fsh2_shared => layout_Fsh2_shared)
    return nothing
end

# First FFT (section 4.10)
function do_first_fft!(emitter)
    @assert Tinner % Tw == 0

    widen2!(
        emitter,
        :E,
        :E,
        SIMD(:simd, 4, 2) => Register(:polr, 1, P),
        SIMD(:simd, 8, 2) => Register(:time, idiv(Touter, 2), 2);
        newtype=FloatValue,
    )
    apply!(emitter, :WE, [:E, :W], (E, W) -> :(complex_mul($W, $E)))

    # G_mq = Γ¹_qn WE_mn
    # C_ij = A_ik  B_kj

    # r = idiv(Npad, 8)
    # n = idiv(Npad, 4) * c + d
    # q = 8 * u + v
    # Γ¹ = exp(π * im * c * v / 4)
    # Γ² = exp(π * im * d * v / Npad)
    layout_Γ¹_registers = Layout(
        Dict(
            FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
            Cplx(:cplx_in, 1, C) => SIMD(:simd, 16, 2), # mma k0
            DishN(:dishN, idiv(Npad, 4), 4) => Thread(:thread, 1, 4), # mma k1, k2
            BeamQ(:beamQ, 1, 8) => Thread(:thread, 4, 8), # mma i0, i1, i2
            Cplx(:cplx, 1, C) => Register(:cplx, 1, 2), # mma i3
        ),
    )
    apply!(emitter, :Γ¹ => layout_Γ¹_registers, :(Float16x2(1, 2)))

    mma_beamQs = [BeamQ(:beamQ, 1, 2), BeamQ(:beamQ, 2, 2), BeamQ(:beamQ, 4, 2), Cplx(:cplx, 1, 2)]
    mma_dishNs = [Cplx(:cplx_in, 1, 2), DishN(:dishN, 1, 2), DishN(:dishN, 2, 2)]
    #TODO mma_dishMs = [DishM(:dishM, 1, 2
    mma_row_col_m16n8k8_f16!(
        emitter, :G, :Γ¹ => (mma_beamQs, mma_dishNs), :WE => (mma_dishNs, mma_dishMs), :G0 => (mma_dishMs, mma_beamQs)
    )

    # Z = Γ¹ X
    # W = Γ² Z
    # Y = Γ³ W

    # :G, :WE

    return nothing
end

function make_frb_kernel()
    emitter = Emitter(kernel_setup)

    # Generate code (section 4.3)

    let
        @assert (M * N) % W == 0    # eqn. (98)
        @assert (M * N) ÷ W ≤ 32    # eqn. (99)
        layout_S_registers = Layout(
            Dict(
                IntValue(:intvalue, 1, 32) => SIMD(:simd, 1, 32),
                Dish(:dish, 1, W) => Warp(:warp, 1, W),
                Dish(:dish, W, idiv(M * N, W)) => Thread(:thread, 1, idiv(M * N, W)),
            ),
        )
        # This loads garbage for threadidx ≥ idiv(M * N, W)
        load!(emitter, :S => layout_S_registers, :S_memory => layout_S_memory)
    end

    let
        # This needs to be compatible with layout_Freg2_registers after widening
        @assert Mw * Tw == W
        ν = trailing_zeros(Npad)
        νm = max(0, 5 - ν)
        νn = max(0, ν - 3)
        @assert νm + νn == 2
        @assert 2 * (1 << νn) == idiv(Npad, 4)
        layout_W_registers = Layout(
            Dict(
                FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
                Cplx(:cplx, 1, C) => SIMD(:simd, 16, 2),
                DishM(:dishM, 1, 1 << νm) => Thread(:thread, 8, 1 << νm),
                DishM(:dishM, Mt, Mw) => Warp(:warp, 1, Mw),
                DishM(:dishM, Mt * Mw, idiv(M, Mt * Mw)) => Register(:dishM, Mt * Mw, Mr),
                DishN(:dishN, 1, 2) => Thread(:thread, 4, 2),
                DishN(:dishN, 2, 1 << νn) => Thread(:thread, 8 * (1 << νm), 1 << νn),
                DishN(:dishN, idiv(Npad, 4), 4) => Thread(:thread, 1, 4),
                Freq(:freq, 1, F) => Block(:block, 1, F),
                Polr(:polr, 1, P) => Register(:polr, 1, P),
            ),
        )
        load!(emitter, :W => layout_W_registers, :W_memory => layout_W_memory)
    end

    loop!(emitter, Time(:time, Touter, idiv(T, Touter)) => Loop(:T1, Touter, idiv(T, Touter))) do emitter
        block!(emitter) do emitter
            copy_global_memory_to_Fsh1!(emitter)
            sync_threads!(emitter)
            nothing
        end

        block!(emitter) do emitter
            read_Fsh1!(emitter)
            sync_threads!(emitter)

            write_Fsh2!(emitter)
            sync_threads!(emitter)
            nothing
        end

        block!(emitter) do emitter
            read_Fsh2!(emitter)
            sync_threads!(emitter)

            loop!(emitter, Time(:time, Tinner, idiv(Touter, Tinner)) => Loop(:T2, Tinner, idiv(Touter, Tinner))) do emitter
                do_first_fft!(emitter)
                #TODO write_G_to_shared_memory!(emitter)
                #TODO sync_threads!(emitter)

                #TODO ... more here ...

                nothing
            end
            nothing
        end

        #TODO ... more here ...

        nothing
    end

    # Emit code

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

println("[Creating frb kernel...]")
const frb_kernel = make_frb_kernel()
println("[Done creating frb kernel]")

@eval function frb(E_memory, S_memory, W_memory)
    shmem = @cuDynamicSharedMem(UInt8, shmem_bytes, 0)
    Fsh1_shared = reinterpret(Int4x8, shmem)
    Fsh2_shared = reinterpret(Int4x8, shmem)

    $frb_kernel
    return nothing
end

function main()
    num_threads = kernel_setup.num_threads
    num_warps = kernel_setup.num_warps
    num_blocks = kernel_setup.num_blocks
    num_blocks_per_sm = kernel_setup.num_blocks_per_sm
    shmem_bytes = kernel_setup.shmem_bytes
    @assert num_warps * num_blocks_per_sm ≤ 32 # (???)
    @assert shmem_bytes ≤ 99 * 1024 # NVIDIA A10/A40 have 99 kB shared memory
    kernel = @cuda launch = false minthreads = num_threads * num_warps blocks_per_sm = num_blocks_per_sm frb(
        CUDA.zeros(Int4x8, 0), CUDA.zeros(Int32, 0), CUDA.zeros(Float16x2, 0)
    )
    attributes(kernel.fun)[CUDA.CU_FUNC_ATTRIBUTE_MAX_DYNAMIC_SHARED_SIZE_BYTES] = shmem_bytes
    return nothing
end

println("Writing \"output/frb.jl\"...")
open("output/frb.jl", "w") do fh
    println(fh, frb_kernel)
end
if CUDA.functional()
    println("Writing \"output/frb.ptx\"...")
    open("output/frb.ptx", "w") do fh
        redirect_stdout(fh) do
            @device_code_ptx main()
        end
    end
    println("Writing \"output/frb.sass\"...")
    open("output/frb.sass", "w") do fh
        redirect_stdout(fh) do
            @device_code_sass main()
        end
    end
end
println("Done.")

# main()
