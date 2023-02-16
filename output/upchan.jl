[Creating upchan kernel...]
[Done creating upchan kernel]
@fastmath @inbounds(
    begin #= /Users/eschnett/src/jl/IndexSpaces/kernels/upchan.jl:518 =#
        F_ringbuf_mtaps0 = zero(Int4x8)
        F_ringbuf_mtaps1 = zero(Int4x8)
        F_ringbuf_mtaps2 = zero(Int4x8)
        Gains = G_memory[(((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 2) % 2) * 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 2) * 4) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2) * 8) ÷ 2) % 8 + 0x01]
        Wpfb_mtaps0 = W_memory[((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2) % 8 + 0x01]
        Wpfb_mtaps1 = W_memory[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2) % 8 + 8) + 0x01]
        Wpfb_mtaps2 = W_memory[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2) % 8 + 16) + 0x01]
        Wpfb_mtaps3 = W_memory[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2) % 8 + 24) + 0x01]
        Xre = let
            thread = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32)
            thread0 = (thread ÷ (1i32)) % (2i32)
            thread1 = (thread ÷ (2i32)) % (2i32)
            thread2 = (thread ÷ (4i32)) % (2i32)
            time0 = (1i32) * thread2 + (2i32) * thread0 + (4i32) * thread1
            time1 = time0 + 8i32
            X0 = cispi(Float32(time0 * (U - 1i32)) / U)
            X1 = cispi(Float32(time1 * (U - 1i32)) / U)
            (real(X0), real(X1))
        end
        Xim = let
            thread = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32)
            thread0 = (thread ÷ (1i32)) % (2i32)
            thread1 = (thread ÷ (2i32)) % (2i32)
            thread2 = (thread ÷ (4i32)) % (2i32)
            time0 = (1i32) * thread2 + (2i32) * thread0 + (4i32) * thread1
            time1 = time0 + 8i32
            X0 = cispi(Float32(time0 * (U - 1i32)) / U)
            X1 = cispi(Float32(time1 * (U - 1i32)) / U)
            (imag(X0), imag(X1))
        end
        X_cplx0 = Xim
        X_cplx1 = Xre
        for t_outer in 0:256:32767
            (E_dish0_time0, E_dish4_time0, E_dish8_time0, E_dish12_time0) = IndexSpaces.unsafe_load4_global(
                E_memory,
                (
                    (
                        (
                            (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 4) % 2) % 2) * 2048 +
                            (
                                (
                                    (
                                        (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 +
                                        ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8
                                    ) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4
                                ) % 32768
                            ) * 4096
                        ) +
                        (
                            (
                                (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16 +
                                (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128
                            ) ÷ 4
                        ) % 128
                    ) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 8) % 16) % 16) * 128
                ) + 1i32,
            )
            (E_dish0_time1, E_dish4_time1, E_dish8_time1, E_dish12_time1) = IndexSpaces.unsafe_load4_global(
                E_memory,
                (
                    (
                        (
                            (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 4) % 2) % 2) * 2048 +
                            (
                                (
                                    (
                                        (
                                            (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 +
                                            ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8
                                        ) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4
                                    ) + 1
                                ) % 32768
                            ) * 4096
                        ) +
                        (
                            (
                                (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16 +
                                (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128
                            ) ÷ 4
                        ) % 128
                    ) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 8) % 16) % 16) * 128
                ) + 1i32,
            )
            (E_dish0_time2, E_dish4_time2, E_dish8_time2, E_dish12_time2) = IndexSpaces.unsafe_load4_global(
                E_memory,
                (
                    (
                        (
                            (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 4) % 2) % 2) * 2048 +
                            (
                                (
                                    (
                                        (
                                            (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 +
                                            ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8
                                        ) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4
                                    ) + 2
                                ) % 32768
                            ) * 4096
                        ) +
                        (
                            (
                                (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16 +
                                (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128
                            ) ÷ 4
                        ) % 128
                    ) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 8) % 16) % 16) * 128
                ) + 1i32,
            )
            (E_dish0_time3, E_dish4_time3, E_dish8_time3, E_dish12_time3) = IndexSpaces.unsafe_load4_global(
                E_memory,
                (
                    (
                        (
                            (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 4) % 2) % 2) * 2048 +
                            (
                                (
                                    (
                                        (
                                            (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 +
                                            ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8
                                        ) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4
                                    ) + 3
                                ) % 32768
                            ) * 4096
                        ) +
                        (
                            (
                                (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16 +
                                (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128
                            ) ÷ 4
                        ) % 128
                    ) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 8) % 16) % 16) * 128
                ) + 1i32,
            )
            is_lo_thread = IndexSpaces.cuda_threadidx() & 0x00000008 == 0x00
            (E1_dish0_time0, E1_dish8_time0) = let
                src = if is_lo_thread
                    E_dish8_time0
                else
                    E_dish0_time0
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000008)
                if is_lo_thread
                    (E_dish0_time0, dst)
                else
                    (dst, E_dish8_time0)
                end
            end
            (E1_dish4_time0, E1_dish12_time0) = let
                src = if is_lo_thread
                    E_dish12_time0
                else
                    E_dish4_time0
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000008)
                if is_lo_thread
                    (E_dish4_time0, dst)
                else
                    (dst, E_dish12_time0)
                end
            end
            (E1_dish0_time1, E1_dish8_time1) = let
                src = if is_lo_thread
                    E_dish8_time1
                else
                    E_dish0_time1
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000008)
                if is_lo_thread
                    (E_dish0_time1, dst)
                else
                    (dst, E_dish8_time1)
                end
            end
            (E1_dish4_time1, E1_dish12_time1) = let
                src = if is_lo_thread
                    E_dish12_time1
                else
                    E_dish4_time1
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000008)
                if is_lo_thread
                    (E_dish4_time1, dst)
                else
                    (dst, E_dish12_time1)
                end
            end
            (E1_dish0_time2, E1_dish8_time2) = let
                src = if is_lo_thread
                    E_dish8_time2
                else
                    E_dish0_time2
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000008)
                if is_lo_thread
                    (E_dish0_time2, dst)
                else
                    (dst, E_dish8_time2)
                end
            end
            (E1_dish4_time2, E1_dish12_time2) = let
                src = if is_lo_thread
                    E_dish12_time2
                else
                    E_dish4_time2
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000008)
                if is_lo_thread
                    (E_dish4_time2, dst)
                else
                    (dst, E_dish12_time2)
                end
            end
            (E1_dish0_time3, E1_dish8_time3) = let
                src = if is_lo_thread
                    E_dish8_time3
                else
                    E_dish0_time3
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000008)
                if is_lo_thread
                    (E_dish0_time3, dst)
                else
                    (dst, E_dish8_time3)
                end
            end
            (E1_dish4_time3, E1_dish12_time3) = let
                src = if is_lo_thread
                    E_dish12_time3
                else
                    E_dish4_time3
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000008)
                if is_lo_thread
                    (E_dish4_time3, dst)
                else
                    (dst, E_dish12_time3)
                end
            end
            E1lo_dish0_time0 = E1_dish0_time0
            E1hi_dish0_time0 = E1_dish0_time8
            E1lo_dish4_time0 = E1_dish4_time0
            E1hi_dish4_time0 = E1_dish4_time8
            E1lo_dish0_time1 = E1_dish0_time1
            E1hi_dish0_time1 = E1_dish0_time9
            E1lo_dish4_time1 = E1_dish4_time1
            E1hi_dish4_time1 = E1_dish4_time9
            E1lo_dish0_time2 = E1_dish0_time2
            E1hi_dish0_time2 = E1_dish0_time10
            E1lo_dish4_time2 = E1_dish4_time2
            E1hi_dish4_time2 = E1_dish4_time10
            E1lo_dish0_time3 = E1_dish0_time3
            E1hi_dish0_time3 = E1_dish0_time11
            E1lo_dish4_time3 = E1_dish4_time3
            E1hi_dish4_time3 = E1_dish4_time11
            E1_dish0_time0 = E1lo_dish0_time0
            E1_dish0_time8 = E1hi_dish0_time0
            E1_dish4_time0 = E1lo_dish4_time0
            E1_dish4_time8 = E1hi_dish4_time0
            E1_dish0_time1 = E1lo_dish0_time1
            E1_dish0_time9 = E1hi_dish0_time1
            E1_dish4_time1 = E1lo_dish4_time1
            E1_dish4_time9 = E1hi_dish4_time1
            E1_dish0_time2 = E1lo_dish0_time2
            E1_dish0_time10 = E1hi_dish0_time2
            E1_dish4_time2 = E1lo_dish4_time2
            E1_dish4_time10 = E1hi_dish4_time2
            E1_dish0_time3 = E1lo_dish0_time3
            E1_dish0_time11 = E1hi_dish0_time3
            E1_dish4_time3 = E1lo_dish4_time3
            E1_dish4_time11 = E1hi_dish4_time3
            (E2_dish0_time0, E2_dish0_time8) = (
                IndexSpaces.get_lo16(E1_dish0_time0, E1_dish0_time8), IndexSpaces.get_hi16(E1_dish0_time0, E1_dish0_time8)
            )
            (E2_dish4_time0, E2_dish4_time8) = (
                IndexSpaces.get_lo16(E1_dish4_time0, E1_dish4_time8), IndexSpaces.get_hi16(E1_dish4_time0, E1_dish4_time8)
            )
            (E2_dish0_time1, E2_dish0_time9) = (
                IndexSpaces.get_lo16(E1_dish0_time1, E1_dish0_time9), IndexSpaces.get_hi16(E1_dish0_time1, E1_dish0_time9)
            )
            (E2_dish4_time1, E2_dish4_time9) = (
                IndexSpaces.get_lo16(E1_dish4_time1, E1_dish4_time9), IndexSpaces.get_hi16(E1_dish4_time1, E1_dish4_time9)
            )
            (E2_dish0_time2, E2_dish0_time10) = (
                IndexSpaces.get_lo16(E1_dish0_time2, E1_dish0_time10), IndexSpaces.get_hi16(E1_dish0_time2, E1_dish0_time10)
            )
            (E2_dish4_time2, E2_dish4_time10) = (
                IndexSpaces.get_lo16(E1_dish4_time2, E1_dish4_time10), IndexSpaces.get_hi16(E1_dish4_time2, E1_dish4_time10)
            )
            (E2_dish0_time3, E2_dish0_time11) = (
                IndexSpaces.get_lo16(E1_dish0_time3, E1_dish0_time11), IndexSpaces.get_hi16(E1_dish0_time3, E1_dish0_time11)
            )
            (E2_dish4_time3, E2_dish4_time11) = (
                IndexSpaces.get_lo16(E1_dish4_time3, E1_dish4_time11), IndexSpaces.get_hi16(E1_dish4_time3, E1_dish4_time11)
            )
            E2lo_dish0_time0 = E2_dish0_time0
            E2hi_dish0_time0 = E2_dish2_time0
            E2lo_dish4_time0 = E2_dish4_time0
            E2hi_dish4_time0 = E2_dish6_time0
            E2lo_dish0_time1 = E2_dish0_time1
            E2hi_dish0_time1 = E2_dish2_time1
            E2lo_dish4_time1 = E2_dish4_time1
            E2hi_dish4_time1 = E2_dish6_time1
            E2lo_dish0_time2 = E2_dish0_time2
            E2hi_dish0_time2 = E2_dish2_time2
            E2lo_dish4_time2 = E2_dish4_time2
            E2hi_dish4_time2 = E2_dish6_time2
            E2lo_dish0_time3 = E2_dish0_time3
            E2hi_dish0_time3 = E2_dish2_time3
            E2lo_dish4_time3 = E2_dish4_time3
            E2hi_dish4_time3 = E2_dish6_time3
            E2_dish0_time0 = E2lo_dish0_time0
            E2_dish2_time0 = E2hi_dish0_time0
            E2_dish4_time0 = E2lo_dish4_time0
            E2_dish6_time0 = E2hi_dish4_time0
            E2_dish0_time1 = E2lo_dish0_time1
            E2_dish2_time1 = E2hi_dish0_time1
            E2_dish4_time1 = E2lo_dish4_time1
            E2_dish6_time1 = E2hi_dish4_time1
            E2_dish0_time2 = E2lo_dish0_time2
            E2_dish2_time2 = E2hi_dish0_time2
            E2_dish4_time2 = E2lo_dish4_time2
            E2_dish6_time2 = E2hi_dish4_time2
            E2_dish0_time3 = E2lo_dish0_time3
            E2_dish2_time3 = E2hi_dish0_time3
            E2_dish4_time3 = E2lo_dish4_time3
            E2_dish6_time3 = E2hi_dish4_time3
            F_dish0_time0 = E2
            F_dish2_time0 = E2
            F_dish4_time0 = E2
            F_dish6_time0 = E2
            F_dish0_time1 = E2
            F_dish2_time1 = E2
            F_dish4_time1 = E2
            F_dish6_time1 = E2
            F_dish0_time2 = E2
            F_dish2_time2 = E2
            F_dish4_time2 = E2
            F_dish6_time2 = E2
            F_dish0_time3 = E2
            F_dish2_time3 = E2
            F_dish4_time3 = E2
            F_dish6_time3 = E2
            F_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) ÷ 16) % 16) * 545 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) % 2) * 260) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) ÷ 2) % 2) * 130) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish0_time0
            F_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) ÷ 16) % 16) * 545 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) % 2) * 260) + (((((2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) ÷ 2) % 2) * 130) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish2_time0
            F_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) ÷ 16) % 16) * 545 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) % 2) * 260) + (((((4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) ÷ 2) % 2) * 130) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish4_time0
            F_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) ÷ 16) % 16) * 545 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) % 2) * 260) + (((((6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) ÷ 2) % 2) * 130) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish6_time0
            F_shared[((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) ÷ 16) % 16) * 545 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) % 2) * 260) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish0_time1
            F_shared[((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) ÷ 16) % 16) * 545 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) % 2) * 260) + (((((2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish2_time1
            F_shared[((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) ÷ 16) % 16) * 545 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) % 2) * 260) + (((((4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish4_time1
            F_shared[((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) ÷ 16) % 16) * 545 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) % 2) * 260) + (((((6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 1) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish6_time1
            F_shared[((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) ÷ 16) % 16) * 545 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) % 2) * 260) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish0_time2
            F_shared[((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) ÷ 16) % 16) * 545 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) % 2) * 260) + (((((2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish2_time2
            F_shared[((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) ÷ 16) % 16) * 545 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) % 2) * 260) + (((((4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish4_time2
            F_shared[((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) ÷ 16) % 16) * 545 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) % 2) * 260) + (((((6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 2) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish6_time2
            F_shared[((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) ÷ 16) % 16) * 545 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) % 2) * 260) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish0_time3
            F_shared[((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) ÷ 16) % 16) * 545 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) % 2) * 260) + (((((2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish2_time3
            F_shared[((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) ÷ 16) % 16) * 545 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) % 2) * 260) + (((((4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish4_time3
            F_shared[((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) ÷ 16) % 16) * 545 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) % 2) * 260) + (((((6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + 3) ÷ 4) % 2) * 65) + 0 + 0x01] =
                F_dish6_time3
            IndexSpaces.cuda_sync_threads()
            for t_inner in 0:16:255
                let
                    dish = 0
                    F_in = F_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2) ÷ 16) % 16) * 545 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2) % 2) * 260) + (((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 8) * 4 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 64) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 32) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) ÷ 8) % 2) * 2) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 2) % 2) * 32) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 8) * 4 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 64) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 32) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) ÷ 8) % 2) * 2) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128) ÷ 4) % 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2) ÷ 2) % 2) * 130) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2) ÷ 4) % 2) * 65) + 0x01]
                    F̄_out = zero(Int8x4)
                    (E_cplx0_dish0, E_cplx1_dish0, E_cplx0_dish1, E_cplx1_dish1) = convert(NTuple{4,Float16x2}, F_in)
                    W_m0 = Wpfb_mtaps0
                    W_m1 = Wpfb_mtaps1
                    W_m2 = Wpfb_mtaps2
                    W_m3 = Wpfb_mtaps3
                    E2_cplx0_dish0 = W_m3 * E_cplx0_dish0
                    E2_cplx1_dish0 = W_m3 * E_cplx1_dish0
                    E2_cplx0_dish1 = W_m3 * E_cplx0_dish1
                    E2_cplx1_dish1 = W_m3 * E_cplx1_dish1
                    F_ringbuf_m0 = F_ringbuf_mtaps0
                    F_ringbuf_m1 = F_ringbuf_mtaps1
                    F_ringbuf_m2 = F_ringbuf_mtaps2
                    (E_ringbuf_m0_cplx0_dish0, E_ringbuf_m0_cplx1_dish0, E_ringbuf_m0_cplx0_dish1, E_ringbuf_m0_cplx1_dish1) = convert(
                        NTuple{4,Float16x2}, F_ringbuf_m0
                    )
                    E2_cplx0_dish0 = muladd(W_m0, E_ringbuf_m0_cplx0_dish0, E2_cplx0_dish0)
                    E2_cplx1_dish0 = muladd(W_m0, E_ringbuf_m0_cplx1_dish0, E2_cplx1_dish0)
                    E2_cplx0_dish1 = muladd(W_m0, E_ringbuf_m0_cplx0_dish1, E2_cplx0_dish1)
                    E2_cplx1_dish1 = muladd(W_m0, E_ringbuf_m0_cplx1_dish1, E2_cplx1_dish1)
                    (E_ringbuf_m1_cplx0_dish0, E_ringbuf_m1_cplx1_dish0, E_ringbuf_m1_cplx0_dish1, E_ringbuf_m1_cplx1_dish1) = convert(
                        NTuple{4,Float16x2}, F_ringbuf_m1
                    )
                    E2_cplx0_dish0 = muladd(W_m1, E_ringbuf_m1_cplx0_dish0, E2_cplx0_dish0)
                    E2_cplx1_dish0 = muladd(W_m1, E_ringbuf_m1_cplx1_dish0, E2_cplx1_dish0)
                    E2_cplx0_dish1 = muladd(W_m1, E_ringbuf_m1_cplx0_dish1, E2_cplx0_dish1)
                    E2_cplx1_dish1 = muladd(W_m1, E_ringbuf_m1_cplx1_dish1, E2_cplx1_dish1)
                    (E_ringbuf_m2_cplx0_dish0, E_ringbuf_m2_cplx1_dish0, E_ringbuf_m2_cplx0_dish1, E_ringbuf_m2_cplx1_dish1) = convert(
                        NTuple{4,Float16x2}, F_ringbuf_m2
                    )
                    E2_cplx0_dish0 = muladd(W_m2, E_ringbuf_m2_cplx0_dish0, E2_cplx0_dish0)
                    E2_cplx1_dish0 = muladd(W_m2, E_ringbuf_m2_cplx1_dish0, E2_cplx1_dish0)
                    E2_cplx0_dish1 = muladd(W_m2, E_ringbuf_m2_cplx0_dish1, E2_cplx0_dish1)
                    E2_cplx1_dish1 = muladd(W_m2, E_ringbuf_m2_cplx1_dish1, E2_cplx1_dish1)
                    E2im_dish0 = E2_cplx0_dish0
                    E2re_dish0 = E2_cplx1_dish0
                    E2im_dish1 = E2_cplx0_dish1
                    E2re_dish1 = E2_cplx1_dish1
                    Xim = X_cplx0
                    Xre = X_cplx1
                    E3re_dish0 = muladd(-Xim * E2im, Xre, E2re)
                    E3re_dish1 = muladd(-Xim * E2im, Xre, E2re)
                    E3im_dish0 = muladd(Xim * E2re, Xre, E2im)
                    E3im_dish1 = muladd(Xim * E2re, Xre, E2im)
                    E3_cplx0_dish0 = E3im_dish0
                    E3_cplx1_dish0 = E3re_dish0
                    E3_cplx0_dish1 = E3im_dish1
                    E3_cplx1_dish1 = E3re_dish1
                end
            end
        end
    end
)
