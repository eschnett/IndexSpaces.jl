#!/bin/bash

set -euxo pipefail

cd $HOME/src/jl/IndexSpaces

# Sync Julia code to Blue
rsync -Paz --exclude .git --exclude *.toml ~/src/jl/IndexSpaces blue.lwlab:src/jl

# Generate kernel
ssh blue.lwlab 'cd src/jl/IndexSpaces && /home/eschnett/.juliaup/bin/julia --optimize --project=@. --threads=$(nproc) kernels/frb.jl 2>&1 | tee output-A40/frb.out'

# Sync kernel back
rsync -Paz blue.lwlab:src/jl/IndexSpaces/output-A40/frb\* output-A40

# Format generated Julia code
julia -e 'using JuliaFormatter; JuliaFormatter.format_file("/Users/eschnett/src/jl/IndexSpaces")'

# Copy kernel to Kotekan
cp output-A40/frb.cxx ~/src/kotekan/lib/cuda/cudaFRBBeamformer.cpp
cp output-A40/frb.jl ~/src/kotekan/lib/cuda/kernels/FRBBeamformer.jl
cp output-A40/frb.ptx ~/src/kotekan/lib/cuda/kernels/FRBBeamformer.ptx
cp output-A40/frb.yaml ~/src/kotekan/lib/cuda/kernels/FRBBeamformer.yaml

# Format Kotekan code
clang-format -i ~/src/kotekan/lib/cuda/cudaFRBBeamformer.cpp

# Sync Kotekan to Blue
(cd ~/src/kotekan && rsync -Paz --exclude .git --exclude cmake-build ~/src/kotekan blue.lwlab:src)

# Build Kotekan on Blue
ssh blue.lwlab 'cd src/kotekan && cmake --build cmake-build --target kotekan/kotekan'

# Run Kotekan on Blue
ssh blue.lwlab 'cd src/kotekan && env JULIA_NUM_THREADS=$(nproc) ./cmake-build/kotekan/kotekan --bind-address 0:23000 --config config/tests/f_engine_frb.yaml'
