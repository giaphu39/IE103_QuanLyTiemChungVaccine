DO $$
DECLARE
    i INT;
    j INT;
    v_k INT;
    rand_nsx DATE;
    v_kh_ns DATE;
    v_ngay_cap_so DATE;
    v_ngay_co_the DATE; 
    v_ngay_tiem_gan_nhat DATE;
    v_ma_so_stc INT;
    v_ma_nv_cm INT;
    v_ma_kh INT;
    v_inserted_hd INT;
    v_temp_id INT;

    v_malo_random INT;
    v_mavx_hientai INT;
    v_phacdo_max INT;
    v_so_loai_vx INT;        
    v_so_mui_da_tiem INT;    
    v_vaccine_index INT;     
    v_inserted_lt INT;       
    
    -- Khai báo biến phục vụ logic khám sàng lọc mới
    v_kl_bac_si KetLuanBSEnum;
    v_ket_qua_tiem KetQuaTiemEnum;
    
    -- Bien khoi tao danh muc dong de map bang trung gian
    v_id_vx_bcg INT; v_id_vx_gar INT; v_id_vx_eng INT; v_id_vx_hex INT; v_id_vx_imo INT;
    v_id_vx_gev INT; v_id_vx_mmr INT; v_id_vx_var INT; v_id_vx_syn INT; v_id_vx_vax INT;
    
    v_id_b_lao INT; v_id_b_hpv INT; v_id_b_vgb INT; v_id_b_bh INT; v_id_b_bl INT;
    v_id_b_vnn INT; v_id_b_sqr INT; v_id_b_td INT; v_id_b_pc INT; v_id_b_cum INT;

    -- Mang dong de luu tru ID thuc te nham chong loi nhay so ID (Sequence)
    arr_id_vacxin INT[] := ARRAY[]::INT[];
    arr_id_lovacxin INT[] := ARRAY[]::INT[];
    arr_id_nv_hc INT[] := ARRAY[]::INT[];
    arr_id_nv_cm INT[] := ARRAY[]::INT[];
    arr_id_nguoi_giam_ho INT[] := ARRAY[]::INT[];
    arr_id_khach_hang INT[] := ARRAY[]::INT[];
    arr_id_so_tiem INT[] := ARRAY[]::INT[];

    -- Kho tu vung tieng Viet de sinh ten va dia chi ngau nhien nhung nhat quan
    arr_ho TEXT[] := ARRAY['Nguyen', 'Tran', 'Le', 'Pham', 'Vu', 'Vo', 'Dang', 'Bui', 'Do', 'Hoang'];
    arr_lot TEXT[] := ARRAY['Van', 'Thi', 'Minh', 'Ngoc', 'Gia', 'Nhat', 'Thanh', 'Duc', 'Hoang', 'An'];
    arr_ten TEXT[] := ARRAY['An', 'Binh', 'Cuong', 'Dung', 'Em', 'Phong', 'Giang', 'Huong', 'Khanh', 'Linh', 'Minh', 'Nam', 'Oanh', 'Phu', 'Quy', 'Son', 'Tu', 'Vinh', 'Xuan', 'Yen'];
    arr_diachi TEXT[] := ARRAY['TP Ho Chi Minh', 'Binh Duong', 'Dong Nai', 'Long An', 'Vung Tau', 'Can Tho', 'Tay Ninh'];
BEGIN
    -- Thiet lap Seed co dinh de du lieu tren may moi thanh vien trung khop hoan toan
    PERFORM setseed(0.5);

    RAISE NOTICE 'Bat dau don sach du lieu cu...';

    -- Don sach du lieu bang TRUNCATE CASCADE de bo qua Trigger va reset ID ve 1
    TRUNCATE TABLE 
        LANTIEM_LOVACXIN,
        LanTiem,
        HoaDon,
        PhieuKhamSangLoc,
        SoTiemChung,
        CHITIET_GIAMHO,
        KhachHang,
        NguoiGiamHo,
        LoVacXin,
        NhanVienChuyenMon,
        NhanVienHanhChinh,
        VACXIN_BENHPHONGNGUA,
        BenhPhongNgua,
        VacXin 
    RESTART IDENTITY CASCADE;

    RAISE NOTICE 'Bat dau nap danh muc co dinh...';

    -- 1. NAP BANG: BENHPHONGNGUA
    INSERT INTO BenhPhongNgua (TenBPN, MucDoNguyHiem) VALUES ('Lao', 'CAO') RETURNING MaBPN INTO v_id_b_lao;
    INSERT INTO BenhPhongNgua (TenBPN, MucDoNguyHiem) VALUES ('Bao tu cung (HPV)', 'TRUNG_BINH') RETURNING MaBPN INTO v_id_b_hpv;
    INSERT INTO BenhPhongNgua (TenBPN, MucDoNguyHiem) VALUES ('Viem gan B', 'CAO') RETURNING MaBPN INTO v_id_b_vgb;
    INSERT INTO BenhPhongNgua (TenBPN, MucDoNguyHiem) VALUES ('Bach hau - Uon van - Ho ga', 'RAT_CAO') RETURNING MaBPN INTO v_id_b_bh;
    INSERT INTO BenhPhongNgua (TenBPN, MucDoNguyHiem) VALUES ('Bai liet', 'RAT_CAO') RETURNING MaBPN INTO v_id_b_bl;
    INSERT INTO BenhPhongNgua (TenBPN, MucDoNguyHiem) VALUES ('Viem nao Nhat Ban', 'RAT_CAO') RETURNING MaBPN INTO v_id_b_vnn;
    INSERT INTO BenhPhongNgua (TenBPN, MucDoNguyHiem) VALUES ('Soi - Quai bi - Rubella', 'CAO') RETURNING MaBPN INTO v_id_b_sqr;
    INSERT INTO BenhPhongNgua (TenBPN, MucDoNguyHiem) VALUES ('Thuy dau', 'TRUNG_BINH') RETURNING MaBPN INTO v_id_b_td;
    INSERT INTO BenhPhongNgua (TenBPN, MucDoNguyHiem) VALUES ('Phe cau khuan', 'CAO') RETURNING MaBPN INTO v_id_b_pc;
    INSERT INTO BenhPhongNgua (TenBPN, MucDoNguyHiem) VALUES ('Cum', 'THAP') RETURNING MaBPN INTO v_id_b_cum;

    -- 2. NAP BANG: VACXIN
    INSERT INTO VacXin (TenVX, PhacDo, HangSX) VALUES ('BCG (Viet Nam)', 1, 'IVAC') RETURNING MaVX INTO v_id_vx_bcg;
    INSERT INTO VacXin (TenVX, PhacDo, HangSX) VALUES ('Gardasil 9', 3, 'MSD') RETURNING MaVX INTO v_id_vx_gar;
    INSERT INTO VacXin (TenVX, PhacDo, HangSX) VALUES ('Engerix B', 3, 'GSK') RETURNING MaVX INTO v_id_vx_eng;
    INSERT INTO VacXin (TenVX, PhacDo, HangSX) VALUES ('Hexaxim 6 trong 1', 4, 'Sanofi Pasteur') RETURNING MaVX INTO v_id_vx_hex;
    INSERT INTO VacXin (TenVX, PhacDo, HangSX) VALUES ('Imojev', 2, 'Sanofi Pasteur') RETURNING MaVX INTO v_id_vx_imo;
    INSERT INTO VacXin (TenVX, PhacDo, HangSX) VALUES ('Jevax', 3, 'VABIOTECH') RETURNING MaVX INTO v_id_vx_gev;
    INSERT INTO VacXin (TenVX, PhacDo, HangSX) VALUES ('MMR II', 2, 'MSD') RETURNING MaVX INTO v_id_vx_mmr;
    INSERT INTO VacXin (TenVX, PhacDo, HangSX) VALUES ('Varilrix', 2, 'GSK') RETURNING MaVX INTO v_id_vx_var;
    INSERT INTO VacXin (TenVX, PhacDo, HangSX) VALUES ('Synflorix', 4, 'GSK') RETURNING MaVX INTO v_id_vx_syn;
    INSERT INTO VacXin (TenVX, PhacDo, HangSX) VALUES ('Vaxigrip Tetra', 1, 'Sanofi Pasteur') RETURNING MaVX INTO v_id_vx_vax;

    arr_id_vacxin := ARRAY[v_id_vx_bcg, v_id_vx_gar, v_id_vx_eng, v_id_vx_hex, v_id_vx_imo, v_id_vx_gev, v_id_vx_mmr, v_id_vx_var, v_id_vx_syn, v_id_vx_vax];

    -- 3. NAP BANG TRUNG GIAN: VACXIN_BENHPHONGNGUA
    INSERT INTO VACXIN_BENHPHONGNGUA (MaVX, MaBPN) VALUES
    (v_id_vx_bcg, v_id_b_lao),
    (v_id_vx_gar, v_id_b_hpv),
    (v_id_vx_eng, v_id_b_vgb),
    (v_id_vx_hex, v_id_b_vgb),
    (v_id_vx_hex, v_id_b_bh),
    (v_id_vx_hex, v_id_b_bl),
    (v_id_vx_imo, v_id_b_vnn),
    (v_id_vx_gev, v_id_b_vnn),
    (v_id_vx_mmr, v_id_b_sqr),
    (v_id_vx_var, v_id_b_td),
    (v_id_vx_syn, v_id_b_pc),
    (v_id_vx_vax, v_id_b_cum);

    RAISE NOTICE 'Da nap xong cac danh muc va bang trung gian co dinh.';

    -- 4. NAP BANG: NHANVIENHANHCHINH (5000 dong)
    FOR i IN 1..5000 LOOP
        INSERT INTO NhanVienHanhChinh (NgaySinh, GioiTinh, ChucDanh, HoTen, DiaChi, SDT)
        VALUES (
            '2026-04-30'::DATE - (INTERVAL '18 years' + (random() * 20 * INTERVAL '365 days')),
            (random() > 0.5),
            (ARRAY['QUAN_LY', 'THU_NGAN', 'LE_TAN'])[floor(random() * 3) + 1]::ChucDanhHC,
            arr_ho[floor(random() * 10) + 1] || ' ' || arr_lot[floor(random() * 10) + 1] || ' ' || arr_ten[floor(random() * 20) + 1],
            arr_diachi[floor(random() * 7) + 1],
            '0' || floor(100000000 + random() * 900000000)::text
        ) RETURNING MaNV INTO v_temp_id;
        arr_id_nv_hc := array_append(arr_id_nv_hc, v_temp_id);
    END LOOP;
    RAISE NOTICE 'Da nap xong 5000 Nhan vien Hanh chinh.';

    -- 5. NAP BANG: NHANVIENCHUYENMON (5000 dong)
    FOR i IN 1..5000 LOOP
        INSERT INTO NhanVienChuyenMon (NgaySinh, GioiTinh, ChucDanh, CCHanhNghe, HoTen, DiaChi, SDT)
        VALUES (
            '2026-04-30'::DATE - (INTERVAL '23 years' + (random() * 25 * INTERVAL '365 days')),
            (random() > 0.5),
            (ARRAY['BAC_SI', 'DIEU_DUONG', 'KY_THUAT_VIEN'])[floor(random() * 3) + 1]::ChucDanhCM,
            'CCHN-' || (100000 + i)::text,
            arr_ho[floor(random() * 10) + 1] || ' ' || arr_lot[floor(random() * 10) + 1] || ' ' || arr_ten[floor(random() * 20) + 1],
            arr_diachi[floor(random() * 7) + 1],
            '0' || floor(100000000 + random() * 900000000)::text
        ) RETURNING MaNV INTO v_temp_id;
        arr_id_nv_cm := array_append(arr_id_nv_cm, v_temp_id);
    END LOOP;
    RAISE NOTICE 'Da nap xong 5000 Nhan vien Chuyen mon.';

    -- 6. NAP BANG: LOVACXIN (5000 dong)
    FOR i IN 1..5000 LOOP
        -- THAY ĐỔI 1: Lùi ngày sản xuất về hẳn 2022-2023 để hợp lệ với lịch tiêm từ 2024
        rand_nsx := '2022-01-01'::DATE + floor(random() * 700)::int * INTERVAL '1 day';
        
        IF i <= 10 THEN
            v_mavx_hientai := arr_id_vacxin[i];
        ELSE
            v_mavx_hientai := arr_id_vacxin[floor(random() * 10) + 1];
        END IF;

        INSERT INTO LoVacXin (HSD, NoiSX, NSX, SoLuongTon, MaVX)
        VALUES (
            -- THAY ĐỔI 2: Tăng hạn dùng lên 5 năm, giúp HSD rơi vào 2027-2028 (Tuyệt đối không bị lỗi hết hạn)
            rand_nsx + INTERVAL '5 years',
            'Nha May Co So ' || i,
            rand_nsx,
            floor(100 + random() * 900)::int,
            v_mavx_hientai
        ) RETURNING MaLo INTO v_temp_id;
        arr_id_lovacxin := array_append(arr_id_lovacxin, v_temp_id);
    END LOOP;
    RAISE NOTICE 'Da nap xong 5000 Lo Vacxin.';

    -- 7. NAP BANG: NGUOIGIAMHO (5000 dong)
    FOR i IN 1..5000 LOOP
        INSERT INTO NguoiGiamHo (NgaySinh, GioiTinh, QHVoiNT, HoTen, DiaChi, SDT)
        VALUES (
            '2026-04-30'::DATE - (INTERVAL '25 years' + (random() * 30 * INTERVAL '365 days')),
            (random() > 0.5),
            (ARRAY['CHA', 'ME', 'ONG', 'BA', 'KHAC'])[floor(random() * 5) + 1]::QuanHeEnum,
            arr_ho[floor(random() * 10) + 1] || ' ' || arr_lot[floor(random() * 10) + 1] || ' ' || arr_ten[floor(random() * 20) + 1],
            arr_diachi[floor(random() * 7) + 1],
            '0' || floor(100000000 + random() * 900000000)::text
        ) RETURNING MaNGH INTO v_temp_id;
        arr_id_nguoi_giam_ho := array_append(arr_id_nguoi_giam_ho, v_temp_id);
    END LOOP;
    RAISE NOTICE 'Da nap xong 5000 Nguoi Giam ho.';

    -- 8. NAP BANG: KHACHHANG (5000 dong)
    FOR i IN 1..5000 LOOP
        INSERT INTO KhachHang (NgaySinh, GioiTinh, HoTen, DiaChi, SDT)
        VALUES (
            (CASE WHEN i <= 2500 THEN '2026-04-30'::DATE - (INTERVAL '18 years' + (random() * 40 * INTERVAL '365 days'))
                  ELSE '2026-04-30'::DATE - (random() * 17 * INTERVAL '365 days') END),
            (random() > 0.5),
            arr_ho[floor(random() * 10) + 1] || ' ' || arr_lot[floor(random() * 10) + 1] || ' ' || arr_ten[floor(random() * 20) + 1],
            arr_diachi[floor(random() * 7) + 1],
            '0' || floor(100000000 + random() * 900000000)::text
        ) RETURNING MaKH INTO v_temp_id;
        arr_id_khach_hang := array_append(arr_id_khach_hang, v_temp_id);
    END LOOP;
    RAISE NOTICE 'Da nap xong 5000 Khach hang.';

    -- 9. NAP BANG: CHITIET_GIAMHO (2500 dong)
    FOR i IN 1..2500 LOOP
        INSERT INTO CHITIET_GIAMHO (MaNGH, MaKH, MoiQuanHe)
        VALUES (
            arr_id_nguoi_giam_ho[i], 
            arr_id_khach_hang[2500 + i],
            (ARRAY['Bo', 'Me', 'Ong Noi', 'Ba Ngoai'])[floor(random() * 4) + 1]
        );
    END LOOP;
    RAISE NOTICE 'Da lien ket xong thong tin nguoi giam ho cho tre em.';

    -- =========================================================
    -- 10. NẠP BẢNG: SỔ TIÊM CHỦNG VÀ CÁC QUY TRÌNH LIÊN KẾT (1-1 ĐỒNG BỘ)
    -- =========================================================
    FOR i IN 1..5000 LOOP
        SELECT NgaySinh INTO v_kh_ns FROM KhachHang WHERE MaKH = arr_id_khach_hang[i];
        
        v_ma_kh := arr_id_khach_hang[i];
        
        v_ngay_co_the := GREATEST('2024-01-01'::DATE, v_kh_ns);
        IF v_ngay_co_the < '2026-04-01'::DATE THEN
            v_ngay_cap_so := v_ngay_co_the + floor(random() * ('2026-04-01'::DATE - v_ngay_co_the))::int * INTERVAL '1 day';
        ELSE
            v_ngay_cap_so := v_ngay_co_the;
        END IF;

        INSERT INTO SoTiemChung (NgayLapSo, GhiChu, TrangThai, MaNV, MaKH)
        VALUES (
            v_ngay_cap_so,
            'So quan ly khach hang dinh danh ' || i,
            (ARRAY['ACTIVE', 'INACTIVE', 'COMPLETED'])[floor(random() * 3) + 1]::TrangThaiSo,
            arr_id_nv_hc[floor(random() * 5000) + 1], 
            v_ma_kh
        ) RETURNING MaSo INTO v_temp_id;
        
        arr_id_so_tiem := array_append(arr_id_so_tiem, v_temp_id);
        v_ma_so_stc := v_temp_id;

        v_so_loai_vx := floor(random() * 3) + 1; 

        -- 11. VÒNG LẶP XỬ LÝ KHÁM SÀNG LỌC VÀ TIÊM CHỦNG ĐỒNG BỘ
        FOR j IN 1..v_so_loai_vx LOOP
            v_vaccine_index := floor(random() * 10) + 1;
            v_mavx_hientai := arr_id_vacxin[v_vaccine_index];
            
            IF EXISTS (
                SELECT 1 FROM LANTIEM_LOVACXIN ltlv
                JOIN LanTiem lt ON ltlv.MaLT = lt.MaLT
                JOIN LoVacXin lv ON ltlv.MaLo = lv.MaLo
                WHERE lt.MaSo = v_ma_so_stc AND lv.MaVX = v_mavx_hientai
            ) THEN
                CONTINUE; 
            END IF;
            
            SELECT PhacDo INTO v_phacdo_max FROM VacXin WHERE MaVX = v_mavx_hientai;
            
            v_so_mui_da_tiem := floor(random() * v_phacdo_max) + 1;
            
            FOR v_k IN 1..v_so_mui_da_tiem LOOP
                
                IF v_k > 1 THEN
                    v_ngay_tiem_gan_nhat := v_ngay_tiem_gan_nhat + (28 + random() * 7)::int * INTERVAL '1 day';
                ELSE
                    v_ngay_tiem_gan_nhat := v_ngay_cap_so + floor(random() * 15)::int * INTERVAL '1 day';
                END IF;

                IF v_ngay_tiem_gan_nhat > '2026-04-30'::DATE THEN
                    EXIT; 
                END IF;

                v_ma_nv_cm := arr_id_nv_cm[floor(random() * 5000) + 1]; 
                v_kl_bac_si := (ARRAY['DU_DIEU_KIEN', 'TAM_HOAN', 'CHONG_CHI_DINH'])[floor(random() * 3) + 1]::KetLuanBSEnum; 

                -- Buoc A: Tao PhieuKhamSangLoc
                INSERT INTO PhieuKhamSangLoc (NgayLap, NhietDo, ChieuCao, CanNang, KLCuaBS, TSDiUng, MaNV)
                VALUES (
                    v_ngay_tiem_gan_nhat,
                    (CASE WHEN v_kl_bac_si = 'DU_DIEU_KIEN' THEN (36.0 + (random() * 1.2))::NUMERIC(4,1)
                          ELSE (38.2 + (random() * 1.8))::NUMERIC(4,1) END),
                    (50.0 + random() * 130.0)::NUMERIC(5,2),
                    (5.0 + random() * 85.0)::NUMERIC(5,2),
                    v_kl_bac_si,
                    (CASE WHEN v_kl_bac_si = 'CHONG_CHI_DINH' THEN 'Co tien su soc phan ve chat dung dich' ELSE 'Khong co' END),
                    v_ma_nv_cm
                ) RETURNING MaPK INTO v_temp_id;

                -- Buoc B: Tao HoaDon thu tien
                INSERT INTO HoaDon (NgayLap, HTThanhToan, TongTien, MaKH, MaNV)
                VALUES (
                    v_ngay_tiem_gan_nhat,
                    (ARRAY['TIEN_MAT', 'CHUYEN_KHOAN', 'THE', 'VI_DIEN_TU'])[floor(random() * 4) + 1]::HinhThucThanhToan,
                    (300000 + (floor(random() * 10) * 100000))::NUMERIC(15,2),
                    v_ma_kh,
                    arr_id_nv_hc[floor(random() * 5000) + 1] 
                ) RETURNING MaHD INTO v_inserted_hd;

                IF v_kl_bac_si = 'DU_DIEU_KIEN' THEN
                    v_ket_qua_tiem := (ARRAY['BINH_THUONG', 'PHAN_UNG_NHE', 'SOT_CAO'])[floor(random() * 3) + 1]::KetQuaTiemEnum;
                ELSE 
                    v_ket_qua_tiem := 'CHUA_TIEM'::KetQuaTiemEnum;
                END IF;

                -- Buoc C: Ghi nhan LanTiem hop nhat
                INSERT INTO LanTiem (NgayTiem, KetQua, MaNV, MaSo, MaPK, MaHD)
                VALUES (
                    v_ngay_tiem_gan_nhat,
                    v_ket_qua_tiem,
                    v_ma_nv_cm, 
                    v_ma_so_stc,
                    v_temp_id,       
                    v_inserted_hd
                ) RETURNING MaLT INTO v_inserted_lt; 

                -- Buoc D: Ghi nhận vật tư hao hụt
                IF v_ket_qua_tiem != 'CHUA_TIEM' THEN
                    -- THAY ĐỔI 3: Thêm điều kiện lọc HSD và NSX để bảo vệ tầng DB, chống triệt để lỗi QT7
                    SELECT MaLo INTO v_malo_random 
                    FROM LoVacXin 
                    WHERE MaVX = v_mavx_hientai 
                      AND HSD >= v_ngay_tiem_gan_nhat
                      AND NSX <= v_ngay_tiem_gan_nhat
                    ORDER BY random() 
                    LIMIT 1;

                    -- Chốt chặn cuối cùng nếu không tìm ra lô (fallback)
                    IF v_malo_random IS NULL THEN
                        SELECT MaLo INTO v_malo_random FROM LoVacXin WHERE MaVX = v_mavx_hientai ORDER BY HSD DESC LIMIT 1;
                    END IF;

                    INSERT INTO LANTIEM_LOVACXIN (MaLT, MaLo, MuiTiemThu)
                    VALUES (
                        v_inserted_lt, 
                        v_malo_random, 
                        v_k 
                    );
                END IF;
                
            END LOOP; 
        END LOOP; 
    END LOOP;
    
    RAISE NOTICE 'Da nap xong 5000 So tiem chung cung cac quy trinh lien ket.';
    RAISE NOTICE 'Hoan tat nap du lieu dong bo toan ven cho he thong.';
END $$;

