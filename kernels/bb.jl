using IndexSpaces
using Test

# threadIdx() = (x=Int32(2), y=Int32(3), z=Int32(1))
# blockIdx() = (x=Int32(4), y=Int32(1), z=Int32(1))
# const T1 = Int32(5)
# const T2 = Int32(6)

@testset "Example" begin
    # Machine indices
    simd = SIMD()
    register = Register()
    thread = Thread()
    warp = Warp()
    block = Block()
    shared = Shared()
    memory = Memory()

    # Physics indices
    value_int4 = Index(:Int4, 4)
    value_int8 = Index(:Int8, 8)
    cplx = Index(:cplx, 2)
    beam = Index(:beam, 128)
    dish = Index(:dish, 512)
    freq = Index(:freq, 16)
    polr = Index(:polr, 2)
    time = Index(:time, 32768)

    # Physics quantities
    E = Quantity(:E, Integer, [cplx, dish, freq, polr, time, value_int4])
    A = Quantity(:A, Integer, [cplx, beam, dish, freq, polr, value_int8])
    J = Quantity(:J, Integer, [cplx, beam, freq, polr, time, value_int4])

    # Memory layouts

    # E-matrix layout

    dish01 = SubIndex(dish, 1, 4)
    dish2etc = SubIndex(dish, 4, 128)

    layout_E_memory = Layout(
        Dict(
            value_int4 => SubIndex(simd, 1, 4),
            cplx => SubIndex(simd, 4, 2),
            dish01 => SubIndex(simd, 4 * 2, 4),
            dish2etc => SubIndex(memory, 1, 128),
            freq => SubIndex(memory, 128, 16),
            polr => SubIndex(memory, 128 * 16, 2),
            time => SubIndex(memory, 128 * 16 * 2, 32768),
        ),
    )

    # A-matrix layout

    dish0 = SubIndex(dish, 1, 2)
    dish1etc = SubIndex(dish, 2, 256)

    layout_A_memory = Layout(
        Dict(
            value_int8 => SubIndex(simd, 1, 8),
            cplx => SubIndex(simd, 8, 2),
            dish0 => SubIndex(simd, 8 * 2, 2),
            dish1etc => SubIndex(memory, 1, 256),
            beam => SubIndex(memory, 256, 128),
            polr => SubIndex(memory, 256 * 128, 2),
            freq => SubIndex(memory, 256 * 128 * 2, 16),
        ),
    )

    # J-matrix layout

    time01 = SubIndex(time, 1, 4)
    time2etc = SubIndex(time, 4, 8192)

    layout_J_memory = Layout(
        Dict(
            value_int4 => SubIndex(simd, 1, 4),
            cplx => SubIndex(simd, 4, 2),
            time01 => SubIndex(memory, 1, 4),
            time2etc => SubIndex(memory, 4, 8192),
            polr => SubIndex(memory, 4 * 8192, 2),
            freq => SubIndex(memory, 4 * 8192 * 2, 16),
            beam => SubIndex(memory, 4 * 8192 * 2 * 16, 128),
        ),
    )

    # Shared memory layouts

    # E-matrix layout

    loopT1 = Loop(:T1, 4)
    loopT2 = Loop(:T2, 256)

    time01234 = SubIndex(time, 1, 32)
    time56 = SubIndex(time, 32, 4)
    time7etc = SubIndex(time, 128, 256)

    layout_E_shared = Layout(
        Dict(
            value_int4 => SubIndex(simd, 1, 4),
            cplx => SubIndex(simd, 4, 2),
            dish01 => SubIndex(simd, 4 * 2, 4),
            dish2etc => SubIndex(shared, 1, 128),
            time01234 => SubIndex(shared, 129, 32),
            time56 => loopT1,
            time7etc => loopT2,
            polr => SubIndex(block, 1, 2),
            freq => SubIndex(block, 2, 16),
        ),
    )

    # Register layouts

    # E-matrix layout

    dish23 = SubIndex(dish, 4, 4)
    dish456 = SubIndex(dish, 16, 8)
    dish78 = SubIndex(dish, 128, 4)

    time234 = SubIndex(time, 4, 8)

    layout_E_registers = Layout(
        Dict(
            value_int4 => SubIndex(simd, 1, 4),
            cplx => SubIndex(simd, 4, 2),
            dish01 => SubIndex(simd, 4 * 2, 4),
            dish23 => SubIndex(register, 1, 4),
            dish456 => SubIndex(thread, 1, 8),
            dish78 => SubIndex(warp, 1, 4),
            time01 => SubIndex(thread, 8, 4),
            time234 => SubIndex(warp, 4, 8),
            time56 => loopT1,
            time7etc => loopT2,
            polr => SubIndex(block, 1, 2),
            freq => SubIndex(block, 2, 16),
        ),
    )

    # A-matrix layout

    dish234 = SubIndex(dish, 4, 8)
    dish56 = SubIndex(dish, 32, 4)

    beam012 = SubIndex(beam, 1, 8)
    beam3 = SubIndex(beam, 8, 2)
    beam456 = SubIndex(beam, 16, 8)

    layout_A_registers = Layout(
        Dict(
            value_int8 => SubIndex(simd, 1, 8),
            cplx => SubIndex(register, 1, 2),
            dish01 => SubIndex(simd, 8, 4), # mma input 01
            dish234 => SubIndex(register, 2, 8),
            dish56 => SubIndex(thread, 1, 4), # mma input 23
            dish78 => SubIndex(warp, 1, 4),
            beam012 => SubIndex(thread, 4, 8), # mma output 012
            beam3 => SubIndex(register, 16, 2),
            beam456 => SubIndex(warp, 4, 8),     # since Wb = 8
            polr => SubIndex(block, 1, 2),
            freq => SubIndex(block, 2, 16),
        ),
    )

    # Generate code

    # state = IndexSpaces.State(0)
    # vals = IndexSpaces.physics_values(state, layout_E_registers)
    # @show vals
    # addr = IndexSpaces.memory_index(layout_E_registers, layout_E_memory, vals)
    # @show addr

    emitter = Emitter()

    dish12 = SubIndex(dish, 2, 4)
    dish34 = SubIndex(dish, 8, 4)
    dish5 = SubIndex(dish, 32, 2)
    dish6 = SubIndex(dish, 64, 2)

    beam0 = SubIndex(beam, 1, 2)
    beam12 = SubIndex(beam, 2, 4)

    let
        layout_A0_registers = Layout(
            Dict(
                value_int8 => SubIndex(simd, 1, 8),
                cplx => SubIndex(simd, 8, 2),
                dish0 => SubIndex(simd, 16, 2),
                dish12 => SubIndex(register, 1, 4),
                dish34 => SubIndex(thread, 2, 4),
                dish5 => SubIndex(thread, 1, 2),
                dish6 => SubIndex(register, 4, 2),
                dish78 => SubIndex(warp, 1, 4),
                beam0 => SubIndex(register, 8, 2),
                beam12 => SubIndex(thread, 8, 4),
                beam3 => SubIndex(register, 16, 2),
                beam456 => SubIndex(warp, 4, 8),     # since Wb = 8
                polr => SubIndex(block, 1, 2),
                freq => SubIndex(block, 2, 16),
            ),
        )

        load!(emitter, :A0 => layout_A0_registers, :A_memory => layout_A_memory)
        permute!(emitter, :A1, :A0, Register, 0, SIMD, 4)
    end

    #TODO load!(emitter, :E => layout_E_registers, :E_memory => layout_E_memory)
    #TODO store!(emitter, :E_shared => layout_E_shared, :E)

    for stmt in emitter.statements
        println(stmt)
    end
end
