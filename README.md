# IndexSpaces.jl

Mapping physics quantities onto hardware for efficient
parallelization.

* [Documentation](https://eschnett.github.io/IndexSpaces.jl/dev/)
* [![GitHub
  CI](https://github.com/eschnett/IndexSpaces.jl/workflows/CI/badge.svg)](https://github.com/eschnett/IndexSpaces.jl/actions)
* [![codecov](https://codecov.io/gh/eschnett/IndexSpaces.jl/branch/main/graph/badge.svg?token=75FT03ULHD)](https://codecov.io/gh/eschnett/IndexSpaces.jl)
* [![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/I/IndexSpaces.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/I/IndexSpaces.html)

(CI code coverage is bad because the CI tests don't test the CUDA
code; these tests need to be run manually.)

## Notes

Run benchmarks:
```sh
julia --optimize=3 --project=@. --threads=$(nproc) kernels/bb.jl
```

Run with profiling:
```sh
/usr/local/cuda/bin/ncu -f -o profile --set full --target-processes all env LD_LIBRARY_PATH="/home/eschnett/julia-1.8/lib/julia:$LD_LIBRARY_PATH" ~/julia-1.8/bin/julia --optimize=3 --project=@. --threads=$(nproc) kernels/bb.jl
```
The juliaup-installed Julia does not work.
One cannot extract PTX or SASS while profiling.

## CPU vs. GPU terms

Intel Skylake vs. Nvidia Tesla V100 (numbers are estimates)

| CPU term        | count on CPU | count on GPU | GPU term                 |
|-----------------|--------------|--------------|--------------------------|
| SIMD lane       |           16 |           32 | thread                   |
| SMT thread      |            2 |           32 | warp                     |
| superscalar     |            6 |            2 |                          |
| OOO             |         >100 |          n/a | n/a                      |
| thread          |           40 |            ? | block                    |
| core            |           40 |           80 | SM                       |
| node            |            1 |            1 | GPU                      |
| scalar register |            ? |            ? | uniform register         |
| SIMD register   |         2688 |           5? | register cache           |
| L1 cache        |         8 kB |       256 kB | register                 |
| L2 cache        |         1 MB |       100 kB | L1 cache / shared memory |
| L3 cache        |            ? |            ? | L2 cache                 |
| HBM             |          n/a |        32 GB | memory                   |
| memory          |       192 GB |          n/a | host memory              |

