# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this package is

IndexSpaces.jl is a Julia-embedded DSL that generates high-performance CUDA
kernels. It expresses how application ("physics") dimensions — beams, dishes,
frequencies, polarizations, time samples — map onto GPU hardware resources
(SIMD lanes within a register, threads, warps, blocks, shared memory, global
memory, loops, registers), and emits a Julia AST that compiles to a CUDA
kernel. Its driving application is the CHORD radio telescope (baseband
beamformer, FRB beamformer, upchannelizer), whose generated kernels are
consumed by Kotekan.

Whole implementation lives in one file: [src/IndexSpaces.jl](src/IndexSpaces.jl)
(~3000 lines, no submodules).

## Existing Markdown files

- [README.md](README.md) — badges, benchmark/profiling invocations, a CPU↔GPU
  terminology table.
- [summary.md](summary.md) — high-level conceptual overview (index categories,
  layouts, emitter, tensor cores, CHORD use case). Good first read.
- [api.md](api.md) — detailed API reference: every exported type, emitter
  operation, tensor-core wrapper, and low-level CUDA helper.
- `summary.md` and `api.md` were written as working notes and are not wired into
  the Documenter build.
- [docs/src/index.md](docs/src/index.md) is just `@autodocs` over the module, so
  the published docs contain only docstrings from the source.

## Layout of the repo

- `src/IndexSpaces.jl` — the entire package.
- `test/runtests.jl` — a single `@testset "Indices and layouts"`. It exercises
  index/layout algebra only; it does **not** run CUDA code. GPU kernels must be
  tested by hand on a GPU machine (this is why code coverage is low).
- `docs/` — Documenter setup; build with `(cd docs && julia make.jl)`.
- `kernels/` — the real-world kernel generators (`bb.jl` baseband beamformer,
  `frb.jl`, `upchan.jl`, plus `-chord`/`-pathfinder`/`-U16..U128` variants),
  C++ reference implementations (`*.cxx`, built via `kernels/Makefile`), the
  Kotekan Mustache template, driver shell scripts, and design PDFs.
  **`kernels` is listed in `.gitignore` and nothing under it is tracked** — it
  is a local working area, so changes there are not committed.

## Commands

Run the tests:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

Format (required style is in `.JuliaFormatter.toml`: blue style, indent 4,
margin 132):

```bash
julia -e 'using JuliaFormatter; JuliaFormatter.format_file("/Users/eschnett/src/jl/IndexSpaces")'
```

Build the docs:

```bash
cd docs && julia make.jl
```

Generate/benchmark a kernel (needs a CUDA GPU; see `kernels/*.sh` for the full
remote-machine workflow, which also copies results into Kotekan):

```bash
julia --optimize=3 --project=@. --threads=$(nproc) kernels/bb.jl
```

## Core concepts

- `Index{Typ,Tag}(name, offset, length)` where `Typ` is `Physics` or `Machine`.
  `offset` is the stride, `length` the extent of this tile; both are powers of
  two in practice. Machine constructors: `SIMD`, `Thread`, `Warp`, `Block`,
  `Shared`, `Memory`, `Loop`, `UnrolledLoop`, `Register`. Physics value
  constructors: `IntValue`, `FloatValue`, `BFloatValue` (the `length` picks the
  CUDASIMDTypes wrapper: 4→`Int4x8`, 8→`Int8x4`, 16→`Int16x2`/`Float16x2`/
  `BFloat16x2`, 32→`Int32`/`Float32`).
- `Layout{Physics,Machine}` is a validated bijection from physics indices to
  machine indices; construction checks disjointness and matching lengths, drops
  `length == 1` entries, and merges adjacent entries (`normalize!`).
- `Emitter(KernelSetup(...))` holds an `Environment` (variable name → layout)
  and accumulates statements. Operations mutate the environment and push AST:
  control flow (`block!`, `if!`, `loop!`, `unrolled_loop!`, `trap!`),
  synchronization (`sync_threads!`, `threadfence_block!`), memory (`load!`,
  `store!`, `unsafe_store4!`), rearrangement (`widen!`, `widen2!`, `narrow!`,
  `narrow2!`, `narrow3!`, `split!`, `select!`, `unselect!`), compute (`apply!`),
  and tensor cores (`mma_row_col_m8n8k16_s8!`, `mma_row_col_m16n8k8_f16!`,
  `mma_row_col_m16n8k16_f16!`, `mma_sp_row_col_m16n8k16_f16!`). The result is
  cleaned with `clean_code` (strips misleading line numbers) and `@eval`ed into
  a kernel.

`api.md` documents the exact layout requirements each operation imposes —
consult it before adding or changing an emitter operation, since most of them
assert on precise index/offset patterns.

## Gotchas

- `Memory` is exported and clashes with `Base.Memory` on Julia ≥ 1.11. Test and
  kernel code does `const Memory = IndexSpaces.Memory` after `using`; keep doing
  that in new code.
- `const DEBUG = Base.JLOptions().opt_level == 0`: the checked-arithmetic
  helpers (`add`, `sub`, `mul`, `idiv`, `imod`, `pos`, `neg`, …) only assert when
  Julia runs with `--optimize=0`. To debug overflow in generated kernels, rerun
  with `--optimize=0`; production runs use `--optimize=3`.
- Emitter operations assert aggressively on layouts. A failed `@assert` about a
  layout usually means the caller's index mapping is wrong, not that the
  operation is buggy.
- CI (`.github/workflows/CI.yml`) runs on Julia 1.10–1.12 across Linux/macOS/
  Windows without a GPU; keep the non-CUDA parts of the package loadable and
  testable on CPU-only machines.
- The `julia` installed via juliaup reportedly does not work for profiling with
  `ncu` (see README); a directly installed Julia is used there instead.
