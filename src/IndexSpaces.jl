module IndexSpaces

using CUDA
using CUDASIMDTypes

################################################################################

export IndexType, Physics, Machine
@enum IndexType Physics Machine

const IndexTag = Any

export MachineIndexTag, SIMDTag, ThreadTag, WarpTag, BlockTag, SharedTag, MemoryTag, LoopTag, RegisterTag
@enum MachineIndexTag SIMDTag ThreadTag WarpTag BlockTag SharedTag MemoryTag LoopTag RegisterTag

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
        @assert length ≥ 2
        return new{Typ,Tag}(name, offset, length)
    end
end

make_tuple(i::Index{Typ,Tag}) where {Typ,Tag} = (Typ, Symbol(Tag), i.name, i.offset, i.length)

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

export SIMD, Thread, Warp, Block, Shared, Memory, Loop, Register
const SIMD = Index{Machine,SIMDTag}
const Thread = Index{Machine,ThreadTag}
const Warp = Index{Machine,WarpTag}
const Block = Index{Machine,BlockTag}
const Shared = Index{Machine,SharedTag}
const Memory = Index{Machine,MemoryTag}
const Loop = Index{Machine,LoopTag}
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

################################################################################

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
        # Handle cancellative elements
        args[1] ≡ :* && args[2] == 0 && return args[2]
        args[1] ≡ :* && args[3] == 0 && return args[3]
        args[1] ≡ :& && args[2] == 0 && return args[2]
        args[1] ≡ :& && args[3] == 0 && return args[3]
    end
    return Expr(head, args...)
end

struct State
    dict::Dict{Symbol,Int32}
end
State() = State(Dict{Symbol,Int32}())
Base.copy(state::State) = State(copy(state.dict))

function register_name(name::Symbol, state::State)
    return Symbol(join([name; [string(r) * string(state.dict[r]) for r in sort!(collect(keys(state.dict)))]], "_"))
end

function loop_over_registers(f, layout::Layout{Physics,Machine})
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

cuda_threadidx() = Int32(0)
cuda_warpidx() = Int32(0)
cuda_blockidx() = Int32(0)
CUDA.@device_override cuda_threadidx() = threadIdx().x - 0x1
CUDA.@device_override cuda_warpidx() = threadIdx().y - 0x1
CUDA.@device_override cuda_blockidx() = blockIdx().x - 0x1

indexvalue(::State, ::SIMD) = @assert false # needs to be handled by the caller
indexvalue(state::State, register::Register) = state.dict[register.name]::Code
indexvalue(::State, ::Thread) = :(IndexSpaces.cuda_threadidx())::Code
indexvalue(::State, ::Warp) = :(IndexSpaces.cuda_warpidx())::Code
indexvalue(::State, ::Block) = :(IndexSpaces.cuda_blockidx())::Code
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

    is_shared = any(mach isa Shared for (phys, mach) in mem_layout.dict)
    is_memory = any(mach isa Memory for (phys, mach) in mem_layout.dict)
    @assert is_shared ⊻ is_memory

    addr = Int32(0)
    for (phys, mach) in mem_layout.dict
        mach isa SIMD && continue
        # Ensure that we are mapping to memory
        is_shared && mach::Union{Block,Shared,Loop}
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
        addr = :($addr + $machval)
    end
    return evaluate_partially(addr)::Code
end

################################################################################

# Code generation

export Environment
struct Environment
    dict::Dict{Symbol,Layout{Physics,Machine}}
end
Environment() = Environment(Dict{Symbol,Layout{Physics,Machine}}())

Base.copy(env::Environment) = Environment(copy(env.dict))
Base.getindex(env::Environment, var::Symbol) = env.dict[var]
Base.in(var::Symbol, env::Environment) = var ∈ keys(env.dict)
Base.setindex!(env::Environment, layout::Layout{Physics,Machine}, var::Symbol) = env.dict[var] = layout

export Emitter
struct Emitter
    environment::Environment
    statements::Vector{Code}
end
Emitter() = Emitter(Environment(), Code[])

################################################################################

# Control flow

export block!
function block!(body!, emitter::Emitter)
    environment′ = copy(emitter.environment)

    emitter′ = Emitter(environment′, Code[])
    body!(emitter′)

    push!(
        emitter.statements,
        quote
            let
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
    environment′[index.name] = Layout{Physics,Machine}(Dict(index => loop))

    emitter′ = Emitter(environment′, Code[])
    body!(emitter′)

    push!(
        emitter.statements,
        quote
            for $(loop.name) in ($(Int32(0))):($(Int32(loop.offset))):($(Int32(loop.offset * loop.length - 1)))
                $(emitter′.statements...)
            end
        end,
    )

    return nothing
end

export unrolled_loop!
function unrolled_loop!(body!, emitter::Emitter, layout::Pair{<:Index{Physics},Loop})
    index, loop = layout

    environment′ = copy(emitter.environment)
    environment′[index.name] = Layout{Physics,Machine}(Dict(index => loop))

    emitter′ = Emitter(environment′, Code[])
    body!(emitter′)

    for i in Int32(0):Int32(loop.offset):Int32(loop.offset * loop.length - 1)
        push!(
            emitter.statements,
            quote
                let
                    $(loop.name) = $i
                    $(emitter′.statements...)
                end
            end,
        )
    end

    return nothing
end

################################################################################

# Thread synchronization

cuda_sync_threads() = nothing
CUDA.@device_override cuda_sync_threads() = sync_threads()

export sync_threads!
function sync_threads!(emitter::Emitter)
    push!(emitter.statements, :(IndexSpaces.cuda_sync_threads()))
    return nothing
end

################################################################################

# Memory access

export load!
function load!(emitter::Emitter, reg::Pair{Symbol,Layout{Physics,Machine}}, mem::Pair{Symbol,Layout{Physics,Machine}})
    reg_var, reg_layout = reg
    mem_var, mem_layout = mem
    @assert reg_var ∉ emitter.environment
    emitter.environment[reg_var] = reg_layout

    loop_over_registers(reg_layout) do state
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

    loop_over_registers(reg_layout) do state
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

function Base.permute!(emitter::Emitter, res::Symbol, var::Symbol, register::Register, simd::SIMD)
    var_layout = emitter.environment[var]

    @assert res ∉ emitter.environment

    @assert register.length == 2
    @assert ispow2(register.offset)
    register_bit = trailing_zeros(register.offset)
    @assert register.offset == 1 << register_bit
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

    loop_over_registers(tmp_layout) do state
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
                $res0_name = $get_lo($var0_name, $var1_name)
                $res1_name = $get_hi($var0_name, $var1_name)
            end,
        )
    end

    return nothing
end

function CUDA.shfl_xor_sync(threadmask::UInt32, val::T, mask::UInt32) where {T<:Union{Float32,Int32}}
    return reinterpret(T, shfl_xor_sync(threadmask, reinterpret(UInt32, val), mask))
end
function CUDA.shfl_xor_sync(threadmask::UInt32, val::T, mask::UInt32) where {T<:Union{Int4x8,Int8x4,Int16x2,Float16x2,BFloat16x2}}
    return T(shfl_xor_sync(threadmask, val.val, mask))
end

cuda_shfl_xor_sync(threadmask, val, mask) = val
CUDA.@device_override cuda_shfl_xor_sync(threadmask, val, mask) = shfl_xor_sync(threadmask, val, mask)

function Base.permute!(emitter::Emitter, res::Symbol, var::Symbol, register::Register, thread::Thread)
    var_layout = emitter.environment[var]

    @assert res ∉ emitter.environment

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

    thread_mask = UInt32(1 << thread_bit)

    push!(
        emitter.statements,
        quote
            is_hi_thread = IndexSpaces.cuda_threadidx() & $thread_mask ≠ 0
        end,
    )
    loop_over_registers(tmp_layout) do state
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
                src = is_hi_thread ? $var0_name : $var1_name
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, $thread_mask)
                if is_hi_thread
                    $res0_name = dst
                    $res1_name = $var1_name
                else
                    $res0_name = $var0_name
                    $res1_name = dst
                end
            end,
        )
    end

    return nothing
end

export widen!
function widen!(emitter::Emitter, res::Symbol, var::Symbol, simd_register::Pair{SIMD,Register})
    simd, register = simd_register

    var_layout = emitter.environment[var]

    # res may or may not already exist
    # @assert res ∉ emitter.environment

    @assert simd.length == 2
    @assert ispow2(simd.offset)
    simd_bit = trailing_zeros(simd.offset)
    @assert simd.offset == 1 << simd_bit
    simd_phys = inv(var_layout)[simd]

    @assert register.length == 2
    @assert ispow2(register.offset)
    register_bit = trailing_zeros(register.offset)
    @assert register.offset == 1 << register_bit

    tmp_layout = copy(var_layout)
    delete!(tmp_layout, simd_phys)

    res_layout = copy(tmp_layout)
    res_layout[simd_phys] = register

    inv_res_layout = inv(res_layout)
    value = inv_res_layout[SIMD(:simd, 1, 2)]
    value_tag = indextag(value)::ValueTag
    res_layout[Index{Physics,value_tag}(value.name, simd.offset, simd.length)] = simd

    emitter.environment[res] = res_layout

    inv_res_layout = inv(res_layout)
    value = inv_res_layout[SIMD(:simd, 1, 2)]
    value_tag = indextag(value)
    @assert value_tag isa ValueTag

    loop_over_registers(tmp_layout) do state
        state0 = copy(state)
        state1 = copy(state)
        state0.dict[register.name] = get(state0.dict, register.name, Int32(0)) + Int32(0 * register.offset)
        state1.dict[register.name] = get(state1.dict, register.name, Int32(0)) + Int32(1 * register.offset)
        res0_name = register_name(res, state0)
        res1_name = register_name(res, state1)
        var_name = register_name(var, state)
        if value_tag == IntValueTag && simd_bit == 2
            stmt = :(($res0_name, $res1_name) = convert(NTuple{2,Int8x4}, $var_name))
        elseif value_tag == IntValueTag && simd_bit == 3
            stmt = :(($res0_name, $res1_name) = convert(NTuple{2,Int16x2}, $var_name))
        elseif value_tag == IntValueTag && simd_bit == 4
            stmt = :(($res0_name, $res1_name) = convert(NTuple{2,Int32}, $var_name))
        elseif value_tag == FloatValueTag && simd_bit == 4
            stmt = :(($res0_name, $res1_name) = convert(NTuple{2,Float32}, $var_name))
        elseif value_tag == BFloatValueTag && simd_bit == 4
            stmt = :(($res0_name, $res1_name) = convert(NTuple{2,BFloat32}, $var_name))
        else
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
    @assert ispow2(register.offset)
    register_bit = trailing_zeros(register.offset)
    @assert register.offset == 1 << register_bit
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

    inv_res_layout = inv(res_layout)
    value = inv_res_layout[SIMD(:simd, 1, 2)]
    value_tag = indextag(value)
    @assert value_tag isa ValueTag

    loop_over_registers(tmp_layout) do state
        state0 = copy(state)
        state1 = copy(state)
        state0.dict[register.name] = get(state0.dict, register.name, Int32(0)) + Int32(0 * register.offset)
        state1.dict[register.name] = get(state1.dict, register.name, Int32(0)) + Int32(1 * register.offset)
        res_name = register_name(res, state)
        var0_name = register_name(var, state0)
        var1_name = register_name(var, state1)
        if value_tag == IntValueTag && simd_bit == 2
            stmt = :($res_name = convert(Int4x8, ($var0_name, $var1_name)))
        elseif value_tag == IntValueTag && simd_bit == 3
            stmt = :($res_name = convert(Int8x4, ($var0_name, $var1_name)))
        elseif value_tag == IntValueTag && simd_bit == 4
            stmt = :($res_name = convert(Int16x2, ($var0_name, $var1_name)))
        elseif value_tag == FloatValueTag && simd_bit == 4
            stmt = :($res_name = convert(NTuple{2,Float32}, ($var0_name, $var1_name)))
        elseif value_tag == BFloatValueTag && simd_bit == 4
            stmt = :($res_name = convert(NTuple{2,BFloat32}, ($var0_name, $var1_name)))
        else
            @assert false
        end
        push!(emitter.statements, stmt)
    end

    return nothing
end

export split!
function split!(emitter::Emitter, ress::AbstractVector{Symbol}, var::Symbol, index::Index{Physics})
    @assert !isempty(ress)
    @assert length(Set(ress)) == length(ress)
    @assert all(res ∉ emitter.environment for res in ress)

    @assert index.length == length(ress)
    var_layout = emitter.environment[var]
    var_layout[index]::Register

    res_layout = delete!(copy(var_layout), index)
    for res in ress
        emitter.environment[res] = res_layout
    end

    loop_over_registers(res_layout) do state
        for (n, res) in enumerate(ress)
            state′ = copy(state)
            state′.dict[index.name] = get(state′.dict, index.name, Int32(0)) + Int32((n - 1) * index.offset)
            res_name = register_name(res, state)
            var_name = register_name(var, state′)
            push!(emitter.statements, :($res_name = $var_name))
        end
    end

    return nothing
end

function Base.merge!(
    emitter::Emitter, res::Symbol, vars::AbstractVector{Symbol}, index_register::Pair{<:Index{Physics},<:Index{Machine}}
)
    index, register = index_register
    @assert index.length == register.length

    @assert length(Set(vars)) == length(vars)

    @assert index.length == length(vars)
    var_layouts = [emitter.environment[var] for var in vars]
    @assert !isempty(vars)
    var_layout = var_layouts[1]
    @assert all(vl == var_layout for vl in var_layouts)
    @assert index ∉ var_layout

    @assert res ∉ emitter.environment
    res_layout = copy(var_layout)
    res_layout[index] = register
    emitter.environment[res] = res_layout

    loop_over_registers(var_layout) do state
        for (n, var) in enumerate(vars)
            state′ = copy(state)
            state′.dict[index.name] = get(state′.dict, index.name, Int32(0)) + Int32((n - 1) * index.offset)
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
    phys_register = inv(var_layout)[register]

    @assert res ∉ emitter.environment
    res_layout = copy(var_layout)
    delete!(res_layout, phys_register)
    emitter.environment[res] = res_layout

    loop_over_registers(res_layout) do state
        res_name = register_name(res, state)
        for i in 0:(loop.offset):(loop.offset * loop.length - 1)
            state′ = copy(state)
            state′.dict[register.name] = get(state′.dict, register.name, Int32(0)) + Int32(i)
            var_name = register_name(var, state′)
            if i == 0
                push!(emitter.statements, :($res_name = zero($var_name)))
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
    delete!(tmp_layout, C_col[1])
    loop_over_registers(tmp_layout) do state
        state0 = copy(state)
        state1 = copy(state)
        state0.dict[C_col[1].name] = get(state0.dict, C_col[1].name, Int32(0)) + Int32(0 * C_col[1].offset)
        state1.dict[C_col[1].name] = get(state1.dict, C_col[1].name, Int32(0)) + Int32(1 * C_col[1].offset)
        A_name = register_name(A, state)
        B_name = register_name(B, state)
        C0_name = register_name(C, state0)
        C1_name = register_name(C, state1)
        D0_name = register_name(D, state0)
        D1_name = register_name(D, state1)
        push!(
            emitter.statements,
            quote
                A_frag = $A_name::Int8x4
                B_frag = $B_name::Int8x4
                C_frag = ($C0_name, $C1_name)::NTuple{2,Int32}
                D_frag = IndexSpaces.mma_m8n8k16(A_frag, B_frag, C_frag)::NTuple{2,Int32}
                ($D0_name, $D1_name) = D_frag
            end,
        )
    end

    return nothing
end

export apply!
function apply!(emitter::Emitter, res::Symbol, res_layout::Layout{Physics,Machine}, code::Code)
    # res might or might not exist
    # @assert res ∉ emitter.environment
    emitter.environment[res] = res_layout

    inv_res_layout = inv(res_layout)
    value = inv_res_layout[SIMD(:simd, 1, 2)]
    value_tag = indextag(value)::ValueTag
    value_bits = 0
    while Index{Physics,value_tag}(value.name, 1, 1 << (value_bits + 1)) in res_layout
        value_bits += 1
    end

    loop_over_registers(res_layout) do state
        res_name = register_name(res, state)
        # if value_tag == IntValueTag && value_bits == 2
        #     stmt = :($res_name = Int4x8($code, $code, $code, $code, $code, $code, $code, $code))
        # elseif value_tag == IntValueTag && value_bits == 3
        #     stmt = :($res_name = Int8x4($code, $code, $code, $code))
        # elseif value_tag == IntValueTag && value_bits == 4
        #     stmt = :($res_name = Int16x2($code, $code))
        # elseif value_tag == IntValueTag && value_bits == 5
        #     stmt = :($res_name = Int32($code))
        # elseif value_tag == FloatValueTag && value_bits == 4
        #     stmt = :($res_name = Float16x2($code, $code))
        # elseif value_tag == FloatValueTag && value_bits == 5
        #     stmt = :($res_name = Float32($code))
        # elseif value_tag == BFloatValueTag && value_bits == 4
        #     stmt = :($res_name = BFloat16x2($code, $code))
        # elseif value_tag == BFloatValueTag && value_bits == 5
        #     stmt = :($res_name = BFloat32($code))
        # else
        #     @assert false
        # end
        # push!(emitter.statements, stmt)

        # TODO: Check type
        push!(emitter.statements, :($res_name = $code))
    end

    return nothing
end

function apply!(emitter::Emitter, res::Symbol, vars::AbstractVector{Symbol}, code)
    @assert !isempty(vars)
    var_layouts = [emitter.environment[var] for var in vars]
    var_layout = var_layouts[1]
    @assert all(vl == var_layout for vl in var_layouts)

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

    loop_over_registers(res_layout) do state
        res_name = register_name(res, state)
        var_names = [register_name(var, state) for var in vars]
        push!(emitter.statements, :($res_name = $(code(var_names...))))
    end

    return nothing
end

end
