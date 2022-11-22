# Generate documentation with this command:
# (cd docs && julia make.jl)

push!(LOAD_PATH, "..")

using Documenter
using IndexSpaces

makedocs(; sitename="IndexSpaces", format=Documenter.HTML(), modules=[IndexSpaces])

deploydocs(; repo="github.com/eschnett/IndexSpaces.jl.git", devbranch="main", push_preview=true)
