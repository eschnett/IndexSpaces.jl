# IndexSpaces.jl — API Reference

## Types

### `Index{Typ, Tag}`

The fundamental unit of the DSL. Represents a dimension in either the physics space or the machine space.

```
Index{Typ, Tag}(name::Symbol, offset::Integer, length::Integer)
```

- **`Typ`** — `Physics` or `Machine` (an `IndexType` enum value)
- **`Tag`** — discriminator type (e.g., `BeamTag`, `SIMDTag`); must be a subtype of `IndexTag` (= `Any`)
- **`name`** — symbolic label (e.g., `:beam`, `:simd`)
- **`offset`** — stride between consecutive elements (`≥ 1`)
- **`length`** — number of elements in this tile (`≥ 1`)

Two indices are equal when their `(Typ, Tag, name, offset, length)` tuples match. Ordering is by `isless` on that tuple.

### `IndexType` enum

`Physics` | `Machine` — discriminates the category of an index.

### `MachineIndexTag` enum

`SIMDTag` | `ThreadTag` | `WarpTag` | `BlockTag` | `SharedTag` | `MemoryTag` | `LoopTag` | `UnrolledLoopTag` | `RegisterTag`

### `ValueTag` enum

`IntValueTag` | `FloatValueTag` | `BFloatValueTag`

### Pre-built Machine Index Constructors

| Constructor | Tag | Meaning |
|---|---|---|
| `SIMD(name, o, l)` | `SIMDTag` | SIMD lanes within a single scalar register |
| `Thread(name, o, l)` | `ThreadTag` | GPU thread (lane within a warp) |
| `Warp(name, o, l)` | `WarpTag` | GPU warp (group of threads) |
| `Block(name, o, l)` | `BlockTag` | GPU block (CTA) |
| `Shared(name, o, l)` | `SharedTag` | Shared memory address |
| `Memory(name, o, l)` | `MemoryTag` | Global memory address |
| `Loop(name, o, l)` | `LoopTag` | Runtime loop iterator |
| `UnrolledLoop(name, o, l)` | `UnrolledLoopTag` | Compile-time (unrolled) loop iterator |
| `Register(name, o, l)` | `RegisterTag` | Register identifier (symbolic index) |

### Pre-built Physics Value Index Constructors

| Constructor | Tag | Julia type mapped |
|---|---|---|
| `IntValue(name, o, l)` | `IntValueTag` | `Int4x8`, `Int8x4`, `Int16x2`, `Int32` |
| `FloatValue(name, o, l)` | `FloatValueTag` | `Float16x2`, `Float32` |
| `BFloatValue(name, o, l)` | `BFloatValueTag` | `BFloat16x2` |

The `length` field determines which CUDASIMDTypes wrapper type is used:
- length 4 → `Int4x8` (4-bit values, 8 per 32-bit register)
- length 8 → `Int8x4`
- length 16 → `Int16x2` or `Float16x2` or `BFloat16x2`
- length 32 → `Int32` or `Float32`

### `Quantity`

```
Quantity(name::Symbol, indices::Vector{Index{Physics}})
```

A named collection of physics indices representing a physical field. Currently a minimal container (used for documentation purposes).

### `Layout{Typ1, Typ2}`

```
Layout(dict::Dict{Index{Typ1}, Index{Typ2}})
Layout(pairs::AbstractVector{Pair{Index{Typ1}, Index{Typ2}}})
```

A bidirectional mapping from indices of one type to indices of another. The most common forms are `Layout{Physics, Machine}` (used for data layouts) and its inverse `Layout{Machine, Physics}`.

**Validation:** on construction, the layout checks:
- All keys (domain indices) are pairwise disjoint
- All values (codomain indices) are pairwise disjoint
- Each key's `length` matches its value's `length`
- Entries with `length == 1` are automatically removed (they carry no information)
- Adjacent entries of the same type/tag/name are merged via `normalize!`

**Layout operations:**
- `layout[key]` — look up the mapping for a sub-index (extrapolates offset/length)
- `layout[key] = value` — add a new mapping
- `delete!(layout, key)` — remove a mapping, splitting adjacent entries if needed
- `inv(layout)` — return the inverse layout (swap domain and codomain)
- `layout1 ⊆ layout2` — true if all entries in layout1 exist in layout2
- `layout1 ∪ layout2` — union of two disjoint layouts
- `copy(layout)` — shallow copy

### `KernelSetup`

```
KernelSetup(num_threads::Int, num_warps::Int, num_blocks::Int,
            num_blocks_per_sm::Int, shmem_bytes::Int)
```

Describes the GPU kernel launch configuration. Fields:
- `num_threads` — threads per warp
- `num_warps` — warps per block
- `num_blocks` — total blocks
- `num_blocks_per_sm` — blocks per streaming multiprocessor (for occupancy control)
- `shmem_bytes` — dynamic shared memory per block (in bytes)

### `Environment`

```
Environment()
```

A mapping from variable names (`Symbol`) to their `Layout{Physics, Machine}`. Also tracks unrolled loop index values (`values::Dict{Symbol, Int32}`). Used internally by the Emitter.

### `Emitter`

```
Emitter(kernel_setup::KernelSetup)
```

The code generation context. Accumulates Julia AST in two lists:
- `init_statements::Vector{Code}` — declarations initialized before the main body (e.g., zero accumulators)
- `statements::Vector{Code}` — main kernel body statements

Tracks:
- `kernel_setup` — launch configuration
- `environment` — current variable-to-layout mapping
- `output_environment` — variables that are outputs (written to memory)

### `Code`

```
Union{Expr, Number, Symbol, Int2x4, Int4x2, Int2x16, Int4x8, Int8x4, Int16x2, Float16x2, BFloat16x2}
```

The union type of valid code fragments that can appear in emitted statements.

### Type Literals

```
i8, i16, i32, i64, u8, u16, u32, u64, f16, f32, f64, bf16
```

Singleton sentinels of type `IntLiteral{I}` or `FloatLiteral{F}`. Used as type hint arguments when the literal value is irrelevant (only the type matters). For example, calling a function with `i32` signals "I want an Int32 here".

---

## Functions

### Index Introspection

```julia
indextype(index::Index) -> IndexType
indextype(::Type{<:Index{Typ}}) -> Typ
```

Return the `IndexType` (`Physics` or `Machine`) of an index value or type.

```julia
indextag(index::Index) -> Tag
indextag(::Type{<:Index{<:Any, Tag}}) -> Tag
```

Return the tag type (e.g., `BeamTag`, `SIMDTag`) of an index value or type.

---

### Layout Normalization

```julia
normalize!(layout::Layout) -> Layout
```

Remove entries with `length == 1` and merge adjacent entries where the end of one range equals the start of the next (for the same name and tag in both domain and codomain). Called automatically during construction.

---

### Code Cleanup

```julia
clean_code(expr) -> Expr
```

Recursively:
- Remove `LineNumberNode`s (except inside `:macrocall` expressions)
- Coalesce nested `:block` expressions
- Unwrap single-element blocks

---

### Arithmetic Helpers (safe, checked in debug mode)

```julia
pos(x), neg(x), add(x, y...), sub(x, y), mul(x, y...), idiv(x, y), imod(x, y)
```

In debug mode (`opt_level == 0`), these assert that results fit in `Int64`. At higher optimization levels they compile to the native operation. Used internally by code generation to avoid overflow bugs.

---

## Emitter Operations

### Control Flow

```julia
trap!(emitter::Emitter)
```

Emit a GPU `trap` instruction (causes kernel to abort). Equivalent to `asm("trap;")`.

```julia
block!(body!, emitter::Emitter)
```

Emit a `let` block. `body!` receives a fresh sub-emitter whose statements are wrapped in a `let ... end`. Output environment variables propagate to the parent.

```julia
if!(body!, emitter::Emitter, cond::Code)
```

Emit an `if cond ... end` block. `body!` receives a sub-emitter; output environment variables propagate upward.

```julia
loop!(body!, emitter::Emitter, physics_index::Pair{Index{Physics}, Loop})
```

Emit a runtime `for` loop:
```julia
for loop_name in 0:loop_offset:(loop_offset * loop_length - 1)
    ...
end
```

The physics index provides the name for the loop variable. The `Loop` index specifies `offset` (stride) and `length` (iteration count).

```julia
unrolled_loop!(body!, emitter::Emitter, physics_index::Pair{Index{Physics}, UnrolledLoop})
```

Emit a compile-time unrolled loop. For each iteration `i`, a separate `let unrolled_name = i ... end` block is emitted with the loop body duplicated. The loop index value is recorded in `environment.values` and influences register name generation.

### Synchronization

```julia
sync_threads!(emitter::Emitter)
```

Emit `IndexSpaces.cuda_sync_threads()` which maps to `CUDA.sync_threads()` (`__syncthreads()`).

```julia
threadfence_block!(emitter::Emitter)
```

Emit `IndexSpaces.cuda_threadfence_block()` which maps to `CUDA.threadfence_block()` (`__threadfence_block()`).

### Memory Access

```julia
load!(emitter, reg::Pair{Symbol, Layout{Physics,Machine}},
            mem::Pair{Symbol, Layout{Physics,Machine}};
            align::Int=4, postprocess=identity)
```

Generate code to load data from memory into registers. The `reg` pair gives the register variable name and its register layout; `mem` gives the memory variable name and its memory layout.

**`align`** controls vectorization:
- `align=4` — scalar load (`arr[idx+1]`)
- `align=8` — load 2 values via `unsafe_load2` (2 × Int32)
- `align=16` — load 4 values via `unsafe_load4` (4 × Int32, 16-byte aligned)

**`postprocess`** — a function `addr -> expr` applied to the computed address before indexing. Used for modulo addressing (ring buffers) and offset handling.

```julia
store!(emitter, mem::Pair{Symbol, Layout{Physics,Machine}},
               reg_var::Symbol;
               align::Int=4, condition=Returns(true), offset::Code=0, postprocess=identity)
```

Generate code to store register values to memory. Same `align` semantics as `load!`.

**`condition`** — a function `state -> Code` returning a boolean condition under which the store occurs. `Returns(true)` means always store.

**`offset`** — constant address offset added to the computed address.

```julia
unsafe_store4!(ptr::Core.LLVMPtr{Int32, AS}, val::NTuple{4,Int32})
unsafe_store4!(arr::CuDeviceArray, idx::Integer, val::NTuple{4,T})
```

Low-level 16-byte aligned store via inline LLVM IR. Writes 4 consecutive `Int32` values. The array variant reinterprets sub-32-bit types.

### Data Rearrangement

```julia
broadcast!(emitter, res::Symbol, var::Symbol, register::Register => thread::Thread)
```

Emit warp shuffle (`shfl_sync`) to broadcast data from one thread to all threads in the warp. The register dimension becomes a thread dimension in the result layout.

```julia
permute!(emitter, res::Symbol, var::Symbol, index1::Index{Physics}, index2::Index{Physics})
permute!(emitter, res::Symbol, var::Symbol, register::Register, simd::SIMD)
permute!(emitter, res::Symbol, var::Symbol, register::Register, thread::Thread)
```

Rearrange bits between two index dimensions in the layout. Three forms:
1. **Register ↔ SIMD**: interleave/deinterleave bits using PTX `prmt` / `bitifelse` operations. When both operands are length 2, this swaps which dimension is in registers vs SIMD lanes.
2. **Register ↔ Thread**: use `shfl_xor_sync` to exchange data between threads, swapping a register dimension with a thread dimension.
3. **Physics → Physics**: dispatches to one of the above based on the actual machine index types.

Internal helper functions used for bit manipulation:
- `get_lo2` / `get_hi2` — 2-bit interleave
- `get_lo4` / `get_hi4` — 4-bit interleave
- `get_lo8` / `get_hi8` — 8-bit interleave (uses `prmt`)
- `get_lo16` / `get_hi16` — 16-bit interleave (uses `prmt`)

### Type Conversion

```julia
widen!(emitter, res::Symbol, var::Symbol, simd::SIMD => register::Register;
       newtype=nothing, swapped_withoffset=false, unshifted_withoffset=false)
```

Widen values by expanding SIMD bits into a register dimension. For example, `Int4x8` → `NTuple{2, Int8x4}`. The `swapped_withoffset` flag indicates CHORD's offset-encoded nibble format. The `unshifted_withoffset` variant skips the nibble shift.

```julia
widen2!(emitter, res::Symbol, var::Symbol, simd1::SIMD => reg1::Register,
        simd2::SIMD => reg2::Register; ...)
```

Double widen: expand two SIMD dimensions into two register dimensions (e.g., `Int4x8` → `NTuple{4, Int16x2}` or `NTuple{4, Float16x2}`).

```julia
narrow!(emitter, res::Symbol, var::Symbol, register::Register => simd::SIMD)
```

Narrow values by collapsing a register dimension into SIMD bits (e.g., two `Int32` registers → one `Int16x2`).

```julia
narrow2!(emitter, res::Symbol, var::Symbol,
         reg1::Register => simd1::SIMD, reg2::Register => simd2::SIMD;
         newtype=nothing, swapped_withoffset=false)
```

Double narrow with optional type change (e.g., `Float32` → `Int4x8` in offset-swapped format). Requires `simd1_bit == 2` and `simd2_bit == 3`.

```julia
narrow3!(emitter, res::Symbol, var::Symbol,
         reg1::Register => simd1::SIMD, reg2::Register => simd2::SIMD, reg3::Register => simd3::SIMD;
         swapped_withoffset=false)
```

Triple narrow (8 registers → one value). Used for packing time-interleaved data. Requires bits 2, 3, 4.

```julia
split!(emitter, ress::AbstractVector{Symbol}, var::Symbol, register::Register)
split!(emitter, ress::AbstractVector{Symbol}, var::Symbol, physics_index::Index{Physics})
```

Split a register variable into multiple variables along a register dimension. Each result variable holds one slice.

```julia
merge!(emitter, res::Symbol, vars::AbstractVector{Symbol},
       physics_index::Index{Physics} => register::Index{Machine})
```

Merge multiple variables into one by introducing a new register dimension. Inverse of `split!`.

### Loop/Register Interaction

```julia
select!(emitter, res::Symbol, var::Symbol, register::Register => loop::Loop)
select!(emitter, res::Symbol, var::Symbol, register::Register => unrolled::UnrolledLoop)
select!(emitter, res::Symbol, var::Symbol, physics_index::Index{Physics} => loop_or_unrolled)
```

Extract one iteration of a loop into a register variable. The result layout replaces the loop index with a register index. For runtime loops, emits `if loop_var == i` branching.

```julia
unselect!(emitter, res::Symbol, var::Symbol, loop::Loop => register::Register)
unselect!(emitter, res::Symbol, var::Symbol, unrolled::UnrolledLoop => register::Register)
```

Promote a register dimension back to a loop dimension. Inverse of `select!`. The resulting variable is recorded in `output_environment` to indicate it should be finalized.

### Element-wise Arithmetic

```julia
apply!(emitter, res_layout::Pair{Symbol, Layout{Physics,Machine}}, code::Code)
```

Assign a constant or expression to a new variable. The expression is evaluated once per register combination. Example: `apply!(emitter, :x => layout, 0i32)`.

```julia
apply!(emitter, res::Symbol, vars::AbstractVector{Symbol}, fn;
       ignore::AbstractVector{Index{Physics}} = Index{Physics}[])
```

Apply a function `fn(var_values...) -> expr` element-wise across register combinations. `fn` receives the register names and must return a Julia expression (or value). The `ignore` parameter allows excluding certain physics indices from layout comparison when the input variables have different layouts.

### Tensor Core Matrix Multiply

```julia
mma_row_col_m8n8k16_s8!(emitter, D::Symbol,
    A::Pair{Symbol, (row_indices, col_indices)},
    B::Pair{Symbol, (row_indices, col_indices)},
    C::Pair{Symbol, (row_indices, col_indices)})
```

Int8 tensor core matrix multiply:
```
D[m,n] = A[m,k] * B[k,n] + C[m,n]   (m8×n8×k16)
```

Requires:
- A: 8-bit values, k-dimension mapped to `[SIMD(:simd,8,2), SIMD(:simd,16,2), Thread(:t,1,2), Thread(:t,2,2)]`, m-dimension mapped to `[Thread(:t,4,2), Thread(:t,8,2), Thread(:t,16,2)]`
- B: 8-bit values, same k-dimension layout as A's k, n-dimension mapped to `[Thread(:t,4,2), Thread(:t,8,2), Thread(:t,16,2)]`
- C/D: 32-bit accumulators, m and n dimensions mapped to `[Register(...), Thread(:t,1,2), Thread(:t,2,2)]` and `[Thread(:t,4,2), Thread(:t,8,2), Thread(:t,16,2)]`

Emits `mma.sync.aligned.m8n8k16.row.col.satfinite.s32.s8.s8.s32`.

```julia
mma_row_col_m16n8k8_f16!(emitter, D, A, B, C)
```

Float16 tensor core multiply (m16×n8×k8). A is a pair of `Float16x2` registers and one SIMD dimension. Emits `mma.sync.aligned.m16n8k8.row.col.f16.f16.f16.f16`.

```julia
mma_row_col_m16n8k16_f16!(emitter, D, A, B, C)
```

Float16 tensor core multiply (m16×n8×k16). A is 4 registers, B is 2 registers. Emits the wider variant `mma.sync.aligned.m16n8k16.row.col.f16.f16.f16.f16`.

```julia
mma_sp_row_col_m16n8k16_f16!(emitter, D, A, B, C, spectator::Index{Physics})
```

Sparse float16 tensor core multiply. Exploits the NVIDIA sparse MMA instruction (`mma.sp.sync.aligned.m16n8k16`). The `spectator` index selects a 2:4 sparsity pattern dimension in the A matrix.

### Low-Level CUDA Helpers

```julia
IndexSpaces.cuda_threadidx() -> Int32     # threadIdx.x - 1
IndexSpaces.cuda_warpidx() -> Int32       # threadIdx.y - 1
IndexSpaces.cuda_blockidx() -> Int32      # blockIdx.x - 1
```

Return zero-indexed CUDA thread/warp/block indices. Outside device code they return `0i32`. Used internally by `indexvalue` for `Thread`, `Warp`, and `Block` indices.

```julia
IndexSpaces.assume_inrange(x, start, stop) -> x
IndexSpaces.assume_inrange(x, start, step, stop) -> x
```

Assert (via `unreachable()`) that a value lies within a range. In non-debug builds the assertion is removed but can serve as an LLVM `assume` hint.

```julia
IndexSpaces.unsafe_load2(arr, idx) -> NTuple{2, T}
IndexSpaces.unsafe_load4(arr, idx) -> NTuple{4, T}
```

16-byte aligned vector loads using inline LLVM IR. Load 2 or 4 consecutive values of type `T` (where `sizeof(T) == sizeof(Int32)`). `unsafe_load2` loads 8 bytes, `unsafe_load4` loads 16 bytes.
