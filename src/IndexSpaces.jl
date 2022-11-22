module IndexSpaces

using CUDASIMDTypes

################################################################################

export IndexType, Physics, Machine
@enum IndexType Physics Machine

const IndexTag = Any

export MachineIndexTag, SIMDTag, ThreadTag, WarpTag, BlockTag, SharedTag, MemoryTag, LoopTag, RegisterTag
@enum MachineIndexTag SIMDTag ThreadTag WarpTag BlockTag SharedTag MemoryTag LoopTag RegisterTag

export Index
struct Index{Typ,Tag}
    name::Symbol
    offset::Int
    length::Int
    function Index{Typ,Tag}(name::Symbol, offset::Integer, length::Integer) where {Typ,Tag}
        @assert Typ isa IndexType
        @assert Tag isa IndexTag
        @assert offset ≥ 1
        @assert length ≥ 2
        return new{Typ,Tag}(name, offset, length)
    end
end

make_tuple(i::Index{Typ,Tag}) where {Typ,Tag} = (Typ, Tag, i.name, i.offset, i.length)

function Base.show(io::IO, index::Index{Typ,Tag}) where {Typ,Tag}
    print(io, "$Typ.$(index.name):$(index.offset)/$(index.length)")
    return nothing
end

export indextype, indextag
indextype(::Type{<:Index{Typ}}) where {Typ} = Typ
indextag(::Type{<:Index{<:Any,Tag}}) where {Tag} = Tag
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
Base.in(x::Index{Typ,Tag}, y::Index{Typ,Tag}) where {Typ,Tag} = x.name == y.name && Range(x) ∈ Range(y)

function Base.isdisjoint(x::Range, y::Range)
    xbeg = x.offset
    xend = x.offset * x.length
    ybeg = y.offset
    yend = y.offset * y.length
    return yend ≤ xbeg || xend ≤ ybeg
end
Base.isdisjoint(x::Index, y::Index) = true
function Base.isdisjoint(x::Index{Typ,Tag}, y::Index{Typ,Tag}) where {Typ,Tag}
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
struct Layout{Typ1,Typ2}
    dict::Dict{Index{Typ1},Index{Typ2}}
    function Layout{Typ1,Typ2}(dict::Dict{<:Index{Typ1},<:Index{Typ2}}) where {Typ1,Typ2}
        @assert Typ1 isa IndexType
        @assert Typ2 isa IndexType
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
    Layout(dict::Dict{<:Index{Typ1},<:Index{Typ2}}) where {Typ1,Typ2} = Layout{Typ1,Typ2}(dict)
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

function Base.:(==)(layout1::Layout{Typ1,Typ2}, layout2::Layout{Typ1,Typ2}) where {Typ1,Typ2}
    return layout1.dict == layout2.dict
end

function Base.inv(layout::Layout{Typ1,Typ2}) where {Typ1,Typ2}
    return Layout(Dict{Index{Typ2},Index{Typ1}}(v => k for (k, v) in layout.dict))
end

function Base.in(key::Index{Typ1}, layout::Layout{Typ1,Typ2}) where {Typ1,Typ2}
    key ∈ keys(layout.dict) && return true
    for (k, v) in layout.dict
        key ∈ k && return true
    end
    return false
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
    throw(KeyError("Index $key not found"))
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

################################################################################

const Code = Union{Expr,Number,Symbol}

evaluate_partially(any::Any) = any
function evaluate_partially(expr::Expr)
    expr = Expr(expr.head, evaluate_partially.(expr.args)...)
    if expr.head ≡ :call && length(expr.args) == 3
        # Evaluate an expression
        if expr.args[2] isa Number && expr.args[3] isa Number
            expr.args[1] ≡ :+ && return expr.args[2] + expr.args[3]
            expr.args[1] ≡ :- && return expr.args[2] - expr.args[3]
            expr.args[1] ≡ :* && return expr.args[2] * expr.args[3]
            expr.args[1] ≡ :÷ && return expr.args[2] ÷ expr.args[3]
            expr.args[1] ≡ :% && return expr.args[2] % expr.args[3]
            expr.args[1] ≡ :& && return expr.args[2] & expr.args[3]
            expr.args[1] ≡ :| && return expr.args[2] | expr.args[3]
            expr.args[1] ≡ :⊻ && return expr.args[2] ⊻ expr.args[3]
        end
        # Remove neutral elements
        expr.args[1] ≡ :+ && expr.args[2] == 0 && return expr.args[3]
        expr.args[1] ≡ :+ && expr.args[3] == 0 && return expr.args[2]
        expr.args[1] ≡ :- && expr.args[3] == 0 && return expr.args[2]
        expr.args[1] ≡ :* && expr.args[2] == 1 && return expr.args[3]
        expr.args[1] ≡ :* && expr.args[3] == 1 && return expr.args[2]
        expr.args[1] ≡ :÷ && expr.args[3] == 1 && return expr.args[2]
        expr.args[1] ≡ :| && expr.args[2] == 0 && return expr.args[3]
        expr.args[1] ≡ :| && expr.args[3] == 0 && return expr.args[2]
        expr.args[1] ≡ :⊻ && expr.args[2] == 0 && return expr.args[3]
        expr.args[1] ≡ :⊻ && expr.args[3] == 0 && return expr.args[2]
        # Handle cancellative elements
        expr.args[1] ≡ :* && expr.args[2] == 0 && return expr.args[2]
        expr.args[1] ≡ :* && expr.args[3] == 0 && return expr.args[3]
        expr.args[1] ≡ :& && expr.args[2] == 0 && return expr.args[2]
        expr.args[1] ≡ :& && expr.args[3] == 0 && return expr.args[3]
    end
    return expr
end

struct State
    dict::Dict{Symbol,Int32}
end
State() = State(Dict{Symbol,Int32}())
Base.copy(state::State) = State(copy(state.dict))

function register_name(name::Symbol, state::State)
    return Symbol(name, "_", join([string(r) * string(state.dict[r]) for r in sort!(collect(keys(state.dict)))], "_"))
end

function register_loop(f, layout::Layout{Physics,Machine})
    registers = sort!(filter!(mach -> mach isa Register, collect(values(layout.dict))))
    function go(state::State, n::Int)
        if n == 0
            f(state)
        else
            reg = registers[n]
            newstate = copy(state)
            for r in 0:(reg.length - 1)
                val = get(state.dict, reg.name, Int32(0))
                newstate.dict[reg.name] = val + reg.offset * r
                go(newstate, n - 1)
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
        oldphysval = get(vals, phys, Int32(0))
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
    return evaluate_partially(addr)::Code
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
function Base.permute!(emitter::Emitter, res::Symbol, var::Symbol, register::Register, simd::SIMD)
    var_layout = emitter.environment[var]

    @assert res ∉ emitter.environment

    @assert register.length == 2
    register_bit = round(Int, log2(register.offset))
    @assert register.offset == 1 << register_bit
    register_phys = inv(var_layout)[register]

    @assert simd.length == 2
    simd_bit = round(Int, log2(simd.offset))
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

    register_loop(tmp_layout) do state
        mask = 1 << register_bit
        state0 = state
        state1 = copy(state)
        state1.dict[register.name] = get(state1.dict, register.name, Int32(0)) + Int32(1 << register_bit)
        res0_name = register_name(res, state0)
        res1_name = register_name(res, state1)
        var0_name = register_name(var, state0)
        var1_name = register_name(var, state1)
        push!(emitter.statements, :($res0_name = $get_lo($var0_name, $var1_name)))
        push!(emitter.statements, :($res1_name = $get_hi($var0_name, $var1_name)))
    end

    return nothing
end

end
