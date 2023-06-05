#!/bin/bash

set -euxo pipefail

cd $HOME/src/jl/IndexSpaces

# Sync Julia code to Blue
rsync -Paz --exclude .git --exclude *.toml ~/src/jl/IndexSpaces blue.lwlab:src/jl

# Generate kernel
ssh blue.lwlab 'cd src/jl/IndexSpaces && /home/eschnett/.juliaup/bin/julia --optimize --project=@. --threads=$(nproc) kernels/bb.jl 2>&1 | tee output-A40/bb.out'

# Sync kernel back
rsync -Paz blue.lwlab:src/jl/IndexSpaces/output-A40/bb\* output-A40

# Format generated Julia code
julia -e 'using JuliaFormatter; JuliaFormatter.format_file("/Users/eschnett/src/jl/IndexSpaces")'

# Copy kernel to Kotekan
cp output-A40/bb.cxx ~/src/kotekan/lib/cuda/cudaBasebandBeamformer.cpp
cp output-A40/bb.jl ~/src/kotekan/lib/cuda/kernels/BasebandBeamformer.jl
cp output-A40/bb.ptx ~/src/kotekan/lib/cuda/kernels/BasebandBeamformer.ptx
cp output-A40/bb.yaml ~/src/kotekan/lib/cuda/kernels/BasebandBeamformer.yaml

# Format Kotekan code
clang-format -i ~/src/kotekan/lib/cuda/cudaBasebandBeamformer.cpp

# Sync Kotekan to Blue
(cd ~/src/kotekan && rsync -Paz --exclude .git --exclude cmake-build ~/src/kotekan blue.lwlab:src)

# Build Kotekan on Blue
ssh blue.lwlab 'cd src/kotekan && cmake --build cmake-build --target kotekan/kotekan'

# Run Kotekan on Blue
ssh blue.lwlab 'cd src/kotekan && ./cmake-build/kotekan/kotekan --bind-address 0:23000 --config config/tests/mvp.yaml'
