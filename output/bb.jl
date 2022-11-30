@inbounds begin #= /home/eschnett/src/jl/IndexSpaces/kernels/bb.jl:484 =#
    s = s_memory[((((IndexSpaces.cuda_blockidx() % 2) % 2) * 128 + ((IndexSpaces.cuda_threadidx() ÷ 8) % 4 + (IndexSpaces.cuda_warpidx() % 32) * 4) % 128) + (((IndexSpaces.cuda_blockidx() ÷ 2) % 16) % 16) * 256) + 0x01]
    (A_beam0_cplx0_dish0, A_beam0_cplx1_dish0, A_beam0_cplx0_dish4, A_beam0_cplx1_dish4) = IndexSpaces.unsafe_load4_global(
        A_memory,
        (
            (
                (
                    ((IndexSpaces.cuda_blockidx() % 2) % 2) * 32768 +
                    ((((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16 + ((IndexSpaces.cuda_threadidx() ÷ 8) % 4) * 2) % 128) * 256
                ) + (((IndexSpaces.cuda_blockidx() ÷ 2) % 16) % 16) * 65536
            ) +
            (
                (
                    ((IndexSpaces.cuda_threadidx() % 2) * 32 + ((IndexSpaces.cuda_threadidx() ÷ 2) % 4) * 8) +
                    (IndexSpaces.cuda_warpidx() % 4) * 128
                ) ÷ 2
            ) % 256
        ) + 1i32,
    )
    (A_beam8_cplx0_dish0, A_beam8_cplx1_dish0, A_beam8_cplx0_dish4, A_beam8_cplx1_dish4) = IndexSpaces.unsafe_load4_global(
        A_memory,
        (
            (
                (
                    ((IndexSpaces.cuda_blockidx() % 2) % 2) * 32768 +
                    (((((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16 + 8) + ((IndexSpaces.cuda_threadidx() ÷ 8) % 4) * 2) % 128) *
                    256
                ) + (((IndexSpaces.cuda_blockidx() ÷ 2) % 16) % 16) * 65536
            ) +
            (
                (
                    ((IndexSpaces.cuda_threadidx() % 2) * 32 + ((IndexSpaces.cuda_threadidx() ÷ 2) % 4) * 8) +
                    (IndexSpaces.cuda_warpidx() % 4) * 128
                ) ÷ 2
            ) % 256
        ) + 1i32,
    )
    (A_beam0_cplx0_dish8, A_beam0_cplx1_dish8, A_beam0_cplx0_dish12, A_beam0_cplx1_dish12) = IndexSpaces.unsafe_load4_global(
        A_memory,
        (
            (
                (
                    ((IndexSpaces.cuda_blockidx() % 2) % 2) * 32768 +
                    ((((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16 + ((IndexSpaces.cuda_threadidx() ÷ 8) % 4) * 2) % 128) * 256
                ) + (((IndexSpaces.cuda_blockidx() ÷ 2) % 16) % 16) * 65536
            ) +
            (
                (
                    (((IndexSpaces.cuda_threadidx() % 2) * 32 + ((IndexSpaces.cuda_threadidx() ÷ 2) % 4) * 8) + 64) +
                    (IndexSpaces.cuda_warpidx() % 4) * 128
                ) ÷ 2
            ) % 256
        ) + 1i32,
    )
    (A_beam8_cplx0_dish8, A_beam8_cplx1_dish8, A_beam8_cplx0_dish12, A_beam8_cplx1_dish12) = IndexSpaces.unsafe_load4_global(
        A_memory,
        (
            (
                (
                    ((IndexSpaces.cuda_blockidx() % 2) % 2) * 32768 +
                    (((((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16 + 8) + ((IndexSpaces.cuda_threadidx() ÷ 8) % 4) * 2) % 128) *
                    256
                ) + (((IndexSpaces.cuda_blockidx() ÷ 2) % 16) % 16) * 65536
            ) +
            (
                (
                    (((IndexSpaces.cuda_threadidx() % 2) * 32 + ((IndexSpaces.cuda_threadidx() ÷ 2) % 4) * 8) + 64) +
                    (IndexSpaces.cuda_warpidx() % 4) * 128
                ) ÷ 2
            ) % 256
        ) + 1i32,
    )
    (A_beam0_cplx0_dish16, A_beam0_cplx1_dish16, A_beam0_cplx0_dish20, A_beam0_cplx1_dish20) = IndexSpaces.unsafe_load4_global(
        A_memory,
        (
            (
                (
                    ((IndexSpaces.cuda_blockidx() % 2) % 2) * 32768 +
                    (((((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16 + 1) + ((IndexSpaces.cuda_threadidx() ÷ 8) % 4) * 2) % 128) *
                    256
                ) + (((IndexSpaces.cuda_blockidx() ÷ 2) % 16) % 16) * 65536
            ) +
            (
                (
                    ((IndexSpaces.cuda_threadidx() % 2) * 32 + ((IndexSpaces.cuda_threadidx() ÷ 2) % 4) * 8) +
                    (IndexSpaces.cuda_warpidx() % 4) * 128
                ) ÷ 2
            ) % 256
        ) + 1i32,
    )
    (A_beam8_cplx0_dish16, A_beam8_cplx1_dish16, A_beam8_cplx0_dish20, A_beam8_cplx1_dish20) = IndexSpaces.unsafe_load4_global(
        A_memory,
        (
            (
                (
                    ((IndexSpaces.cuda_blockidx() % 2) % 2) * 32768 +
                    (
                        (((((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16 + 1) + 8) + ((IndexSpaces.cuda_threadidx() ÷ 8) % 4) * 2) %
                        128
                    ) * 256
                ) + (((IndexSpaces.cuda_blockidx() ÷ 2) % 16) % 16) * 65536
            ) +
            (
                (
                    ((IndexSpaces.cuda_threadidx() % 2) * 32 + ((IndexSpaces.cuda_threadidx() ÷ 2) % 4) * 8) +
                    (IndexSpaces.cuda_warpidx() % 4) * 128
                ) ÷ 2
            ) % 256
        ) + 1i32,
    )
    (A_beam0_cplx0_dish24, A_beam0_cplx1_dish24, A_beam0_cplx0_dish28, A_beam0_cplx1_dish28) = IndexSpaces.unsafe_load4_global(
        A_memory,
        (
            (
                (
                    ((IndexSpaces.cuda_blockidx() % 2) % 2) * 32768 +
                    (((((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16 + 1) + ((IndexSpaces.cuda_threadidx() ÷ 8) % 4) * 2) % 128) *
                    256
                ) + (((IndexSpaces.cuda_blockidx() ÷ 2) % 16) % 16) * 65536
            ) +
            (
                (
                    (((IndexSpaces.cuda_threadidx() % 2) * 32 + ((IndexSpaces.cuda_threadidx() ÷ 2) % 4) * 8) + 64) +
                    (IndexSpaces.cuda_warpidx() % 4) * 128
                ) ÷ 2
            ) % 256
        ) + 1i32,
    )
    (A_beam8_cplx0_dish24, A_beam8_cplx1_dish24, A_beam8_cplx0_dish28, A_beam8_cplx1_dish28) = IndexSpaces.unsafe_load4_global(
        A_memory,
        (
            (
                (
                    ((IndexSpaces.cuda_blockidx() % 2) % 2) * 32768 +
                    (
                        (((((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16 + 1) + 8) + ((IndexSpaces.cuda_threadidx() ÷ 8) % 4) * 2) %
                        128
                    ) * 256
                ) + (((IndexSpaces.cuda_blockidx() ÷ 2) % 16) % 16) * 65536
            ) +
            (
                (
                    (((IndexSpaces.cuda_threadidx() % 2) * 32 + ((IndexSpaces.cuda_threadidx() ÷ 2) % 4) * 8) + 64) +
                    (IndexSpaces.cuda_warpidx() % 4) * 128
                ) ÷ 2
            ) % 256
        ) + 1i32,
    )
    (A_beam0_cplx0_dish0, A_beam0_cplx1_dish0) = (
        IndexSpaces.get_lo16(A_beam0_cplx0_dish0, A_beam0_cplx1_dish0),
        IndexSpaces.get_hi16(A_beam0_cplx0_dish0, A_beam0_cplx1_dish0),
    )
    (A_beam8_cplx0_dish0, A_beam8_cplx1_dish0) = (
        IndexSpaces.get_lo16(A_beam8_cplx0_dish0, A_beam8_cplx1_dish0),
        IndexSpaces.get_hi16(A_beam8_cplx0_dish0, A_beam8_cplx1_dish0),
    )
    (A_beam0_cplx0_dish4, A_beam0_cplx1_dish4) = (
        IndexSpaces.get_lo16(A_beam0_cplx0_dish4, A_beam0_cplx1_dish4),
        IndexSpaces.get_hi16(A_beam0_cplx0_dish4, A_beam0_cplx1_dish4),
    )
    (A_beam8_cplx0_dish4, A_beam8_cplx1_dish4) = (
        IndexSpaces.get_lo16(A_beam8_cplx0_dish4, A_beam8_cplx1_dish4),
        IndexSpaces.get_hi16(A_beam8_cplx0_dish4, A_beam8_cplx1_dish4),
    )
    (A_beam0_cplx0_dish8, A_beam0_cplx1_dish8) = (
        IndexSpaces.get_lo16(A_beam0_cplx0_dish8, A_beam0_cplx1_dish8),
        IndexSpaces.get_hi16(A_beam0_cplx0_dish8, A_beam0_cplx1_dish8),
    )
    (A_beam8_cplx0_dish8, A_beam8_cplx1_dish8) = (
        IndexSpaces.get_lo16(A_beam8_cplx0_dish8, A_beam8_cplx1_dish8),
        IndexSpaces.get_hi16(A_beam8_cplx0_dish8, A_beam8_cplx1_dish8),
    )
    (A_beam0_cplx0_dish12, A_beam0_cplx1_dish12) = (
        IndexSpaces.get_lo16(A_beam0_cplx0_dish12, A_beam0_cplx1_dish12),
        IndexSpaces.get_hi16(A_beam0_cplx0_dish12, A_beam0_cplx1_dish12),
    )
    (A_beam8_cplx0_dish12, A_beam8_cplx1_dish12) = (
        IndexSpaces.get_lo16(A_beam8_cplx0_dish12, A_beam8_cplx1_dish12),
        IndexSpaces.get_hi16(A_beam8_cplx0_dish12, A_beam8_cplx1_dish12),
    )
    (A_beam0_cplx0_dish16, A_beam0_cplx1_dish16) = (
        IndexSpaces.get_lo16(A_beam0_cplx0_dish16, A_beam0_cplx1_dish16),
        IndexSpaces.get_hi16(A_beam0_cplx0_dish16, A_beam0_cplx1_dish16),
    )
    (A_beam8_cplx0_dish16, A_beam8_cplx1_dish16) = (
        IndexSpaces.get_lo16(A_beam8_cplx0_dish16, A_beam8_cplx1_dish16),
        IndexSpaces.get_hi16(A_beam8_cplx0_dish16, A_beam8_cplx1_dish16),
    )
    (A_beam0_cplx0_dish20, A_beam0_cplx1_dish20) = (
        IndexSpaces.get_lo16(A_beam0_cplx0_dish20, A_beam0_cplx1_dish20),
        IndexSpaces.get_hi16(A_beam0_cplx0_dish20, A_beam0_cplx1_dish20),
    )
    (A_beam8_cplx0_dish20, A_beam8_cplx1_dish20) = (
        IndexSpaces.get_lo16(A_beam8_cplx0_dish20, A_beam8_cplx1_dish20),
        IndexSpaces.get_hi16(A_beam8_cplx0_dish20, A_beam8_cplx1_dish20),
    )
    (A_beam0_cplx0_dish24, A_beam0_cplx1_dish24) = (
        IndexSpaces.get_lo16(A_beam0_cplx0_dish24, A_beam0_cplx1_dish24),
        IndexSpaces.get_hi16(A_beam0_cplx0_dish24, A_beam0_cplx1_dish24),
    )
    (A_beam8_cplx0_dish24, A_beam8_cplx1_dish24) = (
        IndexSpaces.get_lo16(A_beam8_cplx0_dish24, A_beam8_cplx1_dish24),
        IndexSpaces.get_hi16(A_beam8_cplx0_dish24, A_beam8_cplx1_dish24),
    )
    (A_beam0_cplx0_dish28, A_beam0_cplx1_dish28) = (
        IndexSpaces.get_lo16(A_beam0_cplx0_dish28, A_beam0_cplx1_dish28),
        IndexSpaces.get_hi16(A_beam0_cplx0_dish28, A_beam0_cplx1_dish28),
    )
    (A_beam8_cplx0_dish28, A_beam8_cplx1_dish28) = (
        IndexSpaces.get_lo16(A_beam8_cplx0_dish28, A_beam8_cplx1_dish28),
        IndexSpaces.get_hi16(A_beam8_cplx0_dish28, A_beam8_cplx1_dish28),
    )
    (A_beam0_cplx0_dish0, A_beam0_cplx1_dish0) = (
        IndexSpaces.get_lo8(A_beam0_cplx0_dish0, A_beam0_cplx1_dish0), IndexSpaces.get_hi8(A_beam0_cplx0_dish0, A_beam0_cplx1_dish0)
    )
    (A_beam8_cplx0_dish0, A_beam8_cplx1_dish0) = (
        IndexSpaces.get_lo8(A_beam8_cplx0_dish0, A_beam8_cplx1_dish0), IndexSpaces.get_hi8(A_beam8_cplx0_dish0, A_beam8_cplx1_dish0)
    )
    (A_beam0_cplx0_dish4, A_beam0_cplx1_dish4) = (
        IndexSpaces.get_lo8(A_beam0_cplx0_dish4, A_beam0_cplx1_dish4), IndexSpaces.get_hi8(A_beam0_cplx0_dish4, A_beam0_cplx1_dish4)
    )
    (A_beam8_cplx0_dish4, A_beam8_cplx1_dish4) = (
        IndexSpaces.get_lo8(A_beam8_cplx0_dish4, A_beam8_cplx1_dish4), IndexSpaces.get_hi8(A_beam8_cplx0_dish4, A_beam8_cplx1_dish4)
    )
    (A_beam0_cplx0_dish8, A_beam0_cplx1_dish8) = (
        IndexSpaces.get_lo8(A_beam0_cplx0_dish8, A_beam0_cplx1_dish8), IndexSpaces.get_hi8(A_beam0_cplx0_dish8, A_beam0_cplx1_dish8)
    )
    (A_beam8_cplx0_dish8, A_beam8_cplx1_dish8) = (
        IndexSpaces.get_lo8(A_beam8_cplx0_dish8, A_beam8_cplx1_dish8), IndexSpaces.get_hi8(A_beam8_cplx0_dish8, A_beam8_cplx1_dish8)
    )
    (A_beam0_cplx0_dish12, A_beam0_cplx1_dish12) = (
        IndexSpaces.get_lo8(A_beam0_cplx0_dish12, A_beam0_cplx1_dish12),
        IndexSpaces.get_hi8(A_beam0_cplx0_dish12, A_beam0_cplx1_dish12),
    )
    (A_beam8_cplx0_dish12, A_beam8_cplx1_dish12) = (
        IndexSpaces.get_lo8(A_beam8_cplx0_dish12, A_beam8_cplx1_dish12),
        IndexSpaces.get_hi8(A_beam8_cplx0_dish12, A_beam8_cplx1_dish12),
    )
    (A_beam0_cplx0_dish16, A_beam0_cplx1_dish16) = (
        IndexSpaces.get_lo8(A_beam0_cplx0_dish16, A_beam0_cplx1_dish16),
        IndexSpaces.get_hi8(A_beam0_cplx0_dish16, A_beam0_cplx1_dish16),
    )
    (A_beam8_cplx0_dish16, A_beam8_cplx1_dish16) = (
        IndexSpaces.get_lo8(A_beam8_cplx0_dish16, A_beam8_cplx1_dish16),
        IndexSpaces.get_hi8(A_beam8_cplx0_dish16, A_beam8_cplx1_dish16),
    )
    (A_beam0_cplx0_dish20, A_beam0_cplx1_dish20) = (
        IndexSpaces.get_lo8(A_beam0_cplx0_dish20, A_beam0_cplx1_dish20),
        IndexSpaces.get_hi8(A_beam0_cplx0_dish20, A_beam0_cplx1_dish20),
    )
    (A_beam8_cplx0_dish20, A_beam8_cplx1_dish20) = (
        IndexSpaces.get_lo8(A_beam8_cplx0_dish20, A_beam8_cplx1_dish20),
        IndexSpaces.get_hi8(A_beam8_cplx0_dish20, A_beam8_cplx1_dish20),
    )
    (A_beam0_cplx0_dish24, A_beam0_cplx1_dish24) = (
        IndexSpaces.get_lo8(A_beam0_cplx0_dish24, A_beam0_cplx1_dish24),
        IndexSpaces.get_hi8(A_beam0_cplx0_dish24, A_beam0_cplx1_dish24),
    )
    (A_beam8_cplx0_dish24, A_beam8_cplx1_dish24) = (
        IndexSpaces.get_lo8(A_beam8_cplx0_dish24, A_beam8_cplx1_dish24),
        IndexSpaces.get_hi8(A_beam8_cplx0_dish24, A_beam8_cplx1_dish24),
    )
    (A_beam0_cplx0_dish28, A_beam0_cplx1_dish28) = (
        IndexSpaces.get_lo8(A_beam0_cplx0_dish28, A_beam0_cplx1_dish28),
        IndexSpaces.get_hi8(A_beam0_cplx0_dish28, A_beam0_cplx1_dish28),
    )
    (A_beam8_cplx0_dish28, A_beam8_cplx1_dish28) = (
        IndexSpaces.get_lo8(A_beam8_cplx0_dish28, A_beam8_cplx1_dish28),
        IndexSpaces.get_hi8(A_beam8_cplx0_dish28, A_beam8_cplx1_dish28),
    )
    is_lo_thread = IndexSpaces.cuda_threadidx() & 0x00000002 == 0
    (A_beam0_cplx0_dish0, A_beam0_cplx0_dish8) = let
        src = if is_lo_thread
            A_beam0_cplx0_dish8
        else
            A_beam0_cplx0_dish0
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam0_cplx0_dish0, dst)
        else
            (dst, A_beam0_cplx0_dish8)
        end
    end
    (A_beam8_cplx0_dish0, A_beam8_cplx0_dish8) = let
        src = if is_lo_thread
            A_beam8_cplx0_dish8
        else
            A_beam8_cplx0_dish0
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam8_cplx0_dish0, dst)
        else
            (dst, A_beam8_cplx0_dish8)
        end
    end
    (A_beam0_cplx1_dish0, A_beam0_cplx1_dish8) = let
        src = if is_lo_thread
            A_beam0_cplx1_dish8
        else
            A_beam0_cplx1_dish0
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam0_cplx1_dish0, dst)
        else
            (dst, A_beam0_cplx1_dish8)
        end
    end
    (A_beam8_cplx1_dish0, A_beam8_cplx1_dish8) = let
        src = if is_lo_thread
            A_beam8_cplx1_dish8
        else
            A_beam8_cplx1_dish0
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam8_cplx1_dish0, dst)
        else
            (dst, A_beam8_cplx1_dish8)
        end
    end
    (A_beam0_cplx0_dish4, A_beam0_cplx0_dish12) = let
        src = if is_lo_thread
            A_beam0_cplx0_dish12
        else
            A_beam0_cplx0_dish4
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam0_cplx0_dish4, dst)
        else
            (dst, A_beam0_cplx0_dish12)
        end
    end
    (A_beam8_cplx0_dish4, A_beam8_cplx0_dish12) = let
        src = if is_lo_thread
            A_beam8_cplx0_dish12
        else
            A_beam8_cplx0_dish4
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam8_cplx0_dish4, dst)
        else
            (dst, A_beam8_cplx0_dish12)
        end
    end
    (A_beam0_cplx1_dish4, A_beam0_cplx1_dish12) = let
        src = if is_lo_thread
            A_beam0_cplx1_dish12
        else
            A_beam0_cplx1_dish4
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam0_cplx1_dish4, dst)
        else
            (dst, A_beam0_cplx1_dish12)
        end
    end
    (A_beam8_cplx1_dish4, A_beam8_cplx1_dish12) = let
        src = if is_lo_thread
            A_beam8_cplx1_dish12
        else
            A_beam8_cplx1_dish4
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam8_cplx1_dish4, dst)
        else
            (dst, A_beam8_cplx1_dish12)
        end
    end
    (A_beam0_cplx0_dish16, A_beam0_cplx0_dish24) = let
        src = if is_lo_thread
            A_beam0_cplx0_dish24
        else
            A_beam0_cplx0_dish16
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam0_cplx0_dish16, dst)
        else
            (dst, A_beam0_cplx0_dish24)
        end
    end
    (A_beam8_cplx0_dish16, A_beam8_cplx0_dish24) = let
        src = if is_lo_thread
            A_beam8_cplx0_dish24
        else
            A_beam8_cplx0_dish16
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam8_cplx0_dish16, dst)
        else
            (dst, A_beam8_cplx0_dish24)
        end
    end
    (A_beam0_cplx1_dish16, A_beam0_cplx1_dish24) = let
        src = if is_lo_thread
            A_beam0_cplx1_dish24
        else
            A_beam0_cplx1_dish16
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam0_cplx1_dish16, dst)
        else
            (dst, A_beam0_cplx1_dish24)
        end
    end
    (A_beam8_cplx1_dish16, A_beam8_cplx1_dish24) = let
        src = if is_lo_thread
            A_beam8_cplx1_dish24
        else
            A_beam8_cplx1_dish16
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam8_cplx1_dish16, dst)
        else
            (dst, A_beam8_cplx1_dish24)
        end
    end
    (A_beam0_cplx0_dish20, A_beam0_cplx0_dish28) = let
        src = if is_lo_thread
            A_beam0_cplx0_dish28
        else
            A_beam0_cplx0_dish20
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam0_cplx0_dish20, dst)
        else
            (dst, A_beam0_cplx0_dish28)
        end
    end
    (A_beam8_cplx0_dish20, A_beam8_cplx0_dish28) = let
        src = if is_lo_thread
            A_beam8_cplx0_dish28
        else
            A_beam8_cplx0_dish20
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam8_cplx0_dish20, dst)
        else
            (dst, A_beam8_cplx0_dish28)
        end
    end
    (A_beam0_cplx1_dish20, A_beam0_cplx1_dish28) = let
        src = if is_lo_thread
            A_beam0_cplx1_dish28
        else
            A_beam0_cplx1_dish20
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam0_cplx1_dish20, dst)
        else
            (dst, A_beam0_cplx1_dish28)
        end
    end
    (A_beam8_cplx1_dish20, A_beam8_cplx1_dish28) = let
        src = if is_lo_thread
            A_beam8_cplx1_dish28
        else
            A_beam8_cplx1_dish20
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
        if is_lo_thread
            (A_beam8_cplx1_dish20, dst)
        else
            (dst, A_beam8_cplx1_dish28)
        end
    end
    is_lo_thread = IndexSpaces.cuda_threadidx() & 0x00000004 == 0
    (A_beam0_cplx0_dish0, A_beam0_cplx0_dish16) = let
        src = if is_lo_thread
            A_beam0_cplx0_dish16
        else
            A_beam0_cplx0_dish0
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam0_cplx0_dish0, dst)
        else
            (dst, A_beam0_cplx0_dish16)
        end
    end
    (A_beam8_cplx0_dish0, A_beam8_cplx0_dish16) = let
        src = if is_lo_thread
            A_beam8_cplx0_dish16
        else
            A_beam8_cplx0_dish0
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam8_cplx0_dish0, dst)
        else
            (dst, A_beam8_cplx0_dish16)
        end
    end
    (A_beam0_cplx1_dish0, A_beam0_cplx1_dish16) = let
        src = if is_lo_thread
            A_beam0_cplx1_dish16
        else
            A_beam0_cplx1_dish0
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam0_cplx1_dish0, dst)
        else
            (dst, A_beam0_cplx1_dish16)
        end
    end
    (A_beam8_cplx1_dish0, A_beam8_cplx1_dish16) = let
        src = if is_lo_thread
            A_beam8_cplx1_dish16
        else
            A_beam8_cplx1_dish0
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam8_cplx1_dish0, dst)
        else
            (dst, A_beam8_cplx1_dish16)
        end
    end
    (A_beam0_cplx0_dish4, A_beam0_cplx0_dish20) = let
        src = if is_lo_thread
            A_beam0_cplx0_dish20
        else
            A_beam0_cplx0_dish4
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam0_cplx0_dish4, dst)
        else
            (dst, A_beam0_cplx0_dish20)
        end
    end
    (A_beam8_cplx0_dish4, A_beam8_cplx0_dish20) = let
        src = if is_lo_thread
            A_beam8_cplx0_dish20
        else
            A_beam8_cplx0_dish4
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam8_cplx0_dish4, dst)
        else
            (dst, A_beam8_cplx0_dish20)
        end
    end
    (A_beam0_cplx1_dish4, A_beam0_cplx1_dish20) = let
        src = if is_lo_thread
            A_beam0_cplx1_dish20
        else
            A_beam0_cplx1_dish4
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam0_cplx1_dish4, dst)
        else
            (dst, A_beam0_cplx1_dish20)
        end
    end
    (A_beam8_cplx1_dish4, A_beam8_cplx1_dish20) = let
        src = if is_lo_thread
            A_beam8_cplx1_dish20
        else
            A_beam8_cplx1_dish4
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam8_cplx1_dish4, dst)
        else
            (dst, A_beam8_cplx1_dish20)
        end
    end
    (A_beam0_cplx0_dish8, A_beam0_cplx0_dish24) = let
        src = if is_lo_thread
            A_beam0_cplx0_dish24
        else
            A_beam0_cplx0_dish8
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam0_cplx0_dish8, dst)
        else
            (dst, A_beam0_cplx0_dish24)
        end
    end
    (A_beam8_cplx0_dish8, A_beam8_cplx0_dish24) = let
        src = if is_lo_thread
            A_beam8_cplx0_dish24
        else
            A_beam8_cplx0_dish8
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam8_cplx0_dish8, dst)
        else
            (dst, A_beam8_cplx0_dish24)
        end
    end
    (A_beam0_cplx1_dish8, A_beam0_cplx1_dish24) = let
        src = if is_lo_thread
            A_beam0_cplx1_dish24
        else
            A_beam0_cplx1_dish8
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam0_cplx1_dish8, dst)
        else
            (dst, A_beam0_cplx1_dish24)
        end
    end
    (A_beam8_cplx1_dish8, A_beam8_cplx1_dish24) = let
        src = if is_lo_thread
            A_beam8_cplx1_dish24
        else
            A_beam8_cplx1_dish8
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam8_cplx1_dish8, dst)
        else
            (dst, A_beam8_cplx1_dish24)
        end
    end
    (A_beam0_cplx0_dish12, A_beam0_cplx0_dish28) = let
        src = if is_lo_thread
            A_beam0_cplx0_dish28
        else
            A_beam0_cplx0_dish12
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam0_cplx0_dish12, dst)
        else
            (dst, A_beam0_cplx0_dish28)
        end
    end
    (A_beam8_cplx0_dish12, A_beam8_cplx0_dish28) = let
        src = if is_lo_thread
            A_beam8_cplx0_dish28
        else
            A_beam8_cplx0_dish12
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam8_cplx0_dish12, dst)
        else
            (dst, A_beam8_cplx0_dish28)
        end
    end
    (A_beam0_cplx1_dish12, A_beam0_cplx1_dish28) = let
        src = if is_lo_thread
            A_beam0_cplx1_dish28
        else
            A_beam0_cplx1_dish12
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam0_cplx1_dish12, dst)
        else
            (dst, A_beam0_cplx1_dish28)
        end
    end
    (A_beam8_cplx1_dish12, A_beam8_cplx1_dish28) = let
        src = if is_lo_thread
            A_beam8_cplx1_dish28
        else
            A_beam8_cplx1_dish12
        end
        dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
        if is_lo_thread
            (A_beam8_cplx1_dish12, dst)
        else
            (dst, A_beam8_cplx1_dish28)
        end
    end
    for T1 in 0:128:32767
        Jper_time0 = zero(Int4x8)
        Jper_time32 = zero(Int4x8)
        Jper_time64 = zero(Int4x8)
        Jper_time96 = zero(Int4x8)
        for T2 in 0:32:127
            let
                (E_dish0, E_dish4, E_dish8, E_dish12) = IndexSpaces.unsafe_load4_global(
                    E_memory,
                    (
                        (
                            (
                                ((IndexSpaces.cuda_blockidx() % 2) % 2) * 2048 +
                                (
                                    (
                                        (
                                            (((T1 ÷ 128) % 256) * 128 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) +
                                            ((T2 ÷ 32) % 4) * 32
                                        ) + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 4
                                    ) % 32768
                                ) * 4096
                            ) + (((IndexSpaces.cuda_blockidx() ÷ 2) % 16) % 16) * 128
                        ) + (((IndexSpaces.cuda_threadidx() % 8) * 16 + (IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 4) % 128
                    ) + 1i32,
                )
                E_shared[(((((((T1 ÷ 128) % 256) * 128 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) + ((T2 ÷ 32) % 4) * 32) + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 4) % 32) * 129 + (((IndexSpaces.cuda_threadidx() % 8) * 16 + (IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 4) % 128) + 0x01] =
                    E_dish0
                E_shared[(((((((T1 ÷ 128) % 256) * 128 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) + ((T2 ÷ 32) % 4) * 32) + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 4) % 32) * 129 + ((((IndexSpaces.cuda_threadidx() % 8) * 16 + 4) + (IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 4) % 128) + 0x01] =
                    E_dish4
                E_shared[(((((((T1 ÷ 128) % 256) * 128 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) + ((T2 ÷ 32) % 4) * 32) + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 4) % 32) * 129 + ((((IndexSpaces.cuda_threadidx() % 8) * 16 + 8) + (IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 4) % 128) + 0x01] =
                    E_dish8
                E_shared[(((((((T1 ÷ 128) % 256) * 128 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) + ((T2 ÷ 32) % 4) * 32) + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 4) % 32) * 129 + ((((IndexSpaces.cuda_threadidx() % 8) * 16 + 12) + (IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 4) % 128) + 0x01] =
                    E_dish12
            end
            IndexSpaces.cuda_sync_threads()
            let
                T3 = 0
                let
                    B = 0
                    AselB_cplx0_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish0 = A_beam0_cplx0_dish0
                    end
                    if B == 8
                        AselB_cplx0_dish0 = A_beam8_cplx0_dish0
                    end
                    AselB_cplx1_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish0 = A_beam0_cplx1_dish0
                    end
                    if B == 8
                        AselB_cplx1_dish0 = A_beam8_cplx1_dish0
                    end
                    AselB_cplx0_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish4 = A_beam0_cplx0_dish4
                    end
                    if B == 8
                        AselB_cplx0_dish4 = A_beam8_cplx0_dish4
                    end
                    AselB_cplx1_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish4 = A_beam0_cplx1_dish4
                    end
                    if B == 8
                        AselB_cplx1_dish4 = A_beam8_cplx1_dish4
                    end
                    AselB_cplx0_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish8 = A_beam0_cplx0_dish8
                    end
                    if B == 8
                        AselB_cplx0_dish8 = A_beam8_cplx0_dish8
                    end
                    AselB_cplx1_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish8 = A_beam0_cplx1_dish8
                    end
                    if B == 8
                        AselB_cplx1_dish8 = A_beam8_cplx1_dish8
                    end
                    AselB_cplx0_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish12 = A_beam0_cplx0_dish12
                    end
                    if B == 8
                        AselB_cplx0_dish12 = A_beam8_cplx0_dish12
                    end
                    AselB_cplx1_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish12 = A_beam0_cplx1_dish12
                    end
                    if B == 8
                        AselB_cplx1_dish12 = A_beam8_cplx1_dish12
                    end
                    AselB_cplx0_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish16 = A_beam0_cplx0_dish16
                    end
                    if B == 8
                        AselB_cplx0_dish16 = A_beam8_cplx0_dish16
                    end
                    AselB_cplx1_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish16 = A_beam0_cplx1_dish16
                    end
                    if B == 8
                        AselB_cplx1_dish16 = A_beam8_cplx1_dish16
                    end
                    AselB_cplx0_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish20 = A_beam0_cplx0_dish20
                    end
                    if B == 8
                        AselB_cplx0_dish20 = A_beam8_cplx0_dish20
                    end
                    AselB_cplx1_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish20 = A_beam0_cplx1_dish20
                    end
                    if B == 8
                        AselB_cplx1_dish20 = A_beam8_cplx1_dish20
                    end
                    AselB_cplx0_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish24 = A_beam0_cplx0_dish24
                    end
                    if B == 8
                        AselB_cplx0_dish24 = A_beam8_cplx0_dish24
                    end
                    AselB_cplx1_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish24 = A_beam0_cplx1_dish24
                    end
                    if B == 8
                        AselB_cplx1_dish24 = A_beam8_cplx1_dish24
                    end
                    AselB_cplx0_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish28 = A_beam0_cplx0_dish28
                    end
                    if B == 8
                        AselB_cplx0_dish28 = A_beam8_cplx0_dish28
                    end
                    AselB_cplx1_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish28 = A_beam0_cplx1_dish28
                    end
                    if B == 8
                        AselB_cplx1_dish28 = A_beam8_cplx1_dish28
                    end
                    Jurepos_time0 = 0
                    Jurepos_time1 = 0
                    Jureneg_time0 = 0
                    Jureneg_time1 = 0
                    Juim_time0 = 0
                    Juim_time1 = 0
                    let
                        D = 0
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 4
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 8
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 12
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 16
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 20
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 24
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 28
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    Jure_time0 = Jurepos_time0 - Jureneg_time0
                    Jure_time1 = Jurepos_time1 - Jureneg_time1
                    Ju_cplx0_time0 = Juim_time0
                    Ju_cplx1_time0 = Jure_time0
                    Ju_cplx0_time1 = Juim_time1
                    Ju_cplx1_time1 = Jure_time1
                    Ju_cplx0_time0 = (Ju_cplx0_time0 + 4) >> 0x00000003
                    Ju_cplx1_time0 = (Ju_cplx1_time0 + 4) >> 0x00000003
                    Ju_cplx0_time1 = (Ju_cplx0_time1 + 4) >> 0x00000003
                    Ju_cplx1_time1 = (Ju_cplx1_time1 + 4) >> 0x00000003
                    Ju_time0 = convert(Int16x2, (Ju_cplx0_time0, Ju_cplx1_time0))
                    Ju_time1 = convert(Int16x2, (Ju_cplx0_time1, Ju_cplx1_time1))
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + ((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) % 32) * 128) + 0x01] =
                        Ju_time0
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + (((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) + 1) % 32) * 128) + 0x01] =
                        Ju_time1
                end
                let
                    B = 8
                    AselB_cplx0_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish0 = A_beam0_cplx0_dish0
                    end
                    if B == 8
                        AselB_cplx0_dish0 = A_beam8_cplx0_dish0
                    end
                    AselB_cplx1_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish0 = A_beam0_cplx1_dish0
                    end
                    if B == 8
                        AselB_cplx1_dish0 = A_beam8_cplx1_dish0
                    end
                    AselB_cplx0_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish4 = A_beam0_cplx0_dish4
                    end
                    if B == 8
                        AselB_cplx0_dish4 = A_beam8_cplx0_dish4
                    end
                    AselB_cplx1_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish4 = A_beam0_cplx1_dish4
                    end
                    if B == 8
                        AselB_cplx1_dish4 = A_beam8_cplx1_dish4
                    end
                    AselB_cplx0_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish8 = A_beam0_cplx0_dish8
                    end
                    if B == 8
                        AselB_cplx0_dish8 = A_beam8_cplx0_dish8
                    end
                    AselB_cplx1_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish8 = A_beam0_cplx1_dish8
                    end
                    if B == 8
                        AselB_cplx1_dish8 = A_beam8_cplx1_dish8
                    end
                    AselB_cplx0_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish12 = A_beam0_cplx0_dish12
                    end
                    if B == 8
                        AselB_cplx0_dish12 = A_beam8_cplx0_dish12
                    end
                    AselB_cplx1_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish12 = A_beam0_cplx1_dish12
                    end
                    if B == 8
                        AselB_cplx1_dish12 = A_beam8_cplx1_dish12
                    end
                    AselB_cplx0_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish16 = A_beam0_cplx0_dish16
                    end
                    if B == 8
                        AselB_cplx0_dish16 = A_beam8_cplx0_dish16
                    end
                    AselB_cplx1_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish16 = A_beam0_cplx1_dish16
                    end
                    if B == 8
                        AselB_cplx1_dish16 = A_beam8_cplx1_dish16
                    end
                    AselB_cplx0_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish20 = A_beam0_cplx0_dish20
                    end
                    if B == 8
                        AselB_cplx0_dish20 = A_beam8_cplx0_dish20
                    end
                    AselB_cplx1_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish20 = A_beam0_cplx1_dish20
                    end
                    if B == 8
                        AselB_cplx1_dish20 = A_beam8_cplx1_dish20
                    end
                    AselB_cplx0_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish24 = A_beam0_cplx0_dish24
                    end
                    if B == 8
                        AselB_cplx0_dish24 = A_beam8_cplx0_dish24
                    end
                    AselB_cplx1_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish24 = A_beam0_cplx1_dish24
                    end
                    if B == 8
                        AselB_cplx1_dish24 = A_beam8_cplx1_dish24
                    end
                    AselB_cplx0_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish28 = A_beam0_cplx0_dish28
                    end
                    if B == 8
                        AselB_cplx0_dish28 = A_beam8_cplx0_dish28
                    end
                    AselB_cplx1_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish28 = A_beam0_cplx1_dish28
                    end
                    if B == 8
                        AselB_cplx1_dish28 = A_beam8_cplx1_dish28
                    end
                    Jurepos_time0 = 0
                    Jurepos_time1 = 0
                    Jureneg_time0 = 0
                    Jureneg_time1 = 0
                    Juim_time0 = 0
                    Juim_time1 = 0
                    let
                        D = 0
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 4
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 8
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 12
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 16
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 20
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 24
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 28
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    Jure_time0 = Jurepos_time0 - Jureneg_time0
                    Jure_time1 = Jurepos_time1 - Jureneg_time1
                    Ju_cplx0_time0 = Juim_time0
                    Ju_cplx1_time0 = Jure_time0
                    Ju_cplx0_time1 = Juim_time1
                    Ju_cplx1_time1 = Jure_time1
                    Ju_cplx0_time0 = (Ju_cplx0_time0 + 4) >> 0x00000003
                    Ju_cplx1_time0 = (Ju_cplx1_time0 + 4) >> 0x00000003
                    Ju_cplx0_time1 = (Ju_cplx0_time1 + 4) >> 0x00000003
                    Ju_cplx1_time1 = (Ju_cplx1_time1 + 4) >> 0x00000003
                    Ju_time0 = convert(Int16x2, (Ju_cplx0_time0, Ju_cplx1_time0))
                    Ju_time1 = convert(Int16x2, (Ju_cplx0_time1, Ju_cplx1_time1))
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + ((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) % 32) * 128) + 0x01] =
                        Ju_time0
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + (((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) + 1) % 32) * 128) + 0x01] =
                        Ju_time1
                end
            end
            let
                T3 = 8
                let
                    B = 0
                    AselB_cplx0_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish0 = A_beam0_cplx0_dish0
                    end
                    if B == 8
                        AselB_cplx0_dish0 = A_beam8_cplx0_dish0
                    end
                    AselB_cplx1_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish0 = A_beam0_cplx1_dish0
                    end
                    if B == 8
                        AselB_cplx1_dish0 = A_beam8_cplx1_dish0
                    end
                    AselB_cplx0_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish4 = A_beam0_cplx0_dish4
                    end
                    if B == 8
                        AselB_cplx0_dish4 = A_beam8_cplx0_dish4
                    end
                    AselB_cplx1_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish4 = A_beam0_cplx1_dish4
                    end
                    if B == 8
                        AselB_cplx1_dish4 = A_beam8_cplx1_dish4
                    end
                    AselB_cplx0_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish8 = A_beam0_cplx0_dish8
                    end
                    if B == 8
                        AselB_cplx0_dish8 = A_beam8_cplx0_dish8
                    end
                    AselB_cplx1_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish8 = A_beam0_cplx1_dish8
                    end
                    if B == 8
                        AselB_cplx1_dish8 = A_beam8_cplx1_dish8
                    end
                    AselB_cplx0_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish12 = A_beam0_cplx0_dish12
                    end
                    if B == 8
                        AselB_cplx0_dish12 = A_beam8_cplx0_dish12
                    end
                    AselB_cplx1_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish12 = A_beam0_cplx1_dish12
                    end
                    if B == 8
                        AselB_cplx1_dish12 = A_beam8_cplx1_dish12
                    end
                    AselB_cplx0_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish16 = A_beam0_cplx0_dish16
                    end
                    if B == 8
                        AselB_cplx0_dish16 = A_beam8_cplx0_dish16
                    end
                    AselB_cplx1_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish16 = A_beam0_cplx1_dish16
                    end
                    if B == 8
                        AselB_cplx1_dish16 = A_beam8_cplx1_dish16
                    end
                    AselB_cplx0_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish20 = A_beam0_cplx0_dish20
                    end
                    if B == 8
                        AselB_cplx0_dish20 = A_beam8_cplx0_dish20
                    end
                    AselB_cplx1_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish20 = A_beam0_cplx1_dish20
                    end
                    if B == 8
                        AselB_cplx1_dish20 = A_beam8_cplx1_dish20
                    end
                    AselB_cplx0_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish24 = A_beam0_cplx0_dish24
                    end
                    if B == 8
                        AselB_cplx0_dish24 = A_beam8_cplx0_dish24
                    end
                    AselB_cplx1_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish24 = A_beam0_cplx1_dish24
                    end
                    if B == 8
                        AselB_cplx1_dish24 = A_beam8_cplx1_dish24
                    end
                    AselB_cplx0_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish28 = A_beam0_cplx0_dish28
                    end
                    if B == 8
                        AselB_cplx0_dish28 = A_beam8_cplx0_dish28
                    end
                    AselB_cplx1_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish28 = A_beam0_cplx1_dish28
                    end
                    if B == 8
                        AselB_cplx1_dish28 = A_beam8_cplx1_dish28
                    end
                    Jurepos_time0 = 0
                    Jurepos_time1 = 0
                    Jureneg_time0 = 0
                    Jureneg_time1 = 0
                    Juim_time0 = 0
                    Juim_time1 = 0
                    let
                        D = 0
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 4
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 8
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 12
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 16
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 20
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 24
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 28
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    Jure_time0 = Jurepos_time0 - Jureneg_time0
                    Jure_time1 = Jurepos_time1 - Jureneg_time1
                    Ju_cplx0_time0 = Juim_time0
                    Ju_cplx1_time0 = Jure_time0
                    Ju_cplx0_time1 = Juim_time1
                    Ju_cplx1_time1 = Jure_time1
                    Ju_cplx0_time0 = (Ju_cplx0_time0 + 4) >> 0x00000003
                    Ju_cplx1_time0 = (Ju_cplx1_time0 + 4) >> 0x00000003
                    Ju_cplx0_time1 = (Ju_cplx0_time1 + 4) >> 0x00000003
                    Ju_cplx1_time1 = (Ju_cplx1_time1 + 4) >> 0x00000003
                    Ju_time0 = convert(Int16x2, (Ju_cplx0_time0, Ju_cplx1_time0))
                    Ju_time1 = convert(Int16x2, (Ju_cplx0_time1, Ju_cplx1_time1))
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + ((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) % 32) * 128) + 0x01] =
                        Ju_time0
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + (((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) + 1) % 32) * 128) + 0x01] =
                        Ju_time1
                end
                let
                    B = 8
                    AselB_cplx0_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish0 = A_beam0_cplx0_dish0
                    end
                    if B == 8
                        AselB_cplx0_dish0 = A_beam8_cplx0_dish0
                    end
                    AselB_cplx1_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish0 = A_beam0_cplx1_dish0
                    end
                    if B == 8
                        AselB_cplx1_dish0 = A_beam8_cplx1_dish0
                    end
                    AselB_cplx0_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish4 = A_beam0_cplx0_dish4
                    end
                    if B == 8
                        AselB_cplx0_dish4 = A_beam8_cplx0_dish4
                    end
                    AselB_cplx1_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish4 = A_beam0_cplx1_dish4
                    end
                    if B == 8
                        AselB_cplx1_dish4 = A_beam8_cplx1_dish4
                    end
                    AselB_cplx0_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish8 = A_beam0_cplx0_dish8
                    end
                    if B == 8
                        AselB_cplx0_dish8 = A_beam8_cplx0_dish8
                    end
                    AselB_cplx1_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish8 = A_beam0_cplx1_dish8
                    end
                    if B == 8
                        AselB_cplx1_dish8 = A_beam8_cplx1_dish8
                    end
                    AselB_cplx0_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish12 = A_beam0_cplx0_dish12
                    end
                    if B == 8
                        AselB_cplx0_dish12 = A_beam8_cplx0_dish12
                    end
                    AselB_cplx1_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish12 = A_beam0_cplx1_dish12
                    end
                    if B == 8
                        AselB_cplx1_dish12 = A_beam8_cplx1_dish12
                    end
                    AselB_cplx0_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish16 = A_beam0_cplx0_dish16
                    end
                    if B == 8
                        AselB_cplx0_dish16 = A_beam8_cplx0_dish16
                    end
                    AselB_cplx1_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish16 = A_beam0_cplx1_dish16
                    end
                    if B == 8
                        AselB_cplx1_dish16 = A_beam8_cplx1_dish16
                    end
                    AselB_cplx0_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish20 = A_beam0_cplx0_dish20
                    end
                    if B == 8
                        AselB_cplx0_dish20 = A_beam8_cplx0_dish20
                    end
                    AselB_cplx1_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish20 = A_beam0_cplx1_dish20
                    end
                    if B == 8
                        AselB_cplx1_dish20 = A_beam8_cplx1_dish20
                    end
                    AselB_cplx0_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish24 = A_beam0_cplx0_dish24
                    end
                    if B == 8
                        AselB_cplx0_dish24 = A_beam8_cplx0_dish24
                    end
                    AselB_cplx1_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish24 = A_beam0_cplx1_dish24
                    end
                    if B == 8
                        AselB_cplx1_dish24 = A_beam8_cplx1_dish24
                    end
                    AselB_cplx0_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish28 = A_beam0_cplx0_dish28
                    end
                    if B == 8
                        AselB_cplx0_dish28 = A_beam8_cplx0_dish28
                    end
                    AselB_cplx1_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish28 = A_beam0_cplx1_dish28
                    end
                    if B == 8
                        AselB_cplx1_dish28 = A_beam8_cplx1_dish28
                    end
                    Jurepos_time0 = 0
                    Jurepos_time1 = 0
                    Jureneg_time0 = 0
                    Jureneg_time1 = 0
                    Juim_time0 = 0
                    Juim_time1 = 0
                    let
                        D = 0
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 4
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 8
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 12
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 16
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 20
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 24
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 28
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    Jure_time0 = Jurepos_time0 - Jureneg_time0
                    Jure_time1 = Jurepos_time1 - Jureneg_time1
                    Ju_cplx0_time0 = Juim_time0
                    Ju_cplx1_time0 = Jure_time0
                    Ju_cplx0_time1 = Juim_time1
                    Ju_cplx1_time1 = Jure_time1
                    Ju_cplx0_time0 = (Ju_cplx0_time0 + 4) >> 0x00000003
                    Ju_cplx1_time0 = (Ju_cplx1_time0 + 4) >> 0x00000003
                    Ju_cplx0_time1 = (Ju_cplx0_time1 + 4) >> 0x00000003
                    Ju_cplx1_time1 = (Ju_cplx1_time1 + 4) >> 0x00000003
                    Ju_time0 = convert(Int16x2, (Ju_cplx0_time0, Ju_cplx1_time0))
                    Ju_time1 = convert(Int16x2, (Ju_cplx0_time1, Ju_cplx1_time1))
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + ((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) % 32) * 128) + 0x01] =
                        Ju_time0
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + (((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) + 1) % 32) * 128) + 0x01] =
                        Ju_time1
                end
            end
            let
                T3 = 16
                let
                    B = 0
                    AselB_cplx0_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish0 = A_beam0_cplx0_dish0
                    end
                    if B == 8
                        AselB_cplx0_dish0 = A_beam8_cplx0_dish0
                    end
                    AselB_cplx1_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish0 = A_beam0_cplx1_dish0
                    end
                    if B == 8
                        AselB_cplx1_dish0 = A_beam8_cplx1_dish0
                    end
                    AselB_cplx0_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish4 = A_beam0_cplx0_dish4
                    end
                    if B == 8
                        AselB_cplx0_dish4 = A_beam8_cplx0_dish4
                    end
                    AselB_cplx1_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish4 = A_beam0_cplx1_dish4
                    end
                    if B == 8
                        AselB_cplx1_dish4 = A_beam8_cplx1_dish4
                    end
                    AselB_cplx0_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish8 = A_beam0_cplx0_dish8
                    end
                    if B == 8
                        AselB_cplx0_dish8 = A_beam8_cplx0_dish8
                    end
                    AselB_cplx1_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish8 = A_beam0_cplx1_dish8
                    end
                    if B == 8
                        AselB_cplx1_dish8 = A_beam8_cplx1_dish8
                    end
                    AselB_cplx0_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish12 = A_beam0_cplx0_dish12
                    end
                    if B == 8
                        AselB_cplx0_dish12 = A_beam8_cplx0_dish12
                    end
                    AselB_cplx1_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish12 = A_beam0_cplx1_dish12
                    end
                    if B == 8
                        AselB_cplx1_dish12 = A_beam8_cplx1_dish12
                    end
                    AselB_cplx0_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish16 = A_beam0_cplx0_dish16
                    end
                    if B == 8
                        AselB_cplx0_dish16 = A_beam8_cplx0_dish16
                    end
                    AselB_cplx1_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish16 = A_beam0_cplx1_dish16
                    end
                    if B == 8
                        AselB_cplx1_dish16 = A_beam8_cplx1_dish16
                    end
                    AselB_cplx0_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish20 = A_beam0_cplx0_dish20
                    end
                    if B == 8
                        AselB_cplx0_dish20 = A_beam8_cplx0_dish20
                    end
                    AselB_cplx1_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish20 = A_beam0_cplx1_dish20
                    end
                    if B == 8
                        AselB_cplx1_dish20 = A_beam8_cplx1_dish20
                    end
                    AselB_cplx0_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish24 = A_beam0_cplx0_dish24
                    end
                    if B == 8
                        AselB_cplx0_dish24 = A_beam8_cplx0_dish24
                    end
                    AselB_cplx1_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish24 = A_beam0_cplx1_dish24
                    end
                    if B == 8
                        AselB_cplx1_dish24 = A_beam8_cplx1_dish24
                    end
                    AselB_cplx0_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish28 = A_beam0_cplx0_dish28
                    end
                    if B == 8
                        AselB_cplx0_dish28 = A_beam8_cplx0_dish28
                    end
                    AselB_cplx1_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish28 = A_beam0_cplx1_dish28
                    end
                    if B == 8
                        AselB_cplx1_dish28 = A_beam8_cplx1_dish28
                    end
                    Jurepos_time0 = 0
                    Jurepos_time1 = 0
                    Jureneg_time0 = 0
                    Jureneg_time1 = 0
                    Juim_time0 = 0
                    Juim_time1 = 0
                    let
                        D = 0
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 4
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 8
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 12
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 16
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 20
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 24
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 28
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    Jure_time0 = Jurepos_time0 - Jureneg_time0
                    Jure_time1 = Jurepos_time1 - Jureneg_time1
                    Ju_cplx0_time0 = Juim_time0
                    Ju_cplx1_time0 = Jure_time0
                    Ju_cplx0_time1 = Juim_time1
                    Ju_cplx1_time1 = Jure_time1
                    Ju_cplx0_time0 = (Ju_cplx0_time0 + 4) >> 0x00000003
                    Ju_cplx1_time0 = (Ju_cplx1_time0 + 4) >> 0x00000003
                    Ju_cplx0_time1 = (Ju_cplx0_time1 + 4) >> 0x00000003
                    Ju_cplx1_time1 = (Ju_cplx1_time1 + 4) >> 0x00000003
                    Ju_time0 = convert(Int16x2, (Ju_cplx0_time0, Ju_cplx1_time0))
                    Ju_time1 = convert(Int16x2, (Ju_cplx0_time1, Ju_cplx1_time1))
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + ((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) % 32) * 128) + 0x01] =
                        Ju_time0
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + (((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) + 1) % 32) * 128) + 0x01] =
                        Ju_time1
                end
                let
                    B = 8
                    AselB_cplx0_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish0 = A_beam0_cplx0_dish0
                    end
                    if B == 8
                        AselB_cplx0_dish0 = A_beam8_cplx0_dish0
                    end
                    AselB_cplx1_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish0 = A_beam0_cplx1_dish0
                    end
                    if B == 8
                        AselB_cplx1_dish0 = A_beam8_cplx1_dish0
                    end
                    AselB_cplx0_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish4 = A_beam0_cplx0_dish4
                    end
                    if B == 8
                        AselB_cplx0_dish4 = A_beam8_cplx0_dish4
                    end
                    AselB_cplx1_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish4 = A_beam0_cplx1_dish4
                    end
                    if B == 8
                        AselB_cplx1_dish4 = A_beam8_cplx1_dish4
                    end
                    AselB_cplx0_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish8 = A_beam0_cplx0_dish8
                    end
                    if B == 8
                        AselB_cplx0_dish8 = A_beam8_cplx0_dish8
                    end
                    AselB_cplx1_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish8 = A_beam0_cplx1_dish8
                    end
                    if B == 8
                        AselB_cplx1_dish8 = A_beam8_cplx1_dish8
                    end
                    AselB_cplx0_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish12 = A_beam0_cplx0_dish12
                    end
                    if B == 8
                        AselB_cplx0_dish12 = A_beam8_cplx0_dish12
                    end
                    AselB_cplx1_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish12 = A_beam0_cplx1_dish12
                    end
                    if B == 8
                        AselB_cplx1_dish12 = A_beam8_cplx1_dish12
                    end
                    AselB_cplx0_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish16 = A_beam0_cplx0_dish16
                    end
                    if B == 8
                        AselB_cplx0_dish16 = A_beam8_cplx0_dish16
                    end
                    AselB_cplx1_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish16 = A_beam0_cplx1_dish16
                    end
                    if B == 8
                        AselB_cplx1_dish16 = A_beam8_cplx1_dish16
                    end
                    AselB_cplx0_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish20 = A_beam0_cplx0_dish20
                    end
                    if B == 8
                        AselB_cplx0_dish20 = A_beam8_cplx0_dish20
                    end
                    AselB_cplx1_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish20 = A_beam0_cplx1_dish20
                    end
                    if B == 8
                        AselB_cplx1_dish20 = A_beam8_cplx1_dish20
                    end
                    AselB_cplx0_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish24 = A_beam0_cplx0_dish24
                    end
                    if B == 8
                        AselB_cplx0_dish24 = A_beam8_cplx0_dish24
                    end
                    AselB_cplx1_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish24 = A_beam0_cplx1_dish24
                    end
                    if B == 8
                        AselB_cplx1_dish24 = A_beam8_cplx1_dish24
                    end
                    AselB_cplx0_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish28 = A_beam0_cplx0_dish28
                    end
                    if B == 8
                        AselB_cplx0_dish28 = A_beam8_cplx0_dish28
                    end
                    AselB_cplx1_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish28 = A_beam0_cplx1_dish28
                    end
                    if B == 8
                        AselB_cplx1_dish28 = A_beam8_cplx1_dish28
                    end
                    Jurepos_time0 = 0
                    Jurepos_time1 = 0
                    Jureneg_time0 = 0
                    Jureneg_time1 = 0
                    Juim_time0 = 0
                    Juim_time1 = 0
                    let
                        D = 0
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 4
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 8
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 12
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 16
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 20
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 24
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 28
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    Jure_time0 = Jurepos_time0 - Jureneg_time0
                    Jure_time1 = Jurepos_time1 - Jureneg_time1
                    Ju_cplx0_time0 = Juim_time0
                    Ju_cplx1_time0 = Jure_time0
                    Ju_cplx0_time1 = Juim_time1
                    Ju_cplx1_time1 = Jure_time1
                    Ju_cplx0_time0 = (Ju_cplx0_time0 + 4) >> 0x00000003
                    Ju_cplx1_time0 = (Ju_cplx1_time0 + 4) >> 0x00000003
                    Ju_cplx0_time1 = (Ju_cplx0_time1 + 4) >> 0x00000003
                    Ju_cplx1_time1 = (Ju_cplx1_time1 + 4) >> 0x00000003
                    Ju_time0 = convert(Int16x2, (Ju_cplx0_time0, Ju_cplx1_time0))
                    Ju_time1 = convert(Int16x2, (Ju_cplx0_time1, Ju_cplx1_time1))
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + ((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) % 32) * 128) + 0x01] =
                        Ju_time0
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + (((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) + 1) % 32) * 128) + 0x01] =
                        Ju_time1
                end
            end
            let
                T3 = 24
                let
                    B = 0
                    AselB_cplx0_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish0 = A_beam0_cplx0_dish0
                    end
                    if B == 8
                        AselB_cplx0_dish0 = A_beam8_cplx0_dish0
                    end
                    AselB_cplx1_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish0 = A_beam0_cplx1_dish0
                    end
                    if B == 8
                        AselB_cplx1_dish0 = A_beam8_cplx1_dish0
                    end
                    AselB_cplx0_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish4 = A_beam0_cplx0_dish4
                    end
                    if B == 8
                        AselB_cplx0_dish4 = A_beam8_cplx0_dish4
                    end
                    AselB_cplx1_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish4 = A_beam0_cplx1_dish4
                    end
                    if B == 8
                        AselB_cplx1_dish4 = A_beam8_cplx1_dish4
                    end
                    AselB_cplx0_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish8 = A_beam0_cplx0_dish8
                    end
                    if B == 8
                        AselB_cplx0_dish8 = A_beam8_cplx0_dish8
                    end
                    AselB_cplx1_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish8 = A_beam0_cplx1_dish8
                    end
                    if B == 8
                        AselB_cplx1_dish8 = A_beam8_cplx1_dish8
                    end
                    AselB_cplx0_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish12 = A_beam0_cplx0_dish12
                    end
                    if B == 8
                        AselB_cplx0_dish12 = A_beam8_cplx0_dish12
                    end
                    AselB_cplx1_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish12 = A_beam0_cplx1_dish12
                    end
                    if B == 8
                        AselB_cplx1_dish12 = A_beam8_cplx1_dish12
                    end
                    AselB_cplx0_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish16 = A_beam0_cplx0_dish16
                    end
                    if B == 8
                        AselB_cplx0_dish16 = A_beam8_cplx0_dish16
                    end
                    AselB_cplx1_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish16 = A_beam0_cplx1_dish16
                    end
                    if B == 8
                        AselB_cplx1_dish16 = A_beam8_cplx1_dish16
                    end
                    AselB_cplx0_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish20 = A_beam0_cplx0_dish20
                    end
                    if B == 8
                        AselB_cplx0_dish20 = A_beam8_cplx0_dish20
                    end
                    AselB_cplx1_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish20 = A_beam0_cplx1_dish20
                    end
                    if B == 8
                        AselB_cplx1_dish20 = A_beam8_cplx1_dish20
                    end
                    AselB_cplx0_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish24 = A_beam0_cplx0_dish24
                    end
                    if B == 8
                        AselB_cplx0_dish24 = A_beam8_cplx0_dish24
                    end
                    AselB_cplx1_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish24 = A_beam0_cplx1_dish24
                    end
                    if B == 8
                        AselB_cplx1_dish24 = A_beam8_cplx1_dish24
                    end
                    AselB_cplx0_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish28 = A_beam0_cplx0_dish28
                    end
                    if B == 8
                        AselB_cplx0_dish28 = A_beam8_cplx0_dish28
                    end
                    AselB_cplx1_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish28 = A_beam0_cplx1_dish28
                    end
                    if B == 8
                        AselB_cplx1_dish28 = A_beam8_cplx1_dish28
                    end
                    Jurepos_time0 = 0
                    Jurepos_time1 = 0
                    Jureneg_time0 = 0
                    Jureneg_time1 = 0
                    Juim_time0 = 0
                    Juim_time1 = 0
                    let
                        D = 0
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 4
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 8
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 12
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 16
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 20
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 24
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 28
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    Jure_time0 = Jurepos_time0 - Jureneg_time0
                    Jure_time1 = Jurepos_time1 - Jureneg_time1
                    Ju_cplx0_time0 = Juim_time0
                    Ju_cplx1_time0 = Jure_time0
                    Ju_cplx0_time1 = Juim_time1
                    Ju_cplx1_time1 = Jure_time1
                    Ju_cplx0_time0 = (Ju_cplx0_time0 + 4) >> 0x00000003
                    Ju_cplx1_time0 = (Ju_cplx1_time0 + 4) >> 0x00000003
                    Ju_cplx0_time1 = (Ju_cplx0_time1 + 4) >> 0x00000003
                    Ju_cplx1_time1 = (Ju_cplx1_time1 + 4) >> 0x00000003
                    Ju_time0 = convert(Int16x2, (Ju_cplx0_time0, Ju_cplx1_time0))
                    Ju_time1 = convert(Int16x2, (Ju_cplx0_time1, Ju_cplx1_time1))
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + ((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) % 32) * 128) + 0x01] =
                        Ju_time0
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + (((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) + 1) % 32) * 128) + 0x01] =
                        Ju_time1
                end
                let
                    B = 8
                    AselB_cplx0_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish0 = A_beam0_cplx0_dish0
                    end
                    if B == 8
                        AselB_cplx0_dish0 = A_beam8_cplx0_dish0
                    end
                    AselB_cplx1_dish0 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish0 = A_beam0_cplx1_dish0
                    end
                    if B == 8
                        AselB_cplx1_dish0 = A_beam8_cplx1_dish0
                    end
                    AselB_cplx0_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish4 = A_beam0_cplx0_dish4
                    end
                    if B == 8
                        AselB_cplx0_dish4 = A_beam8_cplx0_dish4
                    end
                    AselB_cplx1_dish4 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish4 = A_beam0_cplx1_dish4
                    end
                    if B == 8
                        AselB_cplx1_dish4 = A_beam8_cplx1_dish4
                    end
                    AselB_cplx0_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish8 = A_beam0_cplx0_dish8
                    end
                    if B == 8
                        AselB_cplx0_dish8 = A_beam8_cplx0_dish8
                    end
                    AselB_cplx1_dish8 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish8 = A_beam0_cplx1_dish8
                    end
                    if B == 8
                        AselB_cplx1_dish8 = A_beam8_cplx1_dish8
                    end
                    AselB_cplx0_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish12 = A_beam0_cplx0_dish12
                    end
                    if B == 8
                        AselB_cplx0_dish12 = A_beam8_cplx0_dish12
                    end
                    AselB_cplx1_dish12 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish12 = A_beam0_cplx1_dish12
                    end
                    if B == 8
                        AselB_cplx1_dish12 = A_beam8_cplx1_dish12
                    end
                    AselB_cplx0_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish16 = A_beam0_cplx0_dish16
                    end
                    if B == 8
                        AselB_cplx0_dish16 = A_beam8_cplx0_dish16
                    end
                    AselB_cplx1_dish16 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish16 = A_beam0_cplx1_dish16
                    end
                    if B == 8
                        AselB_cplx1_dish16 = A_beam8_cplx1_dish16
                    end
                    AselB_cplx0_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish20 = A_beam0_cplx0_dish20
                    end
                    if B == 8
                        AselB_cplx0_dish20 = A_beam8_cplx0_dish20
                    end
                    AselB_cplx1_dish20 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish20 = A_beam0_cplx1_dish20
                    end
                    if B == 8
                        AselB_cplx1_dish20 = A_beam8_cplx1_dish20
                    end
                    AselB_cplx0_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish24 = A_beam0_cplx0_dish24
                    end
                    if B == 8
                        AselB_cplx0_dish24 = A_beam8_cplx0_dish24
                    end
                    AselB_cplx1_dish24 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish24 = A_beam0_cplx1_dish24
                    end
                    if B == 8
                        AselB_cplx1_dish24 = A_beam8_cplx1_dish24
                    end
                    AselB_cplx0_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx0_dish28 = A_beam0_cplx0_dish28
                    end
                    if B == 8
                        AselB_cplx0_dish28 = A_beam8_cplx0_dish28
                    end
                    AselB_cplx1_dish28 = zero(Int8x4)
                    if B == 0
                        AselB_cplx1_dish28 = A_beam0_cplx1_dish28
                    end
                    if B == 8
                        AselB_cplx1_dish28 = A_beam8_cplx1_dish28
                    end
                    Jurepos_time0 = 0
                    Jurepos_time1 = 0
                    Jureneg_time0 = 0
                    Jureneg_time1 = 0
                    Juim_time0 = 0
                    Juim_time1 = 0
                    let
                        D = 0
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 4
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 8
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 12
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 16
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 20
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 24
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    let
                        D = 28
                        AselBD_cplx0 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx0 = AselB_cplx0_dish0
                        end
                        if D == 4
                            AselBD_cplx0 = AselB_cplx0_dish4
                        end
                        if D == 8
                            AselBD_cplx0 = AselB_cplx0_dish8
                        end
                        if D == 12
                            AselBD_cplx0 = AselB_cplx0_dish12
                        end
                        if D == 16
                            AselBD_cplx0 = AselB_cplx0_dish16
                        end
                        if D == 20
                            AselBD_cplx0 = AselB_cplx0_dish20
                        end
                        if D == 24
                            AselBD_cplx0 = AselB_cplx0_dish24
                        end
                        if D == 28
                            AselBD_cplx0 = AselB_cplx0_dish28
                        end
                        AselBD_cplx1 = zero(Int8x4)
                        if D == 0
                            AselBD_cplx1 = AselB_cplx1_dish0
                        end
                        if D == 4
                            AselBD_cplx1 = AselB_cplx1_dish4
                        end
                        if D == 8
                            AselBD_cplx1 = AselB_cplx1_dish8
                        end
                        if D == 12
                            AselBD_cplx1 = AselB_cplx1_dish12
                        end
                        if D == 16
                            AselBD_cplx1 = AselB_cplx1_dish16
                        end
                        if D == 20
                            AselBD_cplx1 = AselB_cplx1_dish20
                        end
                        if D == 24
                            AselBD_cplx1 = AselB_cplx1_dish24
                        end
                        if D == 28
                            AselBD_cplx1 = AselB_cplx1_dish28
                        end
                        Aim = AselBD_cplx0
                        Are = AselBD_cplx1
                        E0 = E_shared[(((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() ÷ 4) % 8) % 32) * 129 + (((((D ÷ 4) % 8) * 4 + (IndexSpaces.cuda_warpidx() % 4) * 128) + (IndexSpaces.cuda_threadidx() % 4) * 32) ÷ 4) % 128) + 0x01]
                        (E1_cplx0, E1_cplx1) = convert(NTuple{2,Int8x4}, E0)
                        E1im = E1_cplx0
                        E1re = E1_cplx1
                        (Jurepos_time0, Jurepos_time1) = IndexSpaces.mma_m8n8k16(Are, E1re, (Jurepos_time0, Jurepos_time1))
                        (Jureneg_time0, Jureneg_time1) = IndexSpaces.mma_m8n8k16(Aim, E1im, (Jureneg_time0, Jureneg_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Are, E1im, (Juim_time0, Juim_time1))
                        (Juim_time0, Juim_time1) = IndexSpaces.mma_m8n8k16(Aim, E1re, (Juim_time0, Juim_time1))
                    end
                    Jure_time0 = Jurepos_time0 - Jureneg_time0
                    Jure_time1 = Jurepos_time1 - Jureneg_time1
                    Ju_cplx0_time0 = Juim_time0
                    Ju_cplx1_time0 = Jure_time0
                    Ju_cplx0_time1 = Juim_time1
                    Ju_cplx1_time1 = Jure_time1
                    Ju_cplx0_time0 = (Ju_cplx0_time0 + 4) >> 0x00000003
                    Ju_cplx1_time0 = (Ju_cplx1_time0 + 4) >> 0x00000003
                    Ju_cplx0_time1 = (Ju_cplx0_time1 + 4) >> 0x00000003
                    Ju_cplx1_time1 = (Ju_cplx1_time1 + 4) >> 0x00000003
                    Ju_time0 = convert(Int16x2, (Ju_cplx0_time0, Ju_cplx1_time0))
                    Ju_time1 = convert(Int16x2, (Ju_cplx0_time1, Ju_cplx1_time1))
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + ((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) % 32) * 128) + 0x01] =
                        Ju_time0
                    Ju_shared[((((((IndexSpaces.cuda_warpidx() % 4) * 128) ÷ 128) % 4) * 4096 + (((IndexSpaces.cuda_threadidx() ÷ 4) % 8 + ((IndexSpaces.cuda_warpidx() ÷ 4) % 8) * 16) + ((B ÷ 8) % 2) * 8) % 128) + (((((((T3 ÷ 8) % 4) * 8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + (IndexSpaces.cuda_threadidx() % 4) * 2) + 1) % 32) * 128) + 0x01] =
                        Ju_time1
                end
            end
            IndexSpaces.cuda_sync_threads()
            Ju_dish0_time0 = Ju_shared[(((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128 + (((((T1 ÷ 128) % 256) * 128 + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish128_time0 = Ju_shared[((4096 + ((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128) + (((((T1 ÷ 128) % 256) * 128 + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish256_time0 = Ju_shared[((8192 + ((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128) + (((((T1 ÷ 128) % 256) * 128 + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish384_time0 = Ju_shared[((12288 + ((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128) + (((((T1 ÷ 128) % 256) * 128 + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish0_time8 = Ju_shared[(((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128 + ((((8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish128_time8 = Ju_shared[((4096 + ((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128) + ((((8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish256_time8 = Ju_shared[((8192 + ((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128) + ((((8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish384_time8 = Ju_shared[((12288 + ((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128) + ((((8 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish0_time16 = Ju_shared[(((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128 + ((((16 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish128_time16 = Ju_shared[((4096 + ((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128) + ((((16 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish256_time16 = Ju_shared[((8192 + ((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128) + ((((16 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish384_time16 = Ju_shared[((12288 + ((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128) + ((((16 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish0_time24 = Ju_shared[(((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128 + ((((24 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish128_time24 = Ju_shared[((4096 + ((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128) + ((((24 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish256_time24 = Ju_shared[((8192 + ((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128) + ((((24 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            Ju_dish384_time24 = Ju_shared[((12288 + ((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128) + ((((24 + ((T1 ÷ 128) % 256) * 128) + ((T2 ÷ 32) % 4) * 32) + IndexSpaces.cuda_threadidx() % 8) % 32) * 128) + 0x01]
            (Ju_cplx0_dish0_time0, Ju_cplx1_dish0_time0) = convert(NTuple{2,Int32}, Ju_dish0_time0)
            (Ju_cplx0_dish128_time0, Ju_cplx1_dish128_time0) = convert(NTuple{2,Int32}, Ju_dish128_time0)
            (Ju_cplx0_dish256_time0, Ju_cplx1_dish256_time0) = convert(NTuple{2,Int32}, Ju_dish256_time0)
            (Ju_cplx0_dish384_time0, Ju_cplx1_dish384_time0) = convert(NTuple{2,Int32}, Ju_dish384_time0)
            (Ju_cplx0_dish0_time8, Ju_cplx1_dish0_time8) = convert(NTuple{2,Int32}, Ju_dish0_time8)
            (Ju_cplx0_dish128_time8, Ju_cplx1_dish128_time8) = convert(NTuple{2,Int32}, Ju_dish128_time8)
            (Ju_cplx0_dish256_time8, Ju_cplx1_dish256_time8) = convert(NTuple{2,Int32}, Ju_dish256_time8)
            (Ju_cplx0_dish384_time8, Ju_cplx1_dish384_time8) = convert(NTuple{2,Int32}, Ju_dish384_time8)
            (Ju_cplx0_dish0_time16, Ju_cplx1_dish0_time16) = convert(NTuple{2,Int32}, Ju_dish0_time16)
            (Ju_cplx0_dish128_time16, Ju_cplx1_dish128_time16) = convert(NTuple{2,Int32}, Ju_dish128_time16)
            (Ju_cplx0_dish256_time16, Ju_cplx1_dish256_time16) = convert(NTuple{2,Int32}, Ju_dish256_time16)
            (Ju_cplx0_dish384_time16, Ju_cplx1_dish384_time16) = convert(NTuple{2,Int32}, Ju_dish384_time16)
            (Ju_cplx0_dish0_time24, Ju_cplx1_dish0_time24) = convert(NTuple{2,Int32}, Ju_dish0_time24)
            (Ju_cplx0_dish128_time24, Ju_cplx1_dish128_time24) = convert(NTuple{2,Int32}, Ju_dish128_time24)
            (Ju_cplx0_dish256_time24, Ju_cplx1_dish256_time24) = convert(NTuple{2,Int32}, Ju_dish256_time24)
            (Ju_cplx0_dish384_time24, Ju_cplx1_dish384_time24) = convert(NTuple{2,Int32}, Ju_dish384_time24)
            Julo_cplx0_dish0_time0 = Ju_cplx0_dish0_time0
            Juhi_cplx0_dish0_time0 = Ju_cplx0_dish128_time0
            Julo_cplx1_dish0_time0 = Ju_cplx1_dish0_time0
            Juhi_cplx1_dish0_time0 = Ju_cplx1_dish128_time0
            Julo_cplx0_dish256_time0 = Ju_cplx0_dish256_time0
            Juhi_cplx0_dish256_time0 = Ju_cplx0_dish384_time0
            Julo_cplx1_dish256_time0 = Ju_cplx1_dish256_time0
            Juhi_cplx1_dish256_time0 = Ju_cplx1_dish384_time0
            Julo_cplx0_dish0_time8 = Ju_cplx0_dish0_time8
            Juhi_cplx0_dish0_time8 = Ju_cplx0_dish128_time8
            Julo_cplx1_dish0_time8 = Ju_cplx1_dish0_time8
            Juhi_cplx1_dish0_time8 = Ju_cplx1_dish128_time8
            Julo_cplx0_dish256_time8 = Ju_cplx0_dish256_time8
            Juhi_cplx0_dish256_time8 = Ju_cplx0_dish384_time8
            Julo_cplx1_dish256_time8 = Ju_cplx1_dish256_time8
            Juhi_cplx1_dish256_time8 = Ju_cplx1_dish384_time8
            Julo_cplx0_dish0_time16 = Ju_cplx0_dish0_time16
            Juhi_cplx0_dish0_time16 = Ju_cplx0_dish128_time16
            Julo_cplx1_dish0_time16 = Ju_cplx1_dish0_time16
            Juhi_cplx1_dish0_time16 = Ju_cplx1_dish128_time16
            Julo_cplx0_dish256_time16 = Ju_cplx0_dish256_time16
            Juhi_cplx0_dish256_time16 = Ju_cplx0_dish384_time16
            Julo_cplx1_dish256_time16 = Ju_cplx1_dish256_time16
            Juhi_cplx1_dish256_time16 = Ju_cplx1_dish384_time16
            Julo_cplx0_dish0_time24 = Ju_cplx0_dish0_time24
            Juhi_cplx0_dish0_time24 = Ju_cplx0_dish128_time24
            Julo_cplx1_dish0_time24 = Ju_cplx1_dish0_time24
            Juhi_cplx1_dish0_time24 = Ju_cplx1_dish128_time24
            Julo_cplx0_dish256_time24 = Ju_cplx0_dish256_time24
            Juhi_cplx0_dish256_time24 = Ju_cplx0_dish384_time24
            Julo_cplx1_dish256_time24 = Ju_cplx1_dish256_time24
            Juhi_cplx1_dish256_time24 = Ju_cplx1_dish384_time24
            Ju_cplx0_dish0_time0 = Julo_cplx0_dish0_time0 + Juhi_cplx0_dish0_time0
            Ju_cplx1_dish0_time0 = Julo_cplx1_dish0_time0 + Juhi_cplx1_dish0_time0
            Ju_cplx0_dish256_time0 = Julo_cplx0_dish256_time0 + Juhi_cplx0_dish256_time0
            Ju_cplx1_dish256_time0 = Julo_cplx1_dish256_time0 + Juhi_cplx1_dish256_time0
            Ju_cplx0_dish0_time8 = Julo_cplx0_dish0_time8 + Juhi_cplx0_dish0_time8
            Ju_cplx1_dish0_time8 = Julo_cplx1_dish0_time8 + Juhi_cplx1_dish0_time8
            Ju_cplx0_dish256_time8 = Julo_cplx0_dish256_time8 + Juhi_cplx0_dish256_time8
            Ju_cplx1_dish256_time8 = Julo_cplx1_dish256_time8 + Juhi_cplx1_dish256_time8
            Ju_cplx0_dish0_time16 = Julo_cplx0_dish0_time16 + Juhi_cplx0_dish0_time16
            Ju_cplx1_dish0_time16 = Julo_cplx1_dish0_time16 + Juhi_cplx1_dish0_time16
            Ju_cplx0_dish256_time16 = Julo_cplx0_dish256_time16 + Juhi_cplx0_dish256_time16
            Ju_cplx1_dish256_time16 = Julo_cplx1_dish256_time16 + Juhi_cplx1_dish256_time16
            Ju_cplx0_dish0_time24 = Julo_cplx0_dish0_time24 + Juhi_cplx0_dish0_time24
            Ju_cplx1_dish0_time24 = Julo_cplx1_dish0_time24 + Juhi_cplx1_dish0_time24
            Ju_cplx0_dish256_time24 = Julo_cplx0_dish256_time24 + Juhi_cplx0_dish256_time24
            Ju_cplx1_dish256_time24 = Julo_cplx1_dish256_time24 + Juhi_cplx1_dish256_time24
            Julo_cplx0_time0 = Ju_cplx0_dish0_time0
            Juhi_cplx0_time0 = Ju_cplx0_dish256_time0
            Julo_cplx1_time0 = Ju_cplx1_dish0_time0
            Juhi_cplx1_time0 = Ju_cplx1_dish256_time0
            Julo_cplx0_time8 = Ju_cplx0_dish0_time8
            Juhi_cplx0_time8 = Ju_cplx0_dish256_time8
            Julo_cplx1_time8 = Ju_cplx1_dish0_time8
            Juhi_cplx1_time8 = Ju_cplx1_dish256_time8
            Julo_cplx0_time16 = Ju_cplx0_dish0_time16
            Juhi_cplx0_time16 = Ju_cplx0_dish256_time16
            Julo_cplx1_time16 = Ju_cplx1_dish0_time16
            Juhi_cplx1_time16 = Ju_cplx1_dish256_time16
            Julo_cplx0_time24 = Ju_cplx0_dish0_time24
            Juhi_cplx0_time24 = Ju_cplx0_dish256_time24
            Julo_cplx1_time24 = Ju_cplx1_dish0_time24
            Juhi_cplx1_time24 = Ju_cplx1_dish256_time24
            J_cplx0_time0 = Julo_cplx0_time0 + Juhi_cplx0_time0
            J_cplx1_time0 = Julo_cplx1_time0 + Juhi_cplx1_time0
            J_cplx0_time8 = Julo_cplx0_time8 + Juhi_cplx0_time8
            J_cplx1_time8 = Julo_cplx1_time8 + Juhi_cplx1_time8
            J_cplx0_time16 = Julo_cplx0_time16 + Juhi_cplx0_time16
            J_cplx1_time16 = Julo_cplx1_time16 + Juhi_cplx1_time16
            J_cplx0_time24 = Julo_cplx0_time24 + Juhi_cplx0_time24
            J_cplx1_time24 = Julo_cplx1_time24 + Juhi_cplx1_time24
            J_cplx0_time0 = (J_cplx0_time0 + Int32(1) << (s % UInt32 - 0x01)) >> (s % UInt32)
            J_cplx1_time0 = (J_cplx1_time0 + Int32(1) << (s % UInt32 - 0x01)) >> (s % UInt32)
            J_cplx0_time8 = (J_cplx0_time8 + Int32(1) << (s % UInt32 - 0x01)) >> (s % UInt32)
            J_cplx1_time8 = (J_cplx1_time8 + Int32(1) << (s % UInt32 - 0x01)) >> (s % UInt32)
            J_cplx0_time16 = (J_cplx0_time16 + Int32(1) << (s % UInt32 - 0x01)) >> (s % UInt32)
            J_cplx1_time16 = (J_cplx1_time16 + Int32(1) << (s % UInt32 - 0x01)) >> (s % UInt32)
            J_cplx0_time24 = (J_cplx0_time24 + Int32(1) << (s % UInt32 - 0x01)) >> (s % UInt32)
            J_cplx1_time24 = (J_cplx1_time24 + Int32(1) << (s % UInt32 - 0x01)) >> (s % UInt32)
            J_cplx0_time0 = clamp(J_cplx0_time0, (-(Int32(0x07))):+(Int32(0x07)))
            J_cplx1_time0 = clamp(J_cplx1_time0, (-(Int32(0x07))):+(Int32(0x07)))
            J_cplx0_time8 = clamp(J_cplx0_time8, (-(Int32(0x07))):+(Int32(0x07)))
            J_cplx1_time8 = clamp(J_cplx1_time8, (-(Int32(0x07))):+(Int32(0x07)))
            J_cplx0_time16 = clamp(J_cplx0_time16, (-(Int32(0x07))):+(Int32(0x07)))
            J_cplx1_time16 = clamp(J_cplx1_time16, (-(Int32(0x07))):+(Int32(0x07)))
            J_cplx0_time24 = clamp(J_cplx0_time24, (-(Int32(0x07))):+(Int32(0x07)))
            J_cplx1_time24 = clamp(J_cplx1_time24, (-(Int32(0x07))):+(Int32(0x07)))
            J = Int4x8(
                J_cplx0_time0,
                J_cplx1_time0,
                J_cplx0_time8,
                J_cplx1_time8,
                J_cplx0_time16,
                J_cplx1_time16,
                J_cplx0_time24,
                J_cplx1_time24,
            )
            if T2 == 0
                Jper_time0 = J
            end
            if T2 == 32
                Jper_time32 = J
            end
            if T2 == 64
                Jper_time64 = J
            end
            if T2 == 96
                Jper_time96 = J
            end
        end
        (Jper_time0, Jper_time32) = (IndexSpaces.get_lo8(Jper_time0, Jper_time32), IndexSpaces.get_hi8(Jper_time0, Jper_time32))
        (Jper_time64, Jper_time96) = (IndexSpaces.get_lo8(Jper_time64, Jper_time96), IndexSpaces.get_hi8(Jper_time64, Jper_time96))
        is_lo_thread = IndexSpaces.cuda_threadidx() & 0x00000001 == 0
        (Jper_time0, Jper_time32) = let
            src = if is_lo_thread
                Jper_time32
            else
                Jper_time0
            end
            dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000001)
            if is_lo_thread
                (Jper_time0, dst)
            else
                (dst, Jper_time32)
            end
        end
        (Jper_time64, Jper_time96) = let
            src = if is_lo_thread
                Jper_time96
            else
                Jper_time64
            end
            dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000001)
            if is_lo_thread
                (Jper_time64, dst)
            else
                (dst, Jper_time96)
            end
        end
        (Jper_time0, Jper_time32) = (IndexSpaces.get_lo8(Jper_time0, Jper_time32), IndexSpaces.get_hi8(Jper_time0, Jper_time32))
        (Jper_time64, Jper_time96) = (IndexSpaces.get_lo8(Jper_time64, Jper_time96), IndexSpaces.get_hi8(Jper_time64, Jper_time96))
        is_lo_thread = IndexSpaces.cuda_threadidx() & 0x00000002 == 0
        (Jper_time0, Jper_time64) = let
            src = if is_lo_thread
                Jper_time64
            else
                Jper_time0
            end
            dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
            if is_lo_thread
                (Jper_time0, dst)
            else
                (dst, Jper_time64)
            end
        end
        (Jper_time32, Jper_time96) = let
            src = if is_lo_thread
                Jper_time96
            else
                Jper_time32
            end
            dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000002)
            if is_lo_thread
                (Jper_time32, dst)
            else
                (dst, Jper_time96)
            end
        end
        (Jper_time0, Jper_time64) = (IndexSpaces.get_lo16(Jper_time0, Jper_time64), IndexSpaces.get_hi16(Jper_time0, Jper_time64))
        (Jper_time32, Jper_time96) = (
            IndexSpaces.get_lo16(Jper_time32, Jper_time96), IndexSpaces.get_hi16(Jper_time32, Jper_time96)
        )
        is_lo_thread = IndexSpaces.cuda_threadidx() & 0x00000004 == 0
        (Jper_time0, Jper_time32) = let
            src = if is_lo_thread
                Jper_time32
            else
                Jper_time0
            end
            dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
            if is_lo_thread
                (Jper_time0, dst)
            else
                (dst, Jper_time32)
            end
        end
        (Jper_time64, Jper_time96) = let
            src = if is_lo_thread
                Jper_time96
            else
                Jper_time64
            end
            dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000004)
            if is_lo_thread
                (Jper_time64, dst)
            else
                (dst, Jper_time96)
            end
        end
        is_lo_thread = IndexSpaces.cuda_threadidx() & 0x00000001 == 0
        (Jper_time0, Jper_time64) = let
            src = if is_lo_thread
                Jper_time64
            else
                Jper_time0
            end
            dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000001)
            if is_lo_thread
                (Jper_time0, dst)
            else
                (dst, Jper_time64)
            end
        end
        (Jper_time32, Jper_time96) = let
            src = if is_lo_thread
                Jper_time96
            else
                Jper_time32
            end
            dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000001)
            if is_lo_thread
                (Jper_time32, dst)
            else
                (dst, Jper_time96)
            end
        end
        IndexSpaces.unsafe_store4_global!(
            J_memory,
            (
                (
                    (
                        (
                            (
                                (
                                    (
                                        ((IndexSpaces.cuda_threadidx() ÷ 2) % 2) * 64 +
                                        ((IndexSpaces.cuda_threadidx() ÷ 4) % 2) * 32
                                    ) + ((T1 ÷ 128) % 256) * 128
                                ) + (IndexSpaces.cuda_threadidx() % 2) * 16
                            ) ÷ 4
                        ) % 8192 + ((IndexSpaces.cuda_blockidx() % 2) % 2) * 8192
                    ) + (((IndexSpaces.cuda_warpidx() % 32) * 4 + (IndexSpaces.cuda_threadidx() ÷ 8) % 4) % 128) * 262144
                ) + (((IndexSpaces.cuda_blockidx() ÷ 2) % 16) % 16) * 16384
            ) + 0x01,
            (Jper_time0, Jper_time32, Jper_time64, Jper_time96),
        )
    end
end