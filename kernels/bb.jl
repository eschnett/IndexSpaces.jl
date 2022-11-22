using IndexSpaces
using Test

@enum CHORDTag Value_Int4Tag Value_Int8Tag CplxTag BeamTag DishTag FreqTag PolrTag TimeTag

const Value_Int4 = Index{Physics,Value_Int4Tag}
const Value_Int8 = Index{Physics,Value_Int8Tag}
const Cplx = Index{Physics,CplxTag}
const Beam = Index{Physics,BeamTag}
const Dish = Index{Physics,DishTag}
const Freq = Index{Physics,FreqTag}
const Polr = Index{Physics,PolrTag}
const Time = Index{Physics,TimeTag}

# threadIdx() = (x=Int32(2), y=Int32(3), z=Int32(1))
# blockIdx() = (x=Int32(4), y=Int32(1), z=Int32(1))
# const T1 = Int32(5)
# const T2 = Int32(6)

@testset "Example" begin
    # Machine indices
    simd = SIMD(:simd, 1, 32)
    thread = Thread(:thread, 1, 32)
    warp = Warp(:warp, 1, 32)
    block = Block(:block, 1, 1024)
    shared = Shared(:shared, 1, 131072)
    memory = Memory(:memory, 1, 2^32)
    loopT1 = Loop(:T1, 1, 4)
    loopT2 = Loop(:T2, 1, 256)

    # Physics indices
    value_int4 = Value_Int4(:Int4, 1, 4)
    value_int8 = Value_Int8(:Int8, 1, 8)
    cplx = Cplx(:cplx, 1, 2)
    beam = Beam(:beam, 1, 96)
    dish = Dish(:dish, 1, 512)
    freq = Freq(:freq, 1, 16)
    polr = Polr(:polr, 1, 2)
    time = Time(:time, 1, 32768)

    # Physics quantities
    E = Quantity(:E, Integer, [cplx, dish, freq, polr, time, value_int4])
    A = Quantity(:A, Integer, [cplx, beam, dish, freq, polr, value_int8])
    J = Quantity(:J, Integer, [cplx, beam, freq, polr, time, value_int4])

    # Memory layouts

    # E-matrix layout

    dish01 = Dish(:dish, 1, 4)
    dish2etc = Dish(:dish, 4, 128)

    layout_E_memory = Layout(
        Dict(
            value_int4 => SIMD(:simd, 1, 4),
            cplx => SIMD(:simd, 4, 2),
            dish01 => SIMD(:simd, 4 * 2, 4),
            dish2etc => Memory(:memory, 1, 128),
            freq => Memory(:memory, 128, 16),
            polr => Memory(:memory, 128 * 16, 2),
            time => Memory(:memory, 128 * 16 * 2, 32768),
        ),
    )

    # A-matrix layout

    dish0 = Dish(:dish, 1, 2)
    dish1etc = Dish(:dish, 2, 256)

    layout_A_memory = Layout(
        Dict(
            value_int8 => SIMD(:simd, 1, 8),
            cplx => SIMD(:simd, 8, 2),
            dish0 => SIMD(:simd, 8 * 2, 2),
            dish1etc => Memory(:memory, 1, 256),
            beam => Memory(:memory, 256, 96),
            polr => Memory(:memory, 256 * 96, 2),
            freq => Memory(:memory, 256 * 96 * 2, 16),
        ),
    )

    # J-matrix layout

    time01 = Time(:time, 1, 4)
    time2etc = Time(:time, 4, 8192)

    layout_J_memory = Layout(
        Dict(
            value_int4 => SIMD(:simd, 1, 4),
            cplx => SIMD(:simd, 4, 2),
            time01 => Memory(:memory, 1, 4),
            time2etc => Memory(:memory, 4, 8192),
            polr => Memory(:memory, 4 * 8192, 2),
            freq => Memory(:memory, 4 * 8192 * 2, 16),
            beam => Memory(:memory, 4 * 8192 * 2 * 16, 96),
        ),
    )

    # Shared memory layouts

    # E-matrix layout

    loopT1 = Loop(:T1, 1, 4)
    loopT2 = Loop(:T2, 1, 256)

    time01234 = Time(:time, 1, 32)
    time56 = Time(:time, 32, 4)
    time7etc = Time(:time, 128, 256)

    layout_E_shared = Layout(
        Dict(
            value_int4 => SIMD(:simd, 1, 4),
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

    # Register layouts

    # E-matrix layout

    dish23 = Dish(:dish, 4, 4)
    dish456 = Dish(:dish, 16, 8)
    dish78 = Dish(:dish, 128, 4)

    time234 = Time(:time, 4, 8)

    layout_E_registers = Layout(
        Dict(
            value_int4 => SIMD(:simd, 1, 4),
            cplx => SIMD(:simd, 4, 2),
            dish01 => SIMD(:simd, 4 * 2, 4),
            dish23 => Register(:dish, 4, 4),
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

    # A-matrix layout

    dish234 = Dish(:dish, 4, 8)
    dish56 = Dish(:dish, 32, 4)

    beam012 = Beam(:beam, 1, 8)
    beam3 = Beam(:beam, 8, 2)
    beam456 = Beam(:beam, 16, 6)

    layout_A_registers = Layout(
        Dict(
            value_int8 => SIMD(:simd, 1, 8),
            cplx => Register(:cplx, 1, 2),
            dish01 => SIMD(:simd, 8, 4), # mma input 01
            dish234 => Register(:dish, 4, 8),
            dish56 => Thread(:thread, 1, 4), # mma input 23
            dish78 => Warp(:warp, 1, 4),
            beam012 => Thread(:thread, 4, 8), # mma output 012
            beam3 => Register(:beam, 8, 2),
            beam456 => Warp(:warp, 4, 6),     # since Wb = 6
            polr => Block(:block, 1, 2),
            freq => Block(:block, 2, 16),
        ),
    )

    # Generate code

    emitter = Emitter()

    dish12 = Dish(:dish, 2, 4)
    dish34 = Dish(:dish, 8, 4)
    dish5 = Dish(:dish, 32, 2)
    dish6 = Dish(:dish, 64, 2)

    beam0 = Beam(:beam, 1, 2)
    beam12 = Beam(:beam, 2, 4)

    let
        layout_A0_registers = Layout(
            Dict(
                value_int8 => SIMD(:simd, 1, 8),
                cplx => SIMD(:simd, 8, 2),
                dish0 => SIMD(:simd, 16, 2),
                dish12 => Register(:dish, 2, 4),
                dish34 => Thread(:thread, 2, 4),
                dish5 => Thread(:thread, 1, 2),
                dish6 => Register(:dish, 64, 2),
                dish78 => Warp(:warp, 1, 4),
                beam0 => Register(:beam, 1, 2),
                beam12 => Thread(:thread, 8, 4),
                beam3 => Register(:beam, 8, 2),
                beam456 => Warp(:warp, 4, 6),    # since Wb = 6
                polr => Block(:block, 1, 2),
                freq => Block(:block, 2, 16),
            ),
        )

        load!(emitter, :A0 => layout_A0_registers, :A_memory => layout_A_memory)
        permute!(emitter, :A1, :A0, Register(:dish, 2, 2), SIMD(:simd, 16, 2))
    end

    load!(emitter, :E => layout_E_registers, :E_memory => layout_E_memory)
    store!(emitter, :E_shared => layout_E_shared, :E)

    for stmt in emitter.statements
        println(stmt)
    end
end
