using IndexSpaces
using Primes
using Random
using Test

@enum CHORDTag CplxTag BeamTag DishTag FreqTag PolrTag TimeTag

const Cplx = Index{Physics,CplxTag}
const Beam = Index{Physics,BeamTag}
const Dish = Index{Physics,DishTag}
const Freq = Index{Physics,FreqTag}
const Polr = Index{Physics,PolrTag}
const Time = Index{Physics,TimeTag}

Random.seed!(0)
@testset "Indices and layouts" begin
    # Machine indices
    simd = SIMD(:simd, 1, 32)
    thread = Thread(:thread, 1, 32)
    warp = Warp(:warp, 1, 32)
    block = Block(:block, 1, 1024)
    shared = Shared(:shared, 1, 131072)
    memory = Memory(:memory, 1, 2^31)
    # TODO: Split register
    register = Register(:register, 1, 256)
    loopT1 = Loop(:T1, 1, 4)
    loopT2 = Loop(:T2, 1, 256)
    mach_indices = Index{Machine}[simd, register, thread, warp, block, shared, memory, loopT1, loopT2]

    # Physics indices
    int4value = IntValue(:intvalue, 1, 4)
    int8value = IntValue(:intvalue, 1, 8)
    cplx = Cplx(:cplx, 1, 2)
    beam = Beam(:beam, 1, 96)
    dish = Dish(:dish, 1, 512)
    freq = Freq(:freq, 1, 16)
    polr = Polr(:polr, 1, 2)
    time = Time(:time, 1, 32768)
    phys_indices = Index{Physics}[int4value, int8value, cplx, beam, dish, freq, polr, time]

    for indices in [mach_indices, phys_indices]
        # Basic tests for index comparisons
        indices′ = sort(indices)
        @test issorted(indices′)
        sort!(indices)
        @test indices == indices′

        # Create some trivial subindices
        for iter in 1:10
            ind = rand(indices)
            subind = Index{indextype(ind),indextag(ind)}(ind.name, ind.offset, ind.length)
            @test subind == ind
            @test subind ∈ ind
            @test ind ∈ subind
            push!(indices, subind)
        end

        # Create some subindices
        for iter in 1:20
            ind = rand(indices)
            fs = factor(ind.length)
            fs = vcat([repeat([k], v) for (k, v) in fs]...)
            @assert prod(fs) == ind.length
            # Choose destination for each prime factor: 1 => offset, 2 => length, 3 => unused
            fs3 = rand(1:3, length(fs))
            off = prod(fs[i] for i in 1:length(fs) if fs3[i] == 1; init=1)
            len = prod(fs[i] for i in 1:length(fs) if fs3[i] == 2; init=1)
            if len > 1
                subind = Index{indextype(ind),indextag(ind)}(ind.name, ind.offset * off, len)
                @test subind ∈ ind
                if subind == ind
                    @test ind ∈ subind
                else
                    @test ind ∉ subind
                end
                push!(indices, subind)
            end
        end

        sort!(indices)
        @test issorted(indices)
    end

    for mind in mach_indices, pind in phys_indices
        @test mind ≠ pind
    end

    dish01 = Dish(:dish, 1, 4)
    dish2etc = Dish(:dish, 4, 128)

    layout_E_memory = Layout(
        Dict(
            int4value => SIMD(:simd, 1, 4),
            cplx => SIMD(:simd, 4, 2),
            dish01 => SIMD(:simd, 4 * 2, 4),
            dish2etc => Memory(:memory, 1, 128),
            freq => Memory(:memory, 128, 16),
            polr => Memory(:memory, 128 * 16, 2),
            time => Memory(:memory, 128 * 16 * 2, 32768),
        ),
    )

    loopT1 = Loop(:T1, 1, 4)
    loopT2 = Loop(:T2, 1, 256)

    time01234 = Time(:time, 1, 32)
    time56 = Time(:time, 32, 4)
    time7etc = Time(:time, 128, 256)

    layout_E_shared = Layout(
        Dict(
            int4value => SIMD(:simd, 1, 4),
            cplx => SIMD(:simd, 4, 2),
            dish01 => SIMD(:simd, 4 * 2, 4),
            dish2etc => Shared(:shared, 1, 128),
            time01234 => Shared(:shared, 129, 32),
            time56 => loopT1,
            time7etc => loopT2,
            polr => Block(:block, 1, 2),
            freq => Block(:block, 2, 16),
        ),
    )

    dish23 = Dish(:dish, 4, 4)
    dish456 = Dish(:dish, 16, 8)
    dish78 = Dish(:dish, 128, 4)

    time01 = Time(:time, 1, 4)
    time234 = Time(:time, 4, 8)

    layout_E_registers = Layout(
        Dict(
            int4value => SIMD(:simd, 1, 4),
            cplx => SIMD(:simd, 4, 2),
            dish01 => SIMD(:simd, 4 * 2, 4),
            dish23 => Register(:register, 1, 4),
            dish456 => Thread(:thread, 1, 8),
            dish78 => Warp(:warp, 1, 4),
            time01 => Thread(:thread, 8, 4),
            time234 => Warp(:warp, 4, 8),
            time56 => loopT1,
            time7etc => loopT2,
            polr => Block(:block, 1, 2),
            freq => Block(:block, 2, 16),
        ),
    )

    dish1 = Dish(:dish, 2, 2)
    dish2 = Dish(:dish, 4, 2)
    dish3 = Dish(:dish, 8, 2)
    dish4 = Dish(:dish, 16, 2)

    time23 = Time(:time, 4, 4)
    time1 = Time(:time, 2, 2)
    time2 = Time(:time, 4, 2)
    time3 = Time(:time, 8, 2)
    time4 = Time(:time, 16, 2)

    layouts = [layout_E_memory, layout_E_shared, layout_E_registers]
    for layout in layouts
        @test layout == layout
        @test inv(inv(layout)) == layout

        layout′ = copy(layout)
        @test layout′ == layout
        mach_cplx = layout′[cplx]
        mach_dish23 = layout′[dish23]
        mach_time23 = layout′[time23]
        delete!(layout′, cplx)
        @test cplx ∉ layout′
        delete!(layout′, dish23)
        @test dish23 ∉ layout′
        @test dish2 ∉ layout′
        @test dish3 ∉ layout′
        @test dish1 ∈ layout′
        @test dish4 ∈ layout′
        delete!(layout′, time23)
        @test time23 ∉ layout′
        @test time2 ∉ layout′
        @test time3 ∉ layout′
        @test time1 ∈ layout′
        @test time4 ∈ layout′

        layout′[cplx] = mach_cplx
        layout′[dish23] = mach_dish23
        layout′[time23] = mach_time23
        layout1 = layout′
        layout2 = layout
        @test layout′ == layout
    end
end
