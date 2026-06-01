--Phan quyen doi tuong
DROP OWNED BY role_hanhchinh;
DROP OWNED BY role_chuyenmon;
DROP OWNED BY role_kho;
DROP OWNED BY role_quanly;

DROP ROLE IF EXISTS role_hanhchinh;
DROP ROLE IF EXISTS role_chuyenmon;
DROP ROLE IF EXISTS role_kho;
DROP ROLE IF EXISTS role_quanly;

-- KHỞI TẠO CÁC ROLE MỚI

CREATE ROLE role_hanhchinh;
CREATE ROLE role_chuyenmon;
CREATE ROLE role_kho;
CREATE ROLE role_quanly;

-- Cấp quyền sử dụng không gian Schema public cho các Role
GRANT USAGE ON SCHEMA public TO role_hanhchinh, role_chuyenmon, role_kho, role_quanly;

-- CHI TIẾT CẤP QUYỀN TRÊN BẢNG 

-- VAI TRÒ: NHÂN VIÊN HÀNH CHÍNH (role_hanhchinh)
REVOKE EXECUTE ON ALL ROUTINES IN SCHEMA public FROM PUBLIC;


-- Quyền Quản lý hồ sơ, lập sổ tiêm, lập hóa đơn (Read, Insert, Update)
GRANT SELECT, INSERT, UPDATE ON TABLE 
    KhachHang, NguoiGiamHo, CHITIET_GIAMHO, SoTiemChung, HoaDon 
TO role_hanhchinh;

-- Quyền lên lịch hẹn tiêm (Read, Insert)
GRANT SELECT, INSERT ON TABLE LanTiem, LANTIEM_LOVACXIN TO role_hanhchinh;

-- Quyền hỗ trợ xem phiếu khám để in hoặc thu tiền (Read)
GRANT SELECT ON TABLE PhieuKhamSangLoc TO role_hanhchinh;

-- Quyền xem danh mục vắc xin và tài khoản cá nhân (Read)
GRANT SELECT ON TABLE 
    VacXin, BenhPhongNgua, VACXIN_BENHPHONGNGUA, LoVacXin, NhanVienHanhChinh 
TO role_hanhchinh;

-- VAI TRÒ: NHÂN VIÊN CHUYÊN MÔN (role_chuyenmon)

-- Quyền khám sàng lọc, thực hiện tiêm và cập nhật trạng thái (Read, Insert, Update)
GRANT SELECT, INSERT, UPDATE ON TABLE PhieuKhamSangLoc, LanTiem, LANTIEM_LOVACXIN TO role_chuyenmon;

-- Quyền xem thông tin khách hàng, kiểm tra hóa đơn đóng tiền (Read)
GRANT SELECT ON TABLE 
    KhachHang, NguoiGiamHo, CHITIET_GIAMHO, SoTiemChung, HoaDon 
TO role_chuyenmon;

-- Quyền xem danh mục vắc xin và tài khoản cá nhân (Read)
GRANT SELECT ON TABLE 
    VacXin, BenhPhongNgua, VACXIN_BENHPHONGNGUA, LoVacXin, NhanVienChuyenMon 
TO role_chuyenmon;

-- VAI TRÒ: QUẢN LÝ KHO (role_kho)

-- Quyền toàn quyền quản lý danh mục vắc xin, bệnh phòng và tồn kho (CRUD)
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE 
    VacXin, BenhPhongNgua, VACXIN_BENHPHONGNGUA, LoVacXin 
TO role_kho;

-- Quyền xem dữ liệu lần tiêm để đối soát số lượng tiêu hao vật tư thực tế (Read)
GRANT SELECT ON TABLE LanTiem, LANTIEM_LOVACXIN TO role_kho;

-- 3.4 VAI TRÒ: BAN QUẢN LÝ (role_quanly)

-- Quyền Giám sát toàn bộ hoạt động nghiệp vụ và vật tư hệ thống (Chỉ được quyền Read)
GRANT SELECT ON TABLE 
    KhachHang, NguoiGiamHo, CHITIET_GIAMHO, SoTiemChung, HoaDon, 
    PhieuKhamSangLoc, LanTiem, LANTIEM_LOVACXIN, 
    VacXin, BenhPhongNgua, VACXIN_BENHPHONGNGUA, LoVacXin 
TO role_quanly;

-- Quyền Quản lý, cấu hình tài khoản nhân sự (Read, Insert, Update - Cơ chế xóa mềm)
GRANT SELECT, INSERT, UPDATE ON TABLE NhanVienHanhChinh, NhanVienChuyenMon TO role_quanly;


-- CẤP QUYỀN TRÊN SEQUENCE & GÁN USER VÀO ROLE

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO role_hanhchinh, role_chuyenmon, role_kho, role_quanly;

GRANT role_hanhchinh TO hc01;
GRANT role_chuyenmon TO bs01;
GRANT role_kho TO kho01;
GRANT role_quanly TO admin01;

--Kiểm thử

-- SET ROLE role_hanhchinh; -- Đóng vai hành chính

-- -- 1A. [THÀNH CÔNG] Thêm mới một khách hàng đến tiêm
-- INSERT INTO KhachHang (HoTen, NgaySinh, SDT)
-- VALUES ('Nguyễn Văn A', '2006-01-01', '0901234567');

-- -- 1B. [THẤT BẠI] Thử xóa khách hàng vừa thêm (Hệ thống phải chặn)
-- DELETE FROM KhachHang WHERE SDT = '0901234567';

-- RESET ROLE; -- Trả lại quyền tối cao

-- SET ROLE role_chuyenmon; 

-- -- 2A. [THÀNH CÔNG] Xem danh sách vắc-xin hiện có để tư vấn cho khách
-- SELECT MaVX, TenVX FROM VacXin LIMIT 3;

-- -- 2B. [THẤT BẠI] Bác sĩ cố tình sửa đổi số lượng vắc-xin trong kho
-- UPDATE LoVacXin SET SoLuongTon = 5000 WHERE MaLo = 1;

-- RESET ROLE;

-- SET ROLE role_kho; -- Đóng vai Thủ kho

-- -- 3A. [THÀNH CÔNG] Thêm một lô vắc-xin 
-- INSERT INTO LoVacXin (SoLuongTon, MaVX) VALUES (50, 2);

-- -- 3B. [THẤT BẠI] Thủ kho cố tình xem dữ liệu bảng Hóa Đơn 
-- SELECT * FROM HoaDon LIMIT 3;

-- RESET ROLE;

-- SET ROLE role_quanly; -- Đóng vai Ban quản lý

-- -- 4A. [THÀNH CÔNG] Truy vấn View xem báo cáo doanh thu tổng hợp
-- SELECT * FROM v_BaoCaoDoanhThuTheoHoaDon LIMIT 5; 

-- -- 4B. [THẤT BẠI] Ban quản lý cố tình chạy lệnh xóa một hóa đơn gốc
-- DELETE FROM HoaDon WHERE MaHD = 1;

-- RESET ROLE;


-- PHÂN QUYỀN TRÊN PROCEDURE 

-- BƯỚC 1: THU HỒI QUYỀN THI THỨC MẶC ĐỊNH 
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON ROUTINES FROM PUBLIC;

-- BƯỚC 2: PHÂN QUYỀN CHI TIẾT THEO MA TRẬN ĐỒ ÁN

-- === 2.1 NHÂN VIÊN HÀNH CHÍNH (role_hanhchinh) ===
GRANT EXECUTE ON PROCEDURE 
    LuuThongTinKhachHang,
    TaoHoaDon,
    TaoSoTiemChung,
    LuuThongTinNguoiGiamHo,
    TaoChiTietGiamHo,
    CapNhatTTHoSo,
    CapNhatKhachHang,
    CapNhatSoTiem,
    CapNhatThanhToanHoaDon,
    TaoLanTiem,
    TaoLanTiemLoVacXin
TO role_hanhchinh;


-- === 2.2 NHÂN VIÊN CHUYÊN MÔN (role_chuyenmon) ===
GRANT EXECUTE ON PROCEDURE 
    TaoPhieuKhamSangLoc,
    TaoLanTiem,
    TaoLanTiemLoVacXin,
    CapNhatKetLuanBacSi,
    CapNhatKetQuaLanTiem
TO role_chuyenmon;


-- === 2.3 QUẢN LÝ KHO (role_kho) ===
GRANT EXECUTE ON PROCEDURE 
    TaoVacXin,
    TaoLoVacXin,
    LuuTenBenhPhongNgua,
    TaoVacXinBenhPhongNgua,
    CapNhatMucDoNguyHiemBenh,
    CapNhatHSDLoVacXin
TO role_kho;


-- === 2.4 BAN QUẢN LÝ (role_quanly) ===
GRANT EXECUTE ON PROCEDURE 
    ThemNVHanhChinh,
    ThemNVChuyenMon,
    CapNhatNVChuyenMon
TO role_quanly;

--KIEM THU THANH CONG
-- Bước 1: Đứng dưới quyền Admin/Superuser để cấp quyền đọc bảng cho vai trò hành chính
GRANT SELECT ON TABLE NhanVienHanhChinh TO role_hanhchinh;
GRANT SELECT ON TABLE KhachHang TO role_hanhchinh;
GRANT INSERT, SELECT ON TABLE HoaDon TO role_hanhchinh;

-- ==========================================================

-- -- Bước 2: Bắt đầu kịch bản kiểm thử 
-- SET ROLE role_hanhchinh; -- Đóng vai hành chính

-- --CALL TaoHoaDon(
--     '2026-02-08'::DATE, 
--     'CHUYEN_KHOAN'::HinhThucThanhToan, 
--     300000::NUMERIC(15,2), 
--     1::INT, 
--     1::INT
-- );

-- RESET ROLE; 

-- KIEM THU THAT BAI
-- Thu hồi quyền thực thi mặc định của PUBLIC 
REVOKE EXECUTE ON PROCEDURE TaoPhieuKhamSangLoc FROM PUBLIC;

-- Thu hồi đích danh quyền chạy thủ tục này từ role_hanhchinh
REVOKE EXECUTE ON PROCEDURE TaoPhieuKhamSangLoc FROM role_hanhchinh;

-- SET ROLE role_hanhchinh; 

-- -- Gọi thủ tục tạo phiếu khám 
-- --CALL TaoPhieuKhamSangLoc(
--     CURRENT_DATE, 
--     36.5, 
--     170.5, 
--     65.0, 
--     'DU_DIEU_KIEN', 
--     'Khong co', 
--     1
-- );

-- RESET ROLE; 

--Phan quyền trên Function

ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON ROUTINES FROM PUBLIC;

GRANT EXECUTE ON FUNCTION 
    fn_tinh_tuoi_khach_hang,
    fn_dem_so_mui_tiem_khach_hang,
    fn_lich_su_tiem_khach_hang,
    fn_tra_cuu_ls_tiem,
    fn_tra_cuu_lan_tiem,
    fn_tong_tien_khach_hang,
    fn_tra_cuu_hd,
    fn_ton_kho_vacxin,
    fn_tra_cuu_sl_vacxin,
   fn_tra_cuu_thongtin_nv,
   fn_kiem_tra_du_dieu_kien_tiem
TO role_hanhchinh;

GRANT EXECUTE ON FUNCTION 
    fn_tinh_tuoi_khach_hang,
    fn_dem_so_mui_tiem_khach_hang,
    fn_kiem_tra_du_dieu_kien_tiem,
    fn_lich_su_tiem_khach_hang,
    fn_tra_cuu_ls_tiem,
    fn_tra_cuu_lan_tiem,
    fn_ton_kho_vacxin,
    fn_tra_cuu_sl_vacxin,
   fn_tra_cuu_thongtin_nv
TO role_chuyenmon;

GRANT EXECUTE ON FUNCTION 
    fn_ton_kho_vacxin,
    fn_tra_cuu_sl_vacxin,
    fn_danh_sach_lo_sap_het_han,
    fn_thong_ke_su_dung_vacxin,
    fn_danh_sach_lo_sap_het_han,
    fn_nha_cung_cap,
   fn_tra_cuu_thongtin_nv
TO role_kho;

GRANT EXECUTE ON FUNCTION 
    fn_tinh_tuoi_khach_hang, fn_dem_so_mui_tiem_khach_hang, fn_kiem_tra_du_dieu_kien_tiem,
    fn_lich_su_tiem_khach_hang, fn_tra_cuu_ls_tiem, fn_tra_cuu_lan_tiem, fn_tong_tien_khach_hang,
    fn_tra_cuu_hd, fn_tra_cuu_doanh_thu, fn_tra_cuu_sl_hd, fn_ton_kho_vacxin, fn_tra_cuu_sl_vacxin,
    fn_danh_sach_lo_sap_het_han, fn_thong_ke_su_dung_vacxin, fn_danh_sach_lo_sap_het_han,
    fn_nha_cung_cap,fn_tra_cuu_thongtin_nv
TO role_quanly;

-- SET ROLE role_kho; -- Đóng vai Quản lý kho

-- -- Gọi hàm xem các lô vắc-xin sắp hết hạn
-- SELECT * FROM fn_danh_sach_lo_sap_het_han(); 

-- RESET ROLE;

REVOKE EXECUTE ON FUNCTION fn_tra_cuu_doanh_thu() FROM PUBLIC;
-- SET ROLE role_hanhchinh;
-- SELECT * FROM fn_tra_cuu_doanh_thu(); 
-- RESET ROLE;

--Phan quyen tren View

ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON ROUTINES FROM PUBLIC;

GRANT SELECT ON TABLE 
    v_LichSuTiemChung,
    v_DanhSachTreEmCanGiamHo,
    v_BaoCaoDoanhThuTheoHoaDon,
    v_ton_kho_vacxin,
    v_TienDoPhacDo
TO role_hanhchinh;

GRANT SELECT ON TABLE 
    v_LichSuTiemChung,
    v_DanhSachTreEmCanGiamHo,
    v_ton_kho_vacxin,
    v_TienDoPhacDo
TO role_chuyenmon;

GRANT SELECT ON TABLE 
    v_ton_kho_vacxin
TO role_kho;

GRANT SELECT ON TABLE 
    v_LichSuTiemChung,
    v_DanhSachTreEmCanGiamHo,
    v_BaoCaoDoanhThuTheoHoaDon,
    v_ton_kho_vacxin,
    v_TienDoPhacDo
TO role_quanly;

-- SET ROLE role_hanhchinh; -- Đóng vai nhân viên hành chính

-- -- Thực hiện truy vấn dữ liệu từ View
-- SELECT * FROM v_BaoCaoDoanhThuTheoHoaDon LIMIT 5; 

-- RESET ROLE; 


REVOKE SELECT ON v_BaoCaoDoanhThuTheoHoaDon FROM PUBLIC;

REVOKE SELECT ON v_BaoCaoDoanhThuTheoHoaDon FROM role_chuyenmon;

-- SET ROLE role_chuyenmon; -- Đóng vai nhân viên chuyên môn

-- -- Bác sĩ cố tình đọc báo cáo tài chính doanh thu hóa đơn
-- SELECT * FROM v_BaoCaoDoanhThuTheoHoaDon;

-- RESET ROLE;

-- Phan quyen tren Procedure có Cursor

-- 1. THU HỒI QUYỀN THỰC THI MẶC ĐỊNH ĐỂ CHẶN CHẠY KÉ QUA PUBLIC
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON ROUTINES FROM PUBLIC;

-- 2. CẤP QUYỀN CHO NHÂN VIÊN HÀNH CHÍNH (role_hanhchinh)
GRANT EXECUTE ON PROCEDURE 
    TuDongGoiYHenLichTiem,
    QuetHoSoTreEmCanHoTro
TO role_hanhchinh;

-- 3. CẤP QUYỀN CHO NHÂN VIÊN CHUYÊN MÔN (role_chuyenmon)
GRANT EXECUTE ON PROCEDURE 
    QuetCapCuuPhanUngSauTiem,
    TuDongGoiYHenLichTiem
TO role_chuyenmon;

-- 4. CẤP QUYỀN CHO QUẢN LÝ KHO (role_quanlykho)
GRANT EXECUTE ON PROCEDURE 
    KiemTraVaCanhBaoKho,
    TuDongXuLyLoQuaHan
TO role_kho;

-- 5. CẤP QUYỀN CHO BAN QUẢN LÝ (role_banquanly)
GRANT EXECUTE ON PROCEDURE 
    KiemTraVaCanhBaoKho,
    QuetCapCuuPhanUngSauTiem,
    QuetHoSoTreEmCanHoTro,
    GiamSatGiaoDichLon
TO role_quanly;

-- SET ROLE role_hanhchinh; -- Đóng vai nhân viên hành chính

-- -- Gọi thủ tục có cursor duyệt hồ sơ trẻ em
-- --CALL QuetHoSoTreEmCanHoTro(); 

-- RESET ROLE; 

-- Thu hồi quyền chạy của nhóm PUBLIC đối với riêng hàm này 
REVOKE EXECUTE ON PROCEDURE GiamSatGiaoDichLon() FROM PUBLIC;

ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON ROUTINES FROM PUBLIC;

-- SET ROLE role_chuyenmon; -- Đóng vai nhân viên chuyên môn (Bác sĩ)

-- -- Bác sĩ cố tình chạy thủ tục kiểm soát giao dịch lớn của Ban quản lý
-- --CALL GiamSatGiaoDichLon(); 

-- RESET ROLE;

-- Cấp quyền kết nối (mở cửa) cho các Role nghiệp vụ
GRANT CONNECT ON DATABASE "QuanLyTiemChung" TO role_hanhchinh, role_chuyenmon, role_kho, role_quanly;
GRANT CONNECT ON DATABASE "QuanLyTiemChung" TO hc01, bs01, kho01, admin01;



