module IndexSpaces

using CUDA
using CUDASIMDTypes

################################################################################

@inline unreachable() = Core.Intrinsics.llvmcall("unreachable;", Nothing, Tuple{})
# @inline unreachable() = @assert false
# @inline unreachable() = nothing

################################################################################

export i8, i16, i32, i64, u8, u16, u32, u64, f16, f32, f64
struct IntLiteral{I<:Integer} <: Integer end
Base.convert(::Type{I}, ::IntLiteral{J}) where {I<:Integer,J<:Integer} = convert(I, J(1))
Base.promote_rule(::Type{<:Integer}, ::Type{IntLiteral{I}}) where {I<:Integer} = I
struct FloatLiteral{F<:AbstractFloat} <: AbstractFloat end
Base.convert(::Type{F}, ::FloatLiteral{G}) where {F<:AbstractFloat,G<:AbstractFloat} = convert(F, G(1))
Base.promote_rule(::Type{<:AbstractFloat}, ::Type{FloatLiteral{F}}) where {F<:AbstractFloat} = F
const i8 = IntLiteral{Int8}()
const i16 = IntLiteral{Int16}()
const i32 = IntLiteral{Int32}()
const i64 = IntLiteral{Int64}()
const u8 = IntLiteral{UInt8}()
const u16 = IntLiteral{UInt16}()
const u32 = IntLiteral{UInt32}()
const u64 = IntLiteral{UInt64}()
const f16 = FloatLiteral{Float16}()
const f32 = FloatLiteral{Float32}()
const f64 = FloatLiteral{Float64}()

################################################################################

export IndexType, Physics, Machine
@enum IndexType Physics Machine

const IndexTag = Any

export MachineIndexTag, SIMDTag, ThreadTag, WarpTag, BlockTag, SharedTag, MemoryTag, LoopTag, UnrolledLoopTag, RegisterTag
@enum MachineIndexTag SIMDTag ThreadTag WarpTag BlockTag SharedTag MemoryTag LoopTag UnrolledLoopTag RegisterTag

export ValueTag, IntValueTag, FloatValueTag, BFloatValueTag
@enum ValueTag IntValueTag FloatValueTag BFloatValueTag

export Index
struct Index{Typ,Tag}
    name::Symbol
    offset::Int
    length::Int
    function Index{Typ,Tag}(name::Symbol, offset::Integer, length::Integer) where {Typ,Tag}
        @assert Typ isa IndexType
        @assert Tag isa IndexTag
        @assert offset ≥ 1
        @assert length ≥ 1
        return new{Typ,Tag}(name, offset, length)
    end
end

make_tuple(i::Index{Typ,Tag}) where {Typ,Tag} = (Typ, Symbol(Tag), i.name, i.length == 1 ? 1 : i.offset, i.length)

function Base.show(io::IO, index::Index{Typ,Tag}) where {Typ,Tag}
    print(io, "$Typ.$Tag.$(index.name):$(index.offset)/$(index.length)")
    return nothing
end

export indextype, indextag
indextype(::Type{<:Index{Typ}}) where {Typ} = Typ
indextag(::Type{<:Index{<:Any,Tag}}) where {Tag} = Tag
indextype(index::Index) = indextype(typeof(index))
indextag(index::Index) = indextag(typeof(index))

Base.:(==)(i::Index, j::Index) = make_tuple(i) == make_tuple(j)
Base.isless(i::Index, j::Index) = isless(make_tuple(i), make_tuple(j))

export SIMD, Thread, Warp, Block, Shared, Memory, Loop, UnrolledLoop, Register
const SIMD = Index{Machine,SIMDTag}
const Thread = Index{Machine,ThreadTag}
const Warp = Index{Machine,WarpTag}
const Block = Index{Machine,BlockTag}
const Shared = Index{Machine,SharedTag}
const Memory = Index{Machine,MemoryTag}
const Loop = Index{Machine,LoopTag}
const UnrolledLoop = Index{Machine,UnrolledLoopTag}
const Register = Index{Machine,RegisterTag}

export IntValue, FloatValue, BFloatValue
const IntValue = Index{Physics,IntValueTag}
const FloatValue = Index{Physics,FloatValueTag}
const BFloatValue = Index{Physics,BFloatValueTag}

################################################################################

export Quantity
struct Quantity
    name::Symbol
    indices::Vector{Index{Physics}}
    Quantity(name::Symbol, indices::Vector) = new(name, indices)
end

################################################################################

# TODO: Functions to decompose an index space and to check consistency of a decomposed index space

struct Range
    offset::Int
    length::Int
    function Range(offset::Integer, length::Integer)
        @assert offset ≥ 1
        @assert length ≥ 1
        return new(offset, length)
    end
end
Range(index::Index) = Range(index.offset, index.length)

function Base.in(x::Range, y::Range)
    x.length == 1 && return true
    y.length == 1 && return false
    xbeg = x.offset
    xend = x.offset * x.length
    ybeg = y.offset
    yend = y.offset * y.length
    return ybeg ≤ xbeg && xend ≤ yend
end
Base.in(x::Index, y::Index) = false
Base.in(x::Index{Typ,Tag}, y::Index{Typ,Tag}) where {Typ,Tag} = x.name == y.name && Range(x) ∈ Range(y)

function Base.isdisjoint(x::Range, y::Range)
    (x.length == 1 || y.length == 1) && return true

    xbeg = x.offset
    xend = x.offset * x.length
    ybeg = y.offset
    yend = y.offset * y.length
    return yend ≤ xbeg || xend ≤ ybeg
end
Base.isdisjoint(x::Index, y::Index) = true
Base.isdisjoint(x::Index{Typ,Tag}, y::Index{Typ,Tag}) where {Typ,Tag} = x.name ≠ y.name || isdisjoint(Range(x), Range(y))

function pairwise_disjoint(indices::AbstractVector{<:Index})
    # TODO: Don't use n^2 algorithm
    for i in 1:length(indices), j in (i + 1):length(indices)
        !isdisjoint(indices[i], indices[j]) && return false
    end
    return true
end

export Layout
struct Layout{Typ1,Typ2}
    dict::Dict{Index{Typ1},Index{Typ2}}
    function Layout{Typ1,Typ2}(dict::Dict{<:Index{Typ1},<:Index{Typ2}}) where {Typ1,Typ2}
        @assert Typ1 isa IndexType
        @assert Typ2 isa IndexType
        if !pairwise_disjoint(collect(keys(dict)))
            names = sort!(unique([k.name for k in keys(dict)]))
            ranges = [
                "begin/end $(k.name) = $(k.offset)/$(k.offset * k.length)" for name in names for k in keys(dict) if k.name == name
            ]
            throw(ArgumentError("Layout: $Typ1 indices (keys) are overlapping: " * join(ranges, ", ")))
        end
        if !pairwise_disjoint(collect(values(dict)))
            names = sort!(unique([v.name for v in values(dict)]))
            ranges = [
                "begin/end $(v.name) = $(v.offset)/$(v.offset * v.length)" for name in names for v in values(dict) if v.name == name
            ]
            throw(ArgumentError("Layout: $Type indices (values) are overlapping: " * join(ranges, ", ")))
        end
        if !all(k.length == v.length for (k, v) in dict)
            names = sort!(unique([k.name for k in keys(dict)]))
            lengths = [
                "lengths $(k.name)/$(v.name) = $(k.length)/$(v.length)" for name in names for (k, v) in dict if k.name == name
            ]
            throw(ArgumentError("Layout: Index space lengths disagree: " * join(lengths, ", ")))
        end
        return normalize!(new{Typ1,Typ2}(dict))
    end
    Layout(dict::Dict{<:Index{Typ1},<:Index{Typ2}}) where {Typ1,Typ2} = Layout{Typ1,Typ2}(dict)
end

function Layout(pairs::AbstractVector{<:Pair{<:Index{Typ1},<:Index{Typ2}}}) where {Typ1,Typ2}
    dict = Dict{Index{Typ1},Index{Typ2}}()
    for (k, v) in pairs
        if k.length ≠ v.length
            throw(ArgumentError("Layout: Key and value lengths disagree for key $k, value $v"))
        end
        # Skip length 1 pairs
        if k.length > 1
            if k ∈ keys(dict)
                throw(ArgumentError("key $k exists already"))
            end
            if v ∈ values(dict)
                throw(ArgumentError("value $v exists already"))
            end
            @assert k ∉ keys(dict)
            @assert v ∉ values(dict)
            dict[k] = v
        end
    end
    return Layout(dict)::Layout{Typ1,Typ2}
end

function Base.show(io::IO, layout::Layout{Typ1,Typ2}) where {Typ1,Typ2}
    println(io, "Layout{$Typ1,$Typ2}:")
    for k in sort!(collect(keys(layout.dict)))
        v = layout.dict[k]
        println(io, "    $k => $v")
    end
end

Base.copy(layout::Layout) = Layout(copy(layout.dict))

export normalize!
function normalize!(layout::Layout)
    dict = layout.dict

    # Remove empty indices
    filter!(kv -> kv[1].length > 1, dict)

    # Combine index ranges where possible
    @label restart
    # TODO: Don't use n^2 algorithm
    for (key, val) in dict
        for (key′, val′) in dict
            key′ == key && continue
            if indextag(key′) == indextag(key) && key′.name == key.name && indextag(val′) == indextag(val) && val′.name == val.name
                # Index types and tags are the same
                if key.offset * key.length == key′.offset && val.offset * val.length == val′.offset
                    # Both index ranges can be combined
                    delete!(dict, key)
                    delete!(dict, key′)
                    newkey = Index{indextype(key),indextag(key)}(key.name, key.offset, key.length * key′.length)
                    newval = Index{indextype(val),indextag(val)}(val.name, val.offset, val.length * val′.length)
                    dict[newkey] = newval
                    # This makes it worse than n^2
                    @goto restart
                end
            end
        end
    end

    return layout
end

function Base.:(==)(layout1::Layout{Typ1,Typ2}, layout2::Layout{Typ1,Typ2}) where {Typ1,Typ2}
    return layout1.dict == layout2.dict
end
function Base.in(layout1::Layout{Typ1,Typ2}, layout2::Layout{Typ1,Typ2}) where {Typ1,Typ2}
    for (key, val) in layout1.dict
        (key in keys(layout2.dict) && layout2.dict[key] == val) || return false
    end
    return true
end

function Base.inv(layout::Layout{Typ1,Typ2}) where {Typ1,Typ2}
    return Layout(Dict{Index{Typ2},Index{Typ1}}(v => k for (k, v) in layout.dict))
end

Base.isempty(layout::Layout) = isempty(layout.dict)

function Base.in(key::Index{Typ1}, layout::Layout{Typ1,Typ2}) where {Typ1,Typ2}
    key ∈ keys(layout.dict) && return true
    for (k, v) in layout.dict
        key ∈ k && return true
    end
    return false
end

function Base.union(layout1::Layout{Typ1,Typ2}, layout2::Layout{Typ1,Typ2}) where {Typ1,Typ2}
    # TODO: Ensure values are different
    @assert !any(k1 in keys(layout2.dict) for k1 in keys(layout1.dict))
    @assert !any(k2 in keys(layout1.dict) for k2 in keys(layout2.dict))
    return Layout{Typ1,Typ2}(Dict(layout1.dict ∪ layout2.dict))
end

function Base.getindex(layout::Layout{Typ1,Typ2}, key::Index{Typ1}) where {Typ1,Typ2}
    val = get(layout.dict, key, nothing)
    val ≢ nothing && return val

    keybeg = key.offset
    keylen = key.length
    keyend = keybeg * keylen

    for (k, v) in layout.dict
        if key ∈ k
            kbeg = k.offset
            klen = k.length
            kend = kbeg * klen
            vbeg = v.offset
            vlen = v.length
            vend = vbeg * vlen
            @assert (vbeg * keybeg) % kbeg == 0
            valbeg = (vbeg * keybeg) ÷ kbeg
            @assert (vend * keyend) % kend == 0
            valend = (vend * keyend) ÷ kend
            vallen = keylen
            @assert valbeg * vallen == valend
            val = Index{Typ2,indextag(v)}(v.name, valbeg, vallen)
            @assert val ∈ v
            return val
        end
    end
    @show layout key
    throw(KeyError(key))
end

function Base.setindex!(layout::Layout{Typ1,Typ2}, value::Index{Typ2}, key::Index{Typ1}) where {Typ1,Typ2}
    dict = layout.dict

    @assert all(isdisjoint(key, k) for k in keys(dict))
    @assert all(isdisjoint(value, v) for v in values(dict))
    @assert key.length == value.length

    dict[key] = value

    return normalize!(layout)
end

function Base.delete!(layout::Layout{Typ1,Typ2}, key::Index{Typ1}) where {Typ1,Typ2}
    dict = layout.dict

    keybeg = key.offset
    keylen = key.length
    keyend = keybeg * keylen

    @label restart
    for (k, v) in dict
        if !isdisjoint(k, key)
            # We found an overlap

            kbeg = k.offset
            klen = k.length
            kend = kbeg * klen
            vbeg = v.offset
            vlen = v.length
            vend = vbeg * vlen

            # Delete index
            delete!(dict, k)

            if kbeg < keybeg
                # Add lower leftover index
                let
                    newkbeg = kbeg
                    newkend = keybeg
                    @assert newkend % newkbeg == 0
                    newlen = newkend ÷ newkbeg
                    newvbeg = vbeg
                    newvend = newvbeg * newlen
                    newk = Index{Typ1,indextag(k)}(k.name, newkbeg, newlen)
                    newv = Index{Typ2,indextag(v)}(v.name, newvbeg, newlen)
                    @assert newk ∈ k
                    @assert newv ∈ v
                    @assert isdisjoint(newk, key)
                    dict[newk] = newv
                end
            end
            if keyend < kend
                # Add upper leftover index
                let
                    newkbeg = keyend
                    newkend = kend
                    @assert newkend % newkbeg == 0
                    newlen = newkend ÷ newkbeg
                    @assert vend % newlen == 0
                    newvbeg = vend ÷ newlen
                    newvend = vend
                    newk = Index{Typ1,indextag(k)}(k.name, newkbeg, newlen)
                    newv = Index{Typ2,indextag(v)}(v.name, newvbeg, newlen)
                    @assert newk ∈ k
                    @assert newv ∈ v
                    @assert isdisjoint(newk, key)
                    dict[newk] = newv
                end
            end
            # TODO: Don't use n^2 algorithm
            @goto restart
        end
    end

    return normalize!(layout)
end

function get_value_index(layout::Layout)
    # We need to look for larger types first
    for (bits, type, tag, name) in [
        (5, Int32, IntValueTag, :intvalue),
        (4, Int16x2, IntValueTag, :intvalue),
        (3, Int8x4, IntValueTag, :intvalue),
        (2, Int4x8, IntValueTag, :intvalue),
        (5, Float32, FloatValueTag, :floatvalue),
        (4, Float16x2, FloatValueTag, :floatvalue),
        (4, BFloat16x2, BFloatValueTag, :bfloatvalue),
    ]
        value_index = Index{Physics,tag}(name, 1, 1 << bits)
        if value_index ∈ layout
            @assert layout[value_index] == SIMD(:simd, 1, 1 << bits)
            return value_index
        end
    end
    @assert false
end

function get_value_type(layout::Layout)
    # We need to look for larger types first
    for (bits, type, tag, name) in [
        (5, Int32, IntValueTag, :intvalue),
        (4, Int16x2, IntValueTag, :intvalue),
        (3, Int8x4, IntValueTag, :intvalue),
        (2, Int4x8, IntValueTag, :intvalue),
        (5, Float32, FloatValueTag, :floatvalue),
        (4, Float16x2, FloatValueTag, :floatvalue),
        (4, BFloat16x2, BFloatValueTag, :bfloatvalue),
    ]
        value_index = Index{Physics,tag}(name, 1, 1 << bits)
        if value_index ∈ layout
            @assert layout[value_index] == SIMD(:simd, 1, 1 << bits)
            return type
        end
    end
    @assert false
end

################################################################################

export KernelSetup
struct KernelSetup
    num_threads::Int
    num_warps::Int
    num_blocks::Int
    num_blocks_per_sm::Int
    shmem_bytes::Int
end

const Code = Union{Expr,Number,Symbol}

# Remove line numbers. Line numbers are usually wrong because they
# point to this file, instead of the file where the code originates.
# See
# <https://discourse.julialang.org/t/code-generation-unnecessary-comment-lines-when-using-quote/398/2>
export clean_code
clean_code(expr) = expr
function clean_code(expr::Expr)
    head, args = expr.head, expr.args
    # Remove line number nodes (we cannot remove them from macro calls)
    if head ≢ :macrocall
        args = filter(arg -> !(arg isa LineNumberNode), args)
    end
    # Recursive calls
    args = clean_code.(args)
    # Coalesce nested blocks
    if head ≡ :block
        args = vcat([arg isa Expr && arg.head ≡ :block ? arg.args : [arg] for arg in args]...)
    end
    # Remove blocks with only one element
    head ≡ :block && length(args) == 1 && return args[1]
    return Expr(head, args...)
end
export clean_code

evaluate_partially(expr) = expr
function evaluate_partially(expr::Expr)
    head, args = expr.head, expr.args
    args = evaluate_partially.(expr.args)
    if head ≡ :call && length(args) == 3
        # Evaluate an expression
        if args[2] isa Number && args[3] isa Number
            args[1] ≡ :+ && return args[2] + args[3]
            args[1] ≡ :- && return args[2] - args[3]
            args[1] ≡ :* && return args[2] * args[3]
            args[1] ≡ :÷ && return args[2] ÷ args[3]
            args[1] ≡ :% && return args[2] % args[3]
            args[1] ≡ :& && return args[2] & args[3]
            args[1] ≡ :| && return args[2] | args[3]
            args[1] ≡ :⊻ && return args[2] ⊻ args[3]
        end
        # Handle cancellative elements
        args[1] ≡ :* && args[2] == 0 && return args[2]
        args[1] ≡ :* && args[3] == 0 && return args[3]
        args[1] ≡ :& && args[2] == 0 && return args[2]
        args[1] ≡ :& && args[3] == 0 && return args[3]
        # Remove neutral elements
        args[1] ≡ :+ && args[2] == 0 && return args[3]
        args[1] ≡ :+ && args[3] == 0 && return args[2]
        args[1] ≡ :- && args[3] == 0 && return args[2]
        args[1] ≡ :* && args[2] == 1 && return args[3]
        args[1] ≡ :* && args[3] == 1 && return args[2]
        args[1] ≡ :÷ && args[3] == 1 && return args[2]
        args[1] ≡ :| && args[2] == 0 && return args[3]
        args[1] ≡ :| && args[3] == 0 && return args[2]
        args[1] ≡ :⊻ && args[2] == 0 && return args[3]
        args[1] ≡ :⊻ && args[3] == 0 && return args[2]
    end
    return Expr(head, args...)
end

################################################################################

# Code generation

export Environment
struct Environment
    # Types of physical fields, so to say
    dict::Dict{Symbol,Layout{Physics,Machine}}
    # Values of indices, mainly from unrolled loops
    values::Dict{Symbol,Int32}
end
Environment() = Environment(Dict{Symbol,Layout{Physics,Machine}}(), Dict{Symbol,Int32}())

# TODO: Implement a nice interface to access values
Base.copy(env::Environment) = Environment(copy(env.dict), copy(env.values))
Base.getindex(env::Environment, var::Symbol) = env.dict[var]
Base.in(var::Symbol, env::Environment) = var ∈ keys(env.dict)
Base.iterate(env::Environment, state...) = iterate(env.dict, state...)
Base.setindex!(env::Environment, layout::Layout{Physics,Machine}, var::Symbol) = env.dict[var] = layout

export Emitter
struct Emitter
    kernel_setup::KernelSetup
    environment::Environment
    output_environment::Environment
    init_statements::Vector{Code}
    statements::Vector{Code}
end
Emitter(kernel_setup::KernelSetup) = Emitter(kernel_setup, Environment(), Environment(), Code[], Code[])

################################################################################

# Registers

struct State
    kernel_setup::KernelSetup
    # Register values
    dict::Dict{Symbol,Int32}
end
State(kernel_setup::KernelSetup) = State(kernel_setup, Dict{Symbol,Int32}())
Base.copy(state::State) = State(state.kernel_setup, copy(state.dict))

function register_name(name::Symbol, state::State)
    return Symbol(join([name; [string(r) * string(state.dict[r]) for r in sort!(collect(keys(state.dict)))]], "_"))
end

function loop_over_registers(f, emitter::Emitter, layout::Layout{Physics,Machine})
    # state = State(emitter.kernel_setup, emitter.environment.values)
    state = State(emitter.kernel_setup)
    registers = sort!(filter!(mach -> mach isa Register, collect(values(layout.dict))))
    function go(state::State, n::Int)
        if n == 0
            f(state)
        else
            reg = registers[n]
            newstate = copy(state)
            if reg.length > 1
                for r in 0:(reg.length - 1)
                    val = get(state.dict, reg.name, 0i32)
                    newstate.dict[reg.name] = val + reg.offset * r
                    go(newstate, n - 1)
                end
            end
        end
    end
    go(state, length(registers))
    return nothing
end

# TODO: use `LLVM.assume`
function assume_inrange(x, start, stop)
    start ≤ x < stop || IndexSpaces.unreachable()
    return x
end
function assume_inrange(x, start, step, stop)
    start ≤ x < stop && x % step == start || IndexSpaces.unreachable()
    return x
end

cuda_threadidx() = 0i32
cuda_warpidx() = 0i32
cuda_blockidx() = 0i32
CUDA.@device_override cuda_threadidx() = threadIdx().x - 1i32
CUDA.@device_override cuda_warpidx() = threadIdx().y - 1i32
CUDA.@device_override cuda_blockidx() = blockIdx().x - 1i32

indexvalue(::State, ::SIMD) = @assert false # needs to be handled by the caller
indexvalue(state::State, register::Register) = state.dict[register.name]::Code
function indexvalue(state::State, ::Thread)
    return :(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0i32, $(Int32(state.kernel_setup.num_threads))))::Code
end
function indexvalue(state::State, ::Warp)
    return :(IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0i32, $(Int32(state.kernel_setup.num_warps))))::Code
end
function indexvalue(state::State, ::Block)
    return :(IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0i32, $(Int32(state.kernel_setup.num_blocks))))::Code
end
function indexvalue(::State, loop::Loop)
    return :(IndexSpaces.assume_inrange($(loop.name), 0i32, $(Int32(loop.offset)), $(Int32(loop.offset * loop.length))))::Code
end
# indexvalue(state::State, unrolled_loop::UnrolledLoop) = state.dict[unrolled_loop.name]::Int32
indexvalue(::State, unrolled_loop::UnrolledLoop) = unrolled_loop.name::Code
indexvalue(::State, ::Shared) = @assert false
indexvalue(::State, ::Memory) = @assert false

function physics_values(state::State, reg_layout::Layout{Physics,Machine})
    vals = Dict{IndexTag,Code}()
    for (phys, mach) in reg_layout.dict
        mach isa SIMD && continue
        machtag = indextag(mach)
        machoff = Int32(mach.offset)
        machlen = Int32(mach.length)
        machval = indexvalue(state, mach)
        val = :(($machval ÷ $machoff) % $machlen)

        @assert !(phys isa SIMD)
        phystag = indextag(phys)
        physoff = Int32(phys.offset)
        # physlen = Int32(phys.length)
        physval = :($val * $physoff)
        oldphysval = get(vals, phystag, 0i32)
        physval = :($oldphysval + $physval)
        vals[phystag] = physval
    end
    return Dict{IndexTag,Code}(k => evaluate_partially(v) for (k, v) in vals)
end

function memory_index(reg_layout::Layout{Physics,Machine}, mem_layout::Layout{Physics,Machine}, vals::Dict{IndexTag,Code})
    # Ensure that SIMDTag layouts match
    for (phys, mach) in reg_layout.dict
        if mach isa SIMD
            phys ∈ keys(mem_layout.dict) ||
                throw(ArgumentError("$phys maps to SIMD bits in the register layout, but not in the machine layout"))
            @assert mem_layout[phys] == mach
        end
    end
    for (phys, mach) in mem_layout.dict
        if mach isa SIMD
            @assert reg_layout[phys] == mach
        end
    end

    is_shared = any(mach isa Shared for (phys, mach) in mem_layout.dict)
    is_memory = any(mach isa Memory for (phys, mach) in mem_layout.dict)
    @assert !(is_shared && is_memory)

    # addr = 0i32
    addrs = Code[]
    for (phys, mach) in mem_layout.dict
        mach isa SIMD && continue
        # Ensure that we are mapping to memory
        is_shared && mach::Union{Block,Shared,Loop,UnrolledLoop}
        is_memory && mach::Memory
        # Only memory addresses contribute
        !(mach isa Union{Shared,Memory}) && continue

        phystag = indextag(phys)
        physoff = Int32(phys.offset)
        physlen = Int32(phys.length)
        physval = vals[phystag]
        val = :(($physval ÷ $physoff) % $physlen)

        machoff = Int32(mach.offset)
        # machlen = Int32(mach.length)
        machval = :($val * $machoff)
        # addr = :($addr + $machval)
        push!(addrs, machval)
    end
    if length(addrs) == 0
        addr = 0i32
    elseif length(addrs) == 1
        addr = addrs[1]
    else
        addr = :(+($(addrs...)))
    end
    return evaluate_partially(addr)::Code
end

################################################################################

# Control flow

export trap!
function trap!(emitter::Emitter)
    push!(emitter.statements, :(IndexSpaces.cuda_trap()))
    return nothing
end

export block!
function block!(body!, emitter::Emitter)
    environment′ = copy(emitter.environment)

    emitter′ = Emitter(emitter.kernel_setup, environment′, Environment(), Code[], Code[])
    body!(emitter′)

    for (k, v) in emitter′.output_environment
        @assert k ∉ emitter.environment
        emitter.environment[k] = v
    end

    push!(
        emitter.statements,
        quote
            $(emitter′.init_statements...)
            let
                $(emitter′.statements...)
            end
        end,
    )

    return nothing
end

export if!
function if!(body!, emitter::Emitter, cond::Code)
    environment′ = copy(emitter.environment)

    emitter′ = Emitter(emitter.kernel_setup, environment′, Environment(), Code[], Code[])
    body!(emitter′)

    for (k, v) in emitter′.output_environment
        @assert k ∉ emitter.environment
        emitter.environment[k] = v
    end

    push!(
        emitter.statements,
        quote
            $(emitter′.init_statements...)
            if $(cond)
                $(emitter′.statements...)
            end
        end,
    )

    return nothing
end

export loop!
function loop!(body!, emitter::Emitter, layout::Pair{<:Index{Physics},Loop})
    index, loop = layout

    environment′ = copy(emitter.environment)

    # # Add loop index to all layouts
    # for (name, layout) in environment′
    #     layout = copy(layout)
    #     @assert index ∉ layout
    #     layout[index] = loop
    #     environment′[name] = layout
    # end

    emitter′ = Emitter(emitter.kernel_setup, environment′, Environment(), Code[], Code[])
    body!(emitter′)

    for (k, v) in emitter′.output_environment
        @assert k ∉ emitter.environment
        emitter.environment[k] = v
    end

    push!(
        emitter.statements,
        quote
            $(emitter′.init_statements...)
            for $(loop.name) in ($(Int32(0))):($(Int32(loop.offset))):($(Int32(loop.offset * loop.length - 1)))
                $(emitter′.statements...)
            end
        end,
    )

    return nothing
end

export unrolled_loop!

# function unrolled_loop!(body!, emitter::Emitter, layout::Pair{<:Index{Physics},Loop})
#     index, loop = layout
# 
#     environment′ = copy(emitter.environment)
#     @assert index.name ∉ environment′   # (see below for a fix)
#     environment′[index.name] = Layout{Physics,Machine}(Dict(index => loop))
# 
#     emitter′ = Emitter(emitter.kernel_setup, environment′, Environment(), Code[], Code[])
#     body!(emitter′)
# 
#     for (k, v) in emitter′.output_environment
#         @assert k ∉ keys(emitter.environment)
#         emitter.environment[k] = v
#     end
# 
#     push!(
#         emitter.statements,
#         quote
#             $(emitter′.init_statements...)
#         end,
#     )
#     for i in Int32(0):Int32(loop.offset):Int32(loop.offset * loop.length - 1)
#         push!(
#             emitter.statements,
#             quote
#                 let
#                     $(loop.name) = $i
#                     $(emitter′.statements...)
#                 end
#             end,
#         )
#     end
# 
#     return nothing
# end

function unrolled_loop!(body!, emitter::Emitter, layout::Pair{<:Index{Physics},UnrolledLoop})
    index, unrolled_loop = layout

    for i in Int32(0):Int32(unrolled_loop.offset):Int32(unrolled_loop.offset * unrolled_loop.length - 1)
        environment′ = copy(emitter.environment)

        # # Add loop index to all layouts
        # for (name, layout) in environment′
        #     layout = copy(layout)
        #     # The loop index may already exist. In this case, remove
        #     # it, assuming that the loop "focusses" on a particular
        #     # index value.
        #     if index ∈ layout
        #         delete!(layout, index)
        #     end
        #     @assert index ∉ layout
        #     layout[index] = unrolled_loop
        #     environment′[name] = layout
        # end

        @assert unrolled_loop.name ∉ keys(environment′.values)
        environment′.values[unrolled_loop.name] = i

        emitter′ = Emitter(emitter.kernel_setup, environment′, Environment(), Code[], Code[])

        body!(emitter′)

        @assert isempty(emitter′.init_statements)
        @assert isempty(emitter′.output_environment)
        push!(
            emitter.statements,
            quote
                let
                    $(unrolled_loop.name) = $i
                    $(emitter′.statements...)
                end
            end,
        )
    end

    return nothing
end

################################################################################

# Thread synchronization

cuda_trap() = nothing
CUDA.@device_override cuda_trap() = Base.llvmcall("trap;", Tuple{}, Tuple{})

cuda_sync_threads() = nothing
CUDA.@device_override cuda_sync_threads() = sync_threads()

export sync_threads!
function sync_threads!(emitter::Emitter)
    push!(emitter.statements, :(IndexSpaces.cuda_sync_threads()))
    return nothing
end

################################################################################

# Memory access

# Address space 1 is global, 3 is shared
function unsafe_load4_global(ptr::Core.LLVMPtr{Int32,1})
    return Base.llvmcall(
        """
           %ptr = bitcast i8 addrspace(1)* %0 to [4 x i32] addrspace(1)*
           %val = load [4 x i32], [4 x i32] addrspace(1)* %ptr, align 16
           ret [4 x i32] %val
        """,
        NTuple{4,Int32},
        Tuple{Core.LLVMPtr{Int32,1}},
        ptr,
    )
end
function unsafe_load4_global(ptr::Core.LLVMPtr{Int32,3})
    return Base.llvmcall(
        """
           %ptr = bitcast i8 addrspace(3)* %0 to [4 x i32] addrspace(3)*
           %val = load [4 x i32], [4 x i32] addrspace(3)* %ptr, align 16
           ret [4 x i32] %val
        """,
        NTuple{4,Int32},
        Tuple{Core.LLVMPtr{Int32,3}},
        ptr,
    )
end
unsafe_load4_global(arr::CuDeviceArray{Int32}, idx::Integer) = unsafe_load4_global(pointer(arr, idx))
function unsafe_load4_global(arr::CuDeviceArray{T}, idx::Integer) where {T}
    @assert sizeof(T) == sizeof(Int32)
    res = unsafe_load4_global(reinterpret(Int32, arr), idx)::NTuple{4,Int32}
    # return ntuple(n -> reinterpret(T, res[n]), 4)::NTuple{4,T}
    return ntuple(n -> T(res[n] % UInt32), 4)::NTuple{4,T}
end

export load!
function load!(
    emitter::Emitter,
    reg::Pair{Symbol,Layout{Physics,Machine}},
    mem::Pair{Symbol,Layout{Physics,Machine}};
    align::Int=4,
    postprocess=identity,
)
    reg_var, reg_layout = reg
    mem_var, mem_layout = mem
    # reg_var may or may not already exist
    # @assert reg_var ∉ emitter.environment
    emitter.environment[reg_var] = reg_layout

    if align == 4
        loop_over_registers(emitter, reg_layout) do state
            reg_name = register_name(reg_var, state)
            vals = physics_values(state, reg_layout)
            addr = memory_index(reg_layout, mem_layout, vals)
            push!(emitter.statements, :($reg_name = $mem_var[$(postprocess(addr)) + 0x1]))
        end
    elseif align == 16
        # Find registers with strides 1 and 2
        # TODO: Better error message if not accessing global memory
        phys0 = inv(mem_layout)[Memory(:memory, 1, 2)]
        register0 = reg_layout[phys0]::Register
        phys1 = inv(mem_layout)[Memory(:memory, 2, 2)]
        register1 = reg_layout[phys1]::Register
        tmp_layout = copy(reg_layout)
        delete!(tmp_layout, phys0)
        delete!(tmp_layout, phys1)
        loop_over_registers(emitter, tmp_layout) do state
            state0 = copy(state)
            state1 = copy(state)
            state2 = copy(state)
            state3 = copy(state)
            state0.dict[register0.name] = get(state0.dict, register0.name, Int32(0)) + Int32(0 * register0.offset)
            state1.dict[register0.name] = get(state1.dict, register0.name, Int32(0)) + Int32(1 * register0.offset)
            state2.dict[register0.name] = get(state2.dict, register0.name, Int32(0)) + Int32(0 * register0.offset)
            state3.dict[register0.name] = get(state3.dict, register0.name, Int32(0)) + Int32(1 * register0.offset)
            state0.dict[register1.name] = get(state0.dict, register1.name, Int32(0)) + Int32(0 * register1.offset)
            state1.dict[register1.name] = get(state1.dict, register1.name, Int32(0)) + Int32(0 * register1.offset)
            state2.dict[register1.name] = get(state2.dict, register1.name, Int32(0)) + Int32(1 * register1.offset)
            state3.dict[register1.name] = get(state3.dict, register1.name, Int32(0)) + Int32(1 * register1.offset)
            reg0_name = register_name(reg_var, state0)
            reg1_name = register_name(reg_var, state1)
            reg2_name = register_name(reg_var, state2)
            reg3_name = register_name(reg_var, state3)
            vals = physics_values(state0, reg_layout)
            addr = memory_index(reg_layout, mem_layout, vals)
            push!(
                emitter.statements,
                :(
                    ($reg0_name, $reg1_name, $reg2_name, $reg3_name) = IndexSpaces.unsafe_load4_global(
                        $mem_var, $(postprocess(addr)) + 1i32
                    )
                ),
            )
        end
    else
        @assert false
    end

    return nothing
end

export unsafe_store4_global!
# Address space 1 is global, 3 is shared
function unsafe_store4_global!(ptr::Core.LLVMPtr{Int32,1}, val::NTuple{4,Int32})
    return Base.llvmcall(
        """
           %ptr = bitcast i8 addrspace(1)* %0 to [4 x i32] addrspace(1)*
           store [4 x i32] %1, [4 x i32] addrspace(1)* %ptr, align 16
           ret void
        """,
        Nothing,
        Tuple{Core.LLVMPtr{Int32,1},NTuple{4,Int32}},
        ptr,
        val,
    )
end
function unsafe_store4_global!(ptr::Core.LLVMPtr{Int32,3}, val::NTuple{4,Int32})
    return Base.llvmcall(
        """
           %ptr = bitcast i8 addrspace(3)* %0 to [4 x i32] addrspace(3)*
           store [4 x i32] %1, [4 x i32] addrspace(3)* %ptr, align 16
           ret void
        """,
        Nothing,
        Tuple{Core.LLVMPtr{Int32,3},NTuple{4,Int32}},
        ptr,
        val,
    )
end
function unsafe_store4_global!(arr::CuDeviceArray{Int32}, idx::Integer, val::NTuple{4,Int32})
    return unsafe_store4_global!(pointer(arr, idx), val)
end
function unsafe_store4_global!(arr::CuDeviceArray{T}, idx::Integer, val::NTuple{4,T}) where {T}
    @assert sizeof(T) == sizeof(Int32)
    val′ = ntuple(n -> val[n].val % Int32, 4)::NTuple{4,Int32}
    return unsafe_store4_global!(reinterpret(Int32, arr), idx, val′)
end

export store!
function store!(
    emitter::Emitter,
    mem::Pair{Symbol,Layout{Physics,Machine}},
    reg_var::Symbol;
    align::Int=4,
    condition=Returns(true),
    offset::Code=0,
    postprocess=identity,
)
    mem_var, mem_layout = mem
    reg_layout = emitter.environment[reg_var]

    if align == 4
        loop_over_registers(emitter, reg_layout) do state
            reg_name = register_name(reg_var, state)
            vals = physics_values(state, reg_layout)
            addr = memory_index(reg_layout, mem_layout, vals)
            cond = condition(state)
            push!(
                emitter.statements,
                quote
                    if $cond
                        $mem_var[$(postprocess(:($addr + $offset))) + 0x1] = $reg_name
                    end
                end,
            )
        end
    elseif align == 16
        # Find registers with strides 1 and 2
        # TODO: Better error message if not accessing global memory
        phys0 = inv(mem_layout)[Memory(:memory, 1, 2)]
        register0 = reg_layout[phys0]::Register
        phys1 = inv(mem_layout)[Memory(:memory, 2, 2)]
        register1 = reg_layout[phys1]::Register
        tmp_layout = copy(reg_layout)
        delete!(tmp_layout, phys0)
        delete!(tmp_layout, phys1)
        loop_over_registers(emitter, tmp_layout) do state
            state0 = copy(state)
            state1 = copy(state)
            state2 = copy(state)
            state3 = copy(state)
            state0.dict[register0.name] = get(state0.dict, register0.name, Int32(0)) + Int32(0 * register0.offset)
            state1.dict[register0.name] = get(state1.dict, register0.name, Int32(0)) + Int32(1 * register0.offset)
            state2.dict[register0.name] = get(state2.dict, register0.name, Int32(0)) + Int32(0 * register0.offset)
            state3.dict[register0.name] = get(state3.dict, register0.name, Int32(0)) + Int32(1 * register0.offset)
            state0.dict[register1.name] = get(state0.dict, register1.name, Int32(0)) + Int32(0 * register1.offset)
            state1.dict[register1.name] = get(state1.dict, register1.name, Int32(0)) + Int32(0 * register1.offset)
            state2.dict[register1.name] = get(state2.dict, register1.name, Int32(0)) + Int32(1 * register1.offset)
            state3.dict[register1.name] = get(state3.dict, register1.name, Int32(0)) + Int32(1 * register1.offset)
            reg0_name = register_name(reg_var, state0)
            reg1_name = register_name(reg_var, state1)
            reg2_name = register_name(reg_var, state2)
            reg3_name = register_name(reg_var, state3)
            vals = physics_values(state0, reg_layout)
            addr = memory_index(reg_layout, mem_layout, vals)
            cond = condition(state)
            push!(
                emitter.statements,
                quote
                    if $cond
                        IndexSpaces.unsafe_store4_global!(
                            $mem_var, $(postprocess(:($addr + $offset))) + 0x1, ($reg0_name, $reg1_name, $reg2_name, $reg3_name)
                        )
                    end
                end,
            )
        end
    else
        @assert false
    end

    return nothing
end

################################################################################

# Layout rearrangements

function CUDA.shfl_sync(threadmask::UInt32, val::T, thread::UInt32) where {T<:Union{Int4x8,Int8x4,Int16x2,Float16x2,BFloat16x2}}
    return T(shfl_sync(threadmask, val.val, thread))
end

cuda_shfl_sync(threadmask, val, thread) = val
CUDA.@device_override cuda_shfl_sync(threadmask, val, thread) = shfl_sync(threadmask, val, thread % UInt32 + 0x1)

function Base.broadcast!(emitter::Emitter, res::Symbol, var::Symbol, index1_index2::Pair{<:Index{Physics},<:Index{Physics}})
    index1, index2 = index1_index2
    var_layout = emitter.environment[var]
    broadcast!(emitter, res, var, var_layout[index1] => var_layout[index2])
    return nothing
end

function Base.broadcast!(emitter::Emitter, res::Symbol, var::Symbol, register_thread::Pair{<:Register,<:Thread})
    var_layout = emitter.environment[var]

    register, thread = register_thread
    @assert thread.length == register.length

    thread_phys = inv(var_layout)[thread]

    res_layout = copy(var_layout)
    delete!(res_layout, thread_phys)
    res_layout[thread_phys] = register
    emitter.environment[res] = res_layout

    loop_over_registers(emitter, var_layout) do state
        var_name = register_name(var, state)
        for i in 0:(thread.length - 1)
            state0 = copy(state)
            state0.dict[register.name] = get(state0.dict, register.name, Int32(0)) + Int32(i * register.offset)
            res0_name = register_name(res, state0)
            push!(
                emitter.statements,
                quote
                    $res0_name = IndexSpaces.cuda_shfl_sync(0xffffffff, $var_name, $i)
                end,
            )
        end
        nothing
    end

    return nothing
end

function Base.permute!(emitter::Emitter, res::Symbol, var::Symbol, index1::Index{Physics}, index2::Index{Physics})
    @assert index1 ≠ index2
    var_layout = emitter.environment[var]
    if var_layout[index1] isa Register
        permute!(emitter, res, var, var_layout[index1], var_layout[index2])
    else
        permute!(emitter, res, var, var_layout[index2], var_layout[index1])
    end
    return nothing
end

function Base.permute!(emitter::Emitter, res::Symbol, var::Symbol, index1::Index{Physics}, index2::Index{Machine})
    @assert index1 ≠ index2
    var_layout = emitter.environment[var]
    if var_layout[index1] isa Register
        permute!(emitter, res, var, var_layout[index1], index2)
    else
        permute!(emitter, res, var, index2, var_layout[index1])
    end
    return nothing
end

get_lo4(r0::Int4x8, r1::Int4x8) = Int4x8(bitifelse(0x0f0f0f0f, r0.val << 0x0, r1.val << 0x4))
get_hi4(r0::Int4x8, r1::Int4x8) = Int4x8(bitifelse(0x0f0f0f0f, r0.val >> 0x4, r1.val >> 0x0))
get_lo8(r0::T, r1::T) where {T<:Union{Int4x8,Int8x4}} = T(prmt(r0.val, r1.val, 0x6240))
get_hi8(r0::T, r1::T) where {T<:Union{Int4x8,Int8x4}} = T(prmt(r0.val, r1.val, 0x7351))
get_lo16(r0::T, r1::T) where {T<:Union{Int4x8,Int8x4,Int16x2,Float16x2}} = T(prmt(r0.val, r1.val, 0x5410))
get_hi16(r0::T, r1::T) where {T<:Union{Int4x8,Int8x4,Int16x2,Float16x2}} = T(prmt(r0.val, r1.val, 0x7632))

function Base.permute!(emitter::Emitter, res::Symbol, var::Symbol, register::Register, simd::SIMD)
    var_layout = emitter.environment[var]

    # res may or may not already exist
    # @assert res ∉ emitter.environment

    @assert register.length == 2
    register_phys = inv(var_layout)[register]

    @assert simd.length == 2
    @assert ispow2(simd.offset)
    simd_bit = trailing_zeros(simd.offset)
    @assert simd.offset == 1 << simd_bit
    simd_phys = inv(var_layout)[simd]

    tmp_layout = copy(var_layout)
    delete!(tmp_layout, register_phys)
    delete!(tmp_layout, simd_phys)

    res_layout = copy(tmp_layout)
    res_layout[register_phys] = simd
    res_layout[simd_phys] = register

    emitter.environment[res] = res_layout

    if simd_bit == 2
        get_lo = :(IndexSpaces.get_lo4)
        get_hi = :(IndexSpaces.get_hi4)
    elseif simd_bit == 3
        get_lo = :(IndexSpaces.get_lo8)
        get_hi = :(IndexSpaces.get_hi8)
    elseif simd_bit == 4
        get_lo = :(IndexSpaces.get_lo16)
        get_hi = :(IndexSpaces.get_hi16)
    else
        @assert false
    end

    loop_over_registers(emitter, tmp_layout) do state
        state0 = copy(state)
        state1 = copy(state)
        state0.dict[register.name] = get(state0.dict, register.name, Int32(0)) + Int32(0 * register.offset)
        state1.dict[register.name] = get(state1.dict, register.name, Int32(0)) + Int32(1 * register.offset)
        res0_name = register_name(res, state0)
        res1_name = register_name(res, state1)
        var0_name = register_name(var, state0)
        var1_name = register_name(var, state1)
        push!(emitter.statements, :(($res0_name, $res1_name) = ($get_lo($var0_name, $var1_name), $get_hi($var0_name, $var1_name))))
    end

    return nothing
end

function CUDA.shfl_xor_sync(threadmask::UInt32, val::T, mask::UInt32) where {T<:Union{Int4x8,Int8x4,Int16x2,Float16x2,BFloat16x2}}
    return T(shfl_xor_sync(threadmask, val.val, mask))
end

cuda_shfl_xor_sync(threadmask, val, mask) = val
CUDA.@device_override cuda_shfl_xor_sync(threadmask, val, mask) = shfl_xor_sync(threadmask, val, mask)

function Base.permute!(emitter::Emitter, res::Symbol, var::Symbol, register::Register, thread::Thread)
    var_layout = emitter.environment[var]

    # res may or may not already exist
    # @assert res ∉ emitter.environment

    @assert register.length == 2
    register_phys = inv(var_layout)[register]

    @assert thread.length == 2
    @assert ispow2(thread.offset)
    thread_bit = trailing_zeros(thread.offset)
    @assert thread.offset == 1 << thread_bit
    thread_phys = inv(var_layout)[thread]

    tmp_layout = copy(var_layout)
    delete!(tmp_layout, register_phys)
    delete!(tmp_layout, thread_phys)

    res_layout = copy(tmp_layout)
    res_layout[register_phys] = thread
    res_layout[thread_phys] = register

    emitter.environment[res] = res_layout

    thread_mask = 1u32 << thread_bit

    push!(
        emitter.statements,
        quote
            is_lo_thread = IndexSpaces.cuda_threadidx() & $thread_mask == 0x0
        end,
    )
    loop_over_registers(emitter, tmp_layout) do state
        state0 = copy(state)
        state1 = copy(state)
        state0.dict[register.name] = get(state0.dict, register.name, Int32(0)) + Int32(0 * register.offset)
        state1.dict[register.name] = get(state1.dict, register.name, Int32(0)) + Int32(1 * register.offset)
        res0_name = register_name(res, state0)
        res1_name = register_name(res, state1)
        var0_name = register_name(var, state0)
        var1_name = register_name(var, state1)
        push!(
            emitter.statements,
            quote
                ($res0_name, $res1_name) = let
                    src = is_lo_thread ? $var1_name : $var0_name
                    dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, $thread_mask)
                    is_lo_thread ? ($var0_name, dst) : (dst, $var1_name)
                end
            end,
        )
    end

    return nothing
end

# Convert `Int4x8` to `NTuple{2,Int8x4}`, but skip shifting the high nibbles and skip removing the offset encoding.
# This returns `n + 8` for the low values (even indices) and  `16 * (n + 8)` for the high values (odd indices).
function int4x8_to_2int8x4_unshifted_withoffset(a::Int4x8)
    a_lo = lop3(a.val, 0x08080808, 0x0f0f0f0f, CUDASIMDTypes.xor_and_lut)
    a_hi = lop3(a.val, 0x80808080, 0xf0f0f0f0, CUDASIMDTypes.xor_and_lut)
    return (Int8x4(a_lo), Int8x4(a_hi))::NTuple{2,Int8x4}
end

export widen!
function widen!(
    emitter::Emitter,
    res::Symbol,
    var::Symbol,
    simd_register::Pair{SIMD,Register};
    newtype::Union{Nothing,Type}=nothing,
    unshifted_withoffset::Bool=false,
)
    simd, register = simd_register

    var_layout = emitter.environment[var]
    var_value = get_value_index(var_layout)::Index{Physics}
    @assert simd.length == 2
    @assert ispow2(simd.offset)

    # res may or may not already exist
    # @assert res ∉ emitter.environment

    # Ensure that the new bits are the lowest non-value bits
    @assert simd.offset == var_value.length
    simd_phys = inv(var_layout)[simd]

    @assert register.length == simd.length

    tmp_layout = copy(var_layout)
    delete!(tmp_layout, var_value)
    delete!(tmp_layout, simd_phys)

    res_layout = copy(tmp_layout)
    res_layout[simd_phys] = register

    @assert newtype ≡ nothing || newtype <: Index{Physics}
    res_tag = newtype ≡ nothing ? indextag(var_value) : indextag(newtype)
    res_value_name = get(
        Dict(IntValue => :intvalue, FloatValue => :floatvalue, BFloatValue => :bfloatvalue), newtype, var_value.name
    )
    res_value = Index{Physics,res_tag}(res_value_name, var_value.offset, var_value.length * simd.length)

    res_layout[res_value] = SIMD(:simd, var_value.offset, var_value.length * simd.length)

    emitter.environment[res] = res_layout

    loop_over_registers(emitter, tmp_layout) do state
        var_name = register_name(var, state)
        states = State[]
        res_names = Symbol[]
        for i in 0:(register.offset):(register.offset * register.length - 1)
            state′ = copy(state)
            state′.dict[register.name] = get(state′.dict, register.name, Int32(0)) + Int32(i)
            res_name′ = register_name(res, state′)
            push!(states, state′)
            push!(res_names, res_name′)
        end
        if indextag(var_value) == indextag(res_value) == IntValueTag
            if var_value.length == 4 && res_value.length == 8
                if unshifted_withoffset
                    stmt = :(($(res_names...),) = IndexSpaces.int4x8_to_2int8x4_unshifted_withoffset($var_name))
                else
                    stmt = :(($(res_names...),) = convert(NTuple{2,Int8x4}, $var_name))
                end
            elseif var_value.length == 8 && res_value.length == 16
                stmt = :(($(res_names...),) = convert(NTuple{2,Int16x2}, $var_name))
            elseif var_value.length == 16 && res_value.length == 32
                stmt = :(($(res_names...),) = convert(NTuple{2,Int32}, $var_name))
            else
                @assert false
            end
        elseif indextag(var_value) == IntValueTag && indextag(res_value) == FloatValueTag
            if var_value.length == 8 && res_value.length == 16
                stmt = :(($(res_names...),) = convert(NTuple{2,Float16x2}, $var_name))
            elseif var_value.length == 16 && res_value.length == 32
                stmt = :(($(res_names...),) = convert(NTuple{2,Float32}, $var_name))
            else
                @assert false
            end
        else
            # TODO: Implement Float->Float, Float->Int, BFloat
            @assert false
        end
        push!(emitter.statements, stmt)
    end

    return nothing
end

export widen2!
function widen2!(
    emitter::Emitter,
    res::Symbol,
    var::Symbol,
    simd_register1::Pair{SIMD,Register},
    simd_register2::Pair{SIMD,Register};
    newtype::Union{Nothing,Type}=nothing,
    unshifted_withoffset::Bool=false,
)
    simd1, register1 = simd_register1
    simd2, register2 = simd_register2

    var_layout = emitter.environment[var]
    var_value = get_value_index(var_layout)::Index{Physics}
    @assert simd1.length == 2 && simd2.length == 2
    @assert ispow2(simd1.offset) && ispow2(simd2.offset)

    # res may or may not already exist
    # @assert res ∉ emitter.environment

    # Ensure that the new bits are the lowest non-value bits
    @assert simd1.offset == var_value.length
    @assert simd2.offset == var_value.length * simd1.length
    simd1_phys = inv(var_layout)[simd1]
    simd2_phys = inv(var_layout)[simd2]

    @assert register1.length == simd1.length
    @assert register2.length == simd2.length

    tmp_layout = copy(var_layout)
    delete!(tmp_layout, var_value)
    delete!(tmp_layout, simd1_phys)
    delete!(tmp_layout, simd2_phys)

    res_layout = copy(tmp_layout)
    res_layout[simd1_phys] = register1
    res_layout[simd2_phys] = register2

    @assert newtype ≡ nothing || newtype <: Index{Physics}
    res_tag = newtype ≡ nothing ? indextag(var_value) : indextag(newtype)
    res_value_name = get(
        Dict(IntValue => :intvalue, FloatValue => :floatvalue, BFloatValue => :bfloatvalue), newtype, var_value.name
    )
    res_value = Index{Physics,res_tag}(res_value_name, var_value.offset, var_value.length * simd1.length * simd2.length)

    res_layout[res_value] = SIMD(:simd, var_value.offset, var_value.length * simd1.length * simd2.length)

    emitter.environment[res] = res_layout

    loop_over_registers(emitter, tmp_layout) do state
        var_name = register_name(var, state)
        states = State[]
        res_names = Symbol[]
        for j in 0:(register2.offset):(register2.offset * register2.length - 1)
            for i in 0:(register1.offset):(register1.offset * register1.length - 1)
                state′ = copy(state)
                state′.dict[register1.name] = get(state′.dict, register1.name, Int32(0)) + Int32(i)
                state′.dict[register2.name] = get(state′.dict, register2.name, Int32(0)) + Int32(j)
                res_name′ = register_name(res, state′)
                push!(states, state′)
                push!(res_names, res_name′)
            end
        end
        if indextag(var_value) == indextag(res_value) == IntValueTag
            if var_value.length == 4 && res_value.length == 16
                stmt = :(($(res_names...),) = convert(NTuple{4,Int16x2}, $var_name))
            elseif var_value.length == 8 && res_value.length == 32
                stmt = :(($(res_names...),) = convert(NTuple{4,Int32}, $var_name))
            else
                @assert false
            end
        elseif indextag(var_value) == IntValueTag && indextag(res_value) == FloatValueTag
            if var_value.length == 4 && res_value.length == 16
                stmt = :(($(res_names...),) = convert(NTuple{4,Float16x2}, $var_name))
            elseif var_value.length == 8 && res_value.length == 32
                stmt = :(($(res_names...),) = convert(NTuple{4,Float32}, $var_name))
            else
                @show var_value res_value
                @assert false
            end
        else
            # TODO: Implement Float->Int, BFloat
            @assert false
        end
        push!(emitter.statements, stmt)
    end

    return nothing
end

export narrow!
function narrow!(emitter::Emitter, res::Symbol, var::Symbol, register_simd::Pair{Register,SIMD})
    register, simd = register_simd

    var_layout = emitter.environment[var]

    # res may or may not already exist
    # @assert res ∉ emitter.environment

    @assert register.length == 2
    register_phys = inv(var_layout)[register]

    @assert simd.length == 2
    @assert ispow2(simd.offset)
    simd_bit = trailing_zeros(simd.offset)
    @assert simd.offset == 1 << simd_bit

    tmp_layout = copy(var_layout)
    delete!(tmp_layout, register_phys)

    res_layout = copy(tmp_layout)
    inv_res_layout = inv(res_layout)
    value = inv_res_layout[SIMD(:simd, 1, 2)]
    value_tag = indextag(value)::ValueTag
    delete!(res_layout, Index{Physics,value_tag}(value.name, simd.offset, simd.length))
    res_layout[register_phys] = simd

    emitter.environment[res] = res_layout

    # inv_res_layout = inv(res_layout)
    # value = inv_res_layout[SIMD(:simd, 1, 2)]
    # value_tag = indextag(value)
    # @assert value_tag isa ValueTag

    loop_over_registers(emitter, tmp_layout) do state
        state0 = copy(state)
        state1 = copy(state)
        state0.dict[register.name] = get(state0.dict, register.name, 0i32) + Int32(0 * register.offset)
        state1.dict[register.name] = get(state1.dict, register.name, 0i32) + Int32(1 * register.offset)
        res_name = register_name(res, state)
        var0_name = register_name(var, state0)
        var1_name = register_name(var, state1)
        if value_tag == IntValueTag && simd_bit == 2
            stmt = :($res_name = Int4x8(($var0_name, $var1_name)))
        elseif value_tag == IntValueTag && simd_bit == 3
            stmt = :($res_name = Int8x4(($var0_name, $var1_name)))
        elseif value_tag == IntValueTag && simd_bit == 4
            stmt = :($res_name = Int16x2(($var0_name, $var1_name)))
        elseif value_tag == FloatValueTag && simd_bit == 4
            stmt = :($res_name = Float16x2(($var0_name, $var1_name)))
        elseif value_tag == BFloatValueTag && simd_bit == 4
            stmt = :($res_name = BFloat16x2(($var0_name, $var1_name)))
        else
            @assert false
        end
        push!(emitter.statements, stmt)
    end

    return nothing
end

export narrow2!
function narrow2!(
    emitter::Emitter,
    res::Symbol,
    var::Symbol,
    register_simd1::Pair{Register,SIMD},
    register_simd2::Pair{Register,SIMD};
    newtype::Union{Nothing,Type}=nothing,
)
    register1, simd1 = register_simd1
    register2, simd2 = register_simd2

    var_layout = emitter.environment[var]
    var_value = get_value_index(var_layout)::Index{Physics}

    # res may or may not already exist
    # @assert res ∉ emitter.environment

    @assert register1.length == 2
    @assert register2.length == 2
    @assert ispow2(register1.offset)
    @assert ispow2(register2.offset)
    register1_bit = trailing_zeros(register1.offset)
    register2_bit = trailing_zeros(register2.offset)
    @assert register1.offset == 1 << register1_bit
    @assert register2.offset == 1 << register2_bit
    register1_phys = inv(var_layout)[register1]
    register2_phys = inv(var_layout)[register2]

    @assert simd1.length == 2
    @assert simd2.length == 2
    @assert ispow2(simd1.offset)
    @assert ispow2(simd2.offset)
    simd1_bit = trailing_zeros(simd1.offset)
    simd2_bit = trailing_zeros(simd2.offset)
    @assert simd1.offset == 1 << simd1_bit
    @assert simd2.offset == 1 << simd2_bit

    tmp_layout = copy(var_layout)
    delete!(tmp_layout, register1_phys)
    delete!(tmp_layout, register2_phys)

    res_layout = copy(tmp_layout)
    inv_res_layout = inv(res_layout)
    value = inv_res_layout[SIMD(:simd, 1, 2)]
    value_tag = indextag(value)::ValueTag
    # TODO: Generalize this; we could handle other tags as well
    @assert value_tag == FloatValueTag
    @assert newtype <: Index{Physics}
    @assert indextag(newtype) == IntValueTag
    @assert Index{Physics,value_tag}(value.name, simd1.offset, simd1.length) ∈ res_layout
    @assert Index{Physics,value_tag}(value.name, simd2.offset, simd2.length) ∈ res_layout
    delete!(res_layout, var_value)
    delete!(res_layout, Index{Physics,value_tag}(value.name, simd1.offset, simd1.length))
    delete!(res_layout, Index{Physics,value_tag}(value.name, simd2.offset, simd2.length))
    res_tag = newtype ≡ nothing ? indextag(var_value) : indextag(newtype)
    res_value_name = get(
        Dict(IntValue => :intvalue, FloatValue => :floatvalue, BFloatValue => :bfloatvalue), newtype, var_value.name
    )
    res_value = Index{Physics,res_tag}(res_value_name, var_value.offset, var_value.length ÷ simd1.length ÷ simd2.length)
    res_layout[res_value] = SIMD(:simd, var_value.offset, var_value.length ÷ simd1.length ÷ simd2.length)
    res_layout[register1_phys] = simd1
    res_layout[register2_phys] = simd2

    emitter.environment[res] = res_layout

    # TODO: Generalize this; we could handle (3, 4) as well
    @assert simd1_bit == 2
    @assert simd2_bit == 3

    loop_over_registers(emitter, tmp_layout) do state
        state0 = copy(state)
        state1 = copy(state)
        state2 = copy(state)
        state3 = copy(state)
        state0.dict[register1.name] = get(state0.dict, register1.name, Int32(0)) + Int32(0 * register1.offset)
        state1.dict[register1.name] = get(state1.dict, register1.name, Int32(0)) + Int32(1 * register1.offset)
        state2.dict[register1.name] = get(state2.dict, register1.name, Int32(0)) + Int32(0 * register1.offset)
        state3.dict[register1.name] = get(state3.dict, register1.name, Int32(0)) + Int32(1 * register1.offset)
        state0.dict[register2.name] = get(state0.dict, register2.name, Int32(0)) + Int32(0 * register2.offset)
        state1.dict[register2.name] = get(state1.dict, register2.name, Int32(0)) + Int32(0 * register2.offset)
        state2.dict[register2.name] = get(state2.dict, register2.name, Int32(0)) + Int32(1 * register2.offset)
        state3.dict[register2.name] = get(state3.dict, register2.name, Int32(0)) + Int32(1 * register2.offset)
        res_name = register_name(res, state)
        var0_name = register_name(var, state0)
        var1_name = register_name(var, state1)
        var2_name = register_name(var, state2)
        var3_name = register_name(var, state3)
        push!(emitter.statements, :($res_name = Int4x8(($var0_name, $var1_name, $var2_name, $var3_name))))
    end

    return nothing
end

export narrow3!
function narrow3!(
    emitter::Emitter,
    res::Symbol,
    var::Symbol,
    register_simd1::Pair{Register,SIMD},
    register_simd2::Pair{Register,SIMD},
    register_simd3::Pair{Register,SIMD},
)
    register1, simd1 = register_simd1
    register2, simd2 = register_simd2
    register3, simd3 = register_simd3

    var_layout = emitter.environment[var]

    # res may or may not already exist
    # @assert res ∉ emitter.environment

    @assert register1.length == 2
    @assert register2.length == 2
    @assert register3.length == 2
    @assert ispow2(register1.offset)
    @assert ispow2(register2.offset)
    @assert ispow2(register3.offset)
    register1_bit = trailing_zeros(register1.offset)
    register2_bit = trailing_zeros(register2.offset)
    register3_bit = trailing_zeros(register3.offset)
    @assert register1.offset == 1 << register1_bit
    @assert register2.offset == 1 << register2_bit
    @assert register3.offset == 1 << register3_bit
    register1_phys = inv(var_layout)[register1]
    register2_phys = inv(var_layout)[register2]
    register3_phys = inv(var_layout)[register3]

    @assert simd1.length == 2
    @assert simd2.length == 2
    @assert simd3.length == 2
    @assert ispow2(simd1.offset)
    @assert ispow2(simd2.offset)
    @assert ispow2(simd3.offset)
    simd1_bit = trailing_zeros(simd1.offset)
    simd2_bit = trailing_zeros(simd2.offset)
    simd3_bit = trailing_zeros(simd3.offset)
    @assert simd1.offset == 1 << simd1_bit
    @assert simd2.offset == 1 << simd2_bit
    @assert simd3.offset == 1 << simd3_bit

    tmp_layout = copy(var_layout)
    delete!(tmp_layout, register1_phys)
    delete!(tmp_layout, register2_phys)
    delete!(tmp_layout, register3_phys)

    res_layout = copy(tmp_layout)
    inv_res_layout = inv(res_layout)
    value = inv_res_layout[SIMD(:simd, 1, 2)]
    value_tag = indextag(value)::ValueTag
    @assert Index{Physics,value_tag}(value.name, simd1.offset, simd1.length) ∈ res_layout
    @assert Index{Physics,value_tag}(value.name, simd2.offset, simd2.length) ∈ res_layout
    @assert Index{Physics,value_tag}(value.name, simd3.offset, simd3.length) ∈ res_layout
    delete!(res_layout, Index{Physics,value_tag}(value.name, simd1.offset, simd1.length))
    delete!(res_layout, Index{Physics,value_tag}(value.name, simd2.offset, simd2.length))
    delete!(res_layout, Index{Physics,value_tag}(value.name, simd3.offset, simd3.length))
    res_layout[register1_phys] = simd1
    res_layout[register2_phys] = simd2
    res_layout[register3_phys] = simd3

    emitter.environment[res] = res_layout

    @assert value_tag == IntValueTag
    @assert simd1_bit == 2
    @assert simd2_bit == 3
    @assert simd3_bit == 4

    loop_over_registers(emitter, tmp_layout) do state
        state0 = copy(state)
        state1 = copy(state)
        state2 = copy(state)
        state3 = copy(state)
        state4 = copy(state)
        state5 = copy(state)
        state6 = copy(state)
        state7 = copy(state)
        state0.dict[register1.name] = get(state0.dict, register1.name, Int32(0)) + Int32(0 * register1.offset)
        state1.dict[register1.name] = get(state1.dict, register1.name, Int32(0)) + Int32(1 * register1.offset)
        state2.dict[register1.name] = get(state2.dict, register1.name, Int32(0)) + Int32(0 * register1.offset)
        state3.dict[register1.name] = get(state3.dict, register1.name, Int32(0)) + Int32(1 * register1.offset)
        state4.dict[register1.name] = get(state4.dict, register1.name, Int32(0)) + Int32(0 * register1.offset)
        state5.dict[register1.name] = get(state5.dict, register1.name, Int32(0)) + Int32(1 * register1.offset)
        state6.dict[register1.name] = get(state6.dict, register1.name, Int32(0)) + Int32(0 * register1.offset)
        state7.dict[register1.name] = get(state7.dict, register1.name, Int32(0)) + Int32(1 * register1.offset)
        state0.dict[register2.name] = get(state0.dict, register2.name, Int32(0)) + Int32(0 * register2.offset)
        state1.dict[register2.name] = get(state1.dict, register2.name, Int32(0)) + Int32(0 * register2.offset)
        state2.dict[register2.name] = get(state2.dict, register2.name, Int32(0)) + Int32(1 * register2.offset)
        state3.dict[register2.name] = get(state3.dict, register2.name, Int32(0)) + Int32(1 * register2.offset)
        state4.dict[register2.name] = get(state4.dict, register2.name, Int32(0)) + Int32(0 * register2.offset)
        state5.dict[register2.name] = get(state5.dict, register2.name, Int32(0)) + Int32(0 * register2.offset)
        state6.dict[register2.name] = get(state6.dict, register2.name, Int32(0)) + Int32(1 * register2.offset)
        state7.dict[register2.name] = get(state7.dict, register2.name, Int32(0)) + Int32(1 * register2.offset)
        state0.dict[register3.name] = get(state0.dict, register3.name, Int32(0)) + Int32(0 * register3.offset)
        state1.dict[register3.name] = get(state1.dict, register3.name, Int32(0)) + Int32(0 * register3.offset)
        state2.dict[register3.name] = get(state2.dict, register3.name, Int32(0)) + Int32(0 * register3.offset)
        state3.dict[register3.name] = get(state3.dict, register3.name, Int32(0)) + Int32(0 * register3.offset)
        state4.dict[register3.name] = get(state4.dict, register3.name, Int32(0)) + Int32(1 * register3.offset)
        state5.dict[register3.name] = get(state5.dict, register3.name, Int32(0)) + Int32(1 * register3.offset)
        state6.dict[register3.name] = get(state6.dict, register3.name, Int32(0)) + Int32(1 * register3.offset)
        state7.dict[register3.name] = get(state7.dict, register3.name, Int32(0)) + Int32(1 * register3.offset)
        res_name = register_name(res, state)
        var0_name = register_name(var, state0)
        var1_name = register_name(var, state1)
        var2_name = register_name(var, state2)
        var3_name = register_name(var, state3)
        var4_name = register_name(var, state4)
        var5_name = register_name(var, state5)
        var6_name = register_name(var, state6)
        var7_name = register_name(var, state7)
        push!(
            emitter.statements,
            :($res_name = Int4x8($var0_name, $var1_name, $var2_name, $var3_name, $var4_name, $var5_name, $var6_name, $var7_name)),
        )
    end

    return nothing
end

export split!
function split!(emitter::Emitter, ress::AbstractVector{Symbol}, var::Symbol, register::Register)
    @assert !isempty(ress)
    @assert length(Set(ress)) == length(ress)
    # res may or may not already exist
    # @assert all(res ∉ emitter.environment for res in ress)

    @assert register.length == length(ress)
    var_layout = emitter.environment[var]
    index = inv(var_layout)[register]

    res_layout = delete!(copy(var_layout), index)
    for res in ress
        emitter.environment[res] = res_layout
    end

    loop_over_registers(emitter, res_layout) do state
        for (n, res) in enumerate(ress)
            state′ = copy(state)
            state′.dict[register.name] = get(state′.dict, register.name, 0i32) + Int32((n - 1) * register.offset)
            res_name = register_name(res, state)
            var_name = register_name(var, state′)
            push!(emitter.statements, :($res_name = $var_name))
        end
    end

    return nothing
end
function split!(emitter::Emitter, ress::AbstractVector{Symbol}, var::Symbol, index::Index{Physics})
    split!(emitter, ress, var, emitter.environment[var][index]::Register)
    return nothing
end

function Base.merge!(
    emitter::Emitter, res::Symbol, vars::AbstractVector{Symbol}, index_register::Pair{<:Index{Physics},<:Index{Machine}}
)
    index, register = index_register
    @assert index.length == register.length

    # We allow duplicate variables
    # @assert length(Set(vars)) == length(vars)

    @assert index.length == length(vars)
    var_layouts = [emitter.environment[var] for var in vars]
    @assert !isempty(vars)
    var_layout = var_layouts[1]
    @assert all(vl == var_layout for vl in var_layouts)
    @assert index ∉ var_layout

    # res may or may not already exist
    # @assert res ∉ emitter.environment
    res_layout = copy(var_layout)
    res_layout[index] = register
    emitter.environment[res] = res_layout

    loop_over_registers(emitter, var_layout) do state
        for (n, var) in enumerate(vars)
            state′ = copy(state)
            state′.dict[index.name] = get(state′.dict, index.name, 0i32) + Int32((n - 1) * index.offset)
            res_name = register_name(res, state′)
            var_name = register_name(var, state)
            push!(emitter.statements, :($res_name = $var_name))
        end
    end

    return nothing
end

export select!

function select!(emitter::Emitter, res::Symbol, var::Symbol, register_loop::Pair{Register,Loop})
    register, loop = register_loop

    var_layout = emitter.environment[var]
    phys_register = register.length == 1 ? nothing : inv(var_layout)[register]

    @assert res ∉ emitter.environment
    res_layout = copy(var_layout)
    if phys_register ≢ nothing
        delete!(res_layout, phys_register)
        res_layout[phys_register] = loop
    end
    value_type = get_value_type(res_layout)
    emitter.environment[res] = res_layout

    loop_over_registers(emitter, res_layout) do state
        res_name = register_name(res, state)
        for i in 0:(loop.offset):(loop.offset * loop.length - 1)
            state′ = copy(state)
            if loop.length > 1
                state′.dict[register.name] = get(state′.dict, register.name, 0i32) + Int32(i)
            end
            var_name = register_name(var, state′)
            if i == 0
                push!(emitter.statements, :($res_name = zero($value_type)))
            end
            push!(
                emitter.statements,
                quote
                    if $(loop.name) == $(Int32(i))
                        $res_name = $var_name
                    end
                end,
            )
        end
    end

    return nothing
end

function select!(emitter::Emitter, res::Symbol, var::Symbol, register_loop::Pair{Register,UnrolledLoop})
    register, unrolled_loop = register_loop

    var_layout = emitter.environment[var]
    phys_register = register.length == 1 ? nothing : inv(var_layout)[register]

    @assert res ∉ emitter.environment
    res_layout = copy(var_layout)
    if phys_register ≢ nothing
        delete!(res_layout, phys_register)
        res_layout[phys_register] = unrolled_loop
    end
    value_type = get_value_type(res_layout)
    emitter.environment[res] = res_layout

    loop_over_registers(emitter, res_layout) do state
        res_name = register_name(res, state)
        state′ = copy(state)
        if unrolled_loop.length > 1
            state′.dict[register.name] = get(state′.dict, register.name, 0i32) + emitter.environment.values[unrolled_loop.name]
        end
        var_name = register_name(var, state′)
        push!(emitter.statements, :($res_name = $var_name))
    end

    return nothing
end

export unselect!
function unselect!(emitter::Emitter, res::Symbol, var::Symbol, loop_register::Pair{<:Union{Loop,UnrolledLoop},Register})
    loop, register = loop_register

    var_layout = emitter.environment[var]
    phys_loop = loop.length == 1 ? nothing : inv(var_layout)[loop]

    @assert res ∉ emitter.environment
    res_layout = copy(var_layout)
    if phys_loop ≢ nothing
        delete!(res_layout, phys_loop)
        res_layout[phys_loop] = register
    end
    value_type = get_value_type(res_layout)
    emitter.environment[res] = res_layout
    emitter.output_environment[res] = res_layout

    loop_over_registers(emitter, var_layout) do state
        var_name = register_name(var, state)
        for i in 0:(loop.offset):(loop.offset * loop.length - 1)
            state′ = copy(state)
            if loop.length > 1
                state′.dict[register.name] = get(state′.dict, register.name, 0i32) + Int32(i)
            end
            res_name = register_name(res, state′)
            push!(emitter.init_statements, :($res_name = zero($value_type)))
            push!(
                emitter.statements,
                quote
                    if $(loop.name) == $(Int32(i))
                        $res_name = $var_name
                    end
                end,
            )
        end
    end

    return nothing
end

################################################################################

# User code

mma_m8n8k16(A::Int8x4, B::Int8x4, C::NTuple{2,Int32}) = C
CUDA.@device_override function mma_m8n8k16(A::Int8x4, B::Int8x4, C::NTuple{2,Int32})
    return Base.llvmcall(
        """
            %res = call {i32, i32} asm sideeffect "mma.sync.aligned.m8n8k16.row.col.satfinite.s32.s8.s8.s32 {\$0, \$1}, {\$2}, {\$3}, {\$4, \$5};", "=r,=r,r,r,r,r"(i32 %0, i32 %1, i32 %2, i32 %3)
            %res0 = extractvalue {i32, i32} %res, 0
            %res1 = extractvalue {i32, i32} %res, 1
            %val0 = insertvalue [2 x i32] undef, i32 %res0, 0
            %val = insertvalue [2 x i32] %val0, i32 %res1, 1
            ret [2 x i32] %val
        """,
        NTuple{2,Int32},
        NTuple{4,Int32},
        A.val % Int32,
        B.val % Int32,
        C[1],
        C[2],
    )
end

mma_m16n8k8(A::NTuple{2,Float16x2}, B::Float16x2, C::NTuple{2,Float16x2}) = C
CUDA.@device_override function mma_m16n8k8(A::NTuple{2,Float16x2}, B::Float16x2, C::NTuple{2,Float16x2})
    D = Base.llvmcall(
        """
            %res = call {i32, i32} asm sideeffect "mma.sync.aligned.m16n8k8.row.col.f16.f16.f16.f16 {\$0, \$1}, {\$2, \$3}, {\$4}, {\$5, \$6};", "=r,=r,r,r,r,r,r"(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4)
            %res0 = extractvalue {i32, i32} %res, 0
            %res1 = extractvalue {i32, i32} %res, 1
            %val0 = insertvalue [2 x i32] undef, i32 %res0, 0
            %val = insertvalue [2 x i32] %val0, i32 %res1, 1
            ret [2 x i32] %val
        """,
        NTuple{2,Int32},
        NTuple{5,Int32},
        A[1].val % Int32,
        A[2].val % Int32,
        B.val % Int32,
        C[1].val % Int32,
        C[2].val % Int32,
    )
    return (Float16x2(D[1] % UInt32), Float16x2(D[2] % UInt32))
end

mma_m16n8k16(A::NTuple{4,Float16x2}, B::NTuple{2,Float16x2}, C::NTuple{2,Float16x2}) = C
CUDA.@device_override function mma_m16n8k16(A::NTuple{4,Float16x2}, B::NTuple{2,Float16x2}, C::NTuple{2,Float16x2})
    D = Base.llvmcall(
        """
            %res = call {i32, i32} asm sideeffect "mma.sync.aligned.m16n8k16.row.col.f16.f16.f16.f16 {\$0, \$1}, {\$2, \$3, \$4, \$5}, {\$6, \$7}, {\$8, \$9};", "=r,=r,r,r,r,r,r,r,r,r"(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5, i32 %6, i32 %7)
            %res0 = extractvalue {i32, i32} %res, 0
            %res1 = extractvalue {i32, i32} %res, 1
            %val0 = insertvalue [2 x i32] undef, i32 %res0, 0
            %val = insertvalue [2 x i32] %val0, i32 %res1, 1
            ret [2 x i32] %val
        """,
        NTuple{2,Int32},
        NTuple{8,Int32},
        A[1].val % Int32,
        A[2].val % Int32,
        A[3].val % Int32,
        A[4].val % Int32,
        B[1].val % Int32,
        B[2].val % Int32,
        C[1].val % Int32,
        C[2].val % Int32,
    )
    return (Float16x2(D[1] % UInt32), Float16x2(D[2] % UInt32))
end

mma_sp_m16n8k16(A::NTuple{2,Float16x2}, B::NTuple{2,Float16x2}, C::NTuple{2,Float16x2}, e::Int2x16, f::Int32) = C
CUDA.@device_override function mma_sp_m16n8k16(
    A::NTuple{2,Float16x2}, B::NTuple{2,Float16x2}, C::NTuple{2,Float16x2}, e::Int2x16, f::Int32
)
    D = Base.llvmcall(
        """
            %res = call {i32, i32} asm sideeffect "mma.sp.sync.aligned.m16n8k16.row.col.f16.f16.f16.f16 {\$0, \$1}, {\$2, \$3}, {\$4, \$5}, {\$6, \$7}, \$8, \$9;", "=r,=r,r,r,r,r,r,r,r,n"(i32 %0, i32 %1, i32 %2, i32 %3, i32 %4, i32 %5, i32 %6, i32 %7)
            %res0 = extractvalue {i32, i32} %res, 0
            %res1 = extractvalue {i32, i32} %res, 1
            %val0 = insertvalue [2 x i32] undef, i32 %res0, 0
            %val = insertvalue [2 x i32] %val0, i32 %res1, 1
            ret [2 x i32] %val
        """,
        NTuple{2,Int32},
        NTuple{8,Int32},
        A[1].val % Int32,
        A[2].val % Int32,
        B[1].val % Int32,
        B[2].val % Int32,
        C[1].val % Int32,
        C[2].val % Int32,
        e.val % Int32,
        f % Int32,
    )
    return (Float16x2(D[1] % UInt32), Float16x2(D[2] % UInt32))
end

# TODO: combine `mma` functions
export mma_row_col_m8n8k16_s8!
function mma_row_col_m8n8k16_s8!(
    emitter::Emitter,
    D::Symbol,
    A_indices::Pair{Symbol,<:Tuple{<:AbstractVector{<:Index{Physics}},<:AbstractVector{<:Index{Physics}}}},
    B_indices::Pair{Symbol,<:Tuple{<:AbstractVector{<:Index{Physics}},<:AbstractVector{<:Index{Physics}}}},
    C_indices::Pair{Symbol,<:Tuple{<:AbstractVector{<:Index{Physics}},<:AbstractVector{<:Index{Physics}}}},
)
    # D     = A      * B      + C
    # D_ij  = A_ik   * B_kj   + C_ij
    # D_8_8 = A_8_16 * B_16_8 + C_8_8
    # Int32 = Int8   * Int8   + Int32

    (A, (A_row, A_col)) = A_indices
    (B, (B_row, B_col)) = B_indices
    (C, (C_row, C_col)) = C_indices

    A_layout = emitter.environment[A]
    B_layout = emitter.environment[B]
    C_layout = emitter.environment[C]
    # D might or might not be identical to C
    if D ≠ C
        @assert D ∉ emitter.environment
    end
    D_layout = C_layout
    emitter.environment[D] = D_layout

    inv_A_layout = inv(A_layout)
    inv_B_layout = inv(B_layout)
    inv_C_layout = inv(C_layout)
    inv_D_layout = inv(D_layout)

    A_value = inv_A_layout[SIMD(:simd, 1, 2)]
    A_value_tag = indextag(A_value)::ValueTag
    A_value_bits = 0
    while Index{Physics,A_value_tag}(A_value.name, 1, 1 << (A_value_bits + 1)) in A_layout
        A_value_bits += 1
    end
    @assert A_value_bits == 3

    B_value = inv_B_layout[SIMD(:simd, 1, 2)]
    B_value_tag = indextag(B_value)::ValueTag
    B_value_bits = 0
    while Index{Physics,B_value_tag}(B_value.name, 1, 1 << (B_value_bits + 1)) in B_layout
        B_value_bits += 1
    end
    @assert B_value_bits == 3

    C_value = inv_C_layout[SIMD(:simd, 1, 2)]
    C_value_tag = indextag(C_value)::ValueTag
    C_value_bits = 0
    while Index{Physics,C_value_tag}(C_value.name, 1, 1 << (C_value_bits + 1)) in C_layout
        C_value_bits += 1
    end
    @assert C_value_bits == 5

    @assert length(A_col) == 4
    @assert length(A_row) == 3
    @assert A_layout[A_col[1]] == SIMD(:simd, 8, 2)
    @assert A_layout[A_col[2]] == SIMD(:simd, 16, 2)
    @assert A_layout[A_col[3]] == Thread(:thread, 1, 2)
    @assert A_layout[A_col[4]] == Thread(:thread, 2, 2)
    @assert A_layout[A_row[1]] == Thread(:thread, 4, 2)
    @assert A_layout[A_row[2]] == Thread(:thread, 8, 2)
    @assert A_layout[A_row[3]] == Thread(:thread, 16, 2)

    @assert length(B_row) == 4
    @assert length(B_col) == 3
    @assert B_layout[B_row[1]] == SIMD(:simd, 8, 2)
    @assert B_layout[B_row[2]] == SIMD(:simd, 16, 2)
    @assert B_layout[B_row[3]] == Thread(:thread, 1, 2)
    @assert B_layout[B_row[4]] == Thread(:thread, 2, 2)
    @assert B_layout[B_col[1]] == Thread(:thread, 4, 2)
    @assert B_layout[B_col[2]] == Thread(:thread, 8, 2)
    @assert B_layout[B_col[3]] == Thread(:thread, 16, 2)

    @assert length(C_row) == 3
    @assert length(C_col) == 3
    C_layout[C_col[1]]::Register
    @assert C_layout[C_col[1]].length == 2
    @assert C_layout[C_col[2]] == Thread(:thread, 1, 2)
    @assert C_layout[C_col[3]] == Thread(:thread, 2, 2)
    @assert C_layout[C_row[1]] == Thread(:thread, 4, 2)
    @assert C_layout[C_row[2]] == Thread(:thread, 8, 2)
    @assert C_layout[C_row[3]] == Thread(:thread, 16, 2)

    # Check that physics indices match
    @assert C_col == B_col
    @assert C_row == A_row
    @assert A_col == B_row

    tmp_layout = copy(D_layout)
    delete!(tmp_layout, C_col[1]) # delete registers
    loop_over_registers(emitter, tmp_layout) do state
        state0 = copy(state)
        state1 = copy(state)
        state0.dict[C_col[1].name] = get(state0.dict, C_col[1].name, 0i32) + Int32(0 * C_col[1].offset)
        state1.dict[C_col[1].name] = get(state1.dict, C_col[1].name, 0i32) + Int32(1 * C_col[1].offset)
        A_name = register_name(A, state)
        B_name = register_name(B, state)
        C0_name = register_name(C, state0)
        C1_name = register_name(C, state1)
        D0_name = register_name(D, state0)
        D1_name = register_name(D, state1)
        push!(emitter.statements, :(($D0_name, $D1_name) = IndexSpaces.mma_m8n8k16($A_name, $B_name, ($C0_name, $C1_name))))
    end

    return nothing
end

export mma_row_col_m16n8k8_f16!
function mma_row_col_m16n8k8_f16!(
    emitter::Emitter,
    D::Symbol,
    A_indices::Pair{Symbol,<:Tuple{<:AbstractVector{<:Index{Physics}},<:AbstractVector{<:Index{Physics}}}},
    B_indices::Pair{Symbol,<:Tuple{<:AbstractVector{<:Index{Physics}},<:AbstractVector{<:Index{Physics}}}},
    C_indices::Pair{Symbol,<:Tuple{<:AbstractVector{<:Index{Physics}},<:AbstractVector{<:Index{Physics}}}},
)
    # D       = A       * B       + C
    # D_ij    = A_ik    * B_kj    + C_ij
    # D_16_8  = A_16_8  * B_8_8   + C_16_8
    # Float16 = Float16 * Float16 + Float16

    (A, (A_row, A_col)) = A_indices
    (B, (B_row, B_col)) = B_indices
    (C, (C_row, C_col)) = C_indices

    A_layout = emitter.environment[A]
    B_layout = emitter.environment[B]
    C_layout = emitter.environment[C]
    # D might or might not be identical to C
    if D ≠ C
        @assert D ∉ emitter.environment
    end
    D_layout = C_layout
    emitter.environment[D] = D_layout

    inv_A_layout = inv(A_layout)
    inv_B_layout = inv(B_layout)
    inv_C_layout = inv(C_layout)
    inv_D_layout = inv(D_layout)

    A_value = inv_A_layout[SIMD(:simd, 1, 2)]
    A_value_tag = indextag(A_value)::ValueTag
    A_value_bits = 0
    while Index{Physics,A_value_tag}(A_value.name, 1, 1 << (A_value_bits + 1)) in A_layout
        A_value_bits += 1
    end
    @assert A_value_bits == 4

    B_value = inv_B_layout[SIMD(:simd, 1, 2)]
    B_value_tag = indextag(B_value)::ValueTag
    B_value_bits = 0
    while Index{Physics,B_value_tag}(B_value.name, 1, 1 << (B_value_bits + 1)) in B_layout
        B_value_bits += 1
    end
    @assert B_value_bits == 4

    C_value = inv_C_layout[SIMD(:simd, 1, 2)]
    C_value_tag = indextag(C_value)::ValueTag
    C_value_bits = 0
    while Index{Physics,C_value_tag}(C_value.name, 1, 1 << (C_value_bits + 1)) in C_layout
        C_value_bits += 1
    end
    @assert C_value_bits == 4

    @assert length(A_col) == 3
    @assert length(A_row) == 4
    @assert A_layout[A_col[1]] == SIMD(:simd, 16, 2)
    @assert A_layout[A_col[2]] == Thread(:thread, 1, 2)
    @assert A_layout[A_col[3]] == Thread(:thread, 2, 2)
    @assert A_layout[A_row[1]] == Thread(:thread, 4, 2)
    @assert A_layout[A_row[2]] == Thread(:thread, 8, 2)
    @assert A_layout[A_row[3]] == Thread(:thread, 16, 2)
    A_layout[A_row[4]]::Register
    @assert A_layout[A_row[4]].length == 2

    @assert length(B_row) == 3
    @assert length(B_col) == 3
    @assert B_layout[B_row[1]] == SIMD(:simd, 16, 2)
    @assert B_layout[B_row[2]] == Thread(:thread, 1, 2)
    @assert B_layout[B_row[3]] == Thread(:thread, 2, 2)
    @assert B_layout[B_col[1]] == Thread(:thread, 4, 2)
    @assert B_layout[B_col[2]] == Thread(:thread, 8, 2)
    @assert B_layout[B_col[3]] == Thread(:thread, 16, 2)

    @assert length(C_row) == 4
    @assert length(C_col) == 3
    @assert C_layout[C_col[1]] == SIMD(:simd, 16, 2)
    @assert C_layout[C_col[2]] == Thread(:thread, 1, 2)
    @assert C_layout[C_col[3]] == Thread(:thread, 2, 2)
    @assert C_layout[C_row[1]] == Thread(:thread, 4, 2)
    @assert C_layout[C_row[2]] == Thread(:thread, 8, 2)
    @assert C_layout[C_row[3]] == Thread(:thread, 16, 2)
    C_layout[C_row[4]]::Register
    @assert C_layout[C_row[4]].length == 2

    # Check that physics indices match
    @assert C_col == B_col
    @assert C_row == A_row
    @assert A_col == B_row

    # Keep only those state symbols that are in the layout
    function filter_state(state::State, layout::Layout)
        names = Set(map(k -> k.name, collect(keys(layout.dict))))::Set{Symbol}
        return State(state.kernel_setup, filter(kv -> kv[1] ∈ names, state.dict))
    end

    tmp_layout = copy(D_layout)
    delete!(tmp_layout, C_row[4]) # delete registers
    loop_over_registers(emitter, tmp_layout) do state
        Astate = filter_state(state, A_layout)
        Bstate = filter_state(state, B_layout)
        Cstate = filter_state(state, C_layout)
        Dstate = filter_state(state, D_layout)
        Astate0 = copy(Astate)
        Astate1 = copy(Astate)
        Astate0.dict[A_row[4].name] = get(Astate0.dict, A_row[4].name, 0i32) + Int32(0 * A_row[4].offset)
        Astate1.dict[A_row[4].name] = get(Astate1.dict, A_row[4].name, 0i32) + Int32(1 * A_row[4].offset)
        Cstate0 = copy(Cstate)
        Cstate1 = copy(Cstate)
        Cstate0.dict[C_row[4].name] = get(Cstate0.dict, C_row[4].name, 0i32) + Int32(0 * C_row[4].offset)
        Cstate1.dict[C_row[4].name] = get(Cstate1.dict, C_row[4].name, 0i32) + Int32(1 * C_row[4].offset)

        A0_name = register_name(A, Astate0)
        A1_name = register_name(A, Astate1)
        B_name = register_name(B, Bstate)
        C0_name = register_name(C, Cstate0)
        C1_name = register_name(C, Cstate1)
        D0_name = register_name(D, Cstate0)
        D1_name = register_name(D, Cstate1)
        push!(
            emitter.statements,
            :(($D0_name, $D1_name) = IndexSpaces.mma_m16n8k8(($A0_name, $A1_name), $B_name, ($C0_name, $C1_name))),
        )
    end

    return nothing
end

export mma_row_col_m16n8k16_f16!
function mma_row_col_m16n8k16_f16!(
    emitter::Emitter,
    D::Symbol,
    A_indices::Pair{Symbol,<:Tuple{<:AbstractVector{<:Index{Physics}},<:AbstractVector{<:Index{Physics}}}},
    B_indices::Pair{Symbol,<:Tuple{<:AbstractVector{<:Index{Physics}},<:AbstractVector{<:Index{Physics}}}},
    C_indices::Pair{Symbol,<:Tuple{<:AbstractVector{<:Index{Physics}},<:AbstractVector{<:Index{Physics}}}},
)
    # D       = A       * B       + C
    # D_ij    = A_ik    * B_kj    + C_ij
    # D_16_8  = A_16_16 * B_16_8   + C_16_8
    # Float16 = Float16 * Float16 + Float16

    (A, (A_row, A_col)) = A_indices
    (B, (B_row, B_col)) = B_indices
    (C, (C_row, C_col)) = C_indices

    A_layout = emitter.environment[A]
    B_layout = emitter.environment[B]
    C_layout = emitter.environment[C]
    # D might or might not be identical to C
    if D ≠ C
        @assert D ∉ emitter.environment
    end
    D_layout = C_layout
    emitter.environment[D] = D_layout

    inv_A_layout = inv(A_layout)
    inv_B_layout = inv(B_layout)
    inv_C_layout = inv(C_layout)
    inv_D_layout = inv(D_layout)

    A_value = inv_A_layout[SIMD(:simd, 1, 2)]
    A_value_tag = indextag(A_value)::ValueTag
    A_value_bits = 0
    while Index{Physics,A_value_tag}(A_value.name, 1, 1 << (A_value_bits + 1)) in A_layout
        A_value_bits += 1
    end
    @assert A_value_bits == 4

    B_value = inv_B_layout[SIMD(:simd, 1, 2)]
    B_value_tag = indextag(B_value)::ValueTag
    B_value_bits = 0
    while Index{Physics,B_value_tag}(B_value.name, 1, 1 << (B_value_bits + 1)) in B_layout
        B_value_bits += 1
    end
    @assert B_value_bits == 4

    C_value = inv_C_layout[SIMD(:simd, 1, 2)]
    C_value_tag = indextag(C_value)::ValueTag
    C_value_bits = 0
    while Index{Physics,C_value_tag}(C_value.name, 1, 1 << (C_value_bits + 1)) in C_layout
        C_value_bits += 1
    end
    @assert C_value_bits == 4

    @assert length(A_col) == 4
    @assert length(A_row) == 4
    @assert A_layout[A_col[1]] == SIMD(:simd, 16, 2)
    @assert A_layout[A_col[2]] == Thread(:thread, 1, 2)
    @assert A_layout[A_col[3]] == Thread(:thread, 2, 2)
    A_layout[A_col[4]]::Register
    @assert A_layout[A_col[4]].length == 2
    @assert A_layout[A_row[1]] == Thread(:thread, 4, 2)
    @assert A_layout[A_row[2]] == Thread(:thread, 8, 2)
    @assert A_layout[A_row[3]] == Thread(:thread, 16, 2)
    A_layout[A_row[4]]::Register
    @assert A_layout[A_row[4]].length == 2

    @assert length(B_row) == 4
    @assert length(B_col) == 3
    @assert B_layout[B_row[1]] == SIMD(:simd, 16, 2)
    @assert B_layout[B_row[2]] == Thread(:thread, 1, 2)
    @assert B_layout[B_row[3]] == Thread(:thread, 2, 2)
    B_layout[B_row[4]]::Register
    @assert B_layout[B_row[4]].length == 2
    @assert B_layout[B_col[1]] == Thread(:thread, 4, 2)
    @assert B_layout[B_col[2]] == Thread(:thread, 8, 2)
    @assert B_layout[B_col[3]] == Thread(:thread, 16, 2)

    @assert length(C_row) == 4
    @assert length(C_col) == 3
    @assert C_layout[C_col[1]] == SIMD(:simd, 16, 2)
    @assert C_layout[C_col[2]] == Thread(:thread, 1, 2)
    @assert C_layout[C_col[3]] == Thread(:thread, 2, 2)
    @assert C_layout[C_row[1]] == Thread(:thread, 4, 2)
    @assert C_layout[C_row[2]] == Thread(:thread, 8, 2)
    @assert C_layout[C_row[3]] == Thread(:thread, 16, 2)
    C_layout[C_row[4]]::Register
    @assert C_layout[C_row[4]].length == 2

    # Check that physics indices match
    @assert C_col == B_col
    @assert C_row == A_row
    @assert A_col == B_row

    # Keep only those state symbols that are in the layout
    function filter_state(state::State, layout::Layout)
        names = Set(map(k -> k.name, collect(keys(layout.dict))))::Set{Symbol}
        return State(state.kernel_setup, filter(kv -> kv[1] ∈ names, state.dict))
    end

    tmp_layout = copy(D_layout)
    delete!(tmp_layout, C_row[4]) # delete registers
    loop_over_registers(emitter, tmp_layout) do state
        Astate = filter_state(state, A_layout)
        Bstate = filter_state(state, B_layout)
        Cstate = filter_state(state, C_layout)
        Dstate = filter_state(state, D_layout)
        Astate0 = copy(Astate)
        Astate1 = copy(Astate)
        Astate2 = copy(Astate)
        Astate3 = copy(Astate)
        # A is stored column-major in registers
        Astate0.dict[A_row[4].name] = get(Astate0.dict, A_row[4].name, 0i32) + Int32(0 * A_row[4].offset)
        Astate0.dict[A_col[4].name] = get(Astate0.dict, A_col[4].name, 0i32) + Int32(0 * A_col[4].offset)
        Astate1.dict[A_row[4].name] = get(Astate1.dict, A_row[4].name, 0i32) + Int32(1 * A_row[4].offset)
        Astate1.dict[A_col[4].name] = get(Astate1.dict, A_col[4].name, 0i32) + Int32(0 * A_col[4].offset)
        Astate2.dict[A_row[4].name] = get(Astate2.dict, A_row[4].name, 0i32) + Int32(0 * A_row[4].offset)
        Astate2.dict[A_col[4].name] = get(Astate2.dict, A_col[4].name, 0i32) + Int32(1 * A_col[4].offset)
        Astate3.dict[A_row[4].name] = get(Astate3.dict, A_row[4].name, 0i32) + Int32(1 * A_row[4].offset)
        Astate3.dict[A_col[4].name] = get(Astate3.dict, A_col[4].name, 0i32) + Int32(1 * A_col[4].offset)
        Bstate0 = copy(Bstate)
        Bstate1 = copy(Bstate)
        Bstate0.dict[B_row[4].name] = get(Bstate0.dict, B_row[4].name, 0i32) + Int32(0 * B_row[4].offset)
        Bstate1.dict[B_row[4].name] = get(Bstate1.dict, B_row[4].name, 0i32) + Int32(1 * B_row[4].offset)
        Cstate0 = copy(Cstate)
        Cstate1 = copy(Cstate)
        Cstate0.dict[C_row[4].name] = get(Cstate0.dict, C_row[4].name, 0i32) + Int32(0 * C_row[4].offset)
        Cstate1.dict[C_row[4].name] = get(Cstate1.dict, C_row[4].name, 0i32) + Int32(1 * C_row[4].offset)

        A0_name = register_name(A, Astate0)
        A1_name = register_name(A, Astate1)
        A2_name = register_name(A, Astate2)
        A3_name = register_name(A, Astate3)
        B0_name = register_name(B, Bstate0)
        B1_name = register_name(B, Bstate1)
        C0_name = register_name(C, Cstate0)
        C1_name = register_name(C, Cstate1)
        D0_name = register_name(D, Cstate0)
        D1_name = register_name(D, Cstate1)
        push!(
            emitter.statements,
            :(
                ($D0_name, $D1_name) = IndexSpaces.mma_m16n8k16(
                    ($A0_name, $A1_name, $A2_name, $A3_name), ($B0_name, $B1_name), ($C0_name, $C1_name)
                )
            ),
        )
    end

    return nothing
end

export mma_sp_row_col_m16n8k16_f16!
function mma_sp_row_col_m16n8k16_f16!(
    emitter::Emitter,
    D::Symbol,
    A_indices::Pair{Symbol,<:Tuple{<:AbstractVector{<:Index{Physics}},<:AbstractVector{<:Index{Physics}}}},
    B_indices::Pair{Symbol,<:Tuple{<:AbstractVector{<:Index{Physics}},<:AbstractVector{<:Index{Physics}}}},
    C_indices::Pair{Symbol,<:Tuple{<:AbstractVector{<:Index{Physics}},<:AbstractVector{<:Index{Physics}}}},
    spectator::Index{Physics},
)
    # The equivalent non-sparse (dense) operation is:

    # D       = A       * B       + C
    # D_ij    = A_ik    * B_kj    + C_ij
    # D_16_8  = A_16_16 * B_16_8   + C_16_8
    # Float16 = Float16 * Float16 + Float16

    # We assume that this operation has been made sparse by omitting
    # an index, i.e. one of the index bits of `A` is a spectator bit
    # (is passed through). This must be one of the indices in both
    # `A_row` and in `A_col`.

    (A, (A_row, A_col)) = A_indices
    (B, (B_row, B_col)) = B_indices
    (C, (C_row, C_col)) = C_indices

    A_layout = emitter.environment[A]
    B_layout = emitter.environment[B]
    C_layout = emitter.environment[C]
    # D might or might not be identical to C
    if D ≠ C
        @assert D ∉ emitter.environment
    end
    D_layout = C_layout
    emitter.environment[D] = D_layout

    inv_A_layout = inv(A_layout)
    inv_B_layout = inv(B_layout)
    inv_C_layout = inv(C_layout)
    inv_D_layout = inv(D_layout)

    A_value = inv_A_layout[SIMD(:simd, 1, 2)]
    A_value_tag = indextag(A_value)::ValueTag
    A_value_bits = 0
    while Index{Physics,A_value_tag}(A_value.name, 1, 1 << (A_value_bits + 1)) in A_layout
        A_value_bits += 1
    end
    @assert A_value_bits == 4

    B_value = inv_B_layout[SIMD(:simd, 1, 2)]
    B_value_tag = indextag(B_value)::ValueTag
    B_value_bits = 0
    while Index{Physics,B_value_tag}(B_value.name, 1, 1 << (B_value_bits + 1)) in B_layout
        B_value_bits += 1
    end
    @assert B_value_bits == 4

    C_value = inv_C_layout[SIMD(:simd, 1, 2)]
    C_value_tag = indextag(C_value)::ValueTag
    C_value_bits = 0
    while Index{Physics,C_value_tag}(C_value.name, 1, 1 << (C_value_bits + 1)) in C_layout
        C_value_bits += 1
    end
    @assert C_value_bits == 4

    # @assert spectator in A_row
    # @assert spectator in A_col
    # TODO: Generalize this
    if A_row[2] == spectator && A_col[2] == spectator
        Asprow = 2
        Aspcol = 2
    elseif A_row[2] == spectator && A_col[3] == spectator
        # This case is not possible; the sparse column must be one of 1 or 2 (one of the two lowest bits)
        @assert false
        Asprow = 2
        Aspcol = 3
    elseif A_row[3] == spectator && A_col[2] == spectator
        Asprow = 3
        Aspcol = 2
    else
        @show spectator A_row A_col
        @assert false
    end

    @assert length(A_col) == 4
    @assert length(A_row) == 4
    @assert A_layout[A_col[1]] == SIMD(:simd, 16, 2)
    if Aspcol == 2
        @assert A_col[2] == spectator
        @assert A_layout[A_col[3]] == Thread(:thread, 1, 2)
    elseif Aspcol == 3
        @assert false
        @assert A_layout[A_col[2]] == Thread(:thread, 1, 2)
        @assert A_col[3] == spectator
    else
        @assert false
    end
    @assert A_layout[A_col[4]] == Thread(:thread, 2, 2)
    @assert A_layout[A_row[1]] == Thread(:thread, 4, 2)
    @assert A_layout[A_row[2]] == Thread(:thread, 8, 2)
    @assert A_layout[A_row[3]] == Thread(:thread, 16, 2)
    A_layout[A_row[4]]::Register
    @assert A_layout[A_row[4]].length == 2

    @assert length(B_row) == 4
    @assert length(B_col) == 3
    @assert B_layout[B_row[1]] == SIMD(:simd, 16, 2)
    @assert B_layout[B_row[2]] == Thread(:thread, 1, 2)
    @assert B_layout[B_row[3]] == Thread(:thread, 2, 2)
    B_layout[B_row[4]]::Register
    @assert B_layout[B_row[4]].length == 2
    @assert B_layout[B_col[1]] == Thread(:thread, 4, 2)
    @assert B_layout[B_col[2]] == Thread(:thread, 8, 2)
    @assert B_layout[B_col[3]] == Thread(:thread, 16, 2)

    @assert length(C_row) == 4
    @assert length(C_col) == 3
    @assert C_layout[C_col[1]] == SIMD(:simd, 16, 2)
    @assert C_layout[C_col[2]] == Thread(:thread, 1, 2)
    @assert C_layout[C_col[3]] == Thread(:thread, 2, 2)
    @assert C_layout[C_row[1]] == Thread(:thread, 4, 2)
    @assert C_layout[C_row[2]] == Thread(:thread, 8, 2)
    @assert C_layout[C_row[3]] == Thread(:thread, 16, 2)
    C_layout[C_row[4]]::Register
    @assert C_layout[C_row[4]].length == 2

    # Check that physics indices match
    @assert C_col == B_col
    @assert C_row == A_row
    @assert A_col == B_row

    # Keep only those state symbols that are in the layout
    function filter_state(state::State, layout::Layout)
        names = Set(map(k -> k.name, collect(keys(layout.dict))))::Set{Symbol}
        return State(state.kernel_setup, filter(kv -> kv[1] ∈ names, state.dict))
    end

    tmp_layout = copy(D_layout)
    delete!(tmp_layout, C_row[4]) # delete registers
    loop_over_registers(emitter, tmp_layout) do state
        Astate = filter_state(state, A_layout)
        Bstate = filter_state(state, B_layout)
        Cstate = filter_state(state, C_layout)
        Dstate = filter_state(state, D_layout)
        # We have 4 `A` inputs in principle, but sparsity reduces this to 2
        Astate0 = copy(Astate)
        Astate1 = copy(Astate)
        # A is stored column-major in registers
        Astate0.dict[A_row[4].name] = get(Astate0.dict, A_row[4].name, 0i32) + Int32(0 * A_row[4].offset)
        Astate1.dict[A_row[4].name] = get(Astate1.dict, A_row[4].name, 0i32) + Int32(1 * A_row[4].offset)
        Bstate0 = copy(Bstate)
        Bstate1 = copy(Bstate)
        Bstate0.dict[B_row[4].name] = get(Bstate0.dict, B_row[4].name, 0i32) + Int32(0 * B_row[4].offset)
        Bstate1.dict[B_row[4].name] = get(Bstate1.dict, B_row[4].name, 0i32) + Int32(1 * B_row[4].offset)
        Cstate0 = copy(Cstate)
        Cstate1 = copy(Cstate)
        Cstate0.dict[C_row[4].name] = get(Cstate0.dict, C_row[4].name, 0i32) + Int32(0 * C_row[4].offset)
        Cstate1.dict[C_row[4].name] = get(Cstate1.dict, C_row[4].name, 0i32) + Int32(1 * C_row[4].offset)

        A0_name = register_name(A, Astate0)
        A1_name = register_name(A, Astate1)
        B0_name = register_name(B, Bstate0)
        B1_name = register_name(B, Bstate1)
        C0_name = register_name(C, Cstate0)
        C1_name = register_name(C, Cstate1)
        D0_name = register_name(D, Cstate0)
        D1_name = register_name(D, Cstate1)
        @assert A_row[Asprow] == spectator
        @assert A_col[Aspcol] == spectator
        A_pattern = falses(16, 16)
        for row in 0:15, col in 0:15
            sprow = (row >> (Asprow - 1)) & 1
            spcol = (col >> (Aspcol - 1)) & 1
            A_pattern[row + 1, col + 1] = sprow == spcol
        end
        if (Asprow, Aspcol) == (2, 2)
            A_pattern_manual = [
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
            ]
        elseif (Asprow, Aspcol) == (2, 3)
            A_pattern_manual = [
                1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0
                1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0
                0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1
                0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1
                1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0
                1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0
                0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1
                0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1
                1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0
                1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0
                0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1
                0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1
                1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0
                1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0
                0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1
                0 0 0 0 1 1 1 1 0 0 0 0 1 1 1 1
            ]
        elseif (Asprow, Aspcol) == (3, 2)
            A_pattern_manual = [
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
                0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1
            ]
        else
            @assert false
        end
        @assert A_pattern == A_pattern_manual
        function decode_row_pattern(row::Integer, col::Integer)
            @assert col % 4 == 0
            c1 = 0
            while c1 < 4 && !A_pattern[row + 1, col + c1 + 1]
                c1 += 1
            end
            @assert c1 <= 3
            c2 = c1 + 1
            while c2 < 4 && !A_pattern[row + 1, col + c2 + 1]
                c2 += 1
            end
            @assert c2 <= 3
            c3 = c2 + 1
            while c3 < 4 && !A_pattern[row + 1, col + c3 + 1]
                c3 += 1
            end
            @assert c3 == 4
            return (c1, c2)
        end
        a_row_patterns = NTuple{2,Int}[decode_row_pattern(row, col) for row in 0:15, col in 0:4:15]
        e = [Int2x16(reinterpret(Int, vec(a_row_patterns[(threadgroup + 1):8:16, :]))...) for threadgroup in 0:7]
        push!(
            emitter.statements,
            quote
                ($D0_name, $D1_name) = let
                    e0 = $(e[1])
                    e1 = $(e[2])
                    e2 = $(e[3])
                    e3 = $(e[4])
                    e4 = $(e[5])
                    e5 = $(e[6])
                    e6 = $(e[7])
                    e7 = $(e[8])
                    thread = IndexSpaces.cuda_threadidx()
                    threadgroup = thread ÷ 4
                    e = if threadgroup == 0i32
                        e0
                    elseif threadgroup == 1i32
                        e1
                    elseif threadgroup == 2i32
                        e2
                    elseif threadgroup == 3i32
                        e3
                    elseif threadgroup == 4i32
                        e4
                    elseif threadgroup == 5i32
                        e5
                    elseif threadgroup == 6i32
                        e6
                    elseif threadgroup == 7i32
                        e7
                    # else
                    #     @assert false
                    end
                    IndexSpaces.mma_sp_m16n8k16(($A0_name, $A1_name)::NTuple{2,Float16x2}, ($B0_name, $B1_name)::NTuple{2,Float16x2}, ($C0_name, $C1_name)::NTuple{2,Float16x2}, e::Int2x16, 0i32::Int32)::NTuple{2,Float16x2}
                end
            end,
        )
    end

    return nothing
end

export apply!
function apply!(emitter::Emitter, res_layout::Pair{Symbol,Layout{Physics,Machine}}, code::Code)
    res, layout = res_layout
    # res might or might not exist
    # @assert res ∉ emitter.environment
    emitter.environment[res] = layout

    inv_layout = inv(layout)
    value = inv_layout[SIMD(:simd, 1, 2)]
    value_tag = indextag(value)::ValueTag
    value_bits = 0
    while Index{Physics,value_tag}(value.name, 1, 1 << (value_bits + 1)) in layout
        value_bits += 1
    end

    loop_over_registers(emitter, layout) do state
        res_name = register_name(res, state)
        # TODO: Check type
        push!(emitter.statements, :($res_name = $code))
    end

    return nothing
end

function apply!(
    emitter::Emitter, res::Symbol, vars::AbstractVector{Symbol}, code; ignore::AbstractVector{<:Index{Physics}}=Index{Physics}[]
)
    @assert !isempty(vars)
    var_layouts = [emitter.environment[var] for var in vars]
    var_layout = var_layouts[1]
    # We allow the second and following layouts to be "smaller" than the first
    # @assert all(vl == var_layout for vl in var_layouts)
    for vl in var_layouts
        if !isempty(ignore)
            vl = copy(vl)
            for i in ignore
                delete!(vl, i)
            end
        end
        if !(vl ∈ var_layout)
            @show vl var_layout
        end
        @assert vl ∈ var_layout
    end

    # res might or might not exist
    # @assert res ∉ emitter.environment
    res_layout = copy(var_layout)
    emitter.environment[res] = res_layout

    inv_res_layout = inv(res_layout)
    value = inv_res_layout[SIMD(:simd, 1, 2)]
    value_tag = indextag(value)::ValueTag
    value_bits = 0
    while Index{Physics,value_tag}(value.name, 1, 1 << (value_bits + 1)) in res_layout
        value_bits += 1
    end

    # Keep only those state symbols that are in the layout
    function filter_state(state::State, layout::Layout)
        names = Set(map(k -> k.name, collect(keys(layout.dict))))::Set{Symbol}
        return State(state.kernel_setup, filter(kv -> kv[1] ∈ names, state.dict))
    end

    loop_over_registers(emitter, res_layout) do state
        var_states = [filter_state(state, var_layout) for var_layout in var_layouts]
        res_name = register_name(res, state)
        var_names = [register_name(var, var_state) for (var, var_state) in zip(vars, var_states)]
        push!(emitter.statements, :($res_name = $(code(var_names...))))
    end

    return nothing
end

end
