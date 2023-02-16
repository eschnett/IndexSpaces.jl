# CHORD upchannelization kernel
# <CHORD_GPU_upchannelization.pdf>

using CUDASIMDTypes
using IndexSpaces

# CHORD Setup

# Compile-time constants

const C = 2
const T = 32768
const D = 512
const P = 2
const F = 16
const U = 16
const M = 4
const K = 4

const S = M * U
const F̄ = F * U
const T̄ = T ÷ U

# Derived constants

const W = 16
const B = 2

const Touter = 256
const Packed = true

# Machine setup

const num_simd_bits = 32
const num_threads = 32
const num_warps = W
const num_blocks = D * P * F ÷ 128
const num_blocks_per_sm = B

# CHORD indices

@enum CHORDTag begin
    CplxTag
    TimeTag
    DishTag
    PolrTag
    FreqTag
    MTapsTag
    UFactorTag
    # SLengthTag
    TimeBarTag
    FreqBarTag
    ThreadTag
    WarpTag
    BlockTag
end

const Cplx = Index{Physics,CplxTag}
const Time = Index{Physics,TimeTag}
const Dish = Index{Physics,DishTag}
const Polr = Index{Physics,PolrTag}
const Freq = Index{Physics,FreqTag}
const MTaps = Index{Physics,MTapsTag}
const UFactor = Index{Physics,UFactorTag}
# const SLength = Index{Physics,SLengthTag}
const TimeBar = Index{Physics,TimeBarTag}
const FreqBar = Index{Physics,FreqBarTag}

# Layouts

# Global memory layouts

const layout_W_memory = Layout([
    FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
    # TODO: Choose a convenient layout and shuffle when loading
    #TODO Time(:time, 1, 2) => SIMD(:simd, 16, 2),
    #TODO Time(:time, 2, (U ÷ 2) * M) => Memory(:memory, 1, (U ÷ 2) * M),
    Time(:time, 1 << 3, 2) => SIMD(:simd, 16, 2),
    Time(:time, 1, 8) => Memory(:memory, 1, 8),
    # Time(:time, 16, U * M ÷ 16) => Memory(:memory, 8, U * M ÷ 16),
    Time(:time, 16, U ÷ 16) => Memory(:memory, 8, U ÷ 16),
    MTaps(:mtaps, 1, M) => Memory(:memory, 8 * (U ÷ 16), M),
])

const layout_G_memory = Layout([
    FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
    Time(:time, 1, 2) => SIMD(:simd, 16, 2),
    Time(:time, 2, U ÷ 2) => Memory(:memory, 1, U ÷ 2),
])

const layout_E_memory = Layout([
    IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
    Cplx(:cplx, 1, C) => SIMD(:simd, 4, 2),
    Dish(:dish, 1, 4) => SIMD(:simd, 8, 4),
    Dish(:dish, 4, D ÷ 4) => Memory(:memory, 1, D ÷ 4),
    Freq(:freq, 1, F) => Memory(:memory, (D ÷ 4), F),
    Polr(:polr, 1, P) => Memory(:memory, (D ÷ 4) * F, P),
    Time(:time, 1, T) => Memory(:memory, (D ÷ 4) * F * P, T),
])

const layout_Ē_memory = Layout([
    IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
    Cplx(:cplx, 1, C) => SIMD(:simd, 4, 2),
    Dish(:dish, 1, 4) => SIMD(:simd, 8, 4),
    Dish(:dish, 4, D ÷ 4) => Memory(:memory, 1, D ÷ 4),
    FreqBar(:freqbar, 1, F * U) => Memory(:memory, (D ÷ 4), F̄),
    Polr(:polr, 1, P) => Memory(:memory, (D ÷ 4) * F̄, P),
    TimeBar(:timebar, 1, T ÷ U) => Memory(:memory, (D ÷ 4) * F̄ * P, T̄),
])

# Shared memory layouts

# eqn. (101)
const Σ = U ≤ 64 ? 32 * U + 33 : 65 * (U ÷ 2) + 1
@assert Σ ≥ 65 * (U ÷ 2) && Σ % 32 == 1

# eqn. (99)
@assert U == 16
@assert Packed
const layout_F_shared = Layout([
    IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
    Cplx(:cplx, 1, C) => SIMD(:simd, 4, 2),
    Dish(:dish, 1 << 0, 2) => SIMD(:simd, 8, 2),
    Time(:time, 8, 2) => SIMD(:simd, 16, 2),
    #Unpacked FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
    #Unpacked Cplx(:cplx, 1, C) => Register(:cplx, 1, C),
    #Unpacked Dish(:dish, 1 << 0, 2) => Register(:dish, 1 << 0, 2),
    #Unpacked UFactor(:ufactor, 1, 2) => SIMD(:simd, 16, 2),
    # eqn. (94)
    Dish(:dish, 1 << 2, 2) => Shared(:shared, 1, 2),
    Dish(:dish, 1 << 3, 2) => Shared(:shared, 2, 2),
    Dish(:dish, 1 << 4, 2) => Shared(:shared, 4, 2),
    Dish(:dish, 1 << 5, 2) => Shared(:shared, 8, 2),
    Dish(:dish, 1 << 6, 2) => Shared(:shared, 16, 2),
    Dish(:dish, 1 << 1, 2) => Shared(:shared, 32, 2),
    # eqn. (100)
    Time(:time, 4, 2) => Shared(:shared, 65 * (1 << 0), 2),
    Time(:time, 2, 2) => Shared(:shared, 65 * (1 << 1), 2),
    Time(:time, 1, 2) => Shared(:shared, 65 * (1 << 2), 2),
    # eqn. (100)
    # TimeBar(:timebar, 1, Touter ÷ U) => Shared(:shared, Σ, Touter ÷ U),
    Time(:time, U, Touter ÷ U) => Shared(:shared, Σ, Touter ÷ U),
    # sect. 5.2
    Dish(:dish, 1 << 7, D ÷ 128) => Block(:block, 1, D ÷ 128),
    Polr(:polr, 1, P) => Block(:block, D ÷ 128, P),
    Freq(:freq, 1, F) => Block(:block, (D ÷ 128) * P, F),
])

@assert K == 4
const layout_F̄_shared = Layout([
    IntValue(:intvalue, 1, K) => SIMD(:simd, 1, 4),
    Cplx(:cplx, 1, C) => SIMD(:simd, 4, 2),
    Dish(:dish, 1 << 0, 2) => SIMD(:simd, 8, 2),
    UFactor(:ufactor, 1, 2) => SIMD(:simd, 16, 2),
    # eqn. (94)
    Dish(:dish, 1 << 2, 2) => Shared(:shared, 1, 2),
    Dish(:dish, 1 << 3, 2) => Shared(:shared, 2, 2),
    Dish(:dish, 1 << 4, 2) => Shared(:shared, 4, 2),
    Dish(:dish, 1 << 5, 2) => Shared(:shared, 8, 2),
    Dish(:dish, 1 << 6, 2) => Shared(:shared, 16, 2),
    Dish(:dish, 1 << 1, 2) => Shared(:shared, 32, 2),
    # eqn. (100)
    Time(:time, 4, 2) => Shared(:shared, 65 * (1 << 0), 2),
    Time(:time, 2, 2) => Shared(:shared, 65 * (1 << 1), 2),
    Time(:time, 1, 2) => Shared(:shared, 65 * (1 << 2), 2),
    # eqn. (100)
    TimeBar(:timebar, 1, Touter ÷ U) => Shared(:shared, Σ, Touter ÷ U),
    # Cplx(:cplx, 1, C) => Shared(:shared, Σ * (Touter ÷ U), 2),
    # sect. 5.2
    Dish(:dish, 1 << 7, D ÷ 128) => Block(:block, 1, D ÷ 128),
    Polr(:polr, 1, P) => Block(:block, D ÷ 128, P),
    Freq(:freq, 1, F) => Block(:block, (D ÷ 128) * P, F),
])

# Register layouts

@assert U ≤ 32
# eqn. (126)
@assert U == 16
const layout_W_registers = Layout([
    FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
    Time(:time, 1 << 3, 2) => SIMD(:simd, 16, 2),
    Time(:time, 1 << 2, 2) => Thread(:thread, 1 << 1, 2),
    Time(:time, 1 << 1, 2) => Thread(:thread, 1 << 0, 2),
    Time(:time, 1 << 0, 2) => Thread(:thread, 1 << 2, 2),
    # Thread(:thread, 1 << 4, 2),
    # Thread(:thread, 1 << 3, 2),
    MTaps(:mtaps, 1, M) => Register(:mtaps, 1, M),
])

@assert U ≤ 32
# eqn. (127)
@assert U == 16
const layout_X_registers = Layout(
    Dict(
        FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
        Time(:time, 1 << 3, 2) => SIMD(:simd, 16, 2),
        Time(:time, 1 << 2, 2) => Thread(:thread, 1 << 1, 2),
        Time(:time, 1 << 1, 2) => Thread(:thread, 1 << 0, 2),
        Time(:time, 1 << 0, 2) => Thread(:thread, 1 << 2, 2),
        # Thread(:thread, 1 << 4, 2),
        # Thread(:thread, 1 << 3, 2),
        Cplx(:cplx, 1, C) => Register(:cplx, 1, C),
    ),
)

@assert U ≤ 32
# eqn. (128)
@assert U == 16
const layout_G_registers = Layout([
    FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
    Time(:time, 1 << 0, 2) => SIMD(:simd, 16, 2),
    Time(:time, 1 << 1, 2) => Thread(:thread, 1 << 1, 2),
    Time(:time, 1 << 2, 2) => Thread(:thread, 1 << 0, 2),
    Time(:time, 1 << 3, 2) => Thread(:thread, 1 << 2, 2),
    # Thread(:thread, 1 << 4, 2),
    # Thread(:thread, 1 << 3, 2),
])

# eqn. (133)
@assert U == 16
const layout_E_registers = Layout([
    IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
    Cplx(:cplx, 1, C) => SIMD(:simd, 4, 2),
    Dish(:dish, 1, 4) => SIMD(:simd, 8, 4),
    Dish(:dish, 4, 4) => Register(:dish, 4, 4),
    Dish(:dish, 16, 8) => Thread(:thread, 1, 8),
    Time(:time, 8, 2) => Thread(:thread, 8, 2),
    Time(:time, 4, 2) => Thread(:thread, 16, 2),
    Time(:time, 1, 4) => Register(:time, 1, 4),
    # one input tile: 128 dishes, 4 times
    # assign input tiles to warps
    Time(:time, 16, Touter ÷ 16) => Warp(:warp, 1, 16),
    # sect. 5.2
    Dish(:dish, 1 << 7, D ÷ 128) => Block(:block, 1, D ÷ 128),
    Polr(:polr, 1, P) => Block(:block, D ÷ 128, P),
    Freq(:freq, 1, F) => Block(:block, (D ÷ 128) * P, F),
])

# eqn. (104)
@assert U ≤ 32
const (Ut, Ur) = (U ÷ 2, 1)
const (Dt, Dr) = (64 ÷ U, U ÷ W)
@assert Ut * Dr == U ÷ 2
@assert W * Dt * Dr == 64
@assert Ut * Ur == U ÷ 2
@assert Dt * Dr == D ÷ 128

@assert U == 16
@assert W == 16
@assert Packed
const layout_F_registers = Layout([
    # eqn. (110)
    IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
    Cplx(:cplx, 1, C) => SIMD(:simd, 4, 2),
    Dish(:dish, 1 << 0, 2) => SIMD(:simd, 8, 2),
    Time(:time, 1 << 3, 2) => SIMD(:simd, 16, 2),
    # eqn. (111)
    #Unpacked FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
    #Unpacked Cplx(:cplx, 1, C) => Register(:cplx, 1, C),
    #Unpacked Dish(:dish, 1 << 0, 2) => Register(:dish, 1, 2),
    #Unpacked Time(:time, 1 << 3, 2) => SIMD(:simd, 16, 2),
    # eqn. (105)
    Dish(:dish, 1 << 2, 2) => Warp(:warp, 1 << 0, 2),
    Dish(:dish, 1 << 3, 2) => Warp(:warp, 1 << 1, 2),
    Dish(:dish, 1 << 4, 2) => Warp(:warp, 1 << 2, 2),
    Dish(:dish, 1 << 1, 2) => Warp(:warp, 1 << 3, 2),
    Time(:time, 1 << 2, 2) => Thread(:thread, 1 << 1, 2),
    Time(:time, 1 << 1, 2) => Thread(:thread, 1 << 0, 2),
    Time(:time, 1 << 0, 2) => Thread(:thread, 1 << 2, 2),
    Dish(:dish, 1 << 5, 2) => Thread(:thread, 1 << 4, 2),
    Dish(:dish, 1 << 6, 2) => Thread(:thread, 1 << 3, 2),
    # sect. 5.2
    Dish(:dish, 1 << 7, D ÷ 128) => Block(:block, 1, D ÷ 128),
    Polr(:polr, 1, P) => Block(:block, D ÷ 128, P),
    Freq(:freq, 1, F) => Block(:block, (D ÷ 128) * P, F),
])

@assert U == 16
@assert W == 16
@assert K == 4
@assert Packed
const layout_F̄_registers = Layout([
    # eqn. (110)
    IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
    Cplx(:cplx, 1, C) => SIMD(:simd, 4, 2),
    Dish(:dish, 1 << 0, 2) => SIMD(:simd, 8, 2),
    UFactor(:ufactor, 1 << 0, 2) => SIMD(:simd, 16, 2),
    # eqn. (111)
    #Unpacked FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
    #Unpacked Cplx(:cplx, 1, C) => Register(:cplx, 1, C),
    #Unpacked Dish(:dish, 1 << 0, 2) => Register(:dish, 1, 2),
    #Unpacked UFactor(:ufactor, 1 << 0, 2) => SIMD(:simd, 16, 2),
    # eqn. (105)
    Dish(:dish, 1 << 2, 2) => Warp(:warp, 1 << 0, 2),
    Dish(:dish, 1 << 3, 2) => Warp(:warp, 1 << 1, 2),
    Dish(:dish, 1 << 4, 2) => Warp(:warp, 1 << 2, 2),
    Dish(:dish, 1 << 1, 2) => Warp(:warp, 1 << 3, 2),
    UFactor(:ufactor, 1 << 1, 2) => Thread(:thread, 1 << 1, 2),
    UFactor(:ufactor, 1 << 2, 2) => Thread(:thread, 1 << 0, 2),
    UFactor(:ufactor, 1 << 3, 2) => Thread(:thread, 1 << 2, 2),
    Dish(:dish, 1 << 5, 2) => Thread(:thread, 1 << 4, 2),
    Dish(:dish, 1 << 6, 2) => Thread(:thread, 1 << 3, 2),
    # sect. 5.2
    Dish(:dish, 1 << 7, D ÷ 128) => Block(:block, 1, D ÷ 128),
    Polr(:polr, 1, P) => Block(:block, D ÷ 128, P),
    Freq(:freq, 1, F) => Block(:block, (D ÷ 128) * P, F),
])

const layout_F_ringbuf_registers = Layout([
    # eqn. (110)
    IntValue(:intvalue, 1, 4) => SIMD(:simd, 1, 4),
    Cplx(:cplx, 1, C) => SIMD(:simd, 4, 2),
    Dish(:dish, 1 << 0, 2) => SIMD(:simd, 8, 2),
    Time(:time, 1 << 3, 2) => SIMD(:simd, 16, 2),
    # eqn. (111)
    #Unpacked FloatValue(:floatvalue, 1, 16) => SIMD(:simd, 1, 16),
    #Unpacked Cplx(:cplx, 1, C) => Register(:cplx, 1, C),
    #Unpacked Dish(:dish, 1 << 0, 2) => Register(:dish, 1, 2),
    #Unpacked Time(:time, 1 << 3, 2) => SIMD(:simd, 16, 2),
    MTaps(:mtaps, 1, M - 1) => Register(:mtaps, 1, M - 1),
    Time(:time, U ÷ Ur, Ur) => Register(:time, U ÷ Ur, Ur),
    Dish(:dish, D ÷ Dr, Dr) => Register(:dish, D ÷ Dr, Dr),
    # eqn. (105)
    Dish(:dish, 1 << 2, 2) => Warp(:warp, 1 << 0, 2),
    Dish(:dish, 1 << 3, 2) => Warp(:warp, 1 << 1, 2),
    Dish(:dish, 1 << 4, 2) => Warp(:warp, 1 << 2, 2),
    Dish(:dish, 1 << 1, 2) => Warp(:warp, 1 << 3, 2),
    Time(:time, 1 << 2, 2) => Thread(:thread, 1 << 1, 2),
    Time(:time, 1 << 1, 2) => Thread(:thread, 1 << 0, 2),
    Time(:time, 1 << 0, 2) => Thread(:thread, 1 << 2, 2),
    Dish(:dish, 1 << 5, 2) => Thread(:thread, 1 << 4, 2),
    Dish(:dish, 1 << 6, 2) => Thread(:thread, 1 << 3, 2),
    # sect. 5.2
    Dish(:dish, 1 << 7, D ÷ 128) => Block(:block, 1, D ÷ 128),
    Polr(:polr, 1, P) => Block(:block, D ÷ 128, P),
    Freq(:freq, 1, F) => Block(:block, (D ÷ 128) * P, F),
])

# Kernel setup

const shmem_size = 0            # TODO
const shmem_bytes = 4 * shmem_size

const kernel_setup = KernelSetup(num_threads, num_warps, num_blocks, num_blocks_per_sm, shmem_bytes)

# Generate Code

# sect. 5.5
function upchan!(emitter)
    # Initialize ring buffer
    apply!(emitter, :F_ringbuf => layout_F_ringbuf_registers, :(zero(Int4x8)))

    # Load gains
    load!(emitter, :Gains => layout_G_registers, :G_memory => layout_G_memory)

    # Load weights
    load!(emitter, :Wpfb => layout_W_registers, :W_memory => layout_W_memory)

    # Calculate extra phases
    # eqn. (88), (125), (139)
    layout_Xreim_registers = delete!(copy(layout_X_registers), Cplx(:cplx, 1, C))
    apply!(
        emitter,
        :Xre => layout_Xreim_registers,
        :(
            let
                thread = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, $num_threads)
                thread0 = (thread ÷ 1i32) % 2i32
                thread1 = (thread ÷ 2i32) % 2i32
                thread2 = (thread ÷ 4i32) % 2i32
                time0 = 1i32 * thread2 + 2i32 * thread0 + 4i32 * thread1
                time1 = time0 + 8i32
                X0 = cispi(Float32(time0 * (U - 1i32)) / U)
                X1 = cispi(Float32(time1 * (U - 1i32)) / U)
                (real(X0), real(X1))
            end
        ),
    )
    apply!(
        emitter,
        :Xim => layout_Xreim_registers,
        :(
            let
                thread = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, $num_threads)
                thread0 = (thread ÷ 1i32) % 2i32
                thread1 = (thread ÷ 2i32) % 2i32
                thread2 = (thread ÷ 4i32) % 2i32
                time0 = 1i32 * thread2 + 2i32 * thread0 + 4i32 * thread1
                time1 = time0 + 8i32
                X0 = cispi(Float32(time0 * (U - 1i32)) / U)
                X1 = cispi(Float32(time1 * (U - 1i32)) / U)
                (imag(X0), imag(X1))
            end
        ),
    )
    merge!(emitter, :X, [:Xim, :Xre], Cplx(:cplx, 1, C) => Register(:cplx, 1, C))

    # Outermost loop over outer blocks
    loop!(emitter, Time(:time, Touter, T ÷ Touter) => Loop(:t_outer, Touter, T ÷ Touter)) do emitter

        # Step1: Copy outer block from global memory to shared memory

        # Load E
        load!(emitter, :E => layout_E_registers, :E_memory => layout_E_memory; align=16)
        # eqn. (136)
        # Swap Dish(8,2) and Time(8,2), i.e. Register(:dish,8,2) and Thread(8,2)
        permute!(emitter, :E1, :E, Dish(:dish, 8, 2), Time(:time, 8, 2))
        split!(emitter, [:E1lo, :E1hi], :E1, Register(:dish, 8, 2))
        merge!(emitter, :E1, [:E1lo, :E1hi], Time(:time, 8, 2) => Register(:time, 8, 2))
        # Swap Dish(2,2) and Time(8,2), i.e. Register(:dish,8,2) and SIMD(16,2)
        permute!(emitter, :E2, :E1, Dish(:dish, 2, 2), Time(:time, 8, 2))
        split!(emitter, [:E2lo, :E2hi], :E2, Register(:time, 8, 2))
        merge!(emitter, :E2, [:E2lo, :E2hi], Dish(:dish, 2, 2) => Register(:dish, 2, 2))
        apply!(emitter, :F, [:E2], (E2,) -> :E2)
        # Unpack
        #Unpack widen2!(
        #Unpack     emitter,
        #Unpack     :F,
        #Unpack     :E2,
        #Unpack     SIMD(:simd, 4, 2) => Register(:cplx, 1, C),
        #Unpack     SIMD(:simd, 8, 2) => Register(:dish, 1, 2);
        #Unpack     newtype=FloatValue,
        #Unpack )
        # Store F
        store!(emitter, :F_shared => layout_F_shared, :F)

        sync_threads!(emitter)

        # Loop over inner blocks
        loop!(emitter, Time(:time, U, Touter ÷ U) => Loop(:t_inner, U, Touter ÷ U)) do emitter

            # Loop over packed miniblocks
            unrolled_loop!(emitter, Dish(:dish, D ÷ Dr, Dr) => UnrolledLoop(:dish, D ÷ Dr, Dr)) do emitter

                # Step 2: Read F-array miniblock from shared memory

                load!(emitter, :F_in => layout_F_registers, :F_shared => layout_F_shared)
                apply!(emitter, :F̄_out => layout_F̄_registers, :(zero(Int8x4)))

                # Loop over unpacked miniblocks:
                # This is an implicit loop over Dish(:dish, 1, 2)

                # Step 3: Compute E by unpacking F_in
                widen2!(
                    emitter,
                    :E,
                    :F_in,
                    SIMD(:simd, 4, 2) => Register(:cplx, 1, C),
                    SIMD(:simd, 8, 2) => Register(:dish, 1, 2);
                    newtype=FloatValue,
                )

                # Step 4: Compute E2 from E
                # m = M-1
                split!(emitter, [Symbol(:W_m, m) for m in 0:(M - 1)], :Wpfb, Register(:mtaps, 1, M))
                apply!(emitter, :E2, [:E, Symbol(:W_m, M - 1)], (E, W) -> :($W * $E))
                # m ∈ 0:M-2
                # NOTE: For some reason, this `unrolled_loop!`
                # construct calls `widen2!` on all mtaps, not just the
                # ones selected in the current unrolled loop
                # iteration. This makes `unrolled_loop!` unusable, and
                # we have to roll our own.
                # unrolled_loop!(emitter, MTaps(:mtaps, 1, M - 1) => UnrolledLoop(:mtaps, 1, M - 1)) do emitter
                #     widen2!(
                #         emitter,
                #         :E_ringbuf,
                #         :F_ringbuf,
                #         SIMD(:simd, 4, 2) => Register(:cplx, 1, C),
                #         SIMD(:simd, 8, 2) => Register(:dish, 1, 2);
                #         newtype=FloatValue,
                #     )
                #     delete!(emitter.environment[:E_ringbuf], MTaps(:mtaps, 1, M - 1))
                #     apply!(emitter, :E2, [:E2, :E_ringbuf, :W1], (E2, E, W1) -> :(muladd($W1, $E, $E2)))
                #     return nothing
                # end
                split!(emitter, [Symbol(:F_ringbuf_m, m) for m in 0:(M - 2)], :F_ringbuf, Register(:mtaps, 1, M - 1))
                for m in 0:(M - 2)
                    widen2!(
                        emitter,
                        Symbol(:E_ringbuf_m, m),
                        Symbol(:F_ringbuf_m, m),
                        SIMD(:simd, 4, 2) => Register(:cplx, 1, C),
                        SIMD(:simd, 8, 2) => Register(:dish, 1, 2);
                        newtype=FloatValue,
                    )
                    apply!(emitter, :E2, [:E2, Symbol(:E_ringbuf_m, m), Symbol(:W_m, m)], (E2, E, W) -> :(muladd($W, $E, $E2)))
                end

                # Step 5: Compute E3 by applying phases to E2
                split!(emitter, [:E2im, :E2re], :E2, Cplx(:cplx, 1, C))
                split!(emitter, [:Xim, :Xre], :X, Cplx(:cplx, 1, C))
                apply!(emitter, :E3re, [:E2re, :E2im, :Xre, :Xim], (E2re, E2im, Xre, Xim) -> :(muladd(-Xim * E2im, Xre, E2re)))
                apply!(emitter, :E3im, [:E2re, :E2im, :Xre, :Xim], (E2re, E2im, Xre, Xim) -> :(muladd(Xim * E2re, Xre, E2im)))
                merge!(emitter, :E3, [:E3im, :E3re], Cplx(:cplx, 1, C) => Register(:cplx, 1, C))

                # Step 6: Compute E4 by FFTing E3

                return nothing
            end

            return nothing
        end

        return nothing
    end

    return nothing
end

function make_upchan_kernel()
    emitter = Emitter(kernel_setup)

    # Generate kernel
    upchan!(emitter)

    # Emit code
    stmts = clean_code(
        quote
            @fastmath @inbounds begin
                $(emitter.init_statements...)
                $(emitter.statements...)
            end
        end,
    )

    return stmts
end

println("[Creating upchan kernel...]")
const upchan_kernel = make_upchan_kernel()
println("[Done creating upchan kernel]")

println(upchan_kernel)
