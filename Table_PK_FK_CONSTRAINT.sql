-- ENUM: Trạng thái sổ tiêm chủng
CREATE TYPE TrangThaiSo AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'COMPLETED'
);

-- ENUM: Hình thức thanh toán
CREATE TYPE HinhThucThanhToan AS ENUM (
    'TIEN_MAT',
    'CHUYEN_KHOAN',
    'THE',
    'VI_DIEN_TU'
);

-- ENUM: Mức độ nguy hiểm bệnh
CREATE TYPE MucDoNguyHiemEnum AS ENUM (
    'THAP',
    'TRUNG_BINH',
    'CAO',
    'RAT_CAO'
);

-- ENUM: Quan hệ với người tiêm
CREATE TYPE QuanHeEnum AS ENUM (
    'CHA',
    'ME',
    'ONG',
    'BA',
    'KHAC'
);

-- ENUM: Kết quả tiêm
CREATE TYPE KetQuaTiemEnum AS ENUM (
    'BINH_THUONG',
    'PHAN_UNG_NHE',
    'SOT_CAO',
    'SOC_PHAN_VE',
	'CHUA_TIEM'
);

-- ENUM: Kết luận của bác sĩ
CREATE TYPE KetLuanBSEnum AS ENUM (
    'DU_DIEU_KIEN',
    'TAM_HOAN',
    'CHONG_CHI_DINH'
);

-- ENUM: Chức danh nhân viên hành chính
CREATE TYPE ChucDanhHC AS ENUM (
   'LE_TAN',
   'THU_NGAN',
   'QUAN_LY'
);

-- ENUM: Chức danh nhân viên chuyên môn
CREATE TYPE ChucDanhCM AS ENUM (
    'BAC_SI',
    'DIEU_DUONG',
    'KY_THUAT_VIEN'
);

CREATE TABLE NguoiGiamHo (
    MaNGH INT GENERATED ALWAYS AS IDENTITY,
    NgaySinh DATE,
    GioiTinh BOOLEAN,
    QHVoiNT QuanHeEnum,
    HoTen VARCHAR(100),
    DiaChi TEXT,
    SDT VARCHAR(10)
);

CREATE TABLE KhachHang (
    MaKH INT GENERATED ALWAYS AS IDENTITY,
    NgaySinh DATE,
    GioiTinh BOOLEAN,
    HoTen VARCHAR(100),
    DiaChi TEXT,
    SDT VARCHAR(10)
);

CREATE TABLE SoTiemChung (
    MaSo INT GENERATED ALWAYS AS IDENTITY,
    NgayLapSo DATE,
    GhiChu TEXT,
    TrangThai TrangThaiSo,
    MaNV INT,
    MaKH INT
);

CREATE TABLE HoaDon (
    MaHD INT GENERATED ALWAYS AS IDENTITY,
    NgayLap DATE,
    HTThanhToan HinhThucThanhToan,
    TongTien NUMERIC(15,2),
    MaKH INT,
    MaNV INT
);

CREATE TABLE NhanVienHanhChinh (
    MaNV INT GENERATED ALWAYS AS IDENTITY,
    NgaySinh DATE,
    GioiTinh BOOLEAN,
    ChucDanh ChucDanhHC,
    HoTen VARCHAR(100),
    DiaChi TEXT,
    SDT VARCHAR(10)
);

CREATE TABLE VacXin (
    MaVX INT GENERATED ALWAYS AS IDENTITY,
    TenVX VARCHAR(100),
    PhacDo INT,
    HangSX VARCHAR(100)
);

CREATE TABLE BenhPhongNgua (
    MaBPN INT GENERATED ALWAYS AS IDENTITY,
    TenBPN VARCHAR(100),
    MucDoNguyHiem MucDoNguyHiemEnum
);

CREATE TABLE LoVacXin (
    MaLo INT GENERATED ALWAYS AS IDENTITY,
    HSD DATE,
    NoiSX VARCHAR(100),
    NSX DATE,
    SoLuongTon INT,
    MaVX INT	
);

CREATE TABLE LanTiem (
    MaLT INT GENERATED ALWAYS AS IDENTITY,
    NgayTiem DATE,
    KetQua KetQuaTiemEnum,
    MaNV INT,
    MaSo INT,
    MaPK INT,
    MaHD INT
);

CREATE TABLE PhieuKhamSangLoc (
    MaPK INT GENERATED ALWAYS AS IDENTITY,
    NgayLap DATE,
    NhietDo NUMERIC(4,1),
    ChieuCao NUMERIC(5,2),
    CanNang NUMERIC(5,2),
    KLCuaBS KetLuanBSEnum,
    TSDiUng TEXT,
    MaNV INT
);

CREATE TABLE NhanVienChuyenMon (
    MaNV INT GENERATED ALWAYS AS IDENTITY,
    NgaySinh DATE,
    GioiTinh BOOLEAN,
    ChucDanh ChucDanhCM,
    CCHanhNghe VARCHAR(100),
    HoTen VARCHAR(100),
    DiaChi TEXT,
    SDT VARCHAR(10)
);

CREATE TABLE  CHITIET_GIAMHO (
    MaNGH INT, 
    MaKH INT,
    MoiQuanHe VARCHAR(20)
);

CREATE TABLE VACXIN_BENHPHONGNGUA (
    MaVX INT, 
    MaBPN INT
);

CREATE TABLE LANTIEM_LOVACXIN (
    MaLT INT, 
    MaLo INT,
    MuiTiemThu INT
);

-- Định nghĩa khóa chính

ALTER TABLE NguoiGiamHo
ADD CONSTRAINT PK_NguoiGiamHo
PRIMARY KEY (MaNGH)  ;

ALTER TABLE KhachHang
ADD CONSTRAINT PK_KhachHang
PRIMARY KEY (MaKH);

ALTER TABLE SoTiemChung
ADD CONSTRAINT PK_SoTiemChung
PRIMARY KEY (MaSo);

ALTER TABLE HoaDon
ADD CONSTRAINT PK_HoaDon
PRIMARY KEY (MaHD);

ALTER TABLE NhanVienHanhChinh
ADD CONSTRAINT PK_NhanVienHanhChinh
PRIMARY KEY (MaNV);

ALTER TABLE VacXin
ADD CONSTRAINT PK_VacXin
PRIMARY KEY (MaVX);

ALTER TABLE BenhPhongNgua
ADD CONSTRAINT PK_BenhPhongNgua
PRIMARY KEY (MaBPN);

ALTER TABLE LoVacXin
ADD CONSTRAINT PK_LoVacXin
PRIMARY KEY (MaLo);

ALTER TABLE LanTiem
ADD CONSTRAINT PK_LanTiem
PRIMARY KEY (MaLT);

ALTER TABLE PhieuKhamSangLoc
ADD CONSTRAINT PK_PhieuKhamSangLoc
PRIMARY KEY (MaPK);

ALTER TABLE NhanVienChuyenMon
ADD CONSTRAINT PK_NhanVienChuyenMon
PRIMARY KEY (MaNV);

ALTER TABLE CHITIET_GIAMHO
ADD CONSTRAINT PK_CHITIET_GIAMHO
PRIMARY KEY (MaNGH, MaKH);

ALTER TABLE VACXIN_BENHPHONGNGUA
ADD CONSTRAINT PK_VACXIN_BENHPHONGNGUA
PRIMARY KEY (MaVX, MaBPN);

ALTER TABLE LANTIEM_LOVACXIN
ADD CONSTRAINT PK_LANTIEM_LOVACXIN
PRIMARY KEY (MaLT, MaLo);


-- KHÓA NGOẠI CHITIET_GIAMHO
ALTER TABLE CHITIET_GIAMHO
ADD CONSTRAINT fk_chitiet_giamho_nguoigiamho
FOREIGN KEY (MaNGH) REFERENCES NguoiGiamHo(MaNGH);

ALTER TABLE CHITIET_GIAMHO
ADD CONSTRAINT fk_chitiet_giamho_khachhang
FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH);

-- KHÓA NGOẠI SOTIEMCHUNG
ALTER TABLE SoTiemChung
ADD CONSTRAINT fk_sotiemchung_khachhang
FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH);

ALTER TABLE SoTiemChung
ADD CONSTRAINT fk_sotiemchung_nhanvienhc
FOREIGN KEY (MaNV) REFERENCES NhanVienHanhChinh(MaNV);

-- KHÓA NGOẠI HOADON
ALTER TABLE HoaDon
ADD CONSTRAINT fk_hoadon_khachhang
FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH);

ALTER TABLE HoaDon
ADD CONSTRAINT fk_hoadon_nhanvienhc
FOREIGN KEY (MaNV) REFERENCES NhanVienHanhChinh(MaNV);

-- KHÓA NGOẠI PHIEUKHAMSANGLOC
ALTER TABLE PhieuKhamSangLoc
ADD CONSTRAINT fk_phieukhamsangloc_nhanviencm
FOREIGN KEY (MaNV)
REFERENCES NhanVienChuyenMon(MaNV);

-- KHÓA NGOẠI LANTIEM
ALTER TABLE LanTiem
ADD CONSTRAINT fk_lantiem_nhanviencm
FOREIGN KEY (MaNV) REFERENCES NhanVienChuyenMon(MaNV);

ALTER TABLE LanTiem
ADD CONSTRAINT fk_lantiem_sotiemchung
FOREIGN KEY (MaSo) REFERENCES SoTiemChung(MaSo);

ALTER TABLE LanTiem
ADD CONSTRAINT fk_lantiem_phieukhamsangloc
FOREIGN KEY (MaPK) REFERENCES PhieuKhamSangLoc(MaPK);

ALTER TABLE LanTiem 
ADD CONSTRAINT fk_lantiem_hoadon 
FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD); 

-- KHÓA NGOẠI LOVACXIN
ALTER TABLE LoVacXin
ADD CONSTRAINT fk_lovacxin_vacxin
FOREIGN KEY (MaVX) REFERENCES VacXin(MaVX);
-- KHÓA NGOẠI LANTIEM_LOVACXIN
ALTER TABLE LANTIEM_LOVACXIN
ADD CONSTRAINT fk_lantiem_lovacxin_lantiem
FOREIGN KEY (MaLT) REFERENCES LanTiem(MaLT);

ALTER TABLE LANTIEM_LOVACXIN
ADD CONSTRAINT fk_lantiem_lovacxin_lovacxin
FOREIGN KEY (MaLo) REFERENCES LoVacXin(MaLo);

-- KHÓA NGOẠI VACXIN_BENHPHONGNGUA
ALTER TABLE VACXIN_BENHPHONGNGUA
ADD CONSTRAINT fk_vacxin_benhphongngua_vacxin
FOREIGN KEY (MaVX)
REFERENCES VacXin(MaVX);

ALTER TABLE VACXIN_BENHPHONGNGUA
ADD CONSTRAINT fk_vacxin_benhphongngua_benhphongngua
FOREIGN KEY (MaBPN)
REFERENCES BenhPhongNgua(MaBPN);

-- RÀNG BUỘC THUỘC TÍNH 
-- BẢNG KHÁCH HÀNG
ALTER TABLE KhachHang
ADD CONSTRAINT CHK_KH_NgaySinh CHECK (NgaySinh <= CURRENT_DATE),
ADD CONSTRAINT CHK_KH_SDT CHECK (SDT ~ '^[0-9]{10}$'); -- Kiểm tra chính xác 10 ký tự số

-- BẢNG NGƯỜI GIÁM HỘ
ALTER TABLE NguoiGiamHo
ADD CONSTRAINT CHK_NGH_NgaySinh CHECK (NgaySinh <= CURRENT_DATE),
ADD CONSTRAINT CHK_NGH_Tuoi CHECK (EXTRACT(YEAR FROM AGE(CURRENT_DATE, NgaySinh)) >= 18),
ADD CONSTRAINT CHK_NGH_SDT CHECK (SDT ~ '^[0-9]{10}$');

-- BẢNG NHÂN VIÊN HÀNH CHÍNH
ALTER TABLE NhanVienHanhChinh
ADD CONSTRAINT CHK_NVHC_Tuoi CHECK (EXTRACT(YEAR FROM AGE(CURRENT_DATE, NgaySinh)) >= 18),
ADD CONSTRAINT CHK_NVHC_SDT CHECK (SDT ~ '^[0-9]{10}$');

-- BẢNG NHÂN VIÊN CHUYÊN MÔN
ALTER TABLE NhanVienChuyenMon
ADD CONSTRAINT CHK_NVCM_Tuoi CHECK (EXTRACT(YEAR FROM AGE(CURRENT_DATE, NgaySinh)) >= 18),
ADD CONSTRAINT CHK_NVCM_SDT CHECK (SDT ~ '^[0-9]{10}$');

-- BẢNG SỔ TIÊM CHỦNG
ALTER TABLE SoTiemChung
ADD CONSTRAINT CHK_STC_NgayLapSo CHECK (NgayLapSo <= CURRENT_DATE);

-- BẢNG PHIẾU KHÁM SÀNG LỌC
ALTER TABLE PhieuKhamSangLoc
ADD CONSTRAINT CHK_PKSL_NgayLap CHECK (NgayLap <= CURRENT_DATE),
ADD CONSTRAINT CHK_PKSL_NhietDo CHECK (NhietDo >= 34.0 AND NhietDo <= 42.0),
ADD CONSTRAINT CHK_PKSL_ChieuCao CHECK (ChieuCao > 0),
ADD CONSTRAINT CHK_PKSL_CanNang CHECK (CanNang > 0);

-- BẢNG LẦN TIÊM
ALTER TABLE LanTiem
ADD CONSTRAINT CHK_LT_NgayTiem CHECK (NgayTiem <= CURRENT_DATE);

-- BẢNG VẮC XIN
ALTER TABLE VacXin
ADD CONSTRAINT CHK_VX_PhacDo CHECK (PhacDo > 0);

-- BẢNG LÔ VẮC XIN
ALTER TABLE LoVacXin
ADD CONSTRAINT CHK_LOVACXIN_NSX CHECK (NSX <= CURRENT_DATE),
ADD CONSTRAINT CHK_LOVACXIN_SoLuong CHECK (SoLuongTon >= 0);

-- BẢNG HÓA ĐƠN
ALTER TABLE HoaDon
ADD CONSTRAINT CHK_HD_NgayLap CHECK (NgayLap <= CURRENT_DATE),
ADD CONSTRAINT CHK_HD_TongTien CHECK (TongTien >= 0);

-- RÀNG BUỘC LIÊN THUỘC TÍNH 
ALTER TABLE LoVacXin
ADD CONSTRAINT CHK_LOVACXIN_HSD_NSX CHECK (HSD > NSX);



-- TRIGGER
-- Kiểm tra trên bảng KhachHang (Dùng DEFERRABLE để kiểm tra ở cuối Transaction)
CREATE OR REPLACE FUNCTION func_chk_khachhang_giamho()
RETURNS TRIGGER AS $$
BEGIN
    IF (EXTRACT(YEAR FROM AGE(CURRENT_DATE, NEW.NgaySinh)) < 18) THEN
        IF NOT EXISTS (SELECT 1 FROM CHITIET_GIAMHO WHERE MaKH = NEW.MaKH) THEN
            RAISE EXCEPTION 'Khách hàng dưới 18 tuổi (Mã KH: %) bắt buộc phải có ít nhất 1 người giám hộ.', NEW.MaKH;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_chk_khachhang_giamho
AFTER INSERT OR UPDATE OF NgaySinh ON KhachHang
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION func_chk_khachhang_giamho();

-- 1.2 Kiểm tra khi Xóa liên kết trong CHITIET_GIAMHO
CREATE OR REPLACE FUNCTION func_chk_delete_chitiet_giamho()
RETURNS TRIGGER AS $$
DECLARE
    v_tuoi INT;
    v_so_luong_gh INT;
BEGIN
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, NgaySinh)) INTO v_tuoi 
    FROM KhachHang WHERE MaKH = OLD.MaKH;
    
    IF (v_tuoi < 18) THEN
        SELECT COUNT(*) INTO v_so_luong_gh FROM CHITIET_GIAMHO WHERE MaKH = OLD.MaKH;
        IF (v_so_luong_gh <= 1) THEN
            RAISE EXCEPTION 'Lỗi: Không thể xóa người giám hộ cuối cùng của Khách hàng dưới 18 tuổi.';
        END IF;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_delete_update_chitiet_giamho
BEFORE DELETE OR UPDATE OF MaKH ON CHITIET_GIAMHO
FOR EACH ROW EXECUTE FUNCTION func_chk_delete_chitiet_giamho();

-- LANTIEM
CREATE OR REPLACE FUNCTION func_chk_lantiem_ins_upd()
RETURNS TRIGGER AS $$
DECLARE
    v_NgayLapSo DATE;
    v_MaKH_So INT;
    v_NgayLapPK DATE;
    v_KLCuaBS KetLuanBSEnum;
    v_NgayLapHD DATE;
    v_MaKH_HD INT;
BEGIN
    -- [Quy tắc 2 & 9]: Lấy thông tin Sổ tiêm chủng
    SELECT NgayLapSo, MaKH INTO v_NgayLapSo, v_MaKH_So 
    FROM SoTiemChung WHERE MaSo = NEW.MaSo;

    IF (NEW.NgayTiem < v_NgayLapSo) THEN
        RAISE EXCEPTION 'Lỗi (QT2): Ngày tiêm (%) không được diễn ra trước ngày lập sổ (%).', NEW.NgayTiem, v_NgayLapSo;
    END IF;

	-- [Quy tắc 3 & 4]: Lấy thông tin Phiếu khám sàng lọc
    IF NEW.MaPK IS NOT NULL THEN
        SELECT NgayLap, KLCuaBS INTO v_NgayLapPK, v_KLCuaBS 
        FROM PhieuKhamSangLoc WHERE MaPK = NEW.MaPK;
        
        IF (NEW.NgayTiem < v_NgayLapPK) THEN
            RAISE EXCEPTION 'Lỗi (QT3): Ngày tiêm không được trước ngày lập phiếu khám sàng lọc.';
        END IF;
        
        -- Ràng buộc điều kiện y tế: Tạm hoãn / Chống chỉ định thì KetQua phải là CHUA_TIEM
        IF v_KLCuaBS IN ('TAM_HOAN', 'CHONG_CHI_DINH') AND NEW.KetQua != 'CHUA_TIEM' THEN
            RAISE EXCEPTION 'Lỗi: Khách hàng có kết luận khám là % nên kết quả lần tiêm bắt buộc phải là CHUA_TIEM.', v_KLCuaBS;
        END IF;

        -- Ràng buộc: Nếu Đủ điều kiện tiêm thì KetQua chỉ được nhận các trạng thái phản ứng
        IF v_KLCuaBS = 'DU_DIEU_KIEN' AND NEW.KetQua NOT IN ('BINH_THUONG', 'PHAN_UNG_NHE', 'SOT_CAO', 'SOC_PHAN_VE') THEN
            RAISE EXCEPTION 'Lỗi: Khách hàng đủ điều kiện tiêm chủng, kết quả tiêm không hợp lệ (Phải là BINH_THUONG, PHAN_UNG_NHE, SOT_CAO hoặc SOC_PHAN_VE).';
        END IF;
    END IF;

    -- [Quy tắc 6 & 9]: Lấy thông tin Hóa đơn
    IF NEW.MaHD IS NOT NULL THEN
        SELECT NgayLap, MaKH INTO v_NgayLapHD, v_MaKH_HD 
        FROM HoaDon WHERE MaHD = NEW.MaHD;
        
        IF (v_NgayLapHD > NEW.NgayTiem) THEN
            RAISE EXCEPTION 'Lỗi (QT6): Ngày lập hóa đơn phải trước hoặc trong ngày tiêm.';
        END IF;
        
        IF (v_MaKH_So != v_MaKH_HD) THEN
            RAISE EXCEPTION 'Lỗi (QT9): Hóa đơn và Sổ tiêm chủng không thuộc về cùng một khách hàng.';
        END IF;
    END IF;

    -- [Quy tắc 7]: Ràng buộc HSD (Trường hợp Update NgayTiem của Lần tiêm)
    IF TG_OP = 'UPDATE' AND NEW.NgayTiem != OLD.NgayTiem THEN
        IF EXISTS (
            SELECT 1 FROM LANTIEM_LOVACXIN ltlv 
            JOIN LoVacXin lv ON ltlv.MaLo = lv.MaLo
            WHERE ltlv.MaLT = NEW.MaLT AND NEW.NgayTiem > lv.HSD
        ) THEN
            RAISE EXCEPTION 'Lỗi (QT7): Ngày tiêm mới vượt quá Hạn sử dụng của lô vaccine đang được trích xuất.';
        END IF;
    END IF;

    -- [Quy tắc 10]: Đổi Sổ (Trường hợp Update MaSo)
    IF TG_OP = 'UPDATE' AND NEW.MaSo != OLD.MaSo THEN
        IF EXISTS (
            SELECT 1 FROM LANTIEM_LOVACXIN ltlv1
            JOIN LoVacXin lv1 ON ltlv1.MaLo = lv1.MaLo
            JOIN LANTIEM_LOVACXIN ltlv2 ON ltlv1.MuiTiemThu = ltlv2.MuiTiemThu
            JOIN LanTiem lt2 ON ltlv2.MaLT = lt2.MaLT
            JOIN LoVacXin lv2 ON ltlv2.MaLo = lv2.MaLo
            WHERE ltlv1.MaLT = NEW.MaLT 
              AND lt2.MaSo = NEW.MaSo 
              AND lv1.MaVX = lv2.MaVX 
              AND ltlv1.MaLT != ltlv2.MaLT
        ) THEN
            RAISE EXCEPTION 'Lỗi (QT10): Việc chuyển đổi sổ gây trùng lặp mũi tiêm trong sổ mới.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_chk_lantiem_ins_upd
BEFORE INSERT OR UPDATE ON LanTiem
FOR EACH ROW EXECUTE FUNCTION func_chk_lantiem_ins_upd();

-- [Quy tắc 6]: Ngăn chặn Xóa Lần Tiêm đã có Hóa đơn
CREATE OR REPLACE FUNCTION func_prevent_delete_lantiem()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.MaHD IS NOT NULL THEN
        RAISE EXCEPTION 'Lỗi (QT6): Không thể xóa lần tiêm đã liên kết với hóa đơn (Mã HD: %). Vui lòng cập nhật trạng thái kết quả thay vì xóa.', OLD.MaHD;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_delete_lantiem
BEFORE DELETE ON LanTiem
FOR EACH ROW EXECUTE FUNCTION func_prevent_delete_lantiem();

--LANTIEM_LOVACXIN
CREATE OR REPLACE FUNCTION func_chk_lantiem_lovacxin()
RETURNS TRIGGER 
SECURITY DEFINER
AS $$
DECLARE
    v_SoLuongTon INT;
    v_HSD DATE;
    v_MaVX INT;
    v_PhacDo INT;
    v_NgayTiem DATE;
    v_MaSo INT;
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Lấy dữ liệu Vaccine và Lô Vaccine
        SELECT lv.SoLuongTon, lv.HSD, lv.MaVX, vx.PhacDo 
        INTO v_SoLuongTon, v_HSD, v_MaVX, v_PhacDo
        FROM LoVacXin lv JOIN VacXin vx ON lv.MaVX = vx.MaVX
        WHERE lv.MaLo = NEW.MaLo;

        -- Lấy dữ liệu Lần tiêm
        SELECT NgayTiem, MaSo INTO v_NgayTiem, v_MaSo FROM LanTiem WHERE MaLT = NEW.MaLT;

        -- [Quy tắc 7]: Kiểm tra Hạn sử dụng
        IF (v_NgayTiem > v_HSD) THEN
            RAISE EXCEPTION 'Lỗi (QT7): Ngày thực hiện mũi tiêm vượt quá Hạn sử dụng của lô vaccine.';
        END IF;

        -- [Quy tắc 5]: Kiểm tra Phác đồ
        IF (NEW.MuiTiemThu > v_PhacDo) THEN
            RAISE EXCEPTION 'Lỗi (QT5): Mũi tiêm thứ % vượt quá phác đồ quy định (% mũi) của Vaccine này.', NEW.MuiTiemThu, v_PhacDo;
        END IF;

        -- [Quy tắc 10]: Kiểm tra trùng lặp mũi tiêm trong sổ
        IF EXISTS (
            SELECT 1 FROM LANTIEM_LOVACXIN ltlv
            JOIN LanTiem lt ON ltlv.MaLT = lt.MaLT
            JOIN LoVacXin lv ON ltlv.MaLo = lv.MaLo
            WHERE lt.MaSo = v_MaSo 
              AND lv.MaVX = v_MaVX 
              AND ltlv.MuiTiemThu = NEW.MuiTiemThu
              AND ltlv.MaLT != NEW.MaLT
        ) THEN
            RAISE EXCEPTION 'Lỗi (QT10): Sổ tiêm chủng đã tồn tại mũi tiêm thứ % của loại Vaccine này.', NEW.MuiTiemThu;
        END IF;

        -- [Quy tắc 8]: Cập nhật Tồn kho
        IF TG_OP = 'INSERT' THEN
            -- Trừ 1 và kiểm tra đồng thời bằng RETURNING (Triệt tiêu Race Condition)
            UPDATE LoVacXin 
            SET SoLuongTon = SoLuongTon - 1 
            WHERE MaLo = NEW.MaLo AND SoLuongTon > 0 
            RETURNING SoLuongTon INTO v_SoLuongTon;
            
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Lỗi (QT8): Lô vaccine (Mã Lô: %) đã hết hàng hoặc không tồn tại.', NEW.MaLo;
            END IF;
            
        ELSIF TG_OP = 'UPDATE' AND NEW.MaLo != OLD.MaLo THEN
            -- Xử lý đổi Lô: Cộng 1 hoàn lại cho lô cũ
            UPDATE LoVacXin SET SoLuongTon = SoLuongTon + 1 WHERE MaLo = OLD.MaLo;
            
            -- Trừ 1 cho lô mới với khóa dòng an toàn
            UPDATE LoVacXin 
            SET SoLuongTon = SoLuongTon - 1 
            WHERE MaLo = NEW.MaLo AND SoLuongTon > 0 
            RETURNING SoLuongTon INTO v_SoLuongTon;
            
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Lỗi (QT8): Lô vaccine mới (Mã Lô: %) đã hết hàng.', NEW.MaLo;
            END IF;
        END IF;

        RETURN NEW;
    END IF;

    -- [Quy tắc 8]: Hoàn lại kho khi XÓA
    IF TG_OP = 'DELETE' THEN
        UPDATE LoVacXin SET SoLuongTon = SoLuongTon + 1 WHERE MaLo = OLD.MaLo;
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_lantiem_lovacxin
BEFORE INSERT OR UPDATE OR DELETE ON LANTIEM_LOVACXIN
FOR EACH ROW EXECUTE FUNCTION func_chk_lantiem_lovacxin();

--SoTiemChung
CREATE OR REPLACE FUNCTION func_chk_update_sotiemchung() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.NgayLapSo > OLD.NgayLapSo THEN
        IF EXISTS (SELECT 1 FROM LanTiem WHERE MaSo = NEW.MaSo AND NgayTiem < NEW.NgayLapSo) THEN
            RAISE EXCEPTION 'Lỗi (QT2): Không thể dời Ngày lập sổ về sau vì đã có lượt tiêm diễn ra trước ngày này.';
        END IF;
    END IF;
    
    IF NEW.MaKH != OLD.MaKH THEN
        IF EXISTS (SELECT 1 FROM LanTiem WHERE MaSo = NEW.MaSo AND MaHD IS NOT NULL) THEN
            RAISE EXCEPTION 'Lỗi (QT9): Sổ tiêm đã liên kết Lần tiêm và Hóa đơn, không thể thay đổi Khách hàng sở hữu.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_chk_update_sotiemchung
BEFORE UPDATE OF NgayLapSo, MaKH ON SoTiemChung
FOR EACH ROW EXECUTE FUNCTION func_chk_update_sotiemchung();

-- PHIEUKHAMSANGLOC
CREATE OR REPLACE FUNCTION func_chk_update_phieukham() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.NgayLap > OLD.NgayLap THEN
        IF EXISTS (SELECT 1 FROM LanTiem WHERE MaPK = NEW.MaPK AND NgayTiem < NEW.NgayLap) THEN
            RAISE EXCEPTION 'Lỗi (QT3): Ngày lập phiếu khám không thể dời về sau ngày đã thực hiện tiêm.';
        END IF;
    END IF;
    -- Nếu đổi từ Đủ điều kiện sang Tạm hoãn/Chống chỉ định
    IF OLD.KLCuaBS = 'DU_DIEU_KIEN' AND NEW.KLCuaBS IN ('TAM_HOAN', 'CHONG_CHI_DINH') THEN
        -- Kiểm tra xem khách hàng ĐÃ TIÊM THỰC TẾ chưa (KetQua khác CHUA_TIEM)
        IF EXISTS (SELECT 1 FROM LanTiem WHERE MaPK = NEW.MaPK AND KetQua != 'CHUA_TIEM') THEN
            RAISE EXCEPTION 'Lỗi: Khách hàng đã được tiêm thực tế (có ghi nhận phản ứng sau tiêm). Không thể thay đổi Kết luận bác sĩ thành %.', NEW.KLCuaBS;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_chk_update_phieukham
BEFORE UPDATE OF NgayLap, KLCuaBS ON PhieuKhamSangLoc
FOR EACH ROW EXECUTE FUNCTION func_chk_update_phieukham();

--VACXIN
CREATE OR REPLACE FUNCTION func_chk_update_vacxin() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.PhacDo < OLD.PhacDo THEN
        IF EXISTS (
            SELECT 1 FROM LANTIEM_LOVACXIN ltlv 
            JOIN LoVacXin lv ON ltlv.MaLo = lv.MaLo 
            WHERE lv.MaVX = NEW.MaVX AND ltlv.MuiTiemThu > NEW.PhacDo
        ) THEN
            RAISE EXCEPTION 'Lỗi (QT5): Không thể giảm số phác đồ vì đang có Khách hàng tiêm mũi thứ tự lớn hơn Phác đồ mới.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_chk_update_vacxin
BEFORE UPDATE OF PhacDo ON VacXin
FOR EACH ROW EXECUTE FUNCTION func_chk_update_vacxin();

--HOADON
CREATE OR REPLACE FUNCTION func_chk_update_hoadon() RETURNS TRIGGER AS $$
BEGIN
    -- [Quy tắc 9]: Cập nhật định danh người thanh toán
    IF NEW.MaKH != OLD.MaKH THEN
        IF EXISTS (SELECT 1 FROM LanTiem WHERE MaHD = NEW.MaHD AND MaSo IS NOT NULL) THEN
            RAISE EXCEPTION 'Lỗi (QT9): Hóa đơn đã được chốt với Sổ tiêm chủng, không thể thay đổi người thanh toán.';
        END IF;
    END IF;
    
    -- [Quy tắc 6]: Cập nhật dời ngày lập hóa đơn
    IF NEW.NgayLap > OLD.NgayLap THEN
        IF EXISTS (SELECT 1 FROM LanTiem WHERE MaHD = NEW.MaHD AND NgayTiem < NEW.NgayLap) THEN
            RAISE EXCEPTION 'Lỗi (QT6): Không thể dời ngày lập hóa đơn về sau ngày thực hiện tiêm.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_chk_update_hoadon
BEFORE UPDATE OF MaKH, NgayLap ON HoaDon
FOR EACH ROW EXECUTE FUNCTION func_chk_update_hoadon();

--LOVACXIN
CREATE OR REPLACE FUNCTION func_chk_update_lovacxin() RETURNS TRIGGER AS $$
BEGIN
	-- [Quy tắc 8]: Không cho phép đổi số lượng tồn kho
	IF NEW.SoLuongTon != OLD.SoLuongTon AND pg_trigger_depth() = 1 THEN
        RAISE EXCEPTION 'Lỗi(QT8): Không được phép thay đổi trực tiếp Số lượng tồn của lô vaccine. Hệ thống sẽ tự động cập nhật khi có biến động về mũi tiêm.';
    END IF;
    -- [Quy tắc 7]: Rút ngắn HSD
    IF NEW.HSD < OLD.HSD THEN
        IF EXISTS (
            SELECT 1 FROM LANTIEM_LOVACXIN ltlv 
            JOIN LanTiem lt ON ltlv.MaLT = lt.MaLT 
            WHERE ltlv.MaLo = NEW.MaLo AND lt.NgayTiem > NEW.HSD
        ) THEN
            RAISE EXCEPTION 'Lỗi (QT7): Không thể rút ngắn HSD vì đã có mũi tiêm dùng lô này sau thời điểm HSD mới.';
        END IF;
    END IF;
    
    -- [Quy tắc 10]: Đổi Vaccine của Lô
    IF NEW.MaVX != OLD.MaVX THEN
        IF EXISTS (
            SELECT 1 FROM LANTIEM_LOVACXIN ltlv1
            JOIN LanTiem lt1 ON ltlv1.MaLT = lt1.MaLT
            JOIN LanTiem lt2 ON lt1.MaSo = lt2.MaSo
            JOIN LANTIEM_LOVACXIN ltlv2 ON lt2.MaLT = ltlv2.MaLT
            JOIN LoVacXin lv2 ON ltlv2.MaLo = lv2.MaLo
            WHERE ltlv1.MaLo = NEW.MaLo 
              AND lv2.MaVX = NEW.MaVX 
              AND ltlv1.MuiTiemThu = ltlv2.MuiTiemThu
              AND ltlv1.MaLT != ltlv2.MaLT
        ) THEN
            RAISE EXCEPTION 'Lỗi (QT10): Việc đổi mã Vaccine của lô sẽ gây ra trùng lặp mũi tiêm trong các sổ đã sử dụng lô này.';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_chk_update_lovacxin
BEFORE UPDATE OF HSD, MaVX, SoLuongTon ON LoVacXin
FOR EACH ROW EXECUTE FUNCTION func_chk_update_lovacxin();



