# CHORD FRB beamformer
# <CHORD_FRB_beamformer.pdf>

# using CUDA
# using CUDASIMDTypes
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
const Mω = gcd(idiv(M, Mt), W)
const Tω = idiv(W, Mω)
const Mr = idiv(M, Mt * Mω)
const Tr = idiv(Touter, 2 * Tω)

# Fsh1 layout
const ΣF1 = D == 64 ? 260 : 257

# Machine setup

const num_simd_bits = 32
const num_threads = 32
const num_warps = W
const num_blocks = F # ???
const num_blocks_per_sm = B

# TODO ... more here ...

# CHORD indices

@enum CHORDTag CplxTag DishTag FreqTag PolrTag TimeTag

const Cplx = Index{Physics,CplxTag}
const Dish = Index{Physics,DishTag}
const Freq = Index{Physics,FreqTag}
const Polr = Index{Physics,PolrTag}
const Time = Index{Physics,TimeTag}

# const int4value = IntValue(:intvalue, 1, 4)
# const float16value = FloatValue(:floatvalue, 1, 16)

# Layouts

const layout_E_memory = Layout(
    Dict(
        IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
        Cplx(:cplx, 1, 2) => SIMD(:simd, 4, 2),
        Dish(:dish, 1, 4) => SIMD(:simd, 8, 4),
        Dish(:dish, 4, idiv(D, 4)) => Memory(:memory, 1, idiv(D, 4)),
        Freq(:freq, 1, F) => Memory(:memory, idiv(D, 4), F),
        Polr(:polr, 1, P) => Memory(:memory, idiv(D, 4) * F, P),
        Time(:time, 1, T) => Memory(:memory, idiv(D, 4) * F * P, T),
    ),
)

# Eqns. (54)+, (61)+
const layout_Fsh1_shared = Layout(
    Dict(
        IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
        Cplx(:cplx, 1, 2) => SIMD(:simd, 16, 2),
        Dish(:dish, 1, 8) => Shared(:shared, 32, 8),
        Dish(:dish, 8, idiv(D, 8)) => Shared(:shared, ΣF1, idiv(D, 8)),
        Time(:time, 1, idiv(Touter, 2)) => Shared(:shared, 1, idiv(Touter, 2)),
        Time(:time, idiv(Touter, 2), 2) => SIMD(:simd, 8, 2),
        Polr(:polr, 1, 2) => SIMD(:simd, 4, 2),
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

const shmem_Fsh1_bytes = ΣF1 * idiv(D, 8)

const shmem_bytes = max(shmem_Fsh1_bytes) # TODO

const kernel_setup = KernelSetup(num_threads, num_warps, num_blocks, num_blocks_per_sm, shmem_bytes)

# Generate Code

# Copying global memory to shared memory (Fsh1) (section 4.6)
function copy_global_memory_to_Fsh1!(emitter)
    block!(emitter) do emitter
        # Eqn. (90)
        layout_E_registers = Layout(
            Dict(
                IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
                Cplx(:cplx, 1, 2) => SIMD(:simd, 4, 2),
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
        permute!(emitter, :E, :E, Polr(:polr, 1, P), Cplx(:cplx, 1, 2))
        permute!(emitter, :E, :E, Time(:time, idiv(Touter, 2), 2), Dish(:dish, 1, 2))
        permute!(emitter, :E, :E, Cplx(:cplx, 1, 2), Dish(:dish, 2, 2))
        store!(emitter, :Fsh1 => layout_Fsh1_shared, :E)
        nothing
    end
    return nothing
end

function make_frb_kernel()
    emitter = Emitter(kernel_setup)

    # Generate code (section 4.3)

    loop!(emitter, Time(:time, Touter, idiv(T, Touter)) => Loop(:T1, Touter, idiv(T, Touter))) do emitter
        copy_global_memory_to_Fsh1!(emitter)
        sync_threads!(emitter)

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
println(frb_kernel)
