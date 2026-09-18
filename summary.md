# IndexSpaces.jl — Summary

**Author:** Erik Schnetter  
**Version:** 1.10.1  
**Dependencies:** CUDA.jl, CUDASIMDTypes.jl, BFloat16s.jl  
**Repository:** <https://github.com/eschnetter/IndexSpaces.jl>

## What It Is

IndexSpaces.jl is a **Julia-embedded domain-specific language (DSL) for generating high-performance CUDA kernels**. It lets you express the mapping of physics/application data (e.g., beams, dishes, frequencies, time samples) onto GPU hardware resources (SIMD lanes, threads, warps, blocks, shared memory, registers) in a **declarative, layout-centric** manner. The library then **automatically generates the corresponding Julia AST** that compiles to CUDA kernels with optimal memory access patterns and tensor core usage.

## Core Concepts

1. **Two Index Categories**: Every computational dimension is represented as an `Index{Type, Tag}`:
   - **Physics indices** (`Index{Physics, Tag}`) represent application-level quantities (e.g., `Beam`, `Dish`, `Time`, `Freq`, `Polarization`).
   - **Machine indices** (`Index{Machine, Tag}`) represent GPU hardware resources: `SIMD` (SIMD lanes within a thread), `Thread`, `Warp`, `Block`, `Shared` memory, `Memory` (global memory), `Loop`, `UnrolledLoop`, and `Register`.

2. **Layouts**: A `Layout{Physics, Machine}` is a dictionary mapping physics indices to machine indices. The layout encodes how a multi-dimensional array is stored in memory, in shared memory, or in registers. Layouts are compositional — by nesting loops that iterate over sub-segments of an index, you can model tiling.

3. **Emitter**: The code-generation engine. It tracks the current *environment* (a mapping from variable names to their `Layout`) and accumulates Julia AST statements. Operations like `load!`, `store!`, `permute!`, `apply!`, `loop!`, `if!`, etc. modify the environment and emit statements. The final output is a Julia expression tree that, when `@eval`-ed, becomes a CUDA kernel.

4. **Tensor Core Integration**: The package wraps NVIDIA's `mma.sync` PTX instructions for `m8n8k16` (int8), `m16n8k8` and `m16n8k16` (float16), and sparse `mma.sp` variants, enabling direct use of GPU tensor cores from generated kernels.

## Primary Use Case

The package was designed for the **CHORD radio telescope** (Canadian Hydrogen Observatory and Radio-transient Detector), where the `bb.jl` kernel implements a baseband beamformer computing:

    J[t,p,f,b] = s[b,p,f] * Σ[d] A[d,b,p,f] * E[d,p,f,t]

This kernel uses IndexSpaces to tile across beams, dishes, polarizations, frequencies, and time, using layouts to specify how data moves through the GPU memory hierarchy — from global memory → shared memory → registers → tensor core MMA → registers → shared memory → global memory.

## Why It Exists

Writing high-performance CUDA kernels manually is error-prone, especially when targeting tensor cores and managing the complex tiling required for optimal throughput. IndexSpaces.jl separates the *physics of the computation* from the *mechanics of data movement*, allowing a domain expert to describe *what* should be computed and *how it should be laid out* without writing low-level PTX or C++ CUDA code. The compiler-style approach (define layouts → chain operations → emit code) also makes it easy to experiment with different tiling strategies.
