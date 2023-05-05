#!/bin/bash

set -euxo pipefail

cd $HOME/src/jl/IndexSpaces

# Sync Julia code to Blue
rsync -Paz --exclude .git --exclude *.toml ~/src/jl/IndexSpaces blue.lwlab:src/jl

# Generate kernel
ssh blue.lwlab 'cd src/jl/IndexSpaces && /home/eschnett/.juliaup/bin/julia --optimize --project=@. --threads=$(nproc) kernels/upchan.jl 2>&1 | tee output-A40/upchan-U16.out'

# Sync kernel back
rsync -Paz blue.lwlab:src/jl/IndexSpaces/output-A40/upchan\* output-A40

# Format generated Julia code
julia -e 'using JuliaFormatter; JuliaFormatter.format_file("/Users/eschnett/src/jl/IndexSpaces")'

# Copy kernel to Kotekan
cp output-A40/upchan-U16.cxx ~/src/kotekan/lib/cuda/cudaUpchannelizer_U16.cpp
cp output-A40/upchan-U16.ptx ~/src/kotekan/lib/cuda/kernels/Upchannelizer_U16.ptx
cp output-A40/upchan-U16.yaml ~/src/kotekan/lib/cuda/kernels/Upchannelizer_U16.yaml

# Format Kotekan code
clang-format -i ~/src/kotekan/lib/cuda/cudaUpchannelizer_U16.cpp

# Sync Kotekan to Blue
(cd ~/src/kotekan && rsync -Paz --exclude .git --exclude build ~/src/kotekan blue.lwlab:src)

# Build Kotekan on Blue
ssh blue.lwlab 'cd src/kotekan && cmake --build build'

# Run Kotekan on Blue
ssh blue.lwlab 'cd src/kotekan && cd build/kotekan && ./kotekan -c ../../config/tests/mvp.yaml'
