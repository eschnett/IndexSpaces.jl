@fastmath @inbounds(
    begin #= /Users/eschnett/src/jl/IndexSpaces/kernels/upchan.jl:725 =#
        F_ringbuf_mtaps0 = zero(Int4x8)
        F_ringbuf_mtaps1 = zero(Int4x8)
        F_ringbuf_mtaps2 = zero(Int4x8)
        Gains = G_memory[(((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2) * 8 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 2) % 2) * 2) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 2) * 4) ÷ 2) % 8 + 0x01]
        Wpfb_mtaps0 = W_memory[((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2) % 8 + 0x01]
        Wpfb_mtaps1 = W_memory[(8 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2) % 8) + 0x01]
        Wpfb_mtaps2 = W_memory[(16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2) % 8) + 0x01]
        Wpfb_mtaps3 = W_memory[(24 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2) % 8) + 0x01]
        (X0, X1) = let
            thread = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32)
            thread0 = (thread ÷ (1i32)) % (2i32)
            thread1 = (thread ÷ (2i32)) % (2i32)
            thread2 = (thread ÷ (4i32)) % (2i32)
            time0 = (1i32) * thread2 + (2i32) * thread0 + (4i32) * thread1
            time1 = time0 + 8i32
            X0 = cispi(Float32(time0 * (U - 1i32)) / U)
            X1 = cispi(Float32(time1 * (U - 1i32)) / U)
            (X0, X1)
        end
        Xre = Float16x2(real(X0), real(X1))
        Xim = Float16x2(imag(X0), imag(X1))
        X_cplx0 = Xim
        X_cplx1 = Xre
        (Γ¹0, Γ¹1) = let
            thread = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32)
            thread0 = (thread ÷ (1i32)) % (2i32)
            thread1 = (thread ÷ (2i32)) % (2i32)
            thread2 = (thread ÷ (4i32)) % (2i32)
            thread3 = (thread ÷ (8i32)) % (2i32)
            thread4 = (thread ÷ (16i32)) % (2i32)
            timehi0 = (1i32) * thread0 + (2i32) * thread1
            timehi1 = timehi0 + 4i32
            freqbarlo = (1i32) * thread2 + (2i32) * thread3 + (4i32) * thread4
            (Γ¹0, Γ¹1) = (cispi((-2 * timehi0 * freqbarlo) / Float32(2^8)), cispi((-2 * timehi1 * freqbarlo) / Float32(2^8)))
            (Γ¹0, Γ¹1)
        end
        Γ¹rere = Float16x2(real(Γ¹0), real(Γ¹1))
        Γ¹reim = Float16x2(-(imag(Γ¹0)), -(imag(Γ¹1)))
        Γ¹imre = Float16x2(imag(Γ¹0), imag(Γ¹1))
        Γ¹imim = Float16x2(real(Γ¹0), real(Γ¹1))
        Γ¹re_cplx_in0 = Γ¹reim
        Γ¹re_cplx_in1 = Γ¹rere
        Γ¹im_cplx_in0 = Γ¹imim
        Γ¹im_cplx_in1 = Γ¹imre
        Γ¹_cplx0_cplx_in0 = Γ¹im_cplx_in0
        Γ¹_cplx1_cplx_in0 = Γ¹re_cplx_in0
        Γ¹_cplx0_cplx_in1 = Γ¹im_cplx_in1
        Γ¹_cplx1_cplx_in1 = Γ¹re_cplx_in1
        (Γ¹0, Γ¹1) = let
            thread = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32)
            thread0 = (thread ÷ (1i32)) % (2i32)
            thread1 = (thread ÷ (2i32)) % (2i32)
            thread2 = (thread ÷ (4i32)) % (2i32)
            thread3 = (thread ÷ (8i32)) % (2i32)
            thread4 = (thread ÷ (16i32)) % (2i32)
            timelo0 = 0i32
            timelo1 = 1i32
            freqbarlo = (1i32) * thread2 + (2i32) * thread3 + (4i32) * thread4
            (Γ²0, Γ²1) = (cispi((-2 * timelo0 * freqbarlo) / Float32(2^16)), cispi((-2 * timelo1 * freqbarlo) / Float32(2^16)))
            (Γ²0, Γ²1)
        end
        Γ²re = Float16x2(real(Γ²0), real(Γ²1))
        Γ²im = Float16x2(imag(Γ²0), imag(Γ²1))
        Γ²_cplx0 = Γ²im
        Γ²_cplx1 = Γ²re
        (Γ³0, Γ³1) = let
            thread = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32)
            thread0 = (thread ÷ (1i32)) % (2i32)
            thread1 = (thread ÷ (2i32)) % (2i32)
            thread2 = (thread ÷ (4i32)) % (2i32)
            thread3 = (thread ÷ (8i32)) % (2i32)
            thread4 = (thread ÷ (16i32)) % (2i32)
            timelo0 = 0i32
            timelo1 = 1i32
            freqbarlo = (1i32) * thread2
            dish_in = (1i32) * thread1 + (2i32) * thread0
            dish = (1i32) * thread4 + (2i32) * thread3
            delta = dish == dish_in
            (Γ³0, Γ³1) = (
                delta * cispi((-2 * timelo0 * freqbarlo) / Float32(2^1)),
                delta * cispi((-2 * timelo1 * freqbarlo) / Float32(2^1)),
            )
            (Γ³0, Γ³1)
        end
        Γ³rere = Float16x2(real(Γ³0), real(Γ³1))
        Γ³reim = Float16x2(-(imag(Γ³0)), -(imag(Γ³1)))
        Γ³imre = Float16x2(imag(Γ³0), imag(Γ³1))
        Γ³imim = Float16x2(real(Γ³0), real(Γ³1))
        Γ³re_cplx_in0 = Γ³reim
        Γ³re_cplx_in1 = Γ³rere
        Γ³im_cplx_in0 = Γ³imim
        Γ³im_cplx_in1 = Γ³imre
        Γ³_cplx0_cplx_in0 = Γ³im_cplx_in0
        Γ³_cplx1_cplx_in0 = Γ³re_cplx_in0
        Γ³_cplx0_cplx_in1 = Γ³im_cplx_in1
        Γ³_cplx1_cplx_in1 = Γ³re_cplx_in1
        for t_outer in 0:256:32767
            (E_dish0_time0, E_dish4_time0, E_dish8_time0, E_dish12_time0) = IndexSpaces.unsafe_load4_global(
                E_memory,
                (
                    (
                        (
                            (
                                (
                                    (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 +
                                    (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16
                                ) ÷ 4
                            ) % 128 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 8) % 16) % 16) * 128
                        ) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 4) % 2) % 2) * 2048
                    ) +
                    (
                        (
                            (
                                ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 +
                                ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8
                            ) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16
                        ) % 32768
                    ) * 4096
                ) + 1i32,
            )
            (E_dish0_time1, E_dish4_time1, E_dish8_time1, E_dish12_time1) = IndexSpaces.unsafe_load4_global(
                E_memory,
                (
                    (
                        (
                            (
                                (
                                    (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 +
                                    (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16
                                ) ÷ 4
                            ) % 128 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 8) % 16) % 16) * 128
                        ) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 4) % 2) % 2) * 2048
                    ) +
                    (
                        (
                            (
                                (1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) +
                                ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8
                            ) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16
                        ) % 32768
                    ) * 4096
                ) + 1i32,
            )
            (E_dish0_time2, E_dish4_time2, E_dish8_time2, E_dish12_time2) = IndexSpaces.unsafe_load4_global(
                E_memory,
                (
                    (
                        (
                            (
                                (
                                    (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 +
                                    (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16
                                ) ÷ 4
                            ) % 128 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 8) % 16) % 16) * 128
                        ) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 4) % 2) % 2) * 2048
                    ) +
                    (
                        (
                            (
                                (2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) +
                                ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8
                            ) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16
                        ) % 32768
                    ) * 4096
                ) + 1i32,
            )
            (E_dish0_time3, E_dish4_time3, E_dish8_time3, E_dish12_time3) = IndexSpaces.unsafe_load4_global(
                E_memory,
                (
                    (
                        (
                            (
                                (
                                    (IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 +
                                    (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16
                                ) ÷ 4
                            ) % 128 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 8) % 16) % 16) * 128
                        ) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) ÷ 4) % 2) % 2) * 2048
                    ) +
                    (
                        (
                            (
                                (3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) +
                                ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8
                            ) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16
                        ) % 32768
                    ) * 4096
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
            F_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish0_time0
            F_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 2) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 2) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish2_time0
            F_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 4) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 4) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish4_time0
            F_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 6) ÷ 4) % 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 6) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish6_time0
            F_shared[((((((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + ((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + ((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) ÷ 4) % 32) + ((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish0_time1
            F_shared[((((((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + ((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + ((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 2) ÷ 4) % 32) + ((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 2) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish2_time1
            F_shared[((((((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + ((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + ((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 4) ÷ 4) % 32) + ((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 4) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish4_time1
            F_shared[((((((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + ((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + ((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 6) ÷ 4) % 32) + ((((1 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 6) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish6_time1
            F_shared[((((((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + ((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + ((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) ÷ 4) % 32) + ((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish0_time2
            F_shared[((((((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + ((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + ((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 2) ÷ 4) % 32) + ((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 2) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish2_time2
            F_shared[((((((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + ((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + ((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 4) ÷ 4) % 32) + ((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 4) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish4_time2
            F_shared[((((((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + ((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + ((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 6) ÷ 4) % 32) + ((((2 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 6) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish6_time2
            F_shared[((((((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + ((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + ((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) ÷ 4) % 32) + ((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish0_time3
            F_shared[((((((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + ((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + ((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 2) ÷ 4) % 32) + ((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 2) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish2_time3
            F_shared[((((((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + ((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + ((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 4) ÷ 4) % 32) + ((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 4) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish4_time3
            F_shared[((((((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) % 2) * 260 + ((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 4) % 2) * 65) + ((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 2) % 2) * 130) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 6) ÷ 4) % 32) + ((((3 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 4) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 16) * 16) ÷ 16) % 16) * 545) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 8) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 8) * 16) + 6) ÷ 2) % 2) * 32) + 0 + 0x01] =
                F_dish6_time3
            IndexSpaces.cuda_sync_threads()
            for t_inner in 0:16:255
                let
                    dish = 0
                    F_in = F_shared[((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2) % 2) * 260 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2) ÷ 4) % 2) * 65) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2) ÷ 2) % 2) * 130) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 8) * 4) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 32) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) ÷ 8) % 2) * 2) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 64) ÷ 4) % 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 2 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) * 2) ÷ 16) % 16) * 545) + (((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_blockidx(), 0, 128) % 4) * 128 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) % 8) * 4) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 32) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 16) ÷ 8) % 2) * 2) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 8) % 2) * 64) ÷ 2) % 2) * 32) + 0x01]
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
                    XX_cplx0_dish0 = E3_cplx0_dish0
                    XX_cplx1_dish0 = E3_cplx1_dish0
                    XX_cplx0_dish1 = E3_cplx0_dish1
                    XX_cplx1_dish1 = E3_cplx1_dish1
                    WW_cplx0_dish0 = zero(Float16x2)
                    WW_cplx1_dish0 = zero(Float16x2)
                    WW_cplx0_dish1 = zero(Float16x2)
                    WW_cplx1_dish1 = zero(Float16x2)
                    (WW_cplx0_dish0, WW_cplx1_dish0) = IndexSpaces.mma_m16n8k16(
                        (Γ¹_cplx0_cplx_in0, Γ¹_cplx1_cplx_in0, Γ¹_cplx0_cplx_in1, Γ¹_cplx1_cplx_in1),
                        (XX_cplx_in0_dish0, XX_cplx_in1_dish0),
                        (WW_cplx0_dish0, WW_cplx1_dish0),
                    )
                    (WW_cplx0_dish1, WW_cplx1_dish1) = IndexSpaces.mma_m16n8k16(
                        (Γ¹_cplx0_cplx_in0, Γ¹_cplx1_cplx_in0, Γ¹_cplx0_cplx_in1, Γ¹_cplx1_cplx_in1),
                        (XX_cplx_in0_dish1, XX_cplx_in1_dish1),
                        (WW_cplx0_dish1, WW_cplx1_dish1),
                    )
                    ZZ_cplx0_dish0 = swapped_complex_mul(Γ², W)
                    ZZ_cplx1_dish0 = swapped_complex_mul(Γ², W)
                    ZZ_cplx0_dish1 = swapped_complex_mul(Γ², W)
                    ZZ_cplx1_dish1 = swapped_complex_mul(Γ², W)
                    YY_cplx0_dish0 = zero(Float16x2)
                    YY_cplx1_dish0 = zero(Float16x2)
                    YY_cplx0_dish1 = zero(Float16x2)
                    YY_cplx1_dish1 = zero(Float16x2)
                    (YY_cplx0_dish0, YY_cplx1_dish0) = IndexSpaces.mma_m16n8k16(
                        (Γ³_cplx0_cplx_in0_dish0, Γ³_cplx1_cplx_in0_dish0, Γ³_cplx0_cplx_in1_dish0, Γ³_cplx1_cplx_in1_dish0),
                        (ZZ_cplx_in0_dish0, ZZ_cplx_in1_dish0),
                        (YY_cplx0_dish0, YY_cplx1_dish0),
                    )
                    (YY_cplx0_dish1, YY_cplx1_dish1) = IndexSpaces.mma_m16n8k16(
                        (Γ³_cplx0_cplx_in0_dish1, Γ³_cplx1_cplx_in0_dish1, Γ³_cplx0_cplx_in1_dish1, Γ³_cplx1_cplx_in1_dish1),
                        (ZZ_cplx_in0_dish1, ZZ_cplx_in1_dish1),
                        (YY_cplx0_dish1, YY_cplx1_dish1),
                    )
                    E4_cplx0_dish0 = YY
                    E4_cplx1_dish0 = YY
                    E4_cplx0_dish1 = YY
                    E4_cplx1_dish1 = YY
                end
            end
        end
    end
)
