begin
    info = 1
    info_memory[((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) % 32 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24) * 32) + 0 + 0x01] =
        info
    (Γ¹_re_re, Γ¹_re_im, Γ¹_im_re, Γ¹_im_im) = let
        c = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % (4i32)
        v = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ (4i32)
        Γ¹ = cispi((c * v) / 4.0f0)
        (+(Γ¹.re), -(Γ¹.im), +(Γ¹.im), +(Γ¹.re))
    end
    Γ¹_re = Float16x2(Γ¹_re_im, Γ¹_re_re)
    Γ¹_im = Float16x2(Γ¹_im_im, Γ¹_im_re)
    Γ¹_cplx0 = Γ¹_im
    Γ¹_cplx1 = Γ¹_re
    Γ² = (
        (Γ²_d0_re, Γ²_d0_im, Γ²_d1_re, Γ²_d1_im) = let
            d0 = (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % (4i32)) * (2i32) + 0i32
            d1 = (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % (4i32)) * (2i32) + 1i32
            v = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ (4i32)
            Γ²_d0 = if d0 < 6
                cispi((d0 * v) / 24.0f0)
            else
                Complex(0.0f0)
            end
            Γ²_d1 = if d1 < 6
                cispi((d1 * v) / 24.0f0)
            else
                Complex(0.0f0)
            end
            (Γ²_d0.re, Γ²_d0.im, Γ²_d1.re, Γ²_d1.im)
        end
    )
    Γ²_re = Float16x2(Γ²_d0_re, Γ²_d1_re)
    Γ²_im = Float16x2(Γ²_d0_im, Γ²_d1_im)
    Γ²_cplx0 = Γ²_im
    Γ²_cplx1 = Γ²_re
    (Γ³_d0_re_re, Γ³_d0_re_im, Γ³_d0_im_re, Γ³_d0_im_im, Γ³_d1_re_re, Γ³_d1_re_im, Γ³_d1_im_re, Γ³_d1_im_im) = let
        d0 = (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % (4i32)) * (2i32) + 0i32
        d1 = (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % (4i32)) * (2i32) + 1i32
        u = IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ (4i32)
        Γ³_d0 = if d0 < 6 && u < 6
            cispi(((8i32) * d0 * u) / 24.0f0)
        else
            Complex(0.0f0)
        end
        Γ³_d1 = if d1 < 6 && u < 6
            cispi(((8i32) * d1 * u) / 24.0f0)
        else
            Complex(0.0f0)
        end
        (+(Γ³_d0.re), -(Γ³_d0.im), +(Γ³_d0.im), +(Γ³_d0.re), +(Γ³_d1.re), -(Γ³_d1.im), +(Γ³_d1.im), +(Γ³_d1.re))
    end
    Γ³_re_re = Float16x2(Γ³_d0_re_re, Γ³_d1_re_re)
    Γ³_re_im = Float16x2(Γ³_d0_re_im, Γ³_d1_re_im)
    Γ³_im_re = Float16x2(Γ³_d0_im_re, Γ³_d1_im_re)
    Γ³_im_im = Float16x2(Γ³_d0_im_im, Γ³_d1_im_im)
    Γ³_re_cplx_in0 = Γ³_re_im
    Γ³_re_cplx_in1 = Γ³_re_re
    Γ³_im_cplx_in0 = Γ³_im_im
    Γ³_im_cplx_in1 = Γ³_im_re
    Γ³_cplx0_cplx_in0 = Γ³_im_cplx_in0
    Γ³_cplx1_cplx_in0 = Γ³_re_cplx_in0
    Γ³_cplx0_cplx_in1 = Γ³_im_cplx_in1
    Γ³_cplx1_cplx_in1 = Γ³_re_cplx_in1
    S = 999999999
    if IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) < 24
        S = S_memory[((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) * 24 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 576 + 0x01]
    end
    W_polr0 = zero(Float16x2)
    W_polr1 = zero(Float16x2)
    if 0 ≤ IndexSpaces.cuda_threadidx() ÷ 8 < 3
        W_polr0 = W_memory[((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 24) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 144) + 0x01]
        W_polr1 = W_memory[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 24) + 576) + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 144) + 0x01]
    end
    I_beamQ0_polr0 = zero(Float16x2)
    I_beamQ1_polr0 = zero(Float16x2)
    I_beamQ0_polr1 = zero(Float16x2)
    I_beamQ1_polr1 = zero(Float16x2)
    dstime = 0
    t_running = 0
    for t_outer in 0:48:47
        let
            (E_dish0_time0, E_dish4_time0, E_dish8_time0, E_dish12_time0) = IndexSpaces.unsafe_load4_global(
                E_memory,
                (
                    (
                        ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 48) * 256 +
                        (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16) ÷ 4) % 128
                    ) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) % 2) * 128
                ) + 1i32,
            )
            (E_dish256_time0, E_dish260_time0, E_dish264_time0, E_dish268_time0) = IndexSpaces.unsafe_load4_global(
                E_memory,
                (
                    (
                        ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 48) * 256 +
                        (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + 256) ÷ 4) % 128
                    ) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) % 2) * 128
                ) + 1i32,
            )
            (E_dish0_time24, E_dish4_time24, E_dish8_time24, E_dish12_time24) = IndexSpaces.unsafe_load4_global(
                E_memory,
                (
                    (
                        ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24 + 24) % 48) * 256 +
                        (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16) ÷ 4) % 128
                    ) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) % 2) * 128
                ) + 1i32,
            )
            (E_dish256_time24, E_dish260_time24, E_dish264_time24, E_dish268_time24) = IndexSpaces.unsafe_load4_global(
                E_memory,
                (
                    (
                        ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24 + 24) % 48) * 256 +
                        (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + 256) ÷ 4) % 128
                    ) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) % 2) * 128
                ) + 1i32,
            )
            is_lo_thread = IndexSpaces.cuda_threadidx() & 0x00000010 == 0x00
            (E_dish0_time0, E_dish8_time0) = let
                src = if is_lo_thread
                    E_dish8_time0
                else
                    E_dish0_time0
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000010)
                if is_lo_thread
                    (E_dish0_time0, dst)
                else
                    (dst, E_dish8_time0)
                end
            end
            (E_dish4_time0, E_dish12_time0) = let
                src = if is_lo_thread
                    E_dish12_time0
                else
                    E_dish4_time0
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000010)
                if is_lo_thread
                    (E_dish4_time0, dst)
                else
                    (dst, E_dish12_time0)
                end
            end
            (E_dish256_time0, E_dish264_time0) = let
                src = if is_lo_thread
                    E_dish264_time0
                else
                    E_dish256_time0
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000010)
                if is_lo_thread
                    (E_dish256_time0, dst)
                else
                    (dst, E_dish264_time0)
                end
            end
            (E_dish260_time0, E_dish268_time0) = let
                src = if is_lo_thread
                    E_dish268_time0
                else
                    E_dish260_time0
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000010)
                if is_lo_thread
                    (E_dish260_time0, dst)
                else
                    (dst, E_dish268_time0)
                end
            end
            (E_dish0_time24, E_dish8_time24) = let
                src = if is_lo_thread
                    E_dish8_time24
                else
                    E_dish0_time24
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000010)
                if is_lo_thread
                    (E_dish0_time24, dst)
                else
                    (dst, E_dish8_time24)
                end
            end
            (E_dish4_time24, E_dish12_time24) = let
                src = if is_lo_thread
                    E_dish12_time24
                else
                    E_dish4_time24
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000010)
                if is_lo_thread
                    (E_dish4_time24, dst)
                else
                    (dst, E_dish12_time24)
                end
            end
            (E_dish256_time24, E_dish264_time24) = let
                src = if is_lo_thread
                    E_dish264_time24
                else
                    E_dish256_time24
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000010)
                if is_lo_thread
                    (E_dish256_time24, dst)
                else
                    (dst, E_dish264_time24)
                end
            end
            (E_dish260_time24, E_dish268_time24) = let
                src = if is_lo_thread
                    E_dish268_time24
                else
                    E_dish260_time24
                end
                dst = IndexSpaces.cuda_shfl_xor_sync(0xffffffff, src, 0x00000010)
                if is_lo_thread
                    (E_dish260_time24, dst)
                else
                    (dst, E_dish268_time24)
                end
            end
            (E_dish0_time0, E_dish8_time0) = (
                IndexSpaces.get_lo4(E_dish0_time0, E_dish8_time0), IndexSpaces.get_hi4(E_dish0_time0, E_dish8_time0)
            )
            (E_dish4_time0, E_dish12_time0) = (
                IndexSpaces.get_lo4(E_dish4_time0, E_dish12_time0), IndexSpaces.get_hi4(E_dish4_time0, E_dish12_time0)
            )
            (E_dish256_time0, E_dish264_time0) = (
                IndexSpaces.get_lo4(E_dish256_time0, E_dish264_time0), IndexSpaces.get_hi4(E_dish256_time0, E_dish264_time0)
            )
            (E_dish260_time0, E_dish268_time0) = (
                IndexSpaces.get_lo4(E_dish260_time0, E_dish268_time0), IndexSpaces.get_hi4(E_dish260_time0, E_dish268_time0)
            )
            (E_dish0_time24, E_dish8_time24) = (
                IndexSpaces.get_lo4(E_dish0_time24, E_dish8_time24), IndexSpaces.get_hi4(E_dish0_time24, E_dish8_time24)
            )
            (E_dish4_time24, E_dish12_time24) = (
                IndexSpaces.get_lo4(E_dish4_time24, E_dish12_time24), IndexSpaces.get_hi4(E_dish4_time24, E_dish12_time24)
            )
            (E_dish256_time24, E_dish264_time24) = (
                IndexSpaces.get_lo4(E_dish256_time24, E_dish264_time24), IndexSpaces.get_hi4(E_dish256_time24, E_dish264_time24)
            )
            (E_dish260_time24, E_dish268_time24) = (
                IndexSpaces.get_lo4(E_dish260_time24, E_dish268_time24), IndexSpaces.get_hi4(E_dish260_time24, E_dish268_time24)
            )
            (E_dish0_time0, E_dish0_time24) = (
                IndexSpaces.get_lo8(E_dish0_time0, E_dish0_time24), IndexSpaces.get_hi8(E_dish0_time0, E_dish0_time24)
            )
            (E_dish4_time0, E_dish4_time24) = (
                IndexSpaces.get_lo8(E_dish4_time0, E_dish4_time24), IndexSpaces.get_hi8(E_dish4_time0, E_dish4_time24)
            )
            (E_dish8_time0, E_dish8_time24) = (
                IndexSpaces.get_lo8(E_dish8_time0, E_dish8_time24), IndexSpaces.get_hi8(E_dish8_time0, E_dish8_time24)
            )
            (E_dish12_time0, E_dish12_time24) = (
                IndexSpaces.get_lo8(E_dish12_time0, E_dish12_time24), IndexSpaces.get_hi8(E_dish12_time0, E_dish12_time24)
            )
            (E_dish256_time0, E_dish256_time24) = (
                IndexSpaces.get_lo8(E_dish256_time0, E_dish256_time24), IndexSpaces.get_hi8(E_dish256_time0, E_dish256_time24)
            )
            (E_dish260_time0, E_dish260_time24) = (
                IndexSpaces.get_lo8(E_dish260_time0, E_dish260_time24), IndexSpaces.get_hi8(E_dish260_time0, E_dish260_time24)
            )
            (E_dish264_time0, E_dish264_time24) = (
                IndexSpaces.get_lo8(E_dish264_time0, E_dish264_time24), IndexSpaces.get_hi8(E_dish264_time0, E_dish264_time24)
            )
            (E_dish268_time0, E_dish268_time24) = (
                IndexSpaces.get_lo8(E_dish268_time0, E_dish268_time24), IndexSpaces.get_hi8(E_dish268_time0, E_dish268_time24)
            )
            (E_dish0_time0, E_dish8_time0) = (
                IndexSpaces.get_lo16(E_dish0_time0, E_dish8_time0), IndexSpaces.get_hi16(E_dish0_time0, E_dish8_time0)
            )
            (E_dish4_time0, E_dish12_time0) = (
                IndexSpaces.get_lo16(E_dish4_time0, E_dish12_time0), IndexSpaces.get_hi16(E_dish4_time0, E_dish12_time0)
            )
            (E_dish256_time0, E_dish264_time0) = (
                IndexSpaces.get_lo16(E_dish256_time0, E_dish264_time0), IndexSpaces.get_hi16(E_dish256_time0, E_dish264_time0)
            )
            (E_dish260_time0, E_dish268_time0) = (
                IndexSpaces.get_lo16(E_dish260_time0, E_dish268_time0), IndexSpaces.get_hi16(E_dish260_time0, E_dish268_time0)
            )
            (E_dish0_time24, E_dish8_time24) = (
                IndexSpaces.get_lo16(E_dish0_time24, E_dish8_time24), IndexSpaces.get_hi16(E_dish0_time24, E_dish8_time24)
            )
            (E_dish4_time24, E_dish12_time24) = (
                IndexSpaces.get_lo16(E_dish4_time24, E_dish12_time24), IndexSpaces.get_hi16(E_dish4_time24, E_dish12_time24)
            )
            (E_dish256_time24, E_dish264_time24) = (
                IndexSpaces.get_lo16(E_dish256_time24, E_dish264_time24), IndexSpaces.get_hi16(E_dish256_time24, E_dish264_time24)
            )
            (E_dish260_time24, E_dish268_time24) = (
                IndexSpaces.get_lo16(E_dish260_time24, E_dish268_time24), IndexSpaces.get_hi16(E_dish260_time24, E_dish268_time24)
            )
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) % 8) * 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish0_time0
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) % 8) * 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish4_time0
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 2) % 8) * 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 2) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish8_time0
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 2) % 8) * 32) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 2) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish12_time0
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 256) % 8) * 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 256) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish256_time0
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 256) % 8) * 32) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 256) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish260_time0
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 2) + 256) % 8) * 32) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 2) + 256) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish264_time0
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 2) + 256) % 8) * 32) + (((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 2) + 256) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish268_time0
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 1) % 8) * 32) + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 1) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish0_time24
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 1) % 8) * 32) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 1) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish4_time24
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 2) + 1) % 8) * 32) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 2) + 1) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish8_time24
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 2) + 1) % 8) * 32) + (((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 2) + 1) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish12_time24
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + (((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 1) + 256) % 8) * 32) + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 1) + 256) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish256_time24
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 1) + 256) % 8) * 32) + (((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 1) + 256) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish260_time24
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + ((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 2) + 1) + 256) % 8) * 32) + (((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 2) + 1) + 256) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish264_time24
            Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24 + (((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 2) + 1) + 256) % 8) * 32) + ((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 16) * 16 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 16) % 2) * 8) + 4) + 2) + 1) + 256) ÷ 8) % 64) * 257) + 0 + 0x01] =
                E_dish268_time24
            IndexSpaces.cuda_sync_threads()
        end
        let
            Freg1_dish0 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish24 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((24 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((24 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish48 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((48 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((48 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish72 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((72 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((72 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish96 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((96 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((96 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish120 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((120 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((120 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish144 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((144 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((144 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish168 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((168 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((168 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish192 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((192 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((192 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish216 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((216 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((216 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish240 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((240 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((240 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish264 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((264 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((264 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish288 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((288 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((288 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish312 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((312 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((312 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish336 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((336 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((336 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish360 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((360 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((360 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish384 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((384 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((384 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish408 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((408 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((408 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish432 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((432 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((432 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish456 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((456 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((456 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish480 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((480 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((480 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            Freg1_dish504 = Fsh1_shared[(((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + ((504 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 8) * 32) + (((504 + IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) ÷ 8) % 64) * 257) + 0x01]
            IndexSpaces.cuda_sync_threads()
            sd_sd0 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 0)
            sd_sd1 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 1)
            sd_sd2 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 2)
            sd_sd3 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 3)
            sd_sd4 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 4)
            sd_sd5 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 5)
            sd_sd6 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 6)
            sd_sd7 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 7)
            sd_sd8 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 8)
            sd_sd9 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 9)
            sd_sd10 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 10)
            sd_sd11 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 11)
            sd_sd12 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 12)
            sd_sd13 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 13)
            sd_sd14 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 14)
            sd_sd15 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 15)
            sd_sd16 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 16)
            sd_sd17 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 17)
            sd_sd18 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 18)
            sd_sd19 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 19)
            sd_sd20 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 20)
            sd_sd21 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 21)
            sd_sd22 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 22)
            sd_sd23 = IndexSpaces.cuda_shfl_sync(0xffffffff, S, 23)
            Freg1′ = Freg1_dish0
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd0 + 0x01] = Freg1′
            Freg1′ = Freg1_dish24
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd1 + 0x01] = Freg1′
            Freg1′ = Freg1_dish48
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd2 + 0x01] = Freg1′
            Freg1′ = Freg1_dish72
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd3 + 0x01] = Freg1′
            Freg1′ = Freg1_dish96
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd4 + 0x01] = Freg1′
            Freg1′ = Freg1_dish120
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd5 + 0x01] = Freg1′
            Freg1′ = Freg1_dish144
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd6 + 0x01] = Freg1′
            Freg1′ = Freg1_dish168
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd7 + 0x01] = Freg1′
            Freg1′ = Freg1_dish192
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd8 + 0x01] = Freg1′
            Freg1′ = Freg1_dish216
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd9 + 0x01] = Freg1′
            Freg1′ = Freg1_dish240
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd10 + 0x01] = Freg1′
            Freg1′ = Freg1_dish264
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd11 + 0x01] = Freg1′
            Freg1′ = Freg1_dish288
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd12 + 0x01] = Freg1′
            Freg1′ = Freg1_dish312
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd13 + 0x01] = Freg1′
            Freg1′ = Freg1_dish336
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd14 + 0x01] = Freg1′
            Freg1′ = Freg1_dish360
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd15 + 0x01] = Freg1′
            Freg1′ = Freg1_dish384
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd16 + 0x01] = Freg1′
            Freg1′ = Freg1_dish408
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd17 + 0x01] = Freg1′
            Freg1′ = Freg1_dish432
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd18 + 0x01] = Freg1′
            Freg1′ = Freg1_dish456
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd19 + 0x01] = Freg1′
            Freg1′ = Freg1_dish480
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd20 + 0x01] = Freg1′
            Freg1′ = if warp = IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24), dish = warp + 24 * 21, dish < 512
                Freg1_dish504
            else
                (0, 0, 0, 0, 0, 0, 0, 0)
            end
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd21 + 0x01] = Freg1′
            Freg1′ = (0, 0, 0, 0, 0, 0, 0, 0)
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd22 + 0x01] = Freg1′
            Freg1′ = (0, 0, 0, 0, 0, 0, 0, 0)
            Fsh2_shared[(IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 24) % 24 + sd_sd23 + 0x01] = Freg1′
            IndexSpaces.cuda_sync_threads()
        end
        let
            Freg2_time0 = zero(Int4x8)
            Freg2_time1 = zero(Int4x8)
            Freg2_time2 = zero(Int4x8)
            Freg2_time3 = zero(Int4x8)
            Freg2_time4 = zero(Int4x8)
            Freg2_time5 = zero(Int4x8)
            Freg2_time6 = zero(Int4x8)
            Freg2_time7 = zero(Int4x8)
            Freg2_time8 = zero(Int4x8)
            Freg2_time9 = zero(Int4x8)
            Freg2_time10 = zero(Int4x8)
            Freg2_time11 = zero(Int4x8)
            Freg2_time12 = zero(Int4x8)
            Freg2_time13 = zero(Int4x8)
            Freg2_time14 = zero(Int4x8)
            Freg2_time15 = zero(Int4x8)
            Freg2_time16 = zero(Int4x8)
            Freg2_time17 = zero(Int4x8)
            Freg2_time18 = zero(Int4x8)
            Freg2_time19 = zero(Int4x8)
            Freg2_time20 = zero(Int4x8)
            Freg2_time21 = zero(Int4x8)
            Freg2_time22 = zero(Int4x8)
            Freg2_time23 = zero(Int4x8)
            if 0 ≤ IndexSpaces.cuda_threadidx() ÷ 8 < 3
                Freg2_time0 = Fsh2_shared[((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time1 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 1) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time2 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 2) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time3 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 3) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time4 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 4) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time5 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 5) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time6 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 6) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time7 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 7) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time8 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 8) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time9 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 9) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time10 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 10) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time11 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 11) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time12 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 12) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time13 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 13) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time14 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 14) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time15 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 15) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time16 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 16) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time17 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 17) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time18 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 18) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time19 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 19) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time20 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 20) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time21 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 21) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time22 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 22) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
                Freg2_time23 = Fsh2_shared[(((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 198 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) * 33) + 23) + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) % 4) * 4806) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) * 801) + 0x01]
            end
            IndexSpaces.cuda_sync_threads()
            for t_inner in 0:4:47
                (Freg2_polr0_time0, Freg2_polr1_time0, Freg2_polr0_time24, Freg2_polr1_time24) = convert(
                    NTuple{4,Float16x2}, Freg2_time0
                )
                (Freg2_polr0_time1, Freg2_polr1_time1, Freg2_polr0_time25, Freg2_polr1_time25) = convert(
                    NTuple{4,Float16x2}, Freg2_time1
                )
                (Freg2_polr0_time2, Freg2_polr1_time2, Freg2_polr0_time26, Freg2_polr1_time26) = convert(
                    NTuple{4,Float16x2}, Freg2_time2
                )
                (Freg2_polr0_time3, Freg2_polr1_time3, Freg2_polr0_time27, Freg2_polr1_time27) = convert(
                    NTuple{4,Float16x2}, Freg2_time3
                )
                (Freg2_polr0_time4, Freg2_polr1_time4, Freg2_polr0_time28, Freg2_polr1_time28) = convert(
                    NTuple{4,Float16x2}, Freg2_time4
                )
                (Freg2_polr0_time5, Freg2_polr1_time5, Freg2_polr0_time29, Freg2_polr1_time29) = convert(
                    NTuple{4,Float16x2}, Freg2_time5
                )
                (Freg2_polr0_time6, Freg2_polr1_time6, Freg2_polr0_time30, Freg2_polr1_time30) = convert(
                    NTuple{4,Float16x2}, Freg2_time6
                )
                (Freg2_polr0_time7, Freg2_polr1_time7, Freg2_polr0_time31, Freg2_polr1_time31) = convert(
                    NTuple{4,Float16x2}, Freg2_time7
                )
                (Freg2_polr0_time8, Freg2_polr1_time8, Freg2_polr0_time32, Freg2_polr1_time32) = convert(
                    NTuple{4,Float16x2}, Freg2_time8
                )
                (Freg2_polr0_time9, Freg2_polr1_time9, Freg2_polr0_time33, Freg2_polr1_time33) = convert(
                    NTuple{4,Float16x2}, Freg2_time9
                )
                (Freg2_polr0_time10, Freg2_polr1_time10, Freg2_polr0_time34, Freg2_polr1_time34) = convert(
                    NTuple{4,Float16x2}, Freg2_time10
                )
                (Freg2_polr0_time11, Freg2_polr1_time11, Freg2_polr0_time35, Freg2_polr1_time35) = convert(
                    NTuple{4,Float16x2}, Freg2_time11
                )
                (Freg2_polr0_time12, Freg2_polr1_time12, Freg2_polr0_time36, Freg2_polr1_time36) = convert(
                    NTuple{4,Float16x2}, Freg2_time12
                )
                (Freg2_polr0_time13, Freg2_polr1_time13, Freg2_polr0_time37, Freg2_polr1_time37) = convert(
                    NTuple{4,Float16x2}, Freg2_time13
                )
                (Freg2_polr0_time14, Freg2_polr1_time14, Freg2_polr0_time38, Freg2_polr1_time38) = convert(
                    NTuple{4,Float16x2}, Freg2_time14
                )
                (Freg2_polr0_time15, Freg2_polr1_time15, Freg2_polr0_time39, Freg2_polr1_time39) = convert(
                    NTuple{4,Float16x2}, Freg2_time15
                )
                (Freg2_polr0_time16, Freg2_polr1_time16, Freg2_polr0_time40, Freg2_polr1_time40) = convert(
                    NTuple{4,Float16x2}, Freg2_time16
                )
                (Freg2_polr0_time17, Freg2_polr1_time17, Freg2_polr0_time41, Freg2_polr1_time41) = convert(
                    NTuple{4,Float16x2}, Freg2_time17
                )
                (Freg2_polr0_time18, Freg2_polr1_time18, Freg2_polr0_time42, Freg2_polr1_time42) = convert(
                    NTuple{4,Float16x2}, Freg2_time18
                )
                (Freg2_polr0_time19, Freg2_polr1_time19, Freg2_polr0_time43, Freg2_polr1_time43) = convert(
                    NTuple{4,Float16x2}, Freg2_time19
                )
                (Freg2_polr0_time20, Freg2_polr1_time20, Freg2_polr0_time44, Freg2_polr1_time44) = convert(
                    NTuple{4,Float16x2}, Freg2_time20
                )
                (Freg2_polr0_time21, Freg2_polr1_time21, Freg2_polr0_time45, Freg2_polr1_time45) = convert(
                    NTuple{4,Float16x2}, Freg2_time21
                )
                (Freg2_polr0_time22, Freg2_polr1_time22, Freg2_polr0_time46, Freg2_polr1_time46) = convert(
                    NTuple{4,Float16x2}, Freg2_time22
                )
                (Freg2_polr0_time23, Freg2_polr1_time23, Freg2_polr0_time47, Freg2_polr1_time47) = convert(
                    NTuple{4,Float16x2}, Freg2_time23
                )
                E_polr0_time0 = zero(Float16x2)
                if t_inner == 0
                    E_polr0_time0 = Freg2_polr0_time0
                end
                if t_inner == 4
                    E_polr0_time0 = Freg2_polr0_time4
                end
                if t_inner == 8
                    E_polr0_time0 = Freg2_polr0_time8
                end
                if t_inner == 12
                    E_polr0_time0 = Freg2_polr0_time12
                end
                if t_inner == 16
                    E_polr0_time0 = Freg2_polr0_time16
                end
                if t_inner == 20
                    E_polr0_time0 = Freg2_polr0_time20
                end
                if t_inner == 24
                    E_polr0_time0 = Freg2_polr0_time24
                end
                if t_inner == 28
                    E_polr0_time0 = Freg2_polr0_time28
                end
                if t_inner == 32
                    E_polr0_time0 = Freg2_polr0_time32
                end
                if t_inner == 36
                    E_polr0_time0 = Freg2_polr0_time36
                end
                if t_inner == 40
                    E_polr0_time0 = Freg2_polr0_time40
                end
                if t_inner == 44
                    E_polr0_time0 = Freg2_polr0_time44
                end
                E_polr1_time0 = zero(Float16x2)
                if t_inner == 0
                    E_polr1_time0 = Freg2_polr1_time0
                end
                if t_inner == 4
                    E_polr1_time0 = Freg2_polr1_time4
                end
                if t_inner == 8
                    E_polr1_time0 = Freg2_polr1_time8
                end
                if t_inner == 12
                    E_polr1_time0 = Freg2_polr1_time12
                end
                if t_inner == 16
                    E_polr1_time0 = Freg2_polr1_time16
                end
                if t_inner == 20
                    E_polr1_time0 = Freg2_polr1_time20
                end
                if t_inner == 24
                    E_polr1_time0 = Freg2_polr1_time24
                end
                if t_inner == 28
                    E_polr1_time0 = Freg2_polr1_time28
                end
                if t_inner == 32
                    E_polr1_time0 = Freg2_polr1_time32
                end
                if t_inner == 36
                    E_polr1_time0 = Freg2_polr1_time36
                end
                if t_inner == 40
                    E_polr1_time0 = Freg2_polr1_time40
                end
                if t_inner == 44
                    E_polr1_time0 = Freg2_polr1_time44
                end
                E_polr0_time1 = zero(Float16x2)
                if t_inner == 0
                    E_polr0_time1 = Freg2_polr0_time1
                end
                if t_inner == 4
                    E_polr0_time1 = Freg2_polr0_time5
                end
                if t_inner == 8
                    E_polr0_time1 = Freg2_polr0_time9
                end
                if t_inner == 12
                    E_polr0_time1 = Freg2_polr0_time13
                end
                if t_inner == 16
                    E_polr0_time1 = Freg2_polr0_time17
                end
                if t_inner == 20
                    E_polr0_time1 = Freg2_polr0_time21
                end
                if t_inner == 24
                    E_polr0_time1 = Freg2_polr0_time25
                end
                if t_inner == 28
                    E_polr0_time1 = Freg2_polr0_time29
                end
                if t_inner == 32
                    E_polr0_time1 = Freg2_polr0_time33
                end
                if t_inner == 36
                    E_polr0_time1 = Freg2_polr0_time37
                end
                if t_inner == 40
                    E_polr0_time1 = Freg2_polr0_time41
                end
                if t_inner == 44
                    E_polr0_time1 = Freg2_polr0_time45
                end
                E_polr1_time1 = zero(Float16x2)
                if t_inner == 0
                    E_polr1_time1 = Freg2_polr1_time1
                end
                if t_inner == 4
                    E_polr1_time1 = Freg2_polr1_time5
                end
                if t_inner == 8
                    E_polr1_time1 = Freg2_polr1_time9
                end
                if t_inner == 12
                    E_polr1_time1 = Freg2_polr1_time13
                end
                if t_inner == 16
                    E_polr1_time1 = Freg2_polr1_time17
                end
                if t_inner == 20
                    E_polr1_time1 = Freg2_polr1_time21
                end
                if t_inner == 24
                    E_polr1_time1 = Freg2_polr1_time25
                end
                if t_inner == 28
                    E_polr1_time1 = Freg2_polr1_time29
                end
                if t_inner == 32
                    E_polr1_time1 = Freg2_polr1_time33
                end
                if t_inner == 36
                    E_polr1_time1 = Freg2_polr1_time37
                end
                if t_inner == 40
                    E_polr1_time1 = Freg2_polr1_time41
                end
                if t_inner == 44
                    E_polr1_time1 = Freg2_polr1_time45
                end
                E_polr0_time2 = zero(Float16x2)
                if t_inner == 0
                    E_polr0_time2 = Freg2_polr0_time2
                end
                if t_inner == 4
                    E_polr0_time2 = Freg2_polr0_time6
                end
                if t_inner == 8
                    E_polr0_time2 = Freg2_polr0_time10
                end
                if t_inner == 12
                    E_polr0_time2 = Freg2_polr0_time14
                end
                if t_inner == 16
                    E_polr0_time2 = Freg2_polr0_time18
                end
                if t_inner == 20
                    E_polr0_time2 = Freg2_polr0_time22
                end
                if t_inner == 24
                    E_polr0_time2 = Freg2_polr0_time26
                end
                if t_inner == 28
                    E_polr0_time2 = Freg2_polr0_time30
                end
                if t_inner == 32
                    E_polr0_time2 = Freg2_polr0_time34
                end
                if t_inner == 36
                    E_polr0_time2 = Freg2_polr0_time38
                end
                if t_inner == 40
                    E_polr0_time2 = Freg2_polr0_time42
                end
                if t_inner == 44
                    E_polr0_time2 = Freg2_polr0_time46
                end
                E_polr1_time2 = zero(Float16x2)
                if t_inner == 0
                    E_polr1_time2 = Freg2_polr1_time2
                end
                if t_inner == 4
                    E_polr1_time2 = Freg2_polr1_time6
                end
                if t_inner == 8
                    E_polr1_time2 = Freg2_polr1_time10
                end
                if t_inner == 12
                    E_polr1_time2 = Freg2_polr1_time14
                end
                if t_inner == 16
                    E_polr1_time2 = Freg2_polr1_time18
                end
                if t_inner == 20
                    E_polr1_time2 = Freg2_polr1_time22
                end
                if t_inner == 24
                    E_polr1_time2 = Freg2_polr1_time26
                end
                if t_inner == 28
                    E_polr1_time2 = Freg2_polr1_time30
                end
                if t_inner == 32
                    E_polr1_time2 = Freg2_polr1_time34
                end
                if t_inner == 36
                    E_polr1_time2 = Freg2_polr1_time38
                end
                if t_inner == 40
                    E_polr1_time2 = Freg2_polr1_time42
                end
                if t_inner == 44
                    E_polr1_time2 = Freg2_polr1_time46
                end
                E_polr0_time3 = zero(Float16x2)
                if t_inner == 0
                    E_polr0_time3 = Freg2_polr0_time3
                end
                if t_inner == 4
                    E_polr0_time3 = Freg2_polr0_time7
                end
                if t_inner == 8
                    E_polr0_time3 = Freg2_polr0_time11
                end
                if t_inner == 12
                    E_polr0_time3 = Freg2_polr0_time15
                end
                if t_inner == 16
                    E_polr0_time3 = Freg2_polr0_time19
                end
                if t_inner == 20
                    E_polr0_time3 = Freg2_polr0_time23
                end
                if t_inner == 24
                    E_polr0_time3 = Freg2_polr0_time27
                end
                if t_inner == 28
                    E_polr0_time3 = Freg2_polr0_time31
                end
                if t_inner == 32
                    E_polr0_time3 = Freg2_polr0_time35
                end
                if t_inner == 36
                    E_polr0_time3 = Freg2_polr0_time39
                end
                if t_inner == 40
                    E_polr0_time3 = Freg2_polr0_time43
                end
                if t_inner == 44
                    E_polr0_time3 = Freg2_polr0_time47
                end
                E_polr1_time3 = zero(Float16x2)
                if t_inner == 0
                    E_polr1_time3 = Freg2_polr1_time3
                end
                if t_inner == 4
                    E_polr1_time3 = Freg2_polr1_time7
                end
                if t_inner == 8
                    E_polr1_time3 = Freg2_polr1_time11
                end
                if t_inner == 12
                    E_polr1_time3 = Freg2_polr1_time15
                end
                if t_inner == 16
                    E_polr1_time3 = Freg2_polr1_time19
                end
                if t_inner == 20
                    E_polr1_time3 = Freg2_polr1_time23
                end
                if t_inner == 24
                    E_polr1_time3 = Freg2_polr1_time27
                end
                if t_inner == 28
                    E_polr1_time3 = Freg2_polr1_time31
                end
                if t_inner == 32
                    E_polr1_time3 = Freg2_polr1_time35
                end
                if t_inner == 36
                    E_polr1_time3 = Freg2_polr1_time39
                end
                if t_inner == 40
                    E_polr1_time3 = Freg2_polr1_time43
                end
                if t_inner == 44
                    E_polr1_time3 = Freg2_polr1_time47
                end
                WE_polr0_time0 = swapped_complex_mul(W_polr0, E_polr0_time0)
                WE_polr1_time0 = swapped_complex_mul(W_polr1, E_polr1_time0)
                WE_polr0_time1 = swapped_complex_mul(W_polr0, E_polr0_time1)
                WE_polr1_time1 = swapped_complex_mul(W_polr1, E_polr1_time1)
                WE_polr0_time2 = swapped_complex_mul(W_polr0, E_polr0_time2)
                WE_polr1_time2 = swapped_complex_mul(W_polr1, E_polr1_time2)
                WE_polr0_time3 = swapped_complex_mul(W_polr0, E_polr0_time3)
                WE_polr1_time3 = swapped_complex_mul(W_polr1, E_polr1_time3)
                X_polr0_time0 = WE_polr0_time0
                X_polr1_time0 = WE_polr1_time0
                X_polr0_time1 = WE_polr0_time1
                X_polr1_time1 = WE_polr1_time1
                X_polr0_time2 = WE_polr0_time2
                X_polr1_time2 = WE_polr1_time2
                X_polr0_time3 = WE_polr0_time3
                X_polr1_time3 = WE_polr1_time3
                Z_cplx0_polr0_time0 = zero(Float16x2)
                Z_cplx1_polr0_time0 = zero(Float16x2)
                Z_cplx0_polr1_time0 = zero(Float16x2)
                Z_cplx1_polr1_time0 = zero(Float16x2)
                Z_cplx0_polr0_time1 = zero(Float16x2)
                Z_cplx1_polr0_time1 = zero(Float16x2)
                Z_cplx0_polr1_time1 = zero(Float16x2)
                Z_cplx1_polr1_time1 = zero(Float16x2)
                Z_cplx0_polr0_time2 = zero(Float16x2)
                Z_cplx1_polr0_time2 = zero(Float16x2)
                Z_cplx0_polr1_time2 = zero(Float16x2)
                Z_cplx1_polr1_time2 = zero(Float16x2)
                Z_cplx0_polr0_time3 = zero(Float16x2)
                Z_cplx1_polr0_time3 = zero(Float16x2)
                Z_cplx0_polr1_time3 = zero(Float16x2)
                Z_cplx1_polr1_time3 = zero(Float16x2)
                (Z_cplx0_polr0_time0, Z_cplx1_polr0_time0) = IndexSpaces.mma_m16n8k8(
                    (Γ¹_cplx0, Γ¹_cplx1), X_polr0_time0, (Z_cplx0_polr0_time0, Z_cplx1_polr0_time0)
                )
                (Z_cplx0_polr1_time0, Z_cplx1_polr1_time0) = IndexSpaces.mma_m16n8k8(
                    (Γ¹_cplx0, Γ¹_cplx1), X_polr1_time0, (Z_cplx0_polr1_time0, Z_cplx1_polr1_time0)
                )
                (Z_cplx0_polr0_time1, Z_cplx1_polr0_time1) = IndexSpaces.mma_m16n8k8(
                    (Γ¹_cplx0, Γ¹_cplx1), X_polr0_time1, (Z_cplx0_polr0_time1, Z_cplx1_polr0_time1)
                )
                (Z_cplx0_polr1_time1, Z_cplx1_polr1_time1) = IndexSpaces.mma_m16n8k8(
                    (Γ¹_cplx0, Γ¹_cplx1), X_polr1_time1, (Z_cplx0_polr1_time1, Z_cplx1_polr1_time1)
                )
                (Z_cplx0_polr0_time2, Z_cplx1_polr0_time2) = IndexSpaces.mma_m16n8k8(
                    (Γ¹_cplx0, Γ¹_cplx1), X_polr0_time2, (Z_cplx0_polr0_time2, Z_cplx1_polr0_time2)
                )
                (Z_cplx0_polr1_time2, Z_cplx1_polr1_time2) = IndexSpaces.mma_m16n8k8(
                    (Γ¹_cplx0, Γ¹_cplx1), X_polr1_time2, (Z_cplx0_polr1_time2, Z_cplx1_polr1_time2)
                )
                (Z_cplx0_polr0_time3, Z_cplx1_polr0_time3) = IndexSpaces.mma_m16n8k8(
                    (Γ¹_cplx0, Γ¹_cplx1), X_polr0_time3, (Z_cplx0_polr0_time3, Z_cplx1_polr0_time3)
                )
                (Z_cplx0_polr1_time3, Z_cplx1_polr1_time3) = IndexSpaces.mma_m16n8k8(
                    (Γ¹_cplx0, Γ¹_cplx1), X_polr1_time3, (Z_cplx0_polr1_time3, Z_cplx1_polr1_time3)
                )
                Γ²im = Γ²_cplx0
                Γ²re = Γ²_cplx1
                Zim_polr0_time0 = Z_cplx0_polr0_time0
                Zre_polr0_time0 = Z_cplx1_polr0_time0
                Zim_polr1_time0 = Z_cplx0_polr1_time0
                Zre_polr1_time0 = Z_cplx1_polr1_time0
                Zim_polr0_time1 = Z_cplx0_polr0_time1
                Zre_polr0_time1 = Z_cplx1_polr0_time1
                Zim_polr1_time1 = Z_cplx0_polr1_time1
                Zre_polr1_time1 = Z_cplx1_polr1_time1
                Zim_polr0_time2 = Z_cplx0_polr0_time2
                Zre_polr0_time2 = Z_cplx1_polr0_time2
                Zim_polr1_time2 = Z_cplx0_polr1_time2
                Zre_polr1_time2 = Z_cplx1_polr1_time2
                Zim_polr0_time3 = Z_cplx0_polr0_time3
                Zre_polr0_time3 = Z_cplx1_polr0_time3
                Zim_polr1_time3 = Z_cplx0_polr1_time3
                Zre_polr1_time3 = Z_cplx1_polr1_time3
                Vre_polr0_time0 = muladd(Γ²re, Zre_polr0_time0, -Γ²im * Zim_polr0_time0)
                Vre_polr1_time0 = muladd(Γ²re, Zre_polr1_time0, -Γ²im * Zim_polr1_time0)
                Vre_polr0_time1 = muladd(Γ²re, Zre_polr0_time1, -Γ²im * Zim_polr0_time1)
                Vre_polr1_time1 = muladd(Γ²re, Zre_polr1_time1, -Γ²im * Zim_polr1_time1)
                Vre_polr0_time2 = muladd(Γ²re, Zre_polr0_time2, -Γ²im * Zim_polr0_time2)
                Vre_polr1_time2 = muladd(Γ²re, Zre_polr1_time2, -Γ²im * Zim_polr1_time2)
                Vre_polr0_time3 = muladd(Γ²re, Zre_polr0_time3, -Γ²im * Zim_polr0_time3)
                Vre_polr1_time3 = muladd(Γ²re, Zre_polr1_time3, -Γ²im * Zim_polr1_time3)
                Vim_polr0_time0 = muladd(Γ²re, Zim_polr0_time0, +Γ²im * Zre_polr0_time0)
                Vim_polr1_time0 = muladd(Γ²re, Zim_polr1_time0, +Γ²im * Zre_polr1_time0)
                Vim_polr0_time1 = muladd(Γ²re, Zim_polr0_time1, +Γ²im * Zre_polr0_time1)
                Vim_polr1_time1 = muladd(Γ²re, Zim_polr1_time1, +Γ²im * Zre_polr1_time1)
                Vim_polr0_time2 = muladd(Γ²re, Zim_polr0_time2, +Γ²im * Zre_polr0_time2)
                Vim_polr1_time2 = muladd(Γ²re, Zim_polr1_time2, +Γ²im * Zre_polr1_time2)
                Vim_polr0_time3 = muladd(Γ²re, Zim_polr0_time3, +Γ²im * Zre_polr0_time3)
                Vim_polr1_time3 = muladd(Γ²re, Zim_polr1_time3, +Γ²im * Zre_polr1_time3)
                V_cplx0_polr0_time0 = Vim_polr0_time0
                V_cplx1_polr0_time0 = Vre_polr0_time0
                V_cplx0_polr1_time0 = Vim_polr1_time0
                V_cplx1_polr1_time0 = Vre_polr1_time0
                V_cplx0_polr0_time1 = Vim_polr0_time1
                V_cplx1_polr0_time1 = Vre_polr0_time1
                V_cplx0_polr1_time1 = Vim_polr1_time1
                V_cplx1_polr1_time1 = Vre_polr1_time1
                V_cplx0_polr0_time2 = Vim_polr0_time2
                V_cplx1_polr0_time2 = Vre_polr0_time2
                V_cplx0_polr1_time2 = Vim_polr1_time2
                V_cplx1_polr1_time2 = Vre_polr1_time2
                V_cplx0_polr0_time3 = Vim_polr0_time3
                V_cplx1_polr0_time3 = Vre_polr0_time3
                V_cplx0_polr1_time3 = Vim_polr1_time3
                V_cplx1_polr1_time3 = Vre_polr1_time3
                Y_cplx0_polr0_time0 = zero(Float16x2)
                Y_cplx1_polr0_time0 = zero(Float16x2)
                Y_cplx0_polr1_time0 = zero(Float16x2)
                Y_cplx1_polr1_time0 = zero(Float16x2)
                Y_cplx0_polr0_time1 = zero(Float16x2)
                Y_cplx1_polr0_time1 = zero(Float16x2)
                Y_cplx0_polr1_time1 = zero(Float16x2)
                Y_cplx1_polr1_time1 = zero(Float16x2)
                Y_cplx0_polr0_time2 = zero(Float16x2)
                Y_cplx1_polr0_time2 = zero(Float16x2)
                Y_cplx0_polr1_time2 = zero(Float16x2)
                Y_cplx1_polr1_time2 = zero(Float16x2)
                Y_cplx0_polr0_time3 = zero(Float16x2)
                Y_cplx1_polr0_time3 = zero(Float16x2)
                Y_cplx0_polr1_time3 = zero(Float16x2)
                Y_cplx1_polr1_time3 = zero(Float16x2)
                Vim_polr0_time0 = V_cplx0_polr0_time0
                Vre_polr0_time0 = V_cplx1_polr0_time0
                Vim_polr1_time0 = V_cplx0_polr1_time0
                Vre_polr1_time0 = V_cplx1_polr1_time0
                Vim_polr0_time1 = V_cplx0_polr0_time1
                Vre_polr0_time1 = V_cplx1_polr0_time1
                Vim_polr1_time1 = V_cplx0_polr1_time1
                Vre_polr1_time1 = V_cplx1_polr1_time1
                Vim_polr0_time2 = V_cplx0_polr0_time2
                Vre_polr0_time2 = V_cplx1_polr0_time2
                Vim_polr1_time2 = V_cplx0_polr1_time2
                Vre_polr1_time2 = V_cplx1_polr1_time2
                Vim_polr0_time3 = V_cplx0_polr0_time3
                Vre_polr0_time3 = V_cplx1_polr0_time3
                Vim_polr1_time3 = V_cplx0_polr1_time3
                Vre_polr1_time3 = V_cplx1_polr1_time3
                V_cplx_in0_polr0_time0 = Vim_polr0_time0
                V_cplx_in1_polr0_time0 = Vre_polr0_time0
                V_cplx_in0_polr1_time0 = Vim_polr1_time0
                V_cplx_in1_polr1_time0 = Vre_polr1_time0
                V_cplx_in0_polr0_time1 = Vim_polr0_time1
                V_cplx_in1_polr0_time1 = Vre_polr0_time1
                V_cplx_in0_polr1_time1 = Vim_polr1_time1
                V_cplx_in1_polr1_time1 = Vre_polr1_time1
                V_cplx_in0_polr0_time2 = Vim_polr0_time2
                V_cplx_in1_polr0_time2 = Vre_polr0_time2
                V_cplx_in0_polr1_time2 = Vim_polr1_time2
                V_cplx_in1_polr1_time2 = Vre_polr1_time2
                V_cplx_in0_polr0_time3 = Vim_polr0_time3
                V_cplx_in1_polr0_time3 = Vre_polr0_time3
                V_cplx_in0_polr1_time3 = Vim_polr1_time3
                V_cplx_in1_polr1_time3 = Vre_polr1_time3
                (Y_cplx0_polr0_time0, Y_cplx1_polr0_time0) = IndexSpaces.mma_m16n8k16(
                    (Γ³_cplx0_cplx_in0, Γ³_cplx1_cplx_in0, Γ³_cplx0_cplx_in1, Γ³_cplx1_cplx_in1),
                    (V_cplx_in0_polr0_time0, V_cplx_in1_polr0_time0),
                    (Y_cplx0_polr0_time0, Y_cplx1_polr0_time0),
                )
                (Y_cplx0_polr1_time0, Y_cplx1_polr1_time0) = IndexSpaces.mma_m16n8k16(
                    (Γ³_cplx0_cplx_in0, Γ³_cplx1_cplx_in0, Γ³_cplx0_cplx_in1, Γ³_cplx1_cplx_in1),
                    (V_cplx_in0_polr1_time0, V_cplx_in1_polr1_time0),
                    (Y_cplx0_polr1_time0, Y_cplx1_polr1_time0),
                )
                (Y_cplx0_polr0_time1, Y_cplx1_polr0_time1) = IndexSpaces.mma_m16n8k16(
                    (Γ³_cplx0_cplx_in0, Γ³_cplx1_cplx_in0, Γ³_cplx0_cplx_in1, Γ³_cplx1_cplx_in1),
                    (V_cplx_in0_polr0_time1, V_cplx_in1_polr0_time1),
                    (Y_cplx0_polr0_time1, Y_cplx1_polr0_time1),
                )
                (Y_cplx0_polr1_time1, Y_cplx1_polr1_time1) = IndexSpaces.mma_m16n8k16(
                    (Γ³_cplx0_cplx_in0, Γ³_cplx1_cplx_in0, Γ³_cplx0_cplx_in1, Γ³_cplx1_cplx_in1),
                    (V_cplx_in0_polr1_time1, V_cplx_in1_polr1_time1),
                    (Y_cplx0_polr1_time1, Y_cplx1_polr1_time1),
                )
                (Y_cplx0_polr0_time2, Y_cplx1_polr0_time2) = IndexSpaces.mma_m16n8k16(
                    (Γ³_cplx0_cplx_in0, Γ³_cplx1_cplx_in0, Γ³_cplx0_cplx_in1, Γ³_cplx1_cplx_in1),
                    (V_cplx_in0_polr0_time2, V_cplx_in1_polr0_time2),
                    (Y_cplx0_polr0_time2, Y_cplx1_polr0_time2),
                )
                (Y_cplx0_polr1_time2, Y_cplx1_polr1_time2) = IndexSpaces.mma_m16n8k16(
                    (Γ³_cplx0_cplx_in0, Γ³_cplx1_cplx_in0, Γ³_cplx0_cplx_in1, Γ³_cplx1_cplx_in1),
                    (V_cplx_in0_polr1_time2, V_cplx_in1_polr1_time2),
                    (Y_cplx0_polr1_time2, Y_cplx1_polr1_time2),
                )
                (Y_cplx0_polr0_time3, Y_cplx1_polr0_time3) = IndexSpaces.mma_m16n8k16(
                    (Γ³_cplx0_cplx_in0, Γ³_cplx1_cplx_in0, Γ³_cplx0_cplx_in1, Γ³_cplx1_cplx_in1),
                    (V_cplx_in0_polr0_time3, V_cplx_in1_polr0_time3),
                    (Y_cplx0_polr0_time3, Y_cplx1_polr0_time3),
                )
                (Y_cplx0_polr1_time3, Y_cplx1_polr1_time3) = IndexSpaces.mma_m16n8k16(
                    (Γ³_cplx0_cplx_in0, Γ³_cplx1_cplx_in0, Γ³_cplx0_cplx_in1, Γ³_cplx1_cplx_in1),
                    (V_cplx_in0_polr1_time3, V_cplx_in1_polr1_time3),
                    (Y_cplx0_polr1_time3, Y_cplx1_polr1_time3),
                )
                G_cplx0_polr0_time0 = Y_cplx0_polr0_time0
                G_cplx1_polr0_time0 = Y_cplx1_polr0_time0
                G_cplx0_polr1_time0 = Y_cplx0_polr1_time0
                G_cplx1_polr1_time0 = Y_cplx1_polr1_time0
                G_cplx0_polr0_time1 = Y_cplx0_polr0_time1
                G_cplx1_polr0_time1 = Y_cplx1_polr0_time1
                G_cplx0_polr1_time1 = Y_cplx0_polr1_time1
                G_cplx1_polr1_time1 = Y_cplx1_polr1_time1
                G_cplx0_polr0_time2 = Y_cplx0_polr0_time2
                G_cplx1_polr0_time2 = Y_cplx1_polr0_time2
                G_cplx0_polr1_time2 = Y_cplx0_polr1_time2
                G_cplx1_polr1_time2 = Y_cplx1_polr1_time2
                G_cplx0_polr0_time3 = Y_cplx0_polr0_time3
                G_cplx1_polr0_time3 = Y_cplx1_polr0_time3
                G_cplx0_polr1_time3 = Y_cplx0_polr1_time3
                G_cplx1_polr1_time3 = Y_cplx1_polr1_time3
                (G_cplx0_polr0_time0, G_cplx1_polr0_time0) = (
                    IndexSpaces.get_lo16(G_cplx0_polr0_time0, G_cplx1_polr0_time0),
                    IndexSpaces.get_hi16(G_cplx0_polr0_time0, G_cplx1_polr0_time0),
                )
                (G_cplx0_polr1_time0, G_cplx1_polr1_time0) = (
                    IndexSpaces.get_lo16(G_cplx0_polr1_time0, G_cplx1_polr1_time0),
                    IndexSpaces.get_hi16(G_cplx0_polr1_time0, G_cplx1_polr1_time0),
                )
                (G_cplx0_polr0_time1, G_cplx1_polr0_time1) = (
                    IndexSpaces.get_lo16(G_cplx0_polr0_time1, G_cplx1_polr0_time1),
                    IndexSpaces.get_hi16(G_cplx0_polr0_time1, G_cplx1_polr0_time1),
                )
                (G_cplx0_polr1_time1, G_cplx1_polr1_time1) = (
                    IndexSpaces.get_lo16(G_cplx0_polr1_time1, G_cplx1_polr1_time1),
                    IndexSpaces.get_hi16(G_cplx0_polr1_time1, G_cplx1_polr1_time1),
                )
                (G_cplx0_polr0_time2, G_cplx1_polr0_time2) = (
                    IndexSpaces.get_lo16(G_cplx0_polr0_time2, G_cplx1_polr0_time2),
                    IndexSpaces.get_hi16(G_cplx0_polr0_time2, G_cplx1_polr0_time2),
                )
                (G_cplx0_polr1_time2, G_cplx1_polr1_time2) = (
                    IndexSpaces.get_lo16(G_cplx0_polr1_time2, G_cplx1_polr1_time2),
                    IndexSpaces.get_hi16(G_cplx0_polr1_time2, G_cplx1_polr1_time2),
                )
                (G_cplx0_polr0_time3, G_cplx1_polr0_time3) = (
                    IndexSpaces.get_lo16(G_cplx0_polr0_time3, G_cplx1_polr0_time3),
                    IndexSpaces.get_hi16(G_cplx0_polr0_time3, G_cplx1_polr0_time3),
                )
                (G_cplx0_polr1_time3, G_cplx1_polr1_time3) = (
                    IndexSpaces.get_lo16(G_cplx0_polr1_time3, G_cplx1_polr1_time3),
                    IndexSpaces.get_hi16(G_cplx0_polr1_time3, G_cplx1_polr1_time3),
                )
                Gsh_shared[(((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4) % 4) * 64) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx0_polr0_time0
                Gsh_shared[(((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + ((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4) % 4) * 64) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx1_polr0_time0
                Gsh_shared[((((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4) % 4) * 64) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx0_polr1_time0
                Gsh_shared[((((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + 32) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + ((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4) % 4) * 64) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx1_polr1_time0
                Gsh_shared[(((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + 1) % 4) * 64) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx0_polr0_time1
                Gsh_shared[(((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + ((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + 1) % 4) * 64) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx1_polr0_time1
                Gsh_shared[((((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + 1) % 4) * 64) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx0_polr1_time1
                Gsh_shared[((((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + 32) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + ((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + 1) % 4) * 64) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx1_polr1_time1
                Gsh_shared[(((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + 2) % 4) * 64) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx0_polr0_time2
                Gsh_shared[(((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + ((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + 2) % 4) * 64) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx1_polr0_time2
                Gsh_shared[((((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + 2) % 4) * 64) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx0_polr1_time2
                Gsh_shared[((((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + 32) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + ((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + 2) % 4) * 64) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx1_polr1_time2
                Gsh_shared[(((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + 3) % 4) * 64) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx0_polr0_time3
                Gsh_shared[(((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + ((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + 3) % 4) * 64) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx1_polr0_time3
                Gsh_shared[((((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + 3) % 4) * 64) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx0_polr1_time3
                Gsh_shared[((((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) ÷ 6) % 4) * 6) ÷ 6) % 4) * 6 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 6) % 6) + 32) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 16) % 2) * 514) + ((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) % 2) * 8256) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + 3) % 4) * 64) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 4) % 2) * 2056) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 8) % 2) * 1028) + (((1 + (IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 32) % 2) * 257) + 0 + 0x01] =
                    G_cplx1_polr1_time3
                IndexSpaces.cuda_sync_threads()
                for t in 0:1:3
                    G_beamQ0_polr0 = zero(Float16x2)
                    G_beamQ1_polr0 = zero(Float16x2)
                    G_beamQ0_polr1 = zero(Float16x2)
                    G_beamQ1_polr1 = zero(Float16x2)
                    if 0 ≤ IndexSpaces.cuda_threadidx() ÷ 4 < 6
                        G_beamQ0_polr0 = Gsh_shared[(((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) ÷ 6) % 4) * 6 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) ÷ 16) % 2) * 514) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) % 2) * 8256) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + IndexSpaces.assume_inrange(t, 0, 1, 4) % 4) % 4) * 64) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) ÷ 4) % 2) * 2056) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) ÷ 8) % 2) * 1028) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) ÷ 32) % 2) * 257) + 0x01]
                        G_beamQ1_polr0 = Gsh_shared[(((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) ÷ 6) % 4) * 6 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) ÷ 16) % 2) * 514) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) % 2) * 8256) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + IndexSpaces.assume_inrange(t, 0, 1, 4) % 4) % 4) * 64) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) ÷ 4) % 2) * 2056) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) ÷ 8) % 2) * 1028) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) ÷ 32) % 2) * 257) + 0x01]
                        G_beamQ0_polr1 = Gsh_shared[((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) ÷ 6) % 4) * 6 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) + 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) ÷ 16) % 2) * 514) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) % 2) * 8256) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + IndexSpaces.assume_inrange(t, 0, 1, 4) % 4) % 4) * 64) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) ÷ 4) % 2) * 2056) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) ÷ 8) % 2) * 1028) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) ÷ 32) % 2) * 257) + 0x01]
                        G_beamQ1_polr1 = Gsh_shared[((((((((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 4) ÷ 6) % 4) * 6 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) ÷ 4) % 8) % 6) + 32) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) ÷ 16) % 2) * 514) + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) % 2) * 8256) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) ÷ 2) % 2) * 4112) + ((((IndexSpaces.assume_inrange(t_inner, 0, 4, 48) ÷ 4) % 12) * 4 + IndexSpaces.assume_inrange(t, 0, 1, 4) % 4) % 4) * 64) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) ÷ 4) % 2) * 2056) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) ÷ 8) % 2) * 1028) + ((((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) ÷ 32) % 2) * 257) + 0x01]
                    end
                    X_beamQ0_polr0 = G_beamQ0_polr0
                    X_beamQ1_polr0 = G_beamQ1_polr0
                    X_beamQ0_polr1 = G_beamQ0_polr1
                    X_beamQ1_polr1 = G_beamQ1_polr1
                    Z_beamQ0_cplx0_polr0 = zero(Float16x2)
                    Z_beamQ1_cplx0_polr0 = zero(Float16x2)
                    Z_beamQ0_cplx1_polr0 = zero(Float16x2)
                    Z_beamQ1_cplx1_polr0 = zero(Float16x2)
                    Z_beamQ0_cplx0_polr1 = zero(Float16x2)
                    Z_beamQ1_cplx0_polr1 = zero(Float16x2)
                    Z_beamQ0_cplx1_polr1 = zero(Float16x2)
                    Z_beamQ1_cplx1_polr1 = zero(Float16x2)
                    (Z_beamQ0_cplx0_polr0, Z_beamQ0_cplx1_polr0) = IndexSpaces.mma_m16n8k8(
                        (Γ¹_cplx0, Γ¹_cplx1), X_beamQ0_polr0, (Z_beamQ0_cplx0_polr0, Z_beamQ0_cplx1_polr0)
                    )
                    (Z_beamQ1_cplx0_polr0, Z_beamQ1_cplx1_polr0) = IndexSpaces.mma_m16n8k8(
                        (Γ¹_cplx0, Γ¹_cplx1), X_beamQ1_polr0, (Z_beamQ1_cplx0_polr0, Z_beamQ1_cplx1_polr0)
                    )
                    (Z_beamQ0_cplx0_polr1, Z_beamQ0_cplx1_polr1) = IndexSpaces.mma_m16n8k8(
                        (Γ¹_cplx0, Γ¹_cplx1), X_beamQ0_polr1, (Z_beamQ0_cplx0_polr1, Z_beamQ0_cplx1_polr1)
                    )
                    (Z_beamQ1_cplx0_polr1, Z_beamQ1_cplx1_polr1) = IndexSpaces.mma_m16n8k8(
                        (Γ¹_cplx0, Γ¹_cplx1), X_beamQ1_polr1, (Z_beamQ1_cplx0_polr1, Z_beamQ1_cplx1_polr1)
                    )
                    Γ²im = Γ²_cplx0
                    Γ²re = Γ²_cplx1
                    Zim_beamQ0_polr0 = Z_beamQ0_cplx0_polr0
                    Zre_beamQ0_polr0 = Z_beamQ0_cplx1_polr0
                    Zim_beamQ1_polr0 = Z_beamQ1_cplx0_polr0
                    Zre_beamQ1_polr0 = Z_beamQ1_cplx1_polr0
                    Zim_beamQ0_polr1 = Z_beamQ0_cplx0_polr1
                    Zre_beamQ0_polr1 = Z_beamQ0_cplx1_polr1
                    Zim_beamQ1_polr1 = Z_beamQ1_cplx0_polr1
                    Zre_beamQ1_polr1 = Z_beamQ1_cplx1_polr1
                    Vre_beamQ0_polr0 = muladd(Γ²re, Zre_beamQ0_polr0, -Γ²im * Zim_beamQ0_polr0)
                    Vre_beamQ1_polr0 = muladd(Γ²re, Zre_beamQ1_polr0, -Γ²im * Zim_beamQ1_polr0)
                    Vre_beamQ0_polr1 = muladd(Γ²re, Zre_beamQ0_polr1, -Γ²im * Zim_beamQ0_polr1)
                    Vre_beamQ1_polr1 = muladd(Γ²re, Zre_beamQ1_polr1, -Γ²im * Zim_beamQ1_polr1)
                    Vim_beamQ0_polr0 = muladd(Γ²re, Zim_beamQ0_polr0, +Γ²im * Zre_beamQ0_polr0)
                    Vim_beamQ1_polr0 = muladd(Γ²re, Zim_beamQ1_polr0, +Γ²im * Zre_beamQ1_polr0)
                    Vim_beamQ0_polr1 = muladd(Γ²re, Zim_beamQ0_polr1, +Γ²im * Zre_beamQ0_polr1)
                    Vim_beamQ1_polr1 = muladd(Γ²re, Zim_beamQ1_polr1, +Γ²im * Zre_beamQ1_polr1)
                    V_beamQ0_cplx0_polr0 = Vim_beamQ0_polr0
                    V_beamQ0_cplx1_polr0 = Vre_beamQ0_polr0
                    V_beamQ1_cplx0_polr0 = Vim_beamQ1_polr0
                    V_beamQ1_cplx1_polr0 = Vre_beamQ1_polr0
                    V_beamQ0_cplx0_polr1 = Vim_beamQ0_polr1
                    V_beamQ0_cplx1_polr1 = Vre_beamQ0_polr1
                    V_beamQ1_cplx0_polr1 = Vim_beamQ1_polr1
                    V_beamQ1_cplx1_polr1 = Vre_beamQ1_polr1
                    Y_beamQ0_cplx0_polr0 = zero(Float16x2)
                    Y_beamQ1_cplx0_polr0 = zero(Float16x2)
                    Y_beamQ0_cplx1_polr0 = zero(Float16x2)
                    Y_beamQ1_cplx1_polr0 = zero(Float16x2)
                    Y_beamQ0_cplx0_polr1 = zero(Float16x2)
                    Y_beamQ1_cplx0_polr1 = zero(Float16x2)
                    Y_beamQ0_cplx1_polr1 = zero(Float16x2)
                    Y_beamQ1_cplx1_polr1 = zero(Float16x2)
                    Vim_beamQ0_polr0 = V_beamQ0_cplx0_polr0
                    Vre_beamQ0_polr0 = V_beamQ0_cplx1_polr0
                    Vim_beamQ1_polr0 = V_beamQ1_cplx0_polr0
                    Vre_beamQ1_polr0 = V_beamQ1_cplx1_polr0
                    Vim_beamQ0_polr1 = V_beamQ0_cplx0_polr1
                    Vre_beamQ0_polr1 = V_beamQ0_cplx1_polr1
                    Vim_beamQ1_polr1 = V_beamQ1_cplx0_polr1
                    Vre_beamQ1_polr1 = V_beamQ1_cplx1_polr1
                    V_beamQ0_cplx_in0_polr0 = Vim_beamQ0_polr0
                    V_beamQ0_cplx_in1_polr0 = Vre_beamQ0_polr0
                    V_beamQ1_cplx_in0_polr0 = Vim_beamQ1_polr0
                    V_beamQ1_cplx_in1_polr0 = Vre_beamQ1_polr0
                    V_beamQ0_cplx_in0_polr1 = Vim_beamQ0_polr1
                    V_beamQ0_cplx_in1_polr1 = Vre_beamQ0_polr1
                    V_beamQ1_cplx_in0_polr1 = Vim_beamQ1_polr1
                    V_beamQ1_cplx_in1_polr1 = Vre_beamQ1_polr1
                    (Y_beamQ0_cplx0_polr0, Y_beamQ0_cplx1_polr0) = IndexSpaces.mma_m16n8k16(
                        (Γ³_cplx0_cplx_in0, Γ³_cplx1_cplx_in0, Γ³_cplx0_cplx_in1, Γ³_cplx1_cplx_in1),
                        (V_beamQ0_cplx_in0_polr0, V_beamQ0_cplx_in1_polr0),
                        (Y_beamQ0_cplx0_polr0, Y_beamQ0_cplx1_polr0),
                    )
                    (Y_beamQ1_cplx0_polr0, Y_beamQ1_cplx1_polr0) = IndexSpaces.mma_m16n8k16(
                        (Γ³_cplx0_cplx_in0, Γ³_cplx1_cplx_in0, Γ³_cplx0_cplx_in1, Γ³_cplx1_cplx_in1),
                        (V_beamQ1_cplx_in0_polr0, V_beamQ1_cplx_in1_polr0),
                        (Y_beamQ1_cplx0_polr0, Y_beamQ1_cplx1_polr0),
                    )
                    (Y_beamQ0_cplx0_polr1, Y_beamQ0_cplx1_polr1) = IndexSpaces.mma_m16n8k16(
                        (Γ³_cplx0_cplx_in0, Γ³_cplx1_cplx_in0, Γ³_cplx0_cplx_in1, Γ³_cplx1_cplx_in1),
                        (V_beamQ0_cplx_in0_polr1, V_beamQ0_cplx_in1_polr1),
                        (Y_beamQ0_cplx0_polr1, Y_beamQ0_cplx1_polr1),
                    )
                    (Y_beamQ1_cplx0_polr1, Y_beamQ1_cplx1_polr1) = IndexSpaces.mma_m16n8k16(
                        (Γ³_cplx0_cplx_in0, Γ³_cplx1_cplx_in0, Γ³_cplx0_cplx_in1, Γ³_cplx1_cplx_in1),
                        (V_beamQ1_cplx_in0_polr1, V_beamQ1_cplx_in1_polr1),
                        (Y_beamQ1_cplx0_polr1, Y_beamQ1_cplx1_polr1),
                    )
                    Ẽ_beamQ0_cplx0_polr0 = Y_beamQ0_cplx0_polr0
                    Ẽ_beamQ1_cplx0_polr0 = Y_beamQ1_cplx0_polr0
                    Ẽ_beamQ0_cplx1_polr0 = Y_beamQ0_cplx1_polr0
                    Ẽ_beamQ1_cplx1_polr0 = Y_beamQ1_cplx1_polr0
                    Ẽ_beamQ0_cplx0_polr1 = Y_beamQ0_cplx0_polr1
                    Ẽ_beamQ1_cplx0_polr1 = Y_beamQ1_cplx0_polr1
                    Ẽ_beamQ0_cplx1_polr1 = Y_beamQ0_cplx1_polr1
                    Ẽ_beamQ1_cplx1_polr1 = Y_beamQ1_cplx1_polr1
                    Ẽim_beamQ0_polr0 = Ẽ_beamQ0_cplx0_polr0
                    Ẽre_beamQ0_polr0 = Ẽ_beamQ0_cplx1_polr0
                    Ẽim_beamQ1_polr0 = Ẽ_beamQ1_cplx0_polr0
                    Ẽre_beamQ1_polr0 = Ẽ_beamQ1_cplx1_polr0
                    Ẽim_beamQ0_polr1 = Ẽ_beamQ0_cplx0_polr1
                    Ẽre_beamQ0_polr1 = Ẽ_beamQ0_cplx1_polr1
                    Ẽim_beamQ1_polr1 = Ẽ_beamQ1_cplx0_polr1
                    Ẽre_beamQ1_polr1 = Ẽ_beamQ1_cplx1_polr1
                    I_beamQ0_polr0 = muladd(
                        Ẽre_beamQ0_polr0, Ẽre_beamQ0_polr0, muladd(Ẽim_beamQ0_polr0, Ẽim_beamQ0_polr0, I_beamQ0_polr0)
                    )
                    I_beamQ1_polr0 = muladd(
                        Ẽre_beamQ1_polr0, Ẽre_beamQ1_polr0, muladd(Ẽim_beamQ1_polr0, Ẽim_beamQ1_polr0, I_beamQ1_polr0)
                    )
                    I_beamQ0_polr1 = muladd(
                        Ẽre_beamQ0_polr1, Ẽre_beamQ0_polr1, muladd(Ẽim_beamQ0_polr1, Ẽim_beamQ0_polr1, I_beamQ0_polr1)
                    )
                    I_beamQ1_polr1 = muladd(
                        Ẽre_beamQ1_polr1, Ẽre_beamQ1_polr1, muladd(Ẽim_beamQ1_polr1, Ẽim_beamQ1_polr1, I_beamQ1_polr1)
                    )
                    t_running += 1
                    if t_running == 1
                        if let
                            p = (2i32) * IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32)
                            q = (2i32) * IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24)
                            0i32 ≤ p < 48 && 0i32 ≤ q < 48
                        end
                            I_memory[(((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 24 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) % 48) * 24) + ((IndexSpaces.assume_inrange(dstime, 0, 1, 48) % 48) % 48) * 2304) + 0 + 0x01] =
                                I_beamQ0_polr0
                            I_memory[(((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 24 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) % 48) * 24) + ((IndexSpaces.assume_inrange(dstime, 0, 1, 48) % 48) % 48) * 2304) + 0 + 0x01] =
                                I_beamQ1_polr0
                            I_memory[((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 24 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2) % 48) * 24) + ((IndexSpaces.assume_inrange(dstime, 0, 1, 48) % 48) % 48) * 2304) + 1152) + 0 + 0x01] =
                                I_beamQ0_polr1
                            I_memory[((((((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) * 2) ÷ 2) % 24 + (((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) * 2 + 1) % 48) * 24) + ((IndexSpaces.assume_inrange(dstime, 0, 1, 48) % 48) % 48) * 2304) + 1152) + 0 + 0x01] =
                                I_beamQ1_polr1
                        end
                        I_beamQ0_polr0 = zero(Float16x2)
                        I_beamQ1_polr0 = zero(Float16x2)
                        I_beamQ0_polr1 = zero(Float16x2)
                        I_beamQ1_polr1 = zero(Float16x2)
                        t_running = 0
                        dstime += 1
                    end
                end
                IndexSpaces.cuda_sync_threads()
            end
        end
    end
    info = 0
    info_memory[((IndexSpaces.assume_inrange(IndexSpaces.cuda_threadidx(), 0, 32) % 32) % 32 + ((IndexSpaces.assume_inrange(IndexSpaces.cuda_warpidx(), 0, 24) % 24) % 24) * 32) + 0 + 0x01] =
        info
end
