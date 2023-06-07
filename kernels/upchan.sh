#!/bin/bash

set -euxo pipefail

cd $HOME/src/jl/IndexSpaces

Ufactors='16 32 64 128'

# Sync Julia code to Blue
rsync -Paz --exclude .git --exclude *.toml ~/src/jl/IndexSpaces blue.lwlab:src/jl

# Generate kernel
for U in $Ufactors; do
    ssh blue.lwlab 'cd src/jl/IndexSpaces && /home/eschnett/.juliaup/bin/julia --optimize --project=@. --threads=$(nproc) kernels/upchan-U'$U'.jl 2>&1 | tee output-A40/upchan-U'$U'.out'
done

# Sync kernel back
rsync -Paz blue.lwlab:src/jl/IndexSpaces/output-A40/upchan\* output-A40

# Format generated Julia code
julia -e 'using JuliaFormatter; JuliaFormatter.format_file("/Users/eschnett/src/jl/IndexSpaces")'

# Copy kernel to Kotekan
for U in $Ufactors; do
    cp output-A40/upchan-U$U.cxx ~/src/kotekan/lib/cuda/cudaUpchannelizer_U$U.cpp
    cp output-A40/upchan-U$U.jl ~/src/kotekan/lib/cuda/kernels/Upchannelizer_U$U.jl
    cp output-A40/upchan-U$U.ptx ~/src/kotekan/lib/cuda/kernels/Upchannelizer_U$U.ptx
    cp output-A40/upchan-U$U.yaml ~/src/kotekan/lib/cuda/kernels/Upchannelizer_U$U.yaml
done

# Format Kotekan code
for U in $Ufactors; do
    clang-format -i ~/src/kotekan/lib/cuda/cudaUpchannelizer_U$U.cpp
done

# Sync Kotekan to Blue
(cd ~/src/kotekan && rsync -Paz --exclude .git --exclude cmake-build ~/src/kotekan blue.lwlab:src)

# Build Kotekan on Blue
ssh blue.lwlab 'cd src/kotekan && cmake --build cmake-build --target kotekan/kotekan'

# Run Kotekan on Blue
ssh blue.lwlab 'cd src/kotekan && ./cmake-build/kotekan/kotekan --bind-address 0:23000 --config config/tests/mvp.yaml'
