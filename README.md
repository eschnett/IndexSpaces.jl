# IndexSpaces.jl

Mapping physics quantities onto hardware for efficient
parallelization.

* [Documentation](https://eschnett.github.io/IndexSpaces.jl/dev/)
* [![GitHub
  CI](https://github.com/eschnett/IndexSpaces.jl/workflows/CI/badge.svg)](https://github.com/eschnett/IndexSpaces.jl/actions)

TODO * [![codecov](https://codecov.io/gh/eschnett/IndexSpaces.jl/branch/main/graph/badge.svg?token=75FT03ULHD)](https://codecov.io/gh/eschnett/IndexSpaces.jl)

(CI code coverage is bad because the CI tests don't test the CUDA
code; these tests need to be run manually.)


## Notes

Run benchmarks:
```sh
julia --optimize=3 --project=@. --threads=$(nproc) kernels/bb.jl
```

Run with profiling:
```sh
ncu -f -o profile --set full --target-processes all env LD_LIBRARY_PATH="/home/eschnett/julia-1.8/lib/julia:$LD_LIBRARY_PATH" ~/julia-1.8/bin/julia --optimize=3 --project=@. --threads=$(nproc) kernels/bb.jl
```
The juliaup-installed Julia does not work.
One cannot extract PTX or SASS while profiling.
