--Hàm tính tuổi khách hàng
CREATE OR REPLACE FUNCTION fn_tinh_tuoi_khach_hang(
    p_MaKH INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_NgaySinh DATE;
    v_Tuoi INT;
BEGIN
    SELECT NgaySinh
    INTO v_NgaySinh
    FROM KhachHang
    WHERE MaKH = p_MaKH;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Khach hang voi MaKH % khong ton tai', p_MaKH;
    END IF;

    v_Tuoi := EXTRACT(YEAR FROM AGE(CURRENT_DATE, v_NgaySinh))::INT;

    RETURN v_Tuoi;
END;
$$;
--Hàm đếm số mũi tiêm của một khách hàng
CREATE OR REPLACE FUNCTION fn_dem_so_mui_tiem_khach_hang(
    p_MaKH INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_SoMuiTiem INT;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM KhachHang
        WHERE MaKH = p_MaKH
    ) THEN
        RAISE EXCEPTION 'Khach hang voi MaKH % khong ton tai', p_MaKH;
    END IF;

    SELECT COUNT(*)
    INTO v_SoMuiTiem
    FROM LanTiem lt
    JOIN SoTiemChung stc ON lt.MaSo = stc.MaSo
    WHERE stc.MaKH = p_MaKH;

    RETURN v_SoMuiTiem;
END;
$$;
--Hàm tính tổng tiền hóa đơn của một khách hàng
CREATE OR REPLACE FUNCTION fn_tong_tien_khach_hang(
    p_MaKH INT
)
RETURNS NUMERIC(15,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_TongTien NUMERIC(15,2);
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM KhachHang
        WHERE MaKH = p_MaKH
    ) THEN
        RAISE EXCEPTION 'Khach hang voi MaKH % khong ton tai', p_MaKH;
    END IF;

    SELECT COALESCE(SUM(TongTien), 0)
    INTO v_TongTien
    FROM HoaDon
    WHERE MaKH = p_MaKH;

    RETURN v_TongTien;
END;
$$;
--Hàm kiểm tra tổng tồn kho của một loại vaccine
CREATE OR REPLACE FUNCTION fn_ton_kho_vacxin(
    p_MaVX INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_TonKho INT;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM VacXin
        WHERE MaVX = p_MaVX
    ) THEN
        RAISE EXCEPTION 'Vac xin voi MaVX % khong ton tai', p_MaVX;
    END IF;

    SELECT COALESCE(SUM(SoLuongTon), 0)
    INTO v_TonKho
    FROM LoVacXin
    WHERE MaVX = p_MaVX;

    RETURN v_TonKho;
END;
$$;
--Hàm kiểm tra kết luận khám sàng lọc
CREATE OR REPLACE FUNCTION fn_kiem_tra_du_dieu_kien_tiem(
    p_MaPK INT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_KetLuan KetLuanBSEnum;
BEGIN
    SELECT KLCuaBS
    INTO v_KetLuan
    FROM PhieuKhamSangLoc
    WHERE MaPK = p_MaPK;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Phieu kham sang loc voi MaPK % khong ton tai', p_MaPK;
    END IF;

    IF v_KetLuan::TEXT = 'DU_DIEU_KIEN' THEN
        RETURN 'Khach hang du dieu kien tiem chung';
    ELSIF v_KetLuan::TEXT = 'TAM_HOAN' THEN
        RETURN 'Khach hang tam hoan tiem chung';
    ELSE
        RETURN 'Khach hang chong chi dinh tiem chung';
    END IF;
END;
$$;
--Hàm tra cứu lịch sử tiêm chủng của khách hàng
CREATE OR REPLACE FUNCTION fn_lich_su_tiem_khach_hang(
    p_MaKH INT
)
RETURNS TABLE (
    MaLanTiem INT,
    NgayTiem DATE,
    MuiTiemThu INT,
    TenVaccine VARCHAR(100),
    MaLo INT,
    KetQua KetQuaTiemEnum,
    KetLuanBacSi KetLuanBSEnum,
    NhanVienTiem VARCHAR(100)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM KhachHang
        WHERE MaKH = p_MaKH
    ) THEN
        RAISE EXCEPTION 'Khach hang voi MaKH % khong ton tai', p_MaKH;
    END IF;

    RETURN QUERY
    SELECT
        lt.MaLT,
        lt.NgayTiem,
        ltlv.MuiTiemThu,
        vx.TenVX,
        lv.MaLo,
        lt.KetQua,
        pksl.KLCuaBS,
        nvcm.HoTen
    FROM LanTiem lt
    JOIN SoTiemChung stc ON lt.MaSo = stc.MaSo
    LEFT JOIN LANTIEM_LOVACXIN ltlv ON lt.MaLT = ltlv.MaLT
    LEFT JOIN LoVacXin lv ON ltlv.MaLo = lv.MaLo
    LEFT JOIN VacXin vx ON lv.MaVX = vx.MaVX
    LEFT JOIN PhieuKhamSangLoc pksl ON lt.MaPK = pksl.MaPK
    LEFT JOIN NhanVienChuyenMon nvcm ON lt.MaNV = nvcm.MaNV
    WHERE stc.MaKH = p_MaKH
    ORDER BY lt.NgayTiem, ltlv.MuiTiemThu;
END;
$$;
--Hàm liệt kê các lô vaccine sắp hết hạn
CREATE OR REPLACE FUNCTION fn_danh_sach_lo_sap_het_han(
    p_SoNgay INT DEFAULT 30
)
RETURNS TABLE (
    MaLo INT,
    TenVaccine VARCHAR(100),
    HanSuDung DATE,
    SoLuongTon INT,
    SoNgayConLai INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_SoNgay < 0 THEN
        RAISE EXCEPTION 'So ngay kiem tra phai lon hon hoac bang 0';
    END IF;

    RETURN QUERY
    SELECT
        lv.MaLo,
        vx.TenVX,
        lv.HSD,
        lv.SoLuongTon,
        (lv.HSD - CURRENT_DATE)::INT AS SoNgayConLai
    FROM LoVacXin lv
    JOIN VacXin vx ON lv.MaVX = vx.MaVX
    WHERE lv.HSD BETWEEN CURRENT_DATE AND CURRENT_DATE + p_SoNgay
    ORDER BY lv.HSD ASC;
END;
$$;

--Hàm thống kê số lần sử dụng từng loại vaccine
CREATE OR REPLACE FUNCTION fn_thong_ke_su_dung_vacxin(
    p_TuNgay DATE DEFAULT NULL,
    p_DenNgay DATE DEFAULT NULL
)
RETURNS TABLE (
    MaVX INT,
    TenVaccine VARCHAR(100),
    SoLanSuDung BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_TuNgay IS NOT NULL 
       AND p_DenNgay IS NOT NULL 
       AND p_TuNgay > p_DenNgay THEN
        RAISE EXCEPTION 'Ngay bat dau khong duoc lon hon ngay ket thuc';
    END IF;

    RETURN QUERY
    SELECT
        vx.MaVX,
        vx.TenVX,
        COUNT(*) AS SoLanSuDung
    FROM LANTIEM_LOVACXIN ltlv
    JOIN LoVacXin lv ON ltlv.MaLo = lv.MaLo
    JOIN VacXin vx ON lv.MaVX = vx.MaVX
    JOIN LanTiem lt ON ltlv.MaLT = lt.MaLT
    WHERE (p_TuNgay IS NULL OR lt.NgayTiem >= p_TuNgay)
      AND (p_DenNgay IS NULL OR lt.NgayTiem <= p_DenNgay)
    GROUP BY vx.MaVX, vx.TenVX
    ORDER BY SoLanSuDung DESC, vx.MaVX;
END;
$$;

-- ============================== Bổ sung ==============================
-- Hàm TraCuuLichSuTiem
CREATE OR REPLACE FUNCTION fn_tra_cuu_ls_tiem(
    p_makh INT
)
RETURNS TABLE (
    MaLT INT,
    NgayTiem DATE,
    KetQua KetQuaTiemEnum,
    TenVX VARCHAR(100),
    MuiTiemThu INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        lt.MaLT,
        lt.NgayTiem,
        lt.KetQua,
        vx.TenVX,
        ltlv.MuiTiemThu
    FROM SoTiemChung st
    JOIN LanTiem lt ON lt.Maso = st.Maso
    JOIN PhieuKhamSangLoc pk ON pk.MaPK = lt.MaPK
    JOIN LANTIEM_LOVACXIN ltlv ON ltlv.MaLT = lt.MaLT
    JOIN LoVacXin lvx ON lvx.MaLo = ltlv.MaLo
    JOIN VacXin vx ON vx.MaVX = lvx.MaVX
    WHERE st.MaKH = p_makh
    ORDER BY lt.NgayTiem;
END;
$$ LANGUAGE plpgsql;

-- Hàm TraCuuHoaDon
CREATE OR REPLACE FUNCTION fn_tra_cuu_hd(
    p_makh INT
)
RETURNS TABLE (
    MaHD INT,
    NgayLap DATE,
    HTThanhToan HinhThucThanhToan,
    TongTien NUMERIC(15,2)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        hd.MaHD,
        hd.NgayLap,
        hd.HTThanhToan,
        hd.TongTien
    FROM HoaDon hd
    WHERE hd.MaKH = p_makh
    ORDER BY hd.NgayLap DESC;
END;
$$ LANGUAGE plpgsql;


-- Hàm TraCuuThongTinNV
CREATE OR REPLACE FUNCTION fn_tra_cuu_thongtin_nv()
RETURNS TABLE (
    MaNV INT,
    HoTen VARCHAR(100),
    ChucDanh TEXT,
    SDT VARCHAR(10)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY

    SELECT
        nvhc.MaNV,
        nvhc.HoTen,
        nvhc.ChucDanh::TEXT,
        nvhc.SDT
    FROM NhanVienHanhChinh nvhc

    UNION ALL

    SELECT
        nvcm.MaNV,
        nvcm.HoTen,
        nvcm.ChucDanh::TEXT,
        nvcm.SDT
    FROM NhanVienChuyenMon nvcm;
END;
$$;

CREATE OR REPLACE FUNCTION fn_tra_cuu_sl_vacxin(
    p_TenVX VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE (
    MaVX INT,
    TenVX VARCHAR(100),
    HangSX VARCHAR(100),
    TongSoLuong BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        vx.MaVX,
        vx.TenVX,
        vx.HangSX,
        COALESCE(SUM(lvx.SoLuongTon), 0)::BIGINT
    FROM VacXin vx
    LEFT JOIN LoVacXin lvx
        ON lvx.MaVX = vx.MaVX
    WHERE p_TenVX IS NULL
       OR vx.TenVX ILIKE '%' || p_TenVX || '%'
    GROUP BY vx.MaVX, vx.TenVX, vx.HangSX
    ORDER BY COALESCE(SUM(lvx.SoLuongTon), 0) DESC;
END;
$$;

-- Hàm tra cứu thông tin nhà cung cấp
CREATE FUNCTION fn_nha_cung_cap(
    p_NoiSX VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE (
    NoiSX VARCHAR(100),
    SoLuongLo BIGINT,
    TongSoLuongTon BIGINT,
    SoLoConHan BIGINT,
    SoLoHetHan BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        lvx.NoiSX,
        COUNT(*)::BIGINT,
        COALESCE(SUM(lvx.SoLuongTon), 0)::BIGINT,
        COUNT(*) FILTER (
            WHERE lvx.HSD >= CURRENT_DATE
        )::BIGINT,
        COUNT(*) FILTER (
            WHERE lvx.HSD < CURRENT_DATE
        )::BIGINT
    FROM LoVacXin lvx
    WHERE
        p_NoiSX IS NULL
        OR lvx.NoiSX ILIKE '%' || p_NoiSX || '%'
    GROUP BY lvx.NoiSX
    ORDER BY COUNT(*) DESC, lvx.NoiSX;
END;
$$;


-- Hàm TraCuuDoanhThu
CREATE OR REPLACE FUNCTION fn_tra_cuu_doanh_thu()
RETURNS TABLE (
    Ngay DATE,
    DoanhThu NUMERIC(15,2)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        NgayLap,
        SUM(TongTien)
    FROM HoaDon
    GROUP BY NgayLap
    ORDER BY NgayLap;
END;
$$ LANGUAGE plpgsql;

-- Hàm TraCuuSoLuongHD
CREATE OR REPLACE FUNCTION fn_tra_cuu_sl_hd()
RETURNS TABLE (
    Ngay DATE,
    SoLuongHD BIGINT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        NgayLap,
        COUNT(*)
    FROM HoaDon
    GROUP BY NgayLap
    ORDER BY NgayLap;
END;
$$ LANGUAGE plpgsql;


--Hàm TraCuuLanTiem
CREATE OR REPLACE FUNCTION fn_tra_cuu_lan_tiem()
RETURNS TABLE (
    MaLT INT,
    NgayTiem DATE,
    KetQua KetQuaTiemEnum,
    HoTenKH VARCHAR(100)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        lt.MaLT,
        lt.NgayTiem,
        lt.KetQua,
        kh.HoTen
    FROM LanTiem lt
    JOIN PhieuKhamSangLoc pk ON pk.MaPK = lt.MaPK
    JOIN SoTiemChung st ON st.MaSo = lt.MaSo
    JOIN KhachHang kh ON kh.MaKH = st.MaKH
    ORDER BY lt.NgayTiem DESC;
END;
$$ LANGUAGE plpgsql;

-- Hàm tra cứu danh sách tất cả các lô vaccine trong hệ thống 
CREATE FUNCTION fn_tra_cuu_lo_vacxin(
    p_TenVX VARCHAR(100) DEFAULT NULL,
    p_ChiConTon BOOLEAN DEFAULT NULL,
    p_ChiConHan BOOLEAN DEFAULT NULL
)
RETURNS TABLE (
    MaLo INT,
    TenVX VARCHAR(100),
    NSX DATE,
    HSD DATE,
    SoLuongTon INT,
    NoiSX VARCHAR(100),
    SoNgayConLai INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        lvx.MaLo,
        vx.TenVX,
        lvx.NSX,
        lvx.HSD,
        lvx.SoLuongTon,
        lvx.NoiSX,
        (lvx.HSD - CURRENT_DATE)::INT
    FROM LoVacXin lvx
    JOIN VacXin vx ON vx.MaVX = lvx.MaVX
    WHERE
        (
            p_TenVX IS NULL
            OR vx.TenVX ILIKE '%' || p_TenVX || '%'
        )
        AND (
            p_ChiConTon IS NULL
            OR (p_ChiConTon = TRUE AND lvx.SoLuongTon > 0)
            OR (p_ChiConTon = FALSE)
        )
        AND (
            p_ChiConHan IS NULL
            OR (p_ChiConHan = TRUE AND lvx.HSD >= CURRENT_DATE)
            OR (p_ChiConHan = FALSE AND lvx.HSD < CURRENT_DATE)
        )
    ORDER BY lvx.HSD;
END;
$$;





