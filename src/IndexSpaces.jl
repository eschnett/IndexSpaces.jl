module IndexSpaces

using CUDASIMDTypes

################################################################################

export IndexType, Physics, Machine
abstract type IndexType end
struct Physics <: IndexType end
struct Machine <: IndexType end

export IndexTag, SIMDTag, ThreadTag, WarpTag, BlockTag, SharedTag, MemoryTag, LoopTag, RegisterTag
abstract type IndexTag end
struct SIMDTag <: IndexTag end
struct ThreadTag <: IndexTag end
struct WarpTag <: IndexTag end
struct BlockTag <: IndexTag end
struct SharedTag <: IndexTag end
struct MemoryTag <: IndexTag end
struct LoopTag <: IndexTag end
struct RegisterTag <: IndexTag end

export Index
struct Index{Typ<:IndexType,Tag<:IndexTag}
    name::Symbol
    offset::Int
    length::Int
    function Index{Typ,Tag}(name::Symbol, offset::Integer, length::Integer) where {Typ<:IndexType,Tag<:IndexTag}
        @assert offset ≥ 1
        @assert length ≥ 2
        return new{Typ,Tag}(name, offset, length)
    end
end

make_tuple(i::Index{Typ,Tag}) where {Typ<:IndexType,Tag<:IndexTag} = (Symbol(Typ), Symbol(Tag), i.name, i.offset, i.length)

function Base.show(io::IO, index::Index{Typ,Tag}) where {Typ<:IndexType,Tag<:IndexTag}
    print(io, "$Typ.$(index.name):$(index.offset)/$(index.length)")
    return nothing
end

export indextype, indextag
indextype(::Type{<:Index{Typ}}) where {Typ<:IndexType} = Typ
indextag(::Type{<:Index{<:Any,Tag}}) where {Tag<:IndexTag} = Tag
indextype(index::Index) = indextype(typeof(index))
indextag(index::Index) = indextag(typeof(index))

Base.:(==)(i::Index, j::Index) = make_tuple(i) == make_tuple(j)
Base.isless(i::Index, j::Index) = isless(make_tuple(i), make_tuple(j))

export SIMD, Thread, Warp, Block, Shared, Memory, Loop, Register
const SIMD = Index{Machine,SIMDTag}
const Thread = Index{Machine,ThreadTag}
const Warp = Index{Machine,WarpTag}
const Block = Index{Machine,BlockTag}
const Shared = Index{Machine,SharedTag}
const Memory = Index{Machine,MemoryTag}
const Loop = Index{Machine,LoopTag}
const Register = Index{Machine,RegisterTag}

################################################################################

export Quantity
struct Quantity
    name::Symbol
    type::Type                  # AbstractFloat, Integer
    indices::Vector{Index{Physics}}
    Quantity(name::Symbol, type::Type, indices::Vector) = new(name, type, indices)
end

################################################################################

# TODO: Functions to decompose an index space and to check consistency of a decomposed index space

struct Range
    offset::Int
    length::Int
    function Range(offset::Integer, length::Integer)
        @assert offset ≥ 1
        @assert length ≥ 2
        return new(offset, length)
    end
end
Range(index::Index) = Range(index.offset, index.length)

function Base.in(x::Range, y::Range)
    xbeg = x.offset
    xend = x.offset * x.length
    ybeg = y.offset
    yend = y.offset * y.length
    return ybeg ≤ xbeg && xend ≤ yend
end
Base.in(x::Index, y::Index) = false
Base.in(x::Index{Typ,Tag}, y::Index{Typ,Tag}) where {Typ<:IndexType,Tag<:IndexTag} = x.name == y.name && Range(x) ∈ Range(y)

function Base.isdisjoint(x::Range, y::Range)
    xbeg = x.offset
    xend = x.offset * x.length
    ybeg = y.offset
    yend = y.offset * y.length
    return yend ≤ xbeg || xend ≤ ybeg
end
Base.isdisjoint(x::Index, y::Index) = true
function Base.isdisjoint(x::Index{Typ,Tag}, y::Index{Typ,Tag}) where {Typ<:IndexType,Tag<:IndexTag}
    return x.name ≠ y.name || isdisjoint(Range(x), Range(y))
end

function pairwise_disjoint(indices::AbstractVector{<:Index})
    # TODO: Don't use n^2 algorithm
    for i in 1:length(indices), j in (i + 1):length(indices)
        !isdisjoint(indices[i], indices[j]) && return false
    end
    return true
end

export Layout
struct Layout{Typ1<:IndexType,Typ2<:IndexType}
    dict::Dict{Index{Typ1},Index{Typ2}}
    function Layout{Typ1,Typ2}(dict::Dict{<:Index{Typ1},<:Index{Typ2}}) where {Typ1<:IndexType,Typ2<:IndexType}
        pairwise_disjoint(collect(keys(dict))) || throw(ArgumentError("Layout: $Typ1 indices (keys) are overlapping"))
        pairwise_disjoint(collect(values(dict))) || throw(ArgumentError("Layout: $Typ2 indices (values) are overlapping"))
        all(k.length == v.length for (k, v) in dict) || throw(
            ArgumentError(
                "Layout: Index space lengths disagree: " *
                join(["lengths $(k.name)/$(v.name) = $(k.length)/$(v.length)" for (k, v) in dict], ", "),
            ),
        )
        return new{Typ1,Typ2}(dict)
    end
    Layout(dict::Dict{<:Index{Typ1},<:Index{Typ2}}) where {Typ1<:IndexType,Typ2<:IndexType} = Layout{Typ1,Typ2}(dict)
end

function Base.show(io::IO, layout::Layout{K,V}) where {K<:IndexType,V<:IndexType}
    println(io, "Layout{$K,$V}:")
    for k in sort!(collect(keys(layout.dict)))
        v = layout.dict[k]
        println(io, "    $k => $v")
    end
end

Base.copy(layout::Layout) = Layout(copy(layout.dict))

export normalize!
function normalize!(layout::Layout)
    dict = layout.dict

    # Combine index ranges where possible
    @label restart
    # TODO: Don't use n^2 algorithm
    for (key, val) in dict
        for (key′, val′) in dict
            key′ == key && continue
            if indextag(key′) == indextag(key) && indextag(val′) == indextag(val)
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

function Base.:(==)(layout1::Layout{Typ1,Typ2}, layout2::Layout{Typ1,Typ2}) where {Typ1<:IndexType,Typ2<:IndexType}
    return layout1.dict == layout2.dict
end

function Base.inv(layout::Layout{Typ1,Typ2}) where {Typ1<:IndexType,Typ2<:IndexType}
    return Layout(Dict{Index{Typ2},Index{Typ1}}(v => k for (k, v) in layout.dict))
end

function Base.in(key::Index{Typ1}, layout::Layout{Typ1,Typ2}) where {Typ1<:IndexType,Typ2<:IndexType}
    key ∈ keys(layout.dict) && return true
    for (k, v) in layout.dict
        key ∈ k && return true
    end
    return false
end

function Base.getindex(layout::Layout{Typ1,Typ2}, key::Index{Typ1}) where {Typ1<:IndexType,Typ2<:IndexType}
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
    throw(KeyError("Index $key not found"))
end

function Base.setindex!(layout::Layout{Typ1,Typ2}, value::Index{Typ2}, key::Index{Typ1}) where {Typ1<:IndexType,Typ2<:IndexType}
    dict = layout.dict

    @assert all(isdisjoint(key, k) for k in keys(dict))
    @assert all(isdisjoint(value, v) for v in values(dict))
    @assert key.length == value.length

    dict[key] = value

    return normalize!(layout)
end

function Base.delete!(layout::Layout{Typ1,Typ2}, key::Index{Typ1}) where {Typ1<:IndexType,Typ2<:IndexType}
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

################################################################################

const Code = Union{Expr,Number,Symbol}

struct State
    dict::Dict{Symbol,Int32}
end
function register_name(name::Symbol, state::State)
    return Symbol(name, join([string(state.dict[r]) for r in sort!(collect(keys(state.dict)))], "_"))
end

function register_loop(f, layout::Layout{Physics,Machine})
    registers = sort!(filter!(mach -> indextag(mach) isa RegisterTag, collect(values(layout.dict))))
    function go(state::State, n::Int)
        if n == 0
            f(state)
        else
            reg = registers[n]
            for r in 0:(reg.length - 1)
                state.dict[reg.name] = reg.offset * r
                go(state, n - 1)
            end
        end
    end
    go(State(), length(registers))
    return nothing
end

indexvalue(::State, ::SIMD) = @assert false # needs to be handled by the caller
indexvalue(state::State, register::Register) = state.dict[register.name]::Code
indexvalue(::State, ::Thread) = :(threadIdx().x - 0x1)::Code
indexvalue(::State, ::Warp) = :(threadIdx().y - 0x1)::Code
indexvalue(::State, ::Block) = :(blockIdx().x - 0x1)::Code
indexvalue(::State, loop::Loop) = loop.name::Code
indexvalue(::State, ::Shared) = @assert false
indexvalue(::State, ::Memory) = @assert false

function physics_values(state::State, reg_layout::Layout{Physics,Machine})
    vals = Dict{Index,Code}()
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
        oldphysval = get(vals, phys, Int32(0))
        physval = :($oldphysval + $physval)
        vals[phystag] = physval
    end
    return vals
end

function memory_index(reg_layout::Layout{Physics,Machine}, mem_layout::Layout{Physics,Machine}, vals::Dict{Index,Code})
    # Ensure that SIMDTag layouts match
    for (phys, mach) in reg_layout.dict
        if mach isa SIMD
            phys ∈ keys(mem_layout.dict) ||
                throw(ArgumentError("$phys maps to SIMDTag bits in the register layout, but not in the machine layout"))
            @assert mem_layout[phys] == mach
        end
    end
    for (phys, mach) in mem_layout.dict
        if mach isa SIMD
            @assert reg_layout[phys] == mach
        end
    end

    addr = Int32(0)
    for (phys, mach) in mem_layout.dict
        mach isa SIMD && continue
        # Ensure that we are mapping to memory
        mach::Union{Block,Shared,Memory,Loop}

        phystag = indextag(phys)
        physoff = Int32(phys.offset)
        physlen = Int32(phys.length)
        physval = vals[phystag]
        val = :(($physval ÷ $physoff) % $physlen)

        machoff = Int32(mach.offset)
        # machlen = Int32(mach.length)
        machval = :($val * $machoff)
        addr = :($addr + $machval)
    end
    return addr::Code
end

################################################################################

# Code generation

export Environment
struct Environment
    dict::Dict{Symbol,Layout{Physics,Machine}}
    Environment() = new(Dict{Symbol,Layout{Physics,Machine}}())
end

Base.getindex(env::Environment, var::Symbol) = env.dict[var]
Base.in(var::Symbol, env::Environment) = var ∈ keys(env.dict)
Base.setindex!(env::Environment, layout::Layout{Physics,Machine}, var::Symbol) = env.dict[var] = layout

export Emitter
struct Emitter
    environment::Environment
    statements::Vector{Code}
    Emitter() = new(Environment(), Code[])
end

################################################################################

# Memory access

export load!
function load!(emitter::Emitter, reg::Pair{Symbol,Layout{Physics,Machine}}, mem::Pair{Symbol,Layout{Physics,Machine}})
    reg_var, reg_layout = reg
    mem_var, mem_layout = mem
    @assert reg_var ∉ emitter.environment
    emitter.environment[reg_var] = reg_layout

    register_loop(reg_layout) do state
        reg_name = register_name(reg_var, state)
        vals = physics_values(state, reg_layout)
        addr = memory_index(reg_layout, mem_layout, vals)
        push!(emitter.statements, :($reg_name = $mem_var[$addr + 0x1]))
    end

    return nothing
end

export store!
function store!(emitter::Emitter, mem::Pair{Symbol,Layout{Physics,Machine}}, reg_var::Symbol)
    mem_var, mem_layout = mem
    reg_layout = emitter.environment[reg_var]

    register_loop(reg_layout) do state
        reg_name = register_name(reg_var, state)
        vals = physics_values(state, reg_layout)
        addr = memory_index(reg_layout, mem_layout, vals)
        push!(emitter.statements, :($mem_var[$addr + 0x1] = $reg_name))
    end

    return nothing
end

################################################################################

# Layout rearrangements

get_lo4(r0::Int4x8, r1::Int4x8) = Int4x8(bitifelse(0x0f0f0f0f, r0.val << 0x0, r1.val << 0x4))
get_hi4(r0::Int4x8, r1::Int4x8) = Int4x8(bitifelse(0x0f0f0f0f, r0.val >> 0x4, r1.val >> 0x0))
get_lo8(r0::T, r1::T) where {T<:Union{Int4x8,Int8x4}} = T(prmt(r0.val, r1.val, 0x6240))
get_hi8(r0::T, r1::T) where {T<:Union{Int4x8,Int8x4}} = T(prmt(r0.val, r1.val, 0x7351))
get_lo16(r0::T, r1::T) where {T<:Union{Int4x8,Int8x4,Int16x2,Float16x2}} = T(prmt(r0.val, r1.val, 0x5410))
get_hi16(r0::T, r1::T) where {T<:Union{Int4x8,Int8x4,Int16x2,Float16x2}} = T(prmt(r0.val, r1.val, 0x7632))

# TODO: Accept a SubIndex to describe Register and SIMD
function Base.permute!(
    emitter::Emitter, res::Symbol, var::Symbol, ::Type{RegisterTag}, register_bit::Int, ::Type{SIMDTag}, simd_bit::Int
)
    var_layout = emitter.environment[var]
    @show var_layout

    @assert res ∉ emitter.environment

    register_index = SubIndex(RegisterTag(), 2^register_bit, 2)
    simd_index = SubIndex(SIMDTag(), 2^register_bit, 2)
    register_phys_index = inv(var_layout)[register_index]
    simd_phys_index = inv(var_layout)[simd_index]

    res_layout = copy(var_layout)
    delete!(res_layout, register_phys_index)
    delete!(res_layout, simd_phys_index)
    res_layout[register_phys_index] = simd_index
    res_layout[simd_phys_index] = register_index
    @show res_layout

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

    register_loop(res_layout) do state
        mask = 1 << register_bit
        bit = state.register & (1 << register_bit) ≠ 0
        state0 = State(state.register & ~mask)
        state1 = State(state.register | mask)
        reg_name = register_name(res, state)
        var0_name = register_name(var, state0)
        var1_name = register_name(var, state1)
        if !bit
            push!(emitter.statements, :($reg_name = $get_lo($var0_name, $var1_name)))
        else
            push!(emitter.statements, :($reg_name = $get_hi($var0_name, $var1_name)))
        end
    end

    return nothing
end

end
