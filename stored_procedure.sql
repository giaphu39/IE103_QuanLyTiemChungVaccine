
-- Luu thông tin khách hàng
CREATE OR REPLACE PROCEDURE LuuThongTinKhachHang(
    IN p_NgaySinh DATE,
    IN p_GioiTinh BOOLEAN,
    IN p_HoTen VARCHAR(100),
    IN p_DiaChi TEXT,
    IN p_SDT VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO KhachHang(NgaySinh, GioiTinh, HoTen, DiaChi, SDT)
    VALUES (p_NgaySinh, p_GioiTinh, p_HoTen, p_DiaChi, p_SDT);
    RAISE NOTICE 'Luu thong tin khach hang thanh cong';
END;
$$;

--CALL ThemKhachHang('2006-05-10', true, 'Nguyen Van A', 'HCM', '0912345678');

-- Tạo tài khoản nhân viên hành chính
CREATE OR REPLACE PROCEDURE ThemNVHanhChinh(
    IN p_NgaySinh DATE,
    IN p_GioiTinh BOOLEAN,
    IN p_ChucDanh ChucDanhHC,
    IN p_HoTen VARCHAR(100),
    IN p_DiaChi TEXT,
    IN p_SDT VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO NhanVienHanhChinh(NgaySinh, GioiTinh, ChucDanh, HoTen, DiaChi, SDT)
    VALUES (p_NgaySinh, p_GioiTinh, p_ChucDanh, p_HoTen, p_DiaChi, p_SDT);
    RAISE NOTICE 'Tao tai khoan nhan vien hanh chinh thanh cong';
END;
$$;

--CALL ThemNVHanhChinh('1995-06-23', false, 'LE_TAN', 'Huynh Van B', 'HCM', '0123456789');


-- Tạo hóa đơn
CREATE OR REPLACE PROCEDURE TaoHoaDon(
    IN p_NgayLap DATE,
    IN p_HTThanhToan HinhThucThanhToan,
    IN p_TongTien NUMERIC(15,2),
    IN p_MaKH INT,
    IN p_MaNV INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_TongTien <= 0 THEN
        RAISE EXCEPTION 'TongTien phai lon hon 0';
    END IF;
	
	IF NOT EXISTS (
        SELECT 1 
        FROM KhachHang
        WHERE MaKH = p_MaKH
    ) THEN
        RAISE EXCEPTION 'Khach hang khong ton tai';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM NhanVienHanhChinh
        WHERE MaNV = p_MaNV
    ) THEN
        RAISE EXCEPTION 'Nhan vien khong ton tai';
    END IF;
	
    INSERT INTO HoaDon(NgayLap, HTThanhToan, TongTien, MaKH, MaNV)
    VALUES (p_NgayLap, p_HTThanhToan, p_TongTien, p_MaKH, p_MaNV);

	RAISE NOTICE 'Tao hoa don thanh cong';
END;
$$;

--CALL TaoHoaDon('2026-02-08', 'CHUYEN_KHOAN', 300000, 1, 1);

-- Tạo vaccine
CREATE OR REPLACE PROCEDURE TaoVacXin(
    IN p_TenVX VARCHAR(100),
    IN p_PhacDo INT,
    IN p_HangSX VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_TenVX IS NULL OR TRIM(p_TenVX) = '' THEN
        RAISE EXCEPTION 'Ten vaccine khong duoc de trong';
    END IF;

    IF p_PhacDo <= 0 THEN
        RAISE EXCEPTION 'Phac do phai > 0';
    END IF;

    IF p_HangSX IS NULL OR TRIM(p_HangSX) = '' THEN
        RAISE EXCEPTION 'Hang san xuat khong duoc de trong';
    END IF;

	IF EXISTS (
	    SELECT 1
	    FROM VacXin
	    WHERE TenVX = p_TenVX
	      AND HangSX = p_HangSX
	) THEN
	    RAISE EXCEPTION 'Vacxin da ton tai';
	END IF;

    INSERT INTO VacXin(TenVX,PhacDo,HangSX)
    VALUES (p_TenVX, p_PhacDo, p_HangSX);

    RAISE NOTICE 'Tao vaccine thanh cong';

END;
$$;



--CALL TaoVacXin('AstraZeneca', 2, 'Oxford');


-- Tạo lô vaccine
CREATE OR REPLACE PROCEDURE TaoLoVacXin(
    IN p_HSD DATE,
    IN p_NoiSX VARCHAR(100),
    IN p_NSX DATE,
    IN p_SoLuongTon INT,
    IN p_MaVX INT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_NSX > CURRENT_DATE THEN
        RAISE EXCEPTION 'Ngay san xuat khong duoc o tuong lai';
    END IF;

    IF p_HSD <= p_NSX THEN
        RAISE EXCEPTION 'Han su dung phai lon hon ngay san xuat';
    END IF;

    IF p_SoLuongTon < 0 THEN
        RAISE EXCEPTION 'So luong ton kho phai duong';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM VacXin
        WHERE MaVX = p_MaVX
    ) THEN
        RAISE EXCEPTION 'Ma vaccine khong ton tai';
    END IF;

	IF EXISTS (
		SELECT 1 
		FROM LoVacXin
		WHERE MaVX = p_MaVX AND NoiSX = p_NoiSX
	) THEN
        RAISE EXCEPTION 'Lo vaccine da ton tai';
    END IF;

    INSERT INTO LoVacXin(HSD, NoiSX, NSX, SoLuongTon, MaVX)
    VALUES (p_HSD, p_NoiSX, p_NSX, p_SoLuongTon, p_MaVX);

    RAISE NOTICE 'Tao lo vaccine thanh cong';

END;
$$;



--CALL TaoLoVacXin('2027-12-31', 'Viet Nam', '2026-01-01', 500, 1);

-- Tạo tài khoản nhân viên chuyên môn
CREATE OR REPLACE PROCEDURE ThemNVChuyenMon(
    IN p_NgaySinh DATE,
    IN p_GioiTinh BOOLEAN,
    IN p_ChucDanh ChucDanhCM,
    IN p_CCHanhNghe VARCHAR(100),
    IN p_HoTen VARCHAR(100),
    IN p_DiaChi TEXT,
    IN p_SDT VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO NhanVienChuyenMon(NgaySinh, GioiTinh, ChucDanh, CCHanhNghe, HoTen, DiaChi, SDT)
    VALUES (p_NgaySinh, p_GioiTinh, p_ChucDanh, p_CCHanhNghe, p_HoTen, p_DiaChi, p_SDT);
    RAISE NOTICE 'Tao tai khoan nhan vien chuyen mon thanh cong';
END;
$$;

--CALL ThemNVChuyenMon('1998-08-15', true, 'BAC_SI', 'CC123456', 'Le Quang Liem', 'Binh Duong', '0912945678');

-- Tạo sổ tiêm chủng
CREATE OR REPLACE PROCEDURE TaoSoTiemChung(
    IN p_NgayLapSo DATE,
    IN p_GhiChu TEXT,
    IN p_TrangThai TrangThaiSo,
    IN p_MaNV INT,
    IN p_MaKH INT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_NgayLapSo > CURRENT_DATE THEN
        RAISE EXCEPTION 'Ngay lap so khong hop le';
    END IF;

    IF p_TrangThai IS NULL THEN
        RAISE EXCEPTION 'Trang thai khong hop le';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM NhanVienHanhChinh
        WHERE MaNV = p_MaNV
    ) THEN
        RAISE EXCEPTION 'Nhan vien khong ton tai';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM KhachHang
        WHERE MaKH = p_MaKH
    ) THEN
        RAISE EXCEPTION 'Khach hang khong ton tai';
    END IF;

    -- Insert
    INSERT INTO SoTiemChung(NgayLapSo, GhiChu, TrangThai, MaNV, MaKH)
    VALUES (p_NgayLapSo, p_GhiChu, p_TrangThai, p_MaNV, p_MaKH);

    RAISE NOTICE 'Tao so tiem chung thanh cong';

END;
$$;

--CALL TaoSoTiemChung(CURRENT_DATE, 'Khach hang tiem mui 1', 'ACTIVE', 1, 1);

-- Tạo phiếu khám sàng lọc
CREATE OR REPLACE PROCEDURE TaoPhieuKhamSangLoc(
    IN p_NgayLap DATE,
    IN p_NhietDo NUMERIC(4,1),
    IN p_ChieuCao NUMERIC(5,2),
    IN p_CanNang NUMERIC(5,2),
    IN p_KLCuaBS TEXT,
    IN p_TSDiUng TEXT,
    IN p_MaNV INT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_NgayLap > CURRENT_DATE THEN
        RAISE EXCEPTION 'Ngay lap khong hop le';
    END IF;

    IF p_NhietDo < 30 OR p_NhietDo > 45 THEN
        RAISE EXCEPTION 'Nhiet do khong hop le';
    END IF;

    IF p_ChieuCao <= 0 THEN
        RAISE EXCEPTION 'Chieu cao phai > 0';
    END IF;

    IF p_CanNang <= 0 THEN
        RAISE EXCEPTION 'Can nang phai > 0';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM NhanVienChuyenMon
        WHERE MaNV = p_MaNV
    ) THEN
        RAISE EXCEPTION 'Nhan vien khong ton tai';
    END IF;

    INSERT INTO PhieuKhamSangLoc(NgayLap,NhietDo,ChieuCao,CanNang,KLCuaBS,TSDiUng,MaNV)
    VALUES (p_NgayLap,p_NhietDo,p_ChieuCao,p_CanNang,p_KLCuaBS,p_TSDiUng, p_MaNV);

    RAISE NOTICE 'Tao phieu kham sang loc thanh cong';

END;
$$;

--CALL TaoPhieuKhamSangLoc(CURRENT_DATE, 36.5, 170.5, 65.0, 'DU_DIEU_KIEN', 'Khong co', 1);

-- Tạo lần tiêm
CREATE OR REPLACE PROCEDURE TaoLanTiem(
    IN p_NgayTiem DATE,
    IN p_KetQua KetQuaTiemEnum,
    IN p_MaNV INT,
    IN p_MaSo INT,
    IN p_MaPK INT,
    IN p_MaHD INT -- Đã xóa dấu phẩy thừa ở đây
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF p_NgayTiem > CURRENT_DATE THEN
        RAISE EXCEPTION 'Ngay tiem khong hop le';
    END IF;

    IF p_KetQua IS NULL THEN
        RAISE EXCEPTION 'Ket qua tiem khong hop le';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM NhanVienChuyenMon WHERE MaNV = p_MaNV
    ) THEN
        RAISE EXCEPTION 'Nhan vien khong ton tai';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM SoTiemChung WHERE MaSo = p_MaSo
    ) THEN
        RAISE EXCEPTION 'So tiem chung khong ton tai';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM PhieuKhamSangLoc WHERE MaPK = p_MaPK
    ) THEN
        RAISE EXCEPTION 'Phieu kham khong ton tai';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM HoaDon WHERE MaHD = p_MaHD
    ) THEN
        RAISE EXCEPTION 'Hoa don khong ton tai';
    END IF;

    -- Đã bổ sung MaHD và p_MaHD vào câu lệnh INSERT
    INSERT INTO LanTiem(NgayTiem, KetQua, MaNV, MaSo, MaPK, MaHD)
    VALUES (p_NgayTiem, p_KetQua, p_MaNV, p_MaSo, p_MaPK, p_MaHD);

    RAISE NOTICE 'Tao lan tiem thanh cong';
END;
$$;

--CALL TaoLanTiem(CURRENT_DATE, 'BINH_THUONG', 1, 1, 1, 1);

-- Lưu thông tin người giám hộ 
CREATE OR REPLACE PROCEDURE LuuThongTinNguoiGiamHo(
    IN p_NgaySinh DATE,
    IN p_GioiTinh BOOLEAN,
	IN p_QHVoiNT QuanHeEnum,
    IN p_HoTen VARCHAR(100),
    IN p_DiaChi TEXT,
    IN p_SDT VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO NguoiGiamHo(NgaySinh, GioiTinh, QHVoiNT, HoTen, DiaChi, SDT)
    VALUES (p_NgaySinh, p_GioiTinh, p_QHVoiNT, p_HoTen, p_DiaChi, p_SDT);
    RAISE NOTICE 'Luu thong tin nguoi giam ho thanh cong';
END;
$$;

--CALL ThemNguoiGiamHo('1940-05-10', false, 'BA', 'Nguyen Van C', 'HCM', '0217945478');

-- Lưu tên bệnh phòng ngừa
CREATE  PROCEDURE LuuTenBenhPhongNgua(
    IN p_TenBPN VARCHAR(100),
    IN p_MucDoNguyHiem MucDoNguyHiemEnum
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_TenBPN IS NULL OR TRIM(p_TenBPN) = '' THEN
        RAISE EXCEPTION 'Ten benh phong ngua khong hop le';
    END IF;

    IF p_MucDoNguyHiem IS NULL THEN
        RAISE EXCEPTION 'Muc do nguy hiem khong hop le';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM BenhPhongNgua
        WHERE LOWER(TenBPN) = LOWER(p_TenBPN)
    ) THEN
        RAISE EXCEPTION 'Benh phong ngua da ton tai';
    END IF;

    INSERT INTO BenhPhongNgua(TenBPN,MucDoNguyHiem)
    VALUES (p_TenBPN,  p_MucDoNguyHiem);

    RAISE NOTICE 'Tao benh phong ngua thanh cong';

END;
$$;

--CALL TaoBenhPhongNgua('COVID-19', 'RAT_CAO');

-- Tạo chi tiết giám hộ
CREATE OR REPLACE PROCEDURE TaoChiTietGiamHo(
    IN p_MaNGH INT,
    IN p_MaKH INT,
    IN p_MoiQuanHe VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM NguoiGiamHo
        WHERE MaNGH = p_MaNGH
    ) THEN
        RAISE EXCEPTION 'Nguoi giam ho khong ton tai';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM KhachHang
        WHERE MaKH = p_MaKH
    ) THEN
        RAISE EXCEPTION 'Khach hang khong ton tai';
    END IF;

    IF p_MoiQuanHe IS NULL OR TRIM(p_MoiQuanHe) = '' THEN
        RAISE EXCEPTION 'Moi quan he khong hop le';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM CHITIET_GIAMHO
        WHERE MaNGH = p_MaNGH
        AND MaKH = p_MaKH
    ) THEN
        RAISE EXCEPTION 'Chi tiet giam ho da ton tai';
    END IF;

    INSERT INTO CHITIET_GIAMHO(MaNGH, MaKH, MoiQuanHe)
    VALUES (p_MaNGH, p_MaKH, p_MoiQuanHe);

    RAISE NOTICE 'Them chi tiet giam ho thanh cong';

END;
$$;

--CALL TaoChiTietGiamHo(1, 1,'Ba');

-- Tạo Vaccine_Bênh phòng ngừa
CREATE OR REPLACE PROCEDURE TaoVacXinBenhPhongNgua(
    IN p_MaVX INT,
    IN p_MaBPN INT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM VacXin
        WHERE MaVX = p_MaVX
    ) THEN
        RAISE EXCEPTION 'Vac xin khong ton tai';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM BenhPhongNgua
        WHERE MaBPN = p_MaBPN
    ) THEN
        RAISE EXCEPTION 'Benh phong ngua khong ton tai';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM VACXIN_BENHPHONGNGUA
        WHERE MaVX = p_MaVX
        AND MaBPN = p_MaBPN
    ) THEN
        RAISE EXCEPTION 'Lien ket da ton tai';
    END IF;

    INSERT INTO VACXIN_BENHPHONGNGUA(MaVX,MaBPN)
    VALUES (p_MaVX,p_MaBPN);

    RAISE NOTICE 'Them lien ket vac xin - benh thanh cong';

END;
$$;

--CALL TaoVacXinBenhPhongNgua(1,1);


-- Tạo LanTiem_LoVaccine
CREATE OR REPLACE PROCEDURE TaoLanTiemLoVacXin(
    IN p_MaLT INT,
    IN p_MaLo INT,
    IN p_MuiTiemThu INT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM LanTiem
        WHERE MaLT = p_MaLT
    ) THEN
        RAISE EXCEPTION 'Lan tiem khong ton tai';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM LoVacXin
        WHERE MaLo = p_MaLo
    ) THEN
        RAISE EXCEPTION 'Lo vac xin khong ton tai';
    END IF;

    IF p_MuiTiemThu <= 0 THEN
        RAISE EXCEPTION 'Mui tiem thu khong hop le';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM LANTIEM_LOVACXIN
        WHERE MaLT = p_MaLT
        AND MaLo = p_MaLo
    ) THEN
        RAISE EXCEPTION 'Lien ket lan tiem - lo vac xin da ton tai';
    END IF;

	INSERT INTO LANTIEM_LOVACXIN(MaLT,MaLo,MuiTiemThu)
    VALUES (p_MaLT,p_MaLo, p_MuiTiemThu);

    RAISE NOTICE 'Them lan tiem - lo vac xin thanh cong';

END;
$$;

--CALL TaoLanTiemLoVacXin(1, 1, 1);

-- Cập nhật chứng chỉ hoặc chức danh của nhân viên chuyên môn
CREATE OR REPLACE PROCEDURE CapNhatNVChuyenMon(
    IN p_MaNV INT,
    IN p_ChucDanh ChucDanhCM,
    IN p_CCHanhNghe VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM NhanVienChuyenMon
        WHERE MaNV = p_MaNV
    ) THEN
        RAISE EXCEPTION 'Nhan vien khong ton tai';
    END IF;

    IF p_CCHanhNghe IS NULL OR TRIM(p_CCHanhNghe) = '' THEN
        RAISE EXCEPTION 'Chung chi hanh nghe khong hop le';
    END IF;

	IF p_ChucDanh IS NULL THEN
        RAISE EXCEPTION 'Chuc danh khong hop le';
    END IF;

    UPDATE NhanVienChuyenMon
    SET
        ChucDanh = p_ChucDanh,
        CCHanhNghe = p_CCHanhNghe
    WHERE MaNV = p_MaNV;

    RAISE NOTICE 'Cap nhat nhan vien chuyen mon thanh cong';

END;
$$;

--CALL CapNhatNVChuyenMon(1, 'DIEU_DUONG', 'CC9999569');

-- Cập nhật trạng thái hồ sơ tiêm chủng
CREATE OR REPLACE PROCEDURE CapNhatTTHoSo(
    IN p_MaSo INT,
    IN p_TrangThaiSo TrangThaiSo,
    IN p_MaNV INT,
    IN p_MaKH INT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM SoTiemChung
        WHERE MaSo = p_MaSo
    ) THEN
        RAISE EXCEPTION 'Ho so khong ton tai';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM KhachHang
        WHERE MaKH = p_MaKH
    ) THEN
        RAISE EXCEPTION 'Khach hang khong ton tai';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM NhanVienHanhChinh
        WHERE MaNV = p_MaNV
    ) THEN
        RAISE EXCEPTION 'Nhan vien khong ton tai';
    END IF;

    IF p_TrangThaiSo IS NULL THEN
        RAISE EXCEPTION 'Trang thai so khong hop le';
    END IF;

    UPDATE SoTiemChung
    SET
        TrangThai = p_TrangThaiSo,
        MaNV = p_MaNV,
        MaKH = p_MaKH
    WHERE MaSo = p_MaSo;

    RAISE NOTICE 'Cap nhat so tiem chung thanh cong';

END;
$$;

--CALL CapNhatTTHoSo(1, 'COMPLETED', 1, 1);

-- Cập nhật mức độ nguy hiểm bệnh
CREATE OR REPLACE PROCEDURE CapNhatMucDoNguyHiemBenh(
    IN p_MaBPN INT,
    IN p_MucDoNguyHiem MucDoNguyHiemEnum
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM BenhPhongNgua
        WHERE MaBPN = p_MaBPN
    ) THEN
        RAISE EXCEPTION 'Benh khong ton tai';
    END IF;

    IF p_MucDoNguyHiem IS NULL THEN
        RAISE EXCEPTION 'Muc do nguy hiem nghe khong hop le';
    END IF;

    UPDATE BenhPhongNgua
    SET
         MucDoNguyHiem =  p_MucDoNguyHiem
    WHERE MaBPN = p_MaBPN;

    RAISE NOTICE 'Cap nhat muc do nguy hiem cua benh thanh cong';

END;
$$;



--CALL CapNhatMucDoNguyHiemBenh(1, 'RAT_CAO');

--Cập nhật thông tin khách hàng
CREATE OR REPLACE PROCEDURE CapNhatKhachHang(
    IN p_MaKH INT,
    IN p_HoTen VARCHAR(100),
    IN p_NgaySinh DATE,
    IN p_GioiTinh BOOLEAN,
    IN p_DiaChi TEXT,
    IN p_SDT VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM KhachHang
        WHERE MaKH = p_MaKH
    ) THEN
        RAISE EXCEPTION 'Khach hang khong ton tai';
    END IF;

    IF p_HoTen IS NULL OR TRIM(p_HoTen) = '' THEN
        RAISE EXCEPTION 'Ho ten khong hop le';
    END IF;

    IF p_NgaySinh IS NULL OR p_NgaySinh > CURRENT_DATE THEN
        RAISE EXCEPTION 'Ngay sinh khong hop le';
    END IF;

    IF p_GioiTinh IS NULL THEN
        RAISE EXCEPTION 'Gioi tinh khong hop le';
    END IF;

    IF p_SDT IS NULL OR LENGTH(TRIM(p_SDT)) <> 10 THEN
        RAISE EXCEPTION 'So dien thoai khong hop le';
    END IF;

    UPDATE KhachHang
    SET
        HoTen = p_HoTen,
        NgaySinh = p_NgaySinh,
        GioiTinh = p_GioiTinh,
        DiaChi = p_DiaChi,
        SDT = p_SDT
    WHERE MaKH = p_MaKH;

    RAISE NOTICE 'Cap nhat khach hang thanh cong';

END;
$$;

--Cập nhật sổ tiêm
CREATE OR REPLACE PROCEDURE CapNhatSoTiem(
    IN p_MaSo INT,
    IN p_GhiChu TEXT,
    IN p_TrangThai TrangThaiSo
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM SoTiemChung
        WHERE MaSo = p_MaSo
    ) THEN
        RAISE EXCEPTION 'So tiem chung khong ton tai';
    END IF;

    IF p_TrangThai IS NULL THEN
        RAISE EXCEPTION 'Trang thai so khong hop le';
    END IF;

    UPDATE SoTiemChung
    SET
        GhiChu = p_GhiChu,
        TrangThai = p_TrangThai
    WHERE MaSo = p_MaSo;

    RAISE NOTICE 'Cap nhat so tiem chung thanh cong';

END;
$$;

--Cập nhật thanh toán hóa đơn
CREATE OR REPLACE PROCEDURE CapNhatThanhToanHoaDon(
    IN p_MaHD INT,
    IN p_HTTT HinhThucThanhToan,
    IN p_TongTien NUMERIC(15,2)
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM HoaDon
        WHERE MaHD = p_MaHD
    ) THEN
        RAISE EXCEPTION 'Hoa don khong ton tai';
    END IF;

    IF p_HTTT IS NULL THEN
        RAISE EXCEPTION 'Hinh thuc thanh toan khong hop le';
    END IF;

    IF p_TongTien IS NULL OR p_TongTien < 0 THEN
        RAISE EXCEPTION 'Tong tien khong hop le';
    END IF;

    UPDATE HoaDon
    SET
        HTThanhToan = p_HTTT,
        TongTien = p_TongTien
    WHERE MaHD = p_MaHD;

    RAISE NOTICE 'Cap nhat thanh toan hoa don thanh cong';

END;
$$;

--Cập nhật kết luận của bác sĩ
CREATE OR REPLACE PROCEDURE CapNhatKetLuanBacSi(
    IN p_MaPK INT,
    IN p_KetLuan KetLuanBSEnum
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM PhieuKhamSangLoc
        WHERE MaPK = p_MaPK
    ) THEN
        RAISE EXCEPTION 'Phieu kham khong ton tai';
    END IF;

    IF p_KetLuan IS NULL THEN
        RAISE EXCEPTION 'Ket luan cua bac si khong hop le';
    END IF;

    UPDATE PhieuKhamSangLoc
    SET
        KLCuaBS = p_KetLuan
    WHERE MaPK = p_MaPK;

    RAISE NOTICE 'Cap nhat ket luan bac si thanh cong';

END;
$$;

--Cập nhật kết quả lần tiêm
CREATE OR REPLACE PROCEDURE CapNhatKetQuaLanTiem(
    IN p_MaLT INT,
    IN p_KetQua KetQuaTiemEnum
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM LanTiem
        WHERE MaLT = p_MaLT
    ) THEN
        RAISE EXCEPTION 'Lan tiem khong ton tai';
    END IF;

    IF p_KetQua IS NULL THEN
        RAISE EXCEPTION 'Ket qua tiem khong hop le';
    END IF;

    UPDATE LanTiem
    SET
        KetQua = p_KetQua
    WHERE MaLT = p_MaLT;

    RAISE NOTICE 'Cap nhat ket qua lan tiem thanh cong';

END;
$$;

--Cập nhật hạn sử dụng của vaccine
CREATE OR REPLACE PROCEDURE CapNhatHSDLoVacXin(
    IN p_MaLo INT,
    IN p_HSD DATE
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM LoVacXin
        WHERE MaLo = p_MaLo
    ) THEN
        RAISE EXCEPTION 'Lo vaccine khong ton tai';
    END IF;

    IF p_HSD IS NULL OR p_HSD < CURRENT_DATE THEN
        RAISE EXCEPTION 'Han su dung khong hop le';
    END IF;

    UPDATE LoVacXin
    SET
        HSD = p_HSD
    WHERE MaLo = p_MaLo;

    RAISE NOTICE 'Cap nhat han su dung lo vaccine thanh cong';

END;
$$;


