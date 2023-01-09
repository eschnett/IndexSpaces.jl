# CHORD FRB beamformer
# <CHORD_FRB_beamformer.pdf>

using CUDA
using CUDASIMDTypes
using IndexSpaces
using Random
using StaticArrays

if CUDA.functional()
    println("[Choosing CUDA device...]")
    CUDA.device!(0)
    println(name(device()))
    @assert name(device()) == "NVIDIA A40"
end

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
const T = 48 #TODO 2064
const D = 512
const M = 24
const N = 24
const P = 2
const F₀ = 256
const F = 1 #TODO 256

const Touter = 48
const Tinner = 4
const Tds = 1 #TODO 40                  # downsampling factor

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

# Gsh layout
const ΣG1 = 2 * Mpad * Tinner + idiv(32, Npad)
const ΣG0 = Npad * ΣG1 + Mpad

# Registers/thread

const RF1 = (D + W - 1) ÷ W
const RF2 = Mr * Tr

# Shared memory bytes

const Fsh1_shmem_bytes = 4 * idiv(D * ΣF1, 8)
const Fsh2_shmem_bytes = 4 * N * ΣF2
const Gsh_shmem_bytes = 4 * ΣG0 * 2

# Machine setup

const num_simd_bits = 32
const num_threads = 32
const num_warps = W
const num_blocks = F
const num_blocks_per_sm = B

# TODO ... more here ...

# CHORD indices

@enum CHORDTag begin
    CplxTag
    DishTag
    # DishMTag
    DishMloTag
    DishMhiTag
    # DishNTag
    DishNloTag
    DishNhiTag
    BeamPTag
    BeamQTag
    FreqTag
    PolrTag
    TimeTag
    DSTimeTag
    ThreadTag
    WarpTag
    BlockTag
end

const Cplx = Index{Physics,CplxTag}
const Dish = Index{Physics,DishTag}
# const DishM = Index{Physics,DishMTag}
const DishMlo = Index{Physics,DishMloTag}
const DishMhi = Index{Physics,DishMhiTag}
# const DishN = Index{Physics,DishNTag}
const DishNlo = Index{Physics,DishNloTag}
const DishNhi = Index{Physics,DishNhiTag}
const BeamP = Index{Physics,BeamPTag}
const BeamQ = Index{Physics,BeamQTag}
const Freq = Index{Physics,FreqTag}
const Polr = Index{Physics,PolrTag}
const Time = Index{Physics,TimeTag}
const DSTime = Index{Physics,DSTimeTag}

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

function calc_S(m::Integer, n::Integer)
    @assert 0 ≤ m < M
    @assert 0 ≤ n < N
    # mlo = m % idiv(M, 4)
    # mhi = m ÷ idiv(M, 4)
    # @assert 0 ≤ mlo < idiv(M, 4)
    # @assert 0 ≤ mhi < 4
    # nlo = n % idiv(N, 4)
    # nhi = n ÷ idiv(N, 4)
    # @assert 0 ≤ nlo < idiv(N, 4)
    # @assert 0 ≤ nhi < 4
    # S = 33 * mlo + 33 * idiv(M, 4) * mhi + ΣF2 * nlo + ΣF2 * idiv(N, 4) * nhi
    S = 33 * m + ΣF2 * n
    @assert 0 ≤ S < N * ΣF2
    return S
end
# let
#     all_S = [calc_S(m, n) for m in 0:(M - 1), n in 0:(N - 1)]
#     @assert allunique(all_S)
# end

const layout_W_memory = Layout(
    Dict(
        FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
        Cplx(:cplx, 1, C) => SIMD(:simd, 16, 2),
        # TODO: Improve layout
        # DishM(:dishM, 1, M) => Memory(:memory, 1, M),
        DishMlo(:dishMlo, 1, idiv(M, 4)) => Memory(:memory, 1, idiv(M, 4)),
        DishMhi(:dishMhi, idiv(M, 4), 4) => Memory(:memory, idiv(M, 4), 4),
        # DishN(:dishN, 1, N) => Memory(:memory, M, N),
        DishNlo(:dishNlo, 1, idiv(N, 4)) => Memory(:memory, M, idiv(N, 4)),
        DishNhi(:dishNhi, 1, 4) => Memory(:memory, M * idiv(N, 4), 4),
        Freq(:freq, 1, F) => Memory(:memory, M * N, F),
        Polr(:polr, 1, P) => Memory(:memory, M * N * F, P),
    ),
)

# I layout

# TODO: Use M, N instead of Mpad, Npad
@assert Mpad == Npad == 32
const layout_I_memory = Layout(
    Dict(
        FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
        BeamP(:beamP, 1, 2) => SIMD(:simd, 16, 2),
        BeamP(:beamP, 2, M) => Memory(:memory, 1, M),
        BeamQ(:beamQ, 1, 2 * N) => Memory(:memory, M, 2 * N),
        Freq(:freq, 1, F) => Memory(:memory, M * 2 * N, F),
        Polr(:polr, 1, P) => Memory(:memory, M * 2 * N * F, P),
        DSTime(:dstime, 1, T ÷ Tds) => Memory(:memory, M * 2 * N * F * P, T ÷ Tds),
    ),
)

# info layout

const layout_info_memory = Layout(
    Dict(
        IntValue(:intvalue, 1, 32) => SIMD(:simd, 1, 32),
        Index{Physics,ThreadTag}(:thread, 1, num_threads) => Memory(:memory, 1, num_threads),
        Index{Physics,WarpTag}(:warp, 1, num_warps) => Memory(:memory, num_threads, num_warps),
        Index{Physics,BlockTag}(:block, 1, num_blocks) => Memory(:memory, num_threads * num_warps, num_blocks),
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
        Time(:time, Touter, idiv(T, Touter)) => Loop(:t_outer, Touter, idiv(T, Touter)),
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
        Time(:time, Touter, idiv(T, Touter)) => Loop(:t_outer, Touter, idiv(T, Touter)),
    ),
)

# Section 4.5, eqns. (67)+
const layout_Fsh2_shared = Layout(
    Dict(
        IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
        Cplx(:cplx, 1, C) => SIMD(:simd, 16, 2),
        # DishM(:dishM, 1, M) => Shared(:shared, 33, M),
        DishMlo(:dishMlo, 1, idiv(M, 4)) => Shared(:shared, 33, idiv(M, 4)),
        DishMhi(:dishMhi, idiv(M, 4), 4) => Shared(:shared, 33 * idiv(M, 4), 4),
        # DishN(:dishN, 1, N) => Shared(:shared, ΣF2, N),
        DishNlo(:dishNlo, 1, idiv(N, 4)) => Shared(:shared, ΣF2, idiv(N, 4)),
        DishNhi(:dishNhi, 1, 4) => Shared(:shared, ΣF2 * idiv(N, 4), 4),
        Freq(:freq, 1, F) => Block(:block, 1, F),
        Polr(:polr, 1, P) => SIMD(:simd, 4, 2),
        Time(:time, 1, idiv(Touter, 2)) => Shared(:shared, 1, idiv(Touter, 2)),
        Time(:time, idiv(Touter, 2), 2) => SIMD(:simd, 8, 2),
        Time(:time, Touter, idiv(T, Touter)) => Loop(:t_outer, Touter, idiv(T, Touter)),
    ),
)

# Section 4.10, eqn. (76)
@assert Npad ≤ 32
const layout_Gsh_shared = Layout(
    Dict(
        FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
        Cplx(:cplx, 1, C) => SIMD(:simd, 16, 2),
        # DishM(:dishM, 1, M) => Shared(:shared, 1, M),
        DishMlo(:dishMlo, 1, idiv(M, 4)) => Shared(:shared, 1, idiv(M, 4)),
        DishMhi(:dishMhi, idiv(M, 4), 4) => Shared(:shared, idiv(M, 4), 4),
        BeamQ(:beamQ, 1, 2) => Shared(:shared, ΣG0, 2),
        BeamQ(:beamQ, 2, 2) => Shared(:shared, ΣG1 * 16, 2),
        BeamQ(:beamQ, 4, 2) => Shared(:shared, ΣG1 * 8, 2),
        BeamQ(:beamQ, 8, 2) => Shared(:shared, ΣG1 * 4, 2),
        BeamQ(:beamQ, 16, 2) => Shared(:shared, ΣG1 * 2, 2),
        BeamQ(:beamQ, 32, 2) => Shared(:shared, ΣG1, 2),
        Freq(:freq, 1, F) => Block(:block, 1, F),
        Polr(:polr, 1, P) => Shared(:shared, Mpad, 2),
        Time(:time, 1, Tinner) => Shared(:shared, Mpad * 2, Tinner),
        Time(:time, Tinner, idiv(Touter, Tinner)) => Loop(:t_inner, Tinner, idiv(Touter, Tinner)),
        Time(:time, Touter, idiv(T, Touter)) => Loop(:t_outer, Touter, idiv(T, Touter)),
    ),
)

# info layout

const layout_info_registers = Layout(
    Dict(
        IntValue(:intvalue, 1, 32) => SIMD(:simd, 1, 32),
        Index{Physics,ThreadTag}(:thread, 1, num_threads) => Thread(:thread, 1, num_threads),
        Index{Physics,WarpTag}(:warp, 1, num_warps) => Warp(:warp, 1, num_warps),
        Index{Physics,BlockTag}(:block, 1, num_blocks) => Block(:block, 1, num_blocks),
    ),
)

# Machine indices

# const simd = SIMD(:simd, 1, num_simd_bits)
# const thread = Thread(:thread, 1, num_threads)
# const warp = Warp(:warp, 1, num_warps)
# const block = Block(:block, 1, num_blocks)
# const shared = Shared(:shared, 1, 99 * 1024)
# const memory = Memory(:memory, 1, 2^32)

const shmem_bytes = max(Fsh1_shmem_bytes, Fsh2_shmem_bytes, Gsh_shmem_bytes)

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
            Time(:time, Touter, idiv(T, Touter)) => Loop(:t_outer, Touter, idiv(T, Touter)),
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
            Time(:time, Touter, idiv(T, Touter)) => Loop(:t_outer, Touter, idiv(T, Touter)),
        ),
    )
    # This loads garbage for threadidx ≥ idiv(Touter, 2)
    load!(emitter, :Freg1 => layout_Freg1_registers, :Fsh1_shared => layout_Fsh1_shared)
    return nothing
end

# Writing shared memory (Fsh2) from registers (Freg1) (section 4.8)
function write_Fsh2!(emitter)
    # TODO: Skip writing dishes > D?
    # TODO: Skip writing garbage (threadidx ≥ idiv(Touter, 2))?
    # TODO: Set unused gridded dishes to 0?
    broadcast!(emitter, :sd, :S, Register(:sd, 1, idiv(M * N, W)) => Thread(:thread, 1, idiv(M * N, W)))
    for i in 0:(idiv(M * N, W) - 1)
        layout = copy(emitter.environment[:Freg1])
        delete!(layout, Dish(:dish, W, RF1))
        emitter.environment[:Freg1′] = layout
        if i < RF1
            push!(emitter.statements, :(Freg1′ = $(Symbol(:Freg1_dish, string(W * i)))))
        else
            push!(emitter.statements, :(Freg1′ = zero(Int4x8)))
        end
        store!(emitter, :Fsh2_shared => layout_Fsh2_gridding_shared, :Freg1′; offset=Symbol(:sd_sd, "$i"))
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
    # DishM
    @assert idiv(M, 4) ≤ Mw
    layout_Freg2_registers = Layout(
        Dict(
            IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
            Cplx(:cplx, 1, C) => SIMD(:simd, 16, 2),
            # DishM(:dishM, 1, 1 << νm) => Thread(:thread, 8, 1 << νm),
            # DishM(:dishM, Mt, Mw) => Warp(:warp, 1, Mw),
            # DishM(:dishM, Mt * Mw, idiv(M, Mt * Mw)) => Register(:dishM, Mt * Mw, Mr),
            DishMlo(:dishMlo, 1, 1 << νm) => Thread(:thread, 8, 1 << νm),
            DishMlo(:dishMlo, Mt, idiv(M, 4)) => Warp(:warp, 1, idiv(M, 4)),
            DishMhi(:dishMhi, Mt * idiv(M, 4), idiv(Mw, idiv(M, 4))) => Warp(:warp, idiv(M, 4), idiv(Mw, idiv(M, 4))),
            DishMhi(:dishMhi, Mt * Mw, idiv(M, Mt * Mw)) => Register(:dishMhi, Mt * Mw, Mr),
            DishNlo(:dishNlo, 1, 2) => Thread(:thread, 4, 2),
            # Threads idiv(N,8) .. idiv(Npad,8) are padding
            DishNlo(:dishNlo, 2, idiv(Npad, 8)) => Thread(:thread, 8 * (1 << νm), idiv(Npad, 8)),
            DishNhi(:dishNhi, 1, 4) => Thread(:thread, 1, 4),
            Freq(:freq, 1, F) => Block(:block, 1, F),
            Polr(:polr, 1, P) => SIMD(:simd, 4, 2),
            Time(:time, 1, Tw) => Warp(:warp, Mw, Tw),
            Time(:time, Tw, idiv(Touter, 2 * Tw)) => Register(:time, Tw, Tr),
            Time(:time, idiv(Touter, 2), 2) => SIMD(:simd, 8, 2),
            Time(:time, Touter, idiv(T, Touter)) => Loop(:t_outer, Touter, idiv(T, Touter)),
        ),
    )
    # This loads garbage for nlo ≥ idiv(N, 4)
    apply!(emitter, :Freg2 => layout_Freg2_registers, :(zero(Int4x8)))
    # TODO: write this as condition for nlo
    if!(emitter, :(0 ≤ IndexSpaces.cuda_threadidx() ÷ $(8 * (1 << νm)) < $(idiv(N, 8)))) do emitter
        load!(emitter, :Freg2 => layout_Freg2_registers, :Fsh2_shared => layout_Fsh2_shared)
        nothing
    end
    return nothing
end

# First FFT (section 4.10)
function do_first_fft!(emitter)
    @assert Tinner % Tw == 0

    # Here we widen all Freg2 values, but we will use only some of them in the `select!` call.
    widen2!(
        emitter,
        :Freg2,
        :Freg2,
        SIMD(:simd, 4, 2) => Register(:polr, 1, P),
        SIMD(:simd, 8, 2) => Register(:time, idiv(Touter, 2), 2);
        newtype=FloatValue,
    )

    select!(emitter, :E, :Freg2, Register(:time, Tinner, idiv(Touter, Tinner)) => Loop(:t_inner, Tinner, idiv(Touter, Tinner)))

    apply!(emitter, :WE, [:E, :W], (E, W) -> :(swapped_complex_mul($W, $E)))

    # Chapter 4.10 notation:
    #     G_mq = FT WE_mn
    # This is an FT that transforms n to q, with m as spectator index.

    # Chapter 3.3 notation:
    #
    #     n = (N/4) c + d      0 ≤ n < N     (21)
    #     q = 8 u + v          0 ≤ q < 2 N   (22)
    #
    #     Y_uvs = FT X_cds
    #
    #     Z_dvs = Γ¹_cv X_cds
    #     W_dvs = Γ²_dv Z_dvs
    #     Y_uvs = Γ³_du W_dvs

    # Register assignments:
    #     r = trailing_zeros(Npad)

    # Constants:
    #     Γ¹ = exp(π * im * c * v / 4)    (28)
    #     Γ² = exp(π * im * d * v / N)    (29)
    #     Γ³ = exp(8π * im * d * u / N)   (30)

    # Appendix C.1 notation:
    #
    #     C_ik = A_ij B_jk
    #     i:16
    #     j:8
    #     k:8
    #
    #     Z_dvs = Γ¹_cv X_cds
    #     C_ik  = A_ij  B_jk
    #
    #     i => v
    #     j => c
    #     k => ds

    apply!(emitter, :X, [:WE], (WE,) -> :($WE))

    # First step
    let
        # (40)
        ν = trailing_zeros(Npad)
        νm = max(0, 5 - ν)
        νn = max(0, ν - 3)
        @assert νm + νn == 2
        @assert 2 * (1 << νn) == idiv(Npad, 4)
        layout_Z_registers = Layout(
            Dict(
                FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
                Cplx(:cplx, 1, C) => Register(:cplx, 1, 2),
                # DishM(:dishM, 1, 1 << νm) => Thread(:thread, 8, 1 << νm),
                # DishM(:dishM, Mt, Mw) => Warp(:warp, 1, Mw),
                # DishM(:dishM, Mt * Mw, idiv(M, Mt * Mw)) => Register(:dishM, Mt * Mw, Mr),
                DishMlo(:dishMlo, 1, 1 << νm) => Thread(:thread, 8, 1 << νm),
                DishMlo(:dishMlo, Mt, idiv(M, 4)) => Warp(:warp, 1, idiv(M, 4)),
                DishMhi(:dishMhi, Mt * idiv(M, 4), idiv(Mw, idiv(M, 4))) => Warp(:warp, idiv(M, 4), idiv(Mw, idiv(M, 4))),
                DishMhi(:dishMhi, Mt * Mw, idiv(M, Mt * Mw)) => Register(:dishMhi, Mt * Mw, Mr),
                DishNlo(:dishNlo, 1, 2) => SIMD(:simd, 16, 2),
                DishNlo(:dishNlo, 2, 4) => Thread(:thread, 1, 4),
                BeamQ(:beamQ, 1, 8) => Thread(:thread, 4, 8),
                Freq(:freq, 1, F) => Block(:block, 1, F),
                Polr(:polr, 1, P) => Register(:polr, 1, P),
                Time(:time, 1, Tw) => Warp(:warp, Mw, Tw),
                # Time(:time, Tw, idiv(Touter, 2 * Tw)) => Register(:time, Tw, Tr),
                # Time(:time, idiv(Touter, 2), 2) => Register(:time, idiv(Touter, 2), 2),
                Time(:time, Tw, idiv(Tinner, Tw)) => Register(:time, Tw, idiv(Tinner, Tw)),
                Time(:time, Tinner, idiv(Touter, Tinner)) => Loop(:t_inner, Tinner, idiv(Touter, Tinner)),
                Time(:time, Touter, idiv(T, Touter)) => Loop(:t_outer, Touter, idiv(T, Touter)),
            ),
        )
        apply!(emitter, :Z => layout_Z_registers, :(zero(Float16x2)))

        # (38)
        mma_is = [BeamQ(:beamQ, 1, 2), BeamQ(:beamQ, 2, 2), BeamQ(:beamQ, 4, 2), Cplx(:cplx, 1, 2)]
        mma_js = [Cplx(:cplx_in, 1, 2), DishNhi(:dishNhi, 1, 2), DishNhi(:dishNhi, 2, 2)]
        @assert trailing_zeros(Npad) ≥ 5
        mma_ks = [DishNlo(:dishNlo, 1, 2), DishNlo(:dishNlo, 2, 2), DishNlo(:dishNlo, 4, 2)]
        let
            #TODO: Implement this cleanly, e.g. via a `rename!` function
            layout = copy(emitter.environment[:X])
            k = Cplx(:cplx, 1, C)
            k′ = Cplx(:cplx_in, 1, C)
            v = layout[k]
            delete!(layout, k)
            layout[k′] = v
            emitter.environment[:X] = layout
        end
        mma_row_col_m16n8k8_f16!(emitter, :Z, :Γ¹ => (mma_is, mma_js), :X => (mma_js, mma_ks), :Z => (mma_is, mma_ks))
    end

    # Second step
    # Section 3 `W` is called `V` here
    split!(emitter, [:Γ²im, :Γ²re], :Γ², Register(:cplx, 1, 2))
    split!(emitter, [:Zim, :Zre], :Z, Register(:cplx, 1, 2))
    apply!(emitter, :Vre, [:Zre, :Zim, :Γ²re, :Γ²im], (Zre, Zim, Γ²re, Γ²im) -> :(muladd($Γ²re, $Zre, -$Γ²im * $Zim)))
    apply!(emitter, :Vim, [:Zre, :Zim, :Γ²re, :Γ²im], (Zre, Zim, Γ²re, Γ²im) -> :(muladd($Γ²re, $Zim, +$Γ²im * $Zre)))
    merge!(emitter, :V, [:Vim, :Vre], Cplx(:cplx, 1, 2) => Register(:cplx, 1, 2))

    # Third step
    let
        # (44)
        ν = trailing_zeros(Npad)
        νm = max(0, 5 - ν)
        νn = max(0, ν - 3)
        @assert νm + νn == 2
        @assert 2 * (1 << νn) == idiv(Npad, 4)
        layout_Y_registers = Layout(
            Dict(
                FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
                Cplx(:cplx, 1, C) => Register(:cplx, 1, 2),
                # DishM(:dishM, 1, 1 << νm) => Thread(:thread, 8, 1 << νm),
                # DishM(:dishM, Mt, Mw) => Warp(:warp, 1, Mw),
                # DishM(:dishM, Mt * Mw, idiv(M, Mt * Mw)) => Register(:dishM, Mt * Mw, Mr),
                DishMlo(:dishMlo, 1, 1 << νm) => Thread(:thread, 8, 1 << νm),
                DishMlo(:dishMlo, Mt, idiv(M, 4)) => Warp(:warp, 1, idiv(M, 4)),
                DishMhi(:dishMhi, Mt * idiv(M, 4), idiv(Mw, idiv(M, 4))) => Warp(:warp, idiv(M, 4), idiv(Mw, idiv(M, 4))),
                DishMhi(:dishMhi, Mt * Mw, idiv(M, Mt * Mw)) => Register(:dishMhi, Mt * Mw, Mr),
                BeamQ(:beamQ, 1, 2) => SIMD(:simd, 16, 2),
                BeamQ(:beamQ, 2, 4) => Thread(:thread, 1, 4),
                BeamQ(:beamQ, 8, 8) => Thread(:thread, 4, 8),
                Freq(:freq, 1, F) => Block(:block, 1, F),
                Polr(:polr, 1, P) => Register(:polr, 1, P),
                Time(:time, 1, Tw) => Warp(:warp, Mw, Tw),
                # Time(:time, Tw, idiv(Touter, 2 * Tw)) => Register(:time, Tw, Tr),
                # Time(:time, idiv(Touter, 2), 2) => Register(:time, idiv(Touter, 2), 2),
                Time(:time, Tw, idiv(Tinner, Tw)) => Register(:time, Tw, idiv(Tinner, Tw)),
                Time(:time, Tinner, idiv(Touter, Tinner)) => Loop(:t_inner, Tinner, idiv(Touter, Tinner)),
                Time(:time, Touter, idiv(T, Touter)) => Loop(:t_outer, Touter, idiv(T, Touter)),
            ),
        )
        apply!(emitter, :Y => layout_Y_registers, :(zero(Float16x2)))

        # (43)
        @assert trailing_zeros(Npad) ≥ 5
        mma_is = [BeamQ(:beamQ, 8, 2), BeamQ(:beamQ, 16, 2), BeamQ(:beamQ, 32, 2), Cplx(:cplx, 1, 2)]
        mma_js = [DishNlo(:dishNlo, 1, 2), DishNlo(:dishNlo, 2, 2), DishNlo(:dishNlo, 4, 2), Cplx(:cplx_in, 1, 2)]
        mma_ks = [BeamQ(:beamQ, 1, 2), BeamQ(:beamQ, 2, 2), BeamQ(:beamQ, 4, 2)]
        #TODO: Implement this cleaner, e.g. via a `rename!` function
        split!(emitter, [:Vim, :Vre], :V, Cplx(:cplx, 1, 2))
        merge!(emitter, :V, [:Vim, :Vre], Cplx(:cplx_in, 1, 2) => Register(:cplx_in, 1, 2))
        mma_row_col_m16n8k16_f16!(emitter, :Y, :Γ³ => (mma_is, mma_js), :V => (mma_js, mma_ks), :Y => (mma_is, mma_ks))
    end

    apply!(emitter, :G, [:Y], (Y,) -> :($Y))

    # Write G to shared memory
    permute!(emitter, :G, :G, Register(:cplx, 1, 2), SIMD(:simd, 16, 2))
    store!(emitter, :Gsh_shared => layout_Gsh_shared, :G)

    return nothing
end

# Second FFT (section 4.11)
function do_second_fft!(emitter)
    # Read one G-tile from shared memory
    layout_G_registers = Layout(
        Dict(
            FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
            Cplx(:cplx, 1, C) => SIMD(:simd, 16, 2),
            DishMlo(:dishMlo, 1, 8) => Thread(:thread, 4, 8),
            DishMhi(:dishMhi, 1, 4) => Thread(:thread, 1, 4),
            BeamQ(:beamQ, 1, 2) => Register(:beamQ, 1, 2),
            # Is this an efficient warp layout (with reversed warp bits)?
            # This simplifies shared memory addressing; see `layout_Gsh_shared`.
            # BeamQ(:beamQ, 2, 2) => Warp(:warp, 16, 2),
            # BeamQ(:beamQ, 4, 2) => Warp(:warp, 8, 2),
            # BeamQ(:beamQ, 8, 2) => Warp(:warp, 4, 2),
            # BeamQ(:beamQ, 16, 2) => Warp(:warp, 2, 2),
            # BeamQ(:beamQ, 32, 2) => Warp(:warp, 1, 2),
            BeamQ(:beamQ, 2, N) => Warp(:warp, 1, N),
            Freq(:freq, 1, F) => Block(:block, 1, F),
            # Polr(:polr, 1, P) => Loop(:polr, 1, P),
            Polr(:polr, 1, P) => Register(:polr, 1, P),
            Time(:time, 1, Tinner) => Loop(:t, 1, Tinner),
            Time(:time, Tinner, idiv(Touter, Tinner)) => Loop(:t_inner, Tinner, idiv(Touter, Tinner)),
            Time(:time, Touter, idiv(T, Touter)) => Loop(:t_outer, Touter, idiv(T, Touter)),
        ),
    )
    # This loads garbage for idiv(M, 4) ≤ mlo ≤ idiv(Mpad, 4)
    apply!(emitter, :G => layout_G_registers, :(zero(Float16x2)))
    # TODO: write this as condition for mlo
    @assert trailing_zeros(Mpad) == 5
    if!(emitter, :(0 ≤ IndexSpaces.cuda_threadidx() ÷ 4 < $(idiv(M, 4)))) do emitter
        load!(emitter, :G => layout_G_registers, :Gsh_shared => layout_Gsh_shared)
        nothing
    end

    # Chapter 4.11 notation:
    #     Ẽ_pq = FT G_mq
    # This is an FT that transforms m to p, with q as spectator index.

    # (39)
    layout_Γ¹_registers = Layout(
        Dict(
            FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
            Cplx(:cplx_in, 1, C) => SIMD(:simd, 16, 2), # mma j0
            Cplx(:cplx, 1, C) => Register(:cplx, 1, 2), # mma i3
            DishMhi(:dishMhi, 1, 4) => Thread(:thread, 1, 4), # mma j1, j2
            BeamP(:beamP, 1, 8) => Thread(:thread, 4, 8), # mma i0, i1, i2
        ),
    )
    # apply!(emitter, :Γ¹ => layout_Γ¹_registers, :(Float16x2(1, 2))) # TODO
    emitter.environment[:Γ¹] = layout_Γ¹_registers

    # (41)
    @assert trailing_zeros(Mpad) == 5
    layout_Γ²_registers = Layout(
        Dict(
            FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
            Cplx(:cplx, 1, C) => Register(:cplx, 1, 2),
            DishMlo(:dishMlo, 1, 2) => SIMD(:simd, 16, 2),
            DishMlo(:dishMlo, 2, 4) => Thread(:thread, 1, 4),
            BeamP(:beamP, 1, 8) => Thread(:thread, 4, 8),
        ),
    )
    # apply!(emitter, :Γ² => layout_Γ²_registers, :(Float16x2(3, 4))) # TODO
    emitter.environment[:Γ²] = layout_Γ²_registers

    # (45) - (47)
    @assert trailing_zeros(Mpad) == 5
    layout_Γ³_registers = Layout(
        Dict(
            FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
            Cplx(:cplx_in, 1, C) => Register(:cplx_in, 1, 2),
            Cplx(:cplx, 1, C) => Register(:cplx, 1, 2),
            DishMlo(:dishMlo, 1, 2) => SIMD(:simd, 16, 2),
            DishMlo(:dishMlo, 2, 4) => Thread(:thread, 1, 4),
            BeamP(:beamP, 8, 8) => Thread(:thread, 4, 8),
        ),
    )
    # apply!(emitter, :Γ³ => layout_Γ³_registers, :(Float16x2(3, 4))) # TODO
    emitter.environment[:Γ³] = layout_Γ³_registers

    apply!(emitter, :X, [:G], (G,) -> :($G))

    # First step
    let
        # (40)
        layout_Z_registers = Layout(
            Dict(
                FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
                Cplx(:cplx, 1, C) => Register(:cplx, 1, 2),
                DishMlo(:dishMlo, 1, 2) => SIMD(:simd, 16, 2),
                DishMlo(:dishMlo, 2, 4) => Thread(:thread, 1, 4),
                BeamP(:beamP, 1, 8) => Thread(:thread, 4, 8),
                BeamQ(:beamQ, 1, 2) => Register(:beamQ, 1, 2),
                BeamQ(:beamQ, 2, N) => Warp(:warp, 1, N),
                Freq(:freq, 1, F) => Block(:block, 1, F),
                # Polr(:polr, 1, P) => Loop(:polr, 1, P),
                Polr(:polr, 1, P) => Register(:polr, 1, P),
                Time(:time, 1, Tinner) => Loop(:t, 1, Tinner),
                Time(:time, Tinner, idiv(Touter, Tinner)) => Loop(:t_inner, Tinner, idiv(Touter, Tinner)),
                Time(:time, Touter, idiv(T, Touter)) => Loop(:t_outer, Touter, idiv(T, Touter)),
            ),
        )
        apply!(emitter, :Z => layout_Z_registers, :(zero(Float16x2)))

        # (38)
        mma_is = [BeamP(:beamP, 1, 2), BeamP(:beamP, 2, 2), BeamP(:beamP, 4, 2), Cplx(:cplx, 1, 2)]
        mma_js = [Cplx(:cplx_in, 1, 2), DishMhi(:dishMhi, 1, 2), DishMhi(:dishMhi, 2, 2)]
        @assert trailing_zeros(Mpad) ≥ 5
        mma_ks = [DishMlo(:dishMlo, 1, 2), DishMlo(:dishMlo, 2, 2), DishMlo(:dishMlo, 4, 2)]
        let
            #TODO: Implement this cleanly, e.g. via a `rename!` function
            layout = copy(emitter.environment[:X])
            k = Cplx(:cplx, 1, C)
            k′ = Cplx(:cplx_in, 1, C)
            v = layout[k]
            delete!(layout, k)
            layout[k′] = v
            emitter.environment[:X] = layout
        end
        mma_row_col_m16n8k8_f16!(emitter, :Z, :Γ¹ => (mma_is, mma_js), :X => (mma_js, mma_ks), :Z => (mma_is, mma_ks))
    end

    # Second step
    # Section 3 `W` is called `V` here
    split!(emitter, [:Γ²im, :Γ²re], :Γ², Register(:cplx, 1, 2))
    split!(emitter, [:Zim, :Zre], :Z, Register(:cplx, 1, 2))
    apply!(emitter, :Vre, [:Zre, :Zim, :Γ²re, :Γ²im], (Zre, Zim, Γ²re, Γ²im) -> :(muladd($Γ²re, $Zre, -$Γ²im * $Zim)))
    apply!(emitter, :Vim, [:Zre, :Zim, :Γ²re, :Γ²im], (Zre, Zim, Γ²re, Γ²im) -> :(muladd($Γ²re, $Zim, +$Γ²im * $Zre)))
    merge!(emitter, :V, [:Vim, :Vre], Cplx(:cplx, 1, 2) => Register(:cplx, 1, 2))

    # Third step
    let
        # (44)
        ν = trailing_zeros(Npad)
        νm = max(0, 5 - ν)
        νn = max(0, ν - 3)
        @assert νm + νn == 2
        @assert 2 * (1 << νn) == idiv(Npad, 4)
        layout_Y_registers = Layout(
            Dict(
                FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
                Cplx(:cplx, 1, C) => Register(:cplx, 1, 2),
                BeamP(:beamP, 1, 2) => SIMD(:simd, 16, 2),
                BeamP(:beamP, 2, 4) => Thread(:thread, 1, 4),
                BeamP(:beamP, 8, 8) => Thread(:thread, 4, 8),
                BeamQ(:beamQ, 1, 2) => Register(:beamQ, 1, 2),
                BeamQ(:beamQ, 2, N) => Warp(:warp, 1, N),
                Freq(:freq, 1, F) => Block(:block, 1, F),
                # Polr(:polr, 1, P) => Loop(:polr, 1, P),
                Polr(:polr, 1, P) => Register(:polr, 1, P),
                Time(:time, 1, Tinner) => Loop(:t, 1, Tinner),
                Time(:time, Tinner, idiv(Touter, Tinner)) => Loop(:t_inner, Tinner, idiv(Touter, Tinner)),
                Time(:time, Touter, idiv(T, Touter)) => Loop(:t_outer, Touter, idiv(T, Touter)),
            ),
        )
        apply!(emitter, :Y => layout_Y_registers, :(zero(Float16x2)))

        # (43)
        @assert trailing_zeros(Npad) ≥ 5
        mma_is = [BeamP(:beamP, 8, 2), BeamP(:beamP, 16, 2), BeamP(:beamP, 32, 2), Cplx(:cplx, 1, 2)]
        mma_js = [DishMlo(:dishMlo, 1, 2), DishMlo(:dishMlo, 2, 2), DishMlo(:dishMlo, 4, 2), Cplx(:cplx_in, 1, 2)]
        mma_ks = [BeamP(:beamP, 1, 2), BeamP(:beamP, 2, 2), BeamP(:beamP, 4, 2)]
        #TODO: Implement this cleaner, e.g. via a `rename!` function
        split!(emitter, [:Vim, :Vre], :V, Cplx(:cplx, 1, 2))
        merge!(emitter, :V, [:Vim, :Vre], Cplx(:cplx_in, 1, 2) => Register(:cplx_in, 1, 2))
        mma_row_col_m16n8k16_f16!(emitter, :Y, :Γ³ => (mma_is, mma_js), :V => (mma_js, mma_ks), :Y => (mma_is, mma_ks))
    end

    apply!(emitter, :Ẽ, [:Y], (Y,) -> :($Y))

    split!(emitter, [:Ẽim, :Ẽre], :Ẽ, Cplx(:cplx, 1, C))

    apply!(
        emitter,
        :I,
        [:I, :Ẽre, :Ẽim],
        (I, Ẽre, Ẽim) -> :(muladd($Ẽre, $Ẽre, muladd($Ẽim, $Ẽim, $I)));
        ignore=[Time(:time, 1, T)],
    )

    return nothing
end

function make_frb_kernel()
    emitter = Emitter(kernel_setup)

    # Generate code (section 4.3)

    apply!(emitter, :info => layout_info_registers, 1i32)
    store!(emitter, :info_memory => layout_info_memory, :info)

    # Section 3.3
    let
        # (39)
        layout_Γ¹_registers = Layout(
            Dict(
                FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
                Cplx(:cplx_in, 1, C) => SIMD(:simd, 16, 2),
                # Cplx(:cplx, 1, C) => Register(:cplx, 1, 2),
                DishNhi(:dishNhi, 1, 4) => Thread(:thread, 1, 4),
                BeamQ(:beamQ, 1, 8) => Thread(:thread, 4, 8),
            ),
        )
        push!(
            emitter.statements,
            quote
                (Γ¹_re_re, Γ¹_re_im, Γ¹_im_re, Γ¹_im_im) = let
                    # Γ¹ = exp(π * im * c * v / 4)   (28)
                    c = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, $num_threads) % 4i32
                    v = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, $num_threads) ÷ 4i32
                    Γ¹ = cispi(c * v / 4.0f0)
                    (+Γ¹.re, -Γ¹.im, +Γ¹.im, +Γ¹.re)
                end
            end,
        )
        apply!(emitter, :Γ¹_re => layout_Γ¹_registers, :(Float16x2(Γ¹_re_im, Γ¹_re_re)))
        apply!(emitter, :Γ¹_im => layout_Γ¹_registers, :(Float16x2(Γ¹_im_im, Γ¹_im_re)))
        merge!(emitter, :Γ¹, [:Γ¹_im, :Γ¹_re], Cplx(:cplx, 1, C) => Register(:cplx, 1, C))

        # (41)
        @assert trailing_zeros(Npad) == 5
        layout_Γ²_registers = Layout(
            Dict(
                FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
                # Cplx(:cplx, 1, C) => Register(:cplx, 1, 2),
                DishNlo(:dishNlo, 1, 2) => SIMD(:simd, 16, 2),
                DishNlo(:dishNlo, 2, 4) => Thread(:thread, 1, 4),
                BeamQ(:beamQ, 1, 8) => Thread(:thread, 4, 8),
            ),
        )
        apply!(
            emitter,
            :Γ² => layout_Γ²_registers,
            quote
                (Γ²_d0_re, Γ²_d0_im, Γ²_d1_re, Γ²_d1_im) = let
                    # Γ² = exp(π * im * d * v / N)   (29)
                    d0 = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, $num_threads) % 4i32 * 2i32 + 0i32
                    d1 = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, $num_threads) % 4i32 * 2i32 + 1i32
                    v = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, $num_threads) ÷ 4i32
                    Γ²_d0 = cispi(d0 * v / $(Float32(N)))
                    Γ²_d1 = cispi(d1 * v / $(Float32(N)))
                    (Γ²_d0.re, Γ²_d0.im, Γ²_d1.re, Γ²_d1.im)
                end
            end,
        )
        apply!(emitter, :Γ²_re => layout_Γ²_registers, :(Float16x2(Γ²_d0_re, Γ²_d1_re)))
        apply!(emitter, :Γ²_im => layout_Γ²_registers, :(Float16x2(Γ²_d0_im, Γ²_d1_im)))
        merge!(emitter, :Γ², [:Γ²_im, :Γ²_re], Cplx(:cplx, 1, C) => Register(:cplx, 1, C))

        # (45) - (47)
        @assert trailing_zeros(Npad) == 5
        layout_Γ³_registers = Layout(
            Dict(
                FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
                # Cplx(:cplx_in, 1, C) => Register(:cplx_in, 1, 2),
                # Cplx(:cplx, 1, C) => Register(:cplx, 1, 2),
                DishNlo(:dishNlo, 1, 2) => SIMD(:simd, 16, 2),
                DishNlo(:dishNlo, 2, 4) => Thread(:thread, 1, 4),
                BeamQ(:beamQ, 8, 8) => Thread(:thread, 4, 8),
            ),
        )
        push!(
            emitter.statements,
            quote
                (Γ³_d0_re_re, Γ³_d0_re_im, Γ³_d0_im_re, Γ³_d0_im_im, Γ³_d1_re_re, Γ³_d1_re_im, Γ³_d1_im_re, Γ³_d1_im_im) = let
                    # Γ³ = exp(8π * im * d * u / N)   (30)
                    d0 = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, $num_threads) % 4i32 * 2i32 + 0i32
                    d1 = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, $num_threads) % 4i32 * 2i32 + 1i32
                    u = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, $num_threads) ÷ 4i32
                    Γ³_d0 = cispi(8i32 * d0 * u / $(Float32(N)))
                    Γ³_d1 = cispi(8i32 * d1 * u / $(Float32(N)))
                    (+Γ³_d0.re, -Γ³_d0.im, +Γ³_d0.im, +Γ³_d0.re, +Γ³_d1.re, -Γ³_d1.im, +Γ³_d1.im, +Γ³_d1.re)
                end
            end,
        )
        apply!(emitter, :Γ³_re_re => layout_Γ³_registers, :(Float16x2(Γ³_d0_re_re, Γ³_d1_re_re)))
        apply!(emitter, :Γ³_re_im => layout_Γ³_registers, :(Float16x2(Γ³_d0_re_im, Γ³_d1_re_im)))
        apply!(emitter, :Γ³_im_re => layout_Γ³_registers, :(Float16x2(Γ³_d0_im_re, Γ³_d1_im_re)))
        apply!(emitter, :Γ³_im_im => layout_Γ³_registers, :(Float16x2(Γ³_d0_im_im, Γ³_d1_im_im)))
        merge!(emitter, :Γ³_re, [:Γ³_re_im, :Γ³_re_re], Cplx(:cplx_in, 1, C) => Register(:cplx_in, 1, 2))
        merge!(emitter, :Γ³_im, [:Γ³_im_im, :Γ³_im_re], Cplx(:cplx_in, 1, C) => Register(:cplx_in, 1, 2))
        merge!(emitter, :Γ³, [:Γ³_im, :Γ³_re], Cplx(:cplx, 1, C) => Register(:cplx, 1, 2))
    end

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
                # DishM(:dishM, 1, 1 << νm) => Thread(:thread, 8, 1 << νm),
                # DishM(:dishM, Mt, Mw) => Warp(:warp, 1, Mw),
                # DishM(:dishM, Mt * Mw, idiv(M, Mt * Mw)) => Register(:dishM, Mt * Mw, Mr),
                DishMlo(:dishMlo, 1, 1 << νm) => Thread(:thread, 8, 1 << νm),
                DishMlo(:dishMlo, Mt, idiv(M, 4)) => Warp(:warp, 1, idiv(M, 4)),
                DishMhi(:dishMhi, Mt * idiv(M, 4), idiv(Mw, idiv(M, 4))) => Warp(:warp, idiv(M, 4), idiv(Mw, idiv(M, 4))),
                DishMhi(:dishMhi, Mt * Mw, idiv(M, Mt * Mw)) => Register(:dishMhi, Mt * Mw, Mr),
                DishNlo(:dishNlo, 1, 2) => Thread(:thread, 4, 2),
                DishNlo(:dishNlo, 2, idiv(Npad, 8)) => Thread(:thread, 8 * (1 << νm), idiv(Npad, 8)),
                DishNhi(:dishNhi, 1, 4) => Thread(:thread, 1, 4),
                Freq(:freq, 1, F) => Block(:block, 1, F),
                Polr(:polr, 1, P) => Register(:polr, 1, P),
            ),
        )
        # This loads garbage for idiv(N, 4) ≤ nlo ≤ idiv(Npad, 4)
        apply!(emitter, :W => layout_W_registers, :(zero(Float16x2)))
        # TODO: write this as condition for nlo
        if!(emitter, :(0 ≤ IndexSpaces.cuda_threadidx() ÷ $(8 * (1 << νm)) < $(idiv(N, 8)))) do emitter
            load!(emitter, :W => layout_W_registers, :W_memory => layout_W_memory)
            nothing
        end
    end

    let
        # Section 4.11, eqn. (128)
        layout_I_registers = Layout(
            Dict(
                FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
                BeamP(:beamP, 1, 2) => SIMD(:simd, 16, 2),
                BeamP(:beamP, 2, 32) => Thread(:thread, 1, 32),
                BeamQ(:beamQ, 1, 2) => Register(:beamQ, 1, 2),
                BeamQ(:beamQ, 2, N) => Warp(:warp, 1, N),
                Freq(:freq, 1, F) => Block(:block, 1, F),
                Polr(:polr, 1, P) => Register(:polr, 1, P),
                DSTime(:dstime, 1, T ÷ Tds) => Loop(:dstime, 1, T ÷ Tds),
            ),
        )
        apply!(emitter, :I => layout_I_registers, :(zero(Float16x2)))
        push!(emitter.statements, :(dstime = $(0i32)))
        push!(emitter.statements, :(t_running = $(0i32)))
    end

    loop!(emitter, Time(:time, Touter, idiv(T, Touter)) => Loop(:t_outer, Touter, idiv(T, Touter))) do emitter
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

            # This loop should probably be unrolled for execution speed, but that increases compile time significantly
            loop!(emitter, Time(:time, Tinner, idiv(Touter, Tinner)) => Loop(:t_inner, Tinner, idiv(Touter, Tinner))) do emitter

                # 4.10 First FFT
                # (111)
                # unrolled_loop!(emitter, Time(:time, Tw, idiv(Tinner, Tw)) => Loop(:tau_tile, Tw, idiv(Tinner, Tw))) do emitter
                #     unrolled_loop!(
                #         emitter, DishM(:dishM, Mt * Mw, idiv(M, Mt * Mw)) => Loop(:dishM, Mt * Mw, idiv(M, Mt * Mw))
                #     ) do emitter
                #         unrolled_loop!(emitter, Polr(:polr, 1, P) => Loop(:polr, 1, P)) do emitter
                #             do_fft1!(emitter)
                # 
                #             nothing
                #         end
                #         nothing
                #     end
                #     nothing
                # end
                do_first_fft!(emitter)
                sync_threads!(emitter)

                loop!(emitter, Time(:time, 1, Tinner) => Loop(:t, 1, Tinner)) do emitter

                    # 4.11 Second FFT
                    # loop!(emitter, Polr(:polr, 1, P) => Loop(:polr, 1, P)) do emitter
                    #     do_second_fft!(emitter)
                    #     nothing
                    # end
                    do_second_fft!(emitter)

                    push!(emitter.statements, :(t_running += $(1i32)))
                    if!(emitter, :(t_running == $(Tds))) do emitter
                        if!(
                            emitter, :(
                                let
                                    p = 2i32 * IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, $num_threads)
                                    q = 2i32 * IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, $num_warps)
                                    0i32 ≤ p < $(Int32(2 * M)) && 0i32 ≤ q < $(Int32(2 * N))
                                end
                            )
                        ) do emitter
                            store!(emitter, :I_memory => layout_I_memory, :I)
                            nothing
                        end
                        apply!(emitter, :I, [:I], (I,) -> :(zero(Float16x2)))
                        push!(emitter.statements, :(t_running = $(0i32)))
                        push!(emitter.statements, :(dstime += $(1i32)))

                        nothing
                    end

                    nothing
                end
                sync_threads!(emitter)

                nothing
            end

            nothing
        end

        nothing
    end

    apply!(emitter, :info => layout_info_registers, 0i32)
    store!(emitter, :info_memory => layout_info_memory, :info)

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

@eval function frb(S_memory, W_memory, E_memory, I_memory, info_memory, Fsh1_memory, Fsh2_memory, Gsh_memory)
    # shmem = @cuDynamicSharedMem(UInt8, shmem_bytes, 0)
    # Fsh1_shared = reinterpret(Int4x8, shmem)
    # Fsh2_shared = reinterpret(Int4x8, shmem)
    # Gsh_shared = reinterpret(Float16x2, shmem)
    Fsh1_shared = let
        block = IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, $num_blocks)
        block_offset = $(idiv(Fsh1_shmem_bytes, 4))
        @view Fsh1_memory[(block_offset * block + 1):(block_offset * block + block_offset)]
    end
    Fsh2_shared = let
        block = IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, $num_blocks)
        block_offset = $(idiv(Fsh2_shmem_bytes, 4))
        @view Fsh2_memory[(block_offset * block + 1):(block_offset * block + block_offset)]
    end
    Gsh_shared = let
        block = IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, $num_blocks)
        block_offset = $(idiv(Gsh_shmem_bytes, 4))
        @view Gsh_memory[(block_offset * block + 1):(block_offset * block + block_offset)]
    end
    $frb_kernel
    return nothing
end

function main(; compile_only::Bool=false, output_kernel::Bool=false, run_selftest::Bool=false, nruns::Int=0)
    println("CHORD FRB beamformer")

    if output_kernel
        open("output/frb.jl", "w") do fh
            println(fh, frb_kernel)
        end
    end

    println("Compiling kernel...")
    num_threads = kernel_setup.num_threads
    num_warps = kernel_setup.num_warps
    num_blocks = kernel_setup.num_blocks
    num_blocks_per_sm = kernel_setup.num_blocks_per_sm
    shmem_bytes = kernel_setup.shmem_bytes
    @assert num_warps * num_blocks_per_sm ≤ 32 # (???)
    @assert shmem_bytes ≤ 99 * 1024 # NVIDIA A10/A40 have 99 kB shared memory
    kernel = @cuda launch = false minthreads = num_threads * num_warps blocks_per_sm = num_blocks_per_sm frb(
        CUDA.zeros(Int32, 0),
        CUDA.zeros(Float16x2, 0),
        CUDA.zeros(Int4x8, 0),
        CUDA.zeros(Float16x2, 0),
        CUDA.zeros(Int32, 0),
        CUDA.zeros(Int4x8, 0),
        CUDA.zeros(Int4x8, 0),
        CUDA.zeros(Float16x2, 0),
    )
    attributes(kernel.fun)[CUDA.CU_FUNC_ATTRIBUTE_MAX_DYNAMIC_SHARED_SIZE_BYTES] = shmem_bytes

    if compile_only
        return nothing
    end

    if output_kernel
        ptx = read("output/frb.ptx", String)
        ptx = replace(ptx, r".extern .func ([^;]*);"s => s".func \1.noreturn\n{\n\ttrap;\n}")
        open("output/frb.ptx", "w") do fh
            write(fh, ptx)
        end
        kernel_name = match(r"\s\.globl\s+(\S+)"m, ptx).captures[1]
        open("output/frb.yaml", "w") do fh
            print(
                fh,
                """
        --- !<tag:chord-observatory.ca/x-engine/kernel-description-1.0.0>
        kernel-description:
          name: "frb"
          description: "FRB beamformer"
          design-parameters:
            beam-layout: [$(2*M), $(2*N)]
            dish-layout: [$M, $N]
            number-of-complex-components: $C
            number-of-dishes: $D
            number-of-frequencies: $F
            number-of-polarizations: $P
            number-of-timesamples: $T
            sampling-time: $sampling_time
          compile-parameters:
            minthreads: $(num_threads * num_warps)
            blocks_per_sm: $num_blocks_per_sm
          call-parameters:
            threads: [$num_threads, $num_warps]
            blocks: [$num_blocks]
            shmem_bytes: $shmem_bytes
          kernel-name: "$kernel_name"
          kernel-arguments:
            - name: "S"
              intent: in
              type: Int32
              indices: [D]
              shape: [$D]
              strides: [1]
            - name: "W"
              intent: in
              type: Float16
              indices: [C, M, N, F, P]
              shape: [$C, $M, $N, $F, $P]
              strides: [1, $C, $(C*M), $(C*M*N), $(C*M*N*F), $(C*M*N*F*P)]
            - name: "E"
              intent: in
              type: Int4
              indices: [C, D, F, P, T]
              shape: [$C, $D, $F, $P, $T]
              strides: [1, $C, $(C*D), $(C*D*F), $(C*D*F*P)]
            - name: "I"
              intent: out
              type: Float16
              indices: [beamP, beamQ, F, P, Tds]
              shape: [$(2*M), $(2*N), $F, $P, $(T÷Tds)]
              strides: [1, $(2*M), $(2*M*2*N), $(2*M*2*N*F), $(2*M*2*N*F*P)]
            - name: "info"
              intent: out
              type: Int32
              indices: [thread, warp, block]
              shapes: [$num_threads, $num_warps, $num_blocks]
              strides: [1, $num_threads, $(num_threads*num_warps)]
        ...
        """,
            )
        end
    end

    println("Allocating input data...")

    # TODO: determine types and sizes automatically
    S_memory = Array{Int32}(undef, D)
    W_memory = Array{Float16x2}(undef, M * N * F * P)
    E_memory = Array{Int4x8}(undef, idiv(D, 4) * F * P * T)
    I_wanted = Array{Float16x2}(undef, M * 2 * N * F * P * (T ÷ Tds))
    info_wanted = Array{Int32}(undef, num_threads * num_warps * num_blocks)
    # Fsh1_memory = Array{Int4x8}(undef, idiv(Fsh1_shmem_bytes, 4) * num_blocks)
    # Fsh2_memory = Array{Int4x8}(undef, idiv(Fsh2_shmem_bytes, 4) * num_blocks)
    # Gsh_memory = Array{Float16x2}(undef, idiv(Gsh_shmem_bytes, 4) * num_blocks)

    println("Setting up input data...")
    map!(i -> zero(Int32), S_memory, S_memory)
    map!(i -> zero(Float16x2), W_memory, W_memory)
    map!(i -> zero(Int4x8), E_memory, E_memory)
    map!(i -> zero(Float16x2), I_wanted, I_wanted)
    map!(i -> zero(Int32), info_wanted, info_wanted)

    println("Setting up input data...")
    input = :random
    if input ≡ :zero
        # do nothing
    elseif input ≡ :random
        Random.seed!(0)

        # Choose dish grid
        grid = [(m, n) for m in 0:(M - 1), n in 0:(N - 1)]
        # dish_grid = grid[randperm(length(grid))[1:D]]
        dish_grid = grid[1:D]
        S_memory .= [calc_S(m, n) for (m, n) in dish_grid]

        # Generate a uniform complex number in the unit disk. See
        # <https://stats.stackexchange.com/questions/481543/generating-random-points-uniformly-on-a-disk>.
        function uniform_in_disk()
            r = sqrt(rand(Float32))
            α = rand(Float32)
            c = r * cispi(2 * α)
            return c
        end
        c2t(c::Complex) = (imag(c), real(c))
        t2c(t::NTuple{2}) = Complex(t[2], t[1])
        # W_memory .= [Float16x2(c2t(uniform_in_disk())...) for i in eachindex(W_memory)]
        W_memory .= [Float16x2(0, 1) for i in eachindex(W_memory)]

        dish = 0
        freq = 0
        polr = 0
        time = 0
        value = 1 + 0im
        value8 = zero(SVector{8,Int8})
        value8 = setindex(value8, imag(value), dish % 4 + 0 + 1)
        value8 = setindex(value8, real(value), dish % 4 + 1 + 1)
        E_memory[dish ÷ 4 + idiv(D, 4) * freq + idiv(D, 4) * F * polr + idiv(D, 4) * F * P * time + 1] = Int4x8(value8...)
    end

    println("Copying data from CPU to GPU...")
    S_cuda = CuArray(S_memory)
    W_cuda = CuArray(W_memory)
    E_cuda = CuArray(E_memory)
    I_cuda = CUDA.fill(Float16x2(NaN, NaN), length(I_wanted))
    info_cuda = CUDA.fill(-1i32, length(info_wanted))
    Fsh1_cuda = CUDA.fill(Int4x8(-8, -8, -8, -8, -8, -8, -8, -8), idiv(Fsh1_shmem_bytes, 4) * num_blocks)
    Fsh2_cuda = CUDA.fill(Int4x8(-8, -8, -8, -8, -8, -8, -8, -8), idiv(Fsh2_shmem_bytes, 4) * num_blocks)
    Gsh_cuda = CUDA.fill(Float16x2(NaN, NaN), idiv(Gsh_shmem_bytes, 4) * num_blocks)

    println("Running kernel...")
    kernel(
        S_cuda,
        W_cuda,
        E_cuda,
        I_cuda,
        info_cuda,
        Fsh1_cuda,
        Fsh2_cuda,
        Gsh_cuda;
        threads=(num_threads, num_warps),
        blocks=num_blocks,
        shmem=shmem_bytes,
    )
    synchronize()

    println("Copying data back from GPU to CPU...")
    I_memory = Array(I_cuda)
    info_memory = Array(info_cuda)
    @assert all(info_memory .== 0)
    Fsh1_memory = Array(Fsh1_cuda)
    Fsh2_memory = Array(Fsh2_cuda)
    Gsh_memory = Array(Gsh_cuda)

    println("Checking results...")

    did_test_Fsh1_memory = falses(length(Fsh1_memory))
    for time in 0:(Touter - 1), polr in 0:(P - 1), freq in 0:(F - 1), dish in 0:(D - 1)
        idx = 32 * (dish % 8) + ΣF1 * (dish ÷ 8) + time % idiv(Touter, 2)
        if polr == 0 && time ÷ idiv(Touter, 2) == 0
            @assert !did_test_Fsh1_memory[idx + 1]
            did_test_Fsh1_memory[idx + 1] = true
        end
        value8 = convert(NTuple{8,Int8}, Fsh1_memory[idx + 1])
        value_im = value8[polr + 2 * (time ÷ idiv(Touter, 2)) + 4 * 0 + 1]
        value_re = value8[polr + 2 * (time ÷ idiv(Touter, 2)) + 4 * 1 + 1]
        value = Complex(value_re, value_im)
        if value ≠ 0
            S = S_memory[dish + 1]
            m = S ÷ 33 % M
            n = S ÷ ΣF2 % N
            println("    dish=$dish freq=$freq polr=$polr time=$time Fsh1=$value m=$m n=$n S=$S")
        end
    end
    # There is padding
    # @assert all(did_test_Fsh1_memory)

    did_test_Fsh2_memory = falses(length(Fsh2_memory))
    for time in 0:(Touter - 1), polr in 0:(P - 1), freq in 0:(F - 1), dishN in 0:(N - 1), dishM in 0:(M - 1)
        dishMlo = dishM % idiv(M, 4)
        dishMhi = dishM ÷ idiv(M, 4)
        dishNlo = dishN % idiv(N, 4)
        dishNhi = dishN ÷ idiv(N, 4)
        idx = 33 * dishMlo + 33 * idiv(M, 4) * dishMhi + ΣF2 * dishNlo + ΣF2 * idiv(N, 4) * dishNhi + time % idiv(Touter, 2)
        if polr == 0 && time ÷ idiv(Touter, 2) == 0
            @assert !did_test_Fsh2_memory[idx + 1]
            did_test_Fsh2_memory[idx + 1] = true
        end
        value8 = convert(NTuple{8,Int8}, Fsh2_memory[idx + 1])
        value_im = value8[polr + 2 * (time ÷ idiv(Touter, 2)) + 4 * 0 + 1]
        value_re = value8[polr + 2 * (time ÷ idiv(Touter, 2)) + 4 * 1 + 1]
        value = Complex(value_re, value_im)
        if value ≠ 0
            println("    dishM=$dishM dishN=$dishN freq=$freq polr=$polr time=$time Fsh2=$value")
        end
    end
    # There is padding
    # @assert all(did_test_Fsh2_memory)

    did_test_I_memory = falses(length(I_memory))
    for dstime in 0:(T ÷ Tds - 1), polr in 0:(P - 1), freq in 0:(F - 1), beamq in 0:(2 * N - 1), beamp in 0:(2 * M - 1)
        idx = beamp ÷ 2 + M * beamq + M * 2 * N * freq + M * 2 * N * F * polr + M * 2 * N * F * P * dstime
        if beamp % 2 == 0
            @assert !did_test_I_memory[idx + 1]
            did_test_I_memory[idx + 1] = true
        end
        value2 = convert(NTuple{2,Float32}, I_memory[idx + 1])
        value = value2[beamp % 2 + 1]
        if value ≠ 0
            println("    beamp=$beamp beamq=$beamq freq=$freq polr=$polr dstime=$dstime I=$value")
        end
    end
    @assert all(did_test_I_memory)

    println("Done.")
    return nothing
end

if CUDA.functional()
    # Output kernel
    main(; output_kernel=true)
    open("output/frb.ptx", "w") do fh
        redirect_stdout(fh) do
            @device_code_ptx main(; compile_only=true)
        end
    end
    open("output/frb.sass", "w") do fh
        redirect_stdout(fh) do
            @device_code_sass main(; compile_only=true)
        end
    end

    # # Run test
    # main(; run_selftest=true)

    # # Run benchmark
    # main(; nruns=100)

    # # Regular run, also for profiling
    # main()
end
