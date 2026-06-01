-- =============================================================
-- DEMO ROLE_CHUYENMON
-- Gồm: PHÂN QUYỀN, PROCEDURE, FUNCTION, VIEW, CURSOR
--
--
-- 1) Chạy trước toàn bộ code tạo bảng, trigger, data, view, function, procedure.
-- 2) Chạy phần PHÂN QUYỀN bằng postgres/owner database.
-- 3) Chạy SET ROLE role_chuyenmon để đóng vai nhân viên chuyên môn.
-- 4) Với các ca lỗi, nên bôi đen từng dòng CALL/SELECT rồi chạy riêng,
--	vì PostgreSQL sẽ báo ERROR và dừng câu lệnh đó. Đây là lỗi mong đợi.
-- =============================================================
 
-- =============================================================
-- =============== KHỞI TẠO VÀ PHÂN QUYỀN ROLE =================
-- =============================================================
 
-- Trả về quyền của session hiện tại cho role gốc nếu đang SET ROLE
RESET ROLE;
 
-- Xóa role_chuyenmon nếu đã tồn tại để demo lại từ đầu
DO $$
BEGIN
	IF EXISTS (
    	SELECT 1
    	FROM pg_roles
    	WHERE rolname = 'role_chuyenmon'
	) THEN
    	DROP OWNED BY role_chuyenmon;
    	DROP ROLE role_chuyenmon;
	END IF;
END $$;
 
-- Tạo mới role nhân viên chuyên môn
CREATE ROLE role_chuyenmon;
 
-- Cho phép role_chuyenmon truy cập schema public
GRANT USAGE ON SCHEMA public TO role_chuyenmon;
 
-- =============================================================
-- ======================== PHÂN QUYỀN =========================
-- =============================================================
 
 
-- Quyền bảng cho nhân viên chuyên môn
GRANT SELECT, INSERT, UPDATE ON TABLE
	PhieuKhamSangLoc,
	LanTiem,
	LANTIEM_LOVACXIN
TO role_chuyenmon;
 
GRANT SELECT ON TABLE
	KhachHang,
	NguoiGiamHo,
	CHITIET_GIAMHO,
	SoTiemChung,
	HoaDon,
	VacXin,
	BenhPhongNgua,
    VACXIN_BENHPHONGNGUA,
	LoVacXin,
	NhanVienChuyenMon
TO role_chuyenmon;
 
-- Không cho nhân viên chuyên môn xóa dữ liệu nghiệp vụ hoặc sửa dữ liệu ngoài phạm vi
REVOKE DELETE ON TABLE PhieuKhamSangLoc, LanTiem, LANTIEM_LOVACXIN FROM role_chuyenmon;
REVOKE INSERT, UPDATE, DELETE ON TABLE
	KhachHang,
	NguoiGiamHo,
	CHITIET_GIAMHO,
	SoTiemChung,
	HoaDon,
	VacXin,
	BenhPhongNgua,
    VACXIN_BENHPHONGNGUA,
	LoVacXin,
	NhanVienChuyenMon
FROM role_chuyenmon;
 
-- Quyền sequence để INSERT vào bảng identity
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO role_chuyenmon;
 
-- Quyền VIEW được phép xem
GRANT SELECT ON TABLE
	v_LichSuTiemChung,
    v_DanhSachTreEmCanGiamHo,
	v_ton_kho_vacxin,
	v_TienDoPhacDo
TO role_chuyenmon;
 
-- View doanh thu thuộc ban quản lý/hành chính, chuyên môn không được xem
REVOKE SELECT ON TABLE v_BaoCaoDoanhThuTheoHoaDon FROM PUBLIC;
REVOKE SELECT ON TABLE v_BaoCaoDoanhThuTheoHoaDon FROM role_chuyenmon;
 
-- Quyền FUNCTION được phép chạy
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
 
 
-- Quyền PROCEDURE thường được phép chạy
GRANT EXECUTE ON PROCEDURE
    TaoPhieuKhamSangLoc,
	TaoLanTiem,
    TaoLanTiemLoVacXin,
    CapNhatKetLuanBacSi,
    CapNhatKetQuaLanTiem
TO role_chuyenmon;
 
 
 
-- Quyền PROCEDURE có CURSOR
GRANT EXECUTE ON PROCEDURE
    QuetCapCuuPhanUngSauTiem,
    TuDongGoiYHenLichTiem
TO role_chuyenmon;
 
 
-- =============================================================
-- ================ ĐÓNG VAI NHÂN VIÊN CHUYÊN MÔN ==============
-- =============================================================
 
RESET ROLE;
SET ROLE role_chuyenmon;
 
SELECT CURRENT_USER AS current_user, CURRENT_ROLE AS current_role;
 
 
-- =============================================================
-- ========================= PROCEDURE =========================
-- =============================================================
 
-- -------------------------------------------------------------
-- 1. Tạo phiếu khám sàng lọc
-- Chức năng: bác sĩ/nhân viên chuyên môn lập phiếu khám trước tiêm.
-- Tham số: NgayLap, NhietDo, ChieuCao, CanNang, KLCuaBS, TSDiUng, MaNV
-- -------------------------------------------------------------
 
SELECT * FROM PhieuKhamSangLoc ORDER BY MaPK DESC LIMIT 5;
 
-- 1. Hợp lệ
CALL TaoPhieuKhamSangLoc(CURRENT_DATE, 36.5, 170.5, 65.0, 'DU_DIEU_KIEN', 'Thông tin dị ứng ', 1);
 
-- 2. Ngày lập ở tương lai
CALL TaoPhieuKhamSangLoc(CURRENT_DATE + 1, 36.5, 170.5, 65.0, 'DU_DIEU_KIEN', 'Thông tin dị ứng', 1);
 
-- 3. Nhiệt độ không hợp lệ
CALL TaoPhieuKhamSangLoc(CURRENT_DATE, 50.0, 170.5, 65.0, 'DU_DIEU_KIEN', 'Thông tin dị ứng', 1);
 
-- 4. Chiều cao âm
CALL TaoPhieuKhamSangLoc(CURRENT_DATE, 36.5, -170.5, 65.0, 'DU_DIEU_KIEN', 'Thông tin dị ứng', 1);
 
-- 5. Nhân viên chuyên môn không tồn tại
CALL TaoPhieuKhamSangLoc(CURRENT_DATE, 36.5, 170.5, 65.0, 'DU_DIEU_KIEN', 'Thông tin dị ứng', -999999);
 
-- 6. Kết luận bác sĩ không hợp lệ
/* KetLuanBSEnum chỉ có các giá trị hợp lệ:
'DU_DIEU_KIEN'
'TAM_HOAN'
'CHONG_CHI_DINH' */
CALL TaoPhieuKhamSangLoc(CURRENT_DATE, 36.5, 170.5, 65.0, 'KHONG_HOP_LE', 'Thông tin dị ứng', 1);
 
 
-- -------------------------------------------------------------
-- 2. Tạo lần tiêm
-- Chức năng: ghi nhận một lượt tiêm sau khi đã có phiếu khám và hóa đơn.
-- Tham số: NgayTiem, KetQua, MaNV, MaSo, MaPK, MaHD
-- Lưu ý: dùng SELECT để xem mã có sẵn, sau đó CALL trực tiếp bằng mã cụ thể.
-- Không dùng subquery trong CALL để tránh lỗi "cannot use subquery in CALL argument".
-- -------------------------------------------------------------
 
SELECT * FROM LanTiem ORDER BY MaLT DESC LIMIT 5;
 
-- =============================================================
-- ======================= TẠO LẦN TIÊM ========================
-- =============================================================
 
SELECT * FROM LanTiem;
 
-- 1. Hợp lệ
CALL TaoLanTiem(CURRENT_DATE, 'BINH_THUONG', 1, 1, 1, 1);
 
-- 2. Ngày tiêm ở tương lai
CALL TaoLanTiem(CURRENT_DATE + 1, 'BINH_THUONG', 1, 1, 1, 1);
 
-- 3. Kết quả tiêm không hợp lệ
CALL TaoLanTiem(CURRENT_DATE, 'SAI_KET_QUA', 1, 1, 1, 1);
 
-- 4. Nhân viên chuyên môn không tồn tại
CALL TaoLanTiem(CURRENT_DATE, 'BINH_THUONG', -999999, 1, 1, 1);
 
-- 5. Sổ tiêm chủng không tồn tại
CALL TaoLanTiem(CURRENT_DATE, 'BINH_THUONG', 1, -999999, 1, 1);
 
-- 6. Phiếu khám không tồn tại
CALL TaoLanTiem(CURRENT_DATE, 'BINH_THUONG', 1, 1, -999999, 1);
 
-- 7. Hóa đơn không tồn tại
CALL TaoLanTiem(CURRENT_DATE, 'BINH_THUONG', 1, 1, 1, -999999);
-- -------------------------------------------------------------
-- 3. Tạo liên kết lần tiêm - lô vaccine
-- Chức năng: ghi nhận lô vaccine được dùng cho lần tiêm và số mũi tiêm.
-- Tham số: MaLT, MaLo, MuiTiemThu
-- -------------------------------------------------------------
 
SELECT * FROM LANTIEM_LOVACXIN;
 
-- 1. Hợp lệ
CALL TaoLanTiemLoVacXin(1, 5, 1);
 
-- 2. Lần tiêm không tồn tại
CALL TaoLanTiemLoVacXin(-999999, 5, 1);
 
-- 3. Lô vaccine không tồn tại
CALL TaoLanTiemLoVacXin(1, -999999, 1);
 
-- 4. Mũi tiêm thứ không hợp lệ
CALL TaoLanTiemLoVacXin(1, 5, 0);
 
-- 5. Liên kết đã tồn tại
CALL TaoLanTiemLoVacXin(1, 5, 1);
-- -------------------------------------------------------------
-- 4. Cập nhật kết luận bác sĩ
-- Chức năng: cập nhật kết luận sau khám sàng lọc.
-- Tham số: MaPK, KetLuan
-- -------------------------------------------------------------
 
SELECT * FROM PhieuKhamSangLoc ORDER BY MaPK DESC LIMIT 5;
 
-- Xem mã phiếu khám có thể dùng
SELECT MaPK, NgayLap, NhietDo, ChieuCao, CanNang, KLCuaBS, MaNV
FROM PhieuKhamSangLoc
ORDER BY MaPK DESC
LIMIT 10;
 
-- 1. Hợp lệ
-- Nếu MaPK = 1 không phù hợp dữ liệu của bạn, lấy MaPK ở bảng SELECT phía trên rồi thay vào.
CALL CapNhatKetLuanBacSi(16815, 'TAM_HOAN'::KetLuanBSEnum);
 
-- 2. Phiếu khám không tồn tại
CALL CapNhatKetLuanBacSi(-999999, 'DU_DIEU_KIEN'::KetLuanBSEnum);
 
-- 3. Kết luận không hợp lệ
CALL CapNhatKetLuanBacSi(1, 'SAI_KET_LUAN'::KetLuanBSEnum);
 
 
-- -------------------------------------------------------------
-- 5. Cập nhật kết quả lần tiêm
-- Chức năng: cập nhật phản ứng/kết quả sau tiêm.
-- Tham số: MaLT, KetQua
-- -------------------------------------------------------------
 
SELECT * FROM LanTiem ORDER BY MaLT DESC LIMIT 5;
 
-- Xem mã lần tiêm có thể dùng
SELECT MaLT, NgayTiem, KetQua, MaNV, MaSo, MaPK, MaHD
FROM LanTiem
ORDER BY MaLT DESC
LIMIT 10;
 
-- 1. Hợp lệ
-- Nếu MaLT = 1 không phù hợp dữ liệu của bạn, lấy MaLT ở bảng SELECT phía trên rồi thay vào.
CALL CapNhatKetQuaLanTiem(1, 'PHAN_UNG_NHE'::KetQuaTiemEnum);
 
-- 2. Lần tiêm không tồn tại
CALL CapNhatKetQuaLanTiem(-999999, 'BINH_THUONG'::KetQuaTiemEnum);
 
-- 3. Kết quả tiêm không hợp lệ
CALL CapNhatKetQuaLanTiem(1, 'KET_QUA_SAI'::KetQuaTiemEnum);
 
 
-- -------------------------------------------------------------
-- 6. Test vượt quyền PROCEDURE
-- Các lệnh dưới đây phải bị chặn với role_chuyenmon.
-- -------------------------------------------------------------
 
-- 1. Không được tạo hóa đơn
CALL TaoHoaDon(CURRENT_DATE, 'TIEN_MAT'::HinhThucThanhToan, 300000, 1, 1);
 
-- 2. Không được tạo vaccine
CALL TaoVacXin('Vacxin Sai Quyen Chuyen Mon', 2, 'Demo Hang SX');
 
-- 3. Không được tạo lô vaccine
CALL TaoLoVacXin(CURRENT_DATE + 365, 'Demo Noi SX', CURRENT_DATE - 10, 100, 1);
 
-- 4. Không được cập nhật hạn sử dụng lô vaccine
CALL CapNhatHSDLoVacXin(1, CURRENT_DATE + 365);
 
-- 5. Không được tạo tài khoản nhân viên chuyên môn
CALL ThemNVChuyenMon('1990-01-01', TRUE, 'BAC_SI'::ChucDanhCM, 'CCHN_DEMO', 'Nhan vien sai quyen', 'HCM', '0901234567');
 
 
-- =============================================================
-- ========================= FUNCTION ==========================
-- =============================================================
 
-- -------------------------------------------------------------
-- 1. Hàm tính tuổi khách hàng: fn_tinh_tuoi_khach_hang(MaKH)
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
SELECT fn_tinh_tuoi_khach_hang(1);
 
-- 2. Mã khách hàng không tồn tại
SELECT fn_tinh_tuoi_khach_hang(-999999);
 
-- 3. Để trống tham số
SELECT fn_tinh_tuoi_khach_hang();
 
 
-- -------------------------------------------------------------
-- 2. Hàm đếm số mũi tiêm của khách hàng: fn_dem_so_mui_tiem_khach_hang(MaKH)
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
SELECT fn_dem_so_mui_tiem_khach_hang(1);
 
-- 2. Mã khách hàng không tồn tại
SELECT fn_dem_so_mui_tiem_khach_hang(-999999);
 
-- 3. Để trống tham số
SELECT fn_dem_so_mui_tiem_khach_hang();
 
 
-- -------------------------------------------------------------
-- 3. Hàm kiểm tra đủ điều kiện tiêm: fn_kiem_tra_du_dieu_kien_tiem(MaPK)
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
SELECT fn_kiem_tra_du_dieu_kien_tiem(1);
 
-- 2. Phiếu khám không tồn tại
SELECT fn_kiem_tra_du_dieu_kien_tiem(-999999);
 
-- 3. Để trống tham số
SELECT fn_kiem_tra_du_dieu_kien_tiem();
 
 
-- -------------------------------------------------------------
-- 4. Hàm lịch sử tiêm khách hàng: fn_lich_su_tiem_khach_hang(MaKH)
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
SELECT * FROM fn_lich_su_tiem_khach_hang(1);
 
-- 2. Khách hàng không tồn tại
SELECT * FROM fn_lich_su_tiem_khach_hang(-999999);
 
-- 3. Để trống tham số
SELECT * FROM fn_lich_su_tiem_khach_hang();
 
 
-- -------------------------------------------------------------
-- 5. Hàm tra cứu lịch sử tiêm: fn_tra_cuu_ls_tiem(MaKH)
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
SELECT * FROM fn_tra_cuu_ls_tiem(1);
 
-- 2. Khách hàng không tồn tại
SELECT * FROM fn_tra_cuu_ls_tiem(-999999);
 
-- 3. Để trống tham số
SELECT * FROM fn_tra_cuu_ls_tiem();
 
 
-- -------------------------------------------------------------
-- 6. Hàm tra cứu lần tiêm: fn_tra_cuu_lan_tiem()
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
SELECT * FROM fn_tra_cuu_lan_tiem() LIMIT 10;
 
 
-- -------------------------------------------------------------
-- 7. Hàm kiểm tra tổng tồn kho vaccine: fn_ton_kho_vacxin(MaVX)
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
SELECT fn_ton_kho_vacxin(1);
 
-- 2. Mã vaccine không tồn tại
SELECT fn_ton_kho_vacxin(-999999);
 
-- 3. Để trống tham số
SELECT fn_ton_kho_vacxin();
 
 
-- -------------------------------------------------------------
-- 8. Hàm tra cứu số lượng vaccine: fn_tra_cuu_sl_vacxin(TenVX)
-- -------------------------------------------------------------
 
-- 1. Tìm tất cả
SELECT * FROM fn_tra_cuu_sl_vacxin(NULL);
 
-- 2. Tìm theo tên
SELECT * FROM fn_tra_cuu_sl_vacxin('BCG');
 
-- 3. Không có vaccine theo tên này
SELECT * FROM fn_tra_cuu_sl_vacxin('Khong Co Vaccine Nay');
 
 
-- -------------------------------------------------------------
-- 9. Hàm tra cứu thông tin nhân viên: fn_tra_cuu_thongtin_nv()
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
SELECT * FROM fn_tra_cuu_thongtin_nv() LIMIT 10;
 
 
-- -------------------------------------------------------------
-- 10. Test vượt quyền FUNCTION
-- Các lệnh dưới đây phải bị chặn với role_chuyenmon.
-- -------------------------------------------------------------
 
-- 1. Không được xem tổng tiền khách hàng
SELECT fn_tong_tien_khach_hang(1);
 
-- 2. Không được tra cứu hóa đơn
SELECT * FROM fn_tra_cuu_hd(1);
 
-- 3. Không được xem doanh thu hệ thống
SELECT * FROM fn_tra_cuu_doanh_thu();
 
-- 4. Không được xem số lượng hóa đơn
SELECT * FROM fn_tra_cuu_sl_hd();
 
-- 5. Không được xem danh sách lô sắp hết hạn chuyên sâu của kho
SELECT * FROM fn_danh_sach_lo_sap_het_han(365);
 
-- 6. Không được thống kê sử dụng vaccine theo ngày
SELECT * FROM fn_thong_ke_su_dung_vacxin('2025-01-01', '2025-12-31');
 
-- 7. Không được tra cứu chi tiết lô vaccine theo quyền kho
SELECT * FROM fn_tra_cuu_lo_vacxin(NULL, TRUE, TRUE);
 
-- 8. Không được tra cứu nhà cung cấp
SELECT * FROM fn_nha_cung_cap('Germany');
 
 
-- =============================================================
-- =========================== VIEW ============================
-- =============================================================
 
-- -------------------------------------------------------------
-- 1. View lịch sử tiêm chủng
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
SELECT * FROM v_LichSuTiemChung LIMIT 10;
 
 
-- -------------------------------------------------------------
-- 2. View danh sách trẻ em cần giám hộ
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
SELECT * FROM v_DanhSachTreEmCanGiamHo LIMIT 10;
 
 
-- -------------------------------------------------------------
-- 3. View tồn kho vaccine dạng tổng hợp
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
SELECT * FROM v_ton_kho_vacxin LIMIT 10;
 
 
-- -------------------------------------------------------------
-- 4. View tiến độ phác đồ
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
SELECT * FROM v_TienDoPhacDo LIMIT 10;
 
 
-- -------------------------------------------------------------
-- 5. View bị chặn với nhân viên chuyên môn
-- -------------------------------------------------------------
 
-- 1. Không được xem báo cáo doanh thu hóa đơn
SELECT * FROM v_BaoCaoDoanhThuTheoHoaDon LIMIT 10;
 
-- 2. Không được INSERT vào view tồn kho
INSERT INTO v_ton_kho_vacxin(MaVX, TenVX, HangSX, PhacDo)
VALUES (999999, 'Vacxin Sai Quyen', 'Demo', 2);
 
-- 3. Không được UPDATE view trẻ em
UPDATE v_DanhSachTreEmCanGiamHo
SET HoTenTreEm = 'Ten Bi Sua Sai'
WHERE MaKH = 1;
 
 
-- =============================================================
-- ========================== CURSOR ===========================
-- =============================================================
 
-- -------------------------------------------------------------
-- 1. Cursor quét phản ứng nặng sau tiêm
-- Chức năng: quét các lượt tiêm hôm nay có SOT_CAO hoặc SOC_PHAN_VE.
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
CALL QuetCapCuuPhanUngSauTiem();
 
 
-- -------------------------------------------------------------
-- 2. Cursor tự động gợi ý hẹn lịch tiêm
-- Chức năng: phân tích tiến độ phác đồ của khách hàng và gợi ý lịch tiêm tiếp theo.
-- -------------------------------------------------------------
 
-- 1. Hợp lệ
CALL TuDongGoiYHenLichTiem(1);
 
-- 2. Khách hàng không tồn tại
CALL TuDongGoiYHenLichTiem(-999999);
 
 
-- -------------------------------------------------------------
-- 3. Test vượt quyền CURSOR PROCEDURE
-- Các lệnh dưới đây phải bị chặn với role_chuyenmon.
-- -------------------------------------------------------------
 
-- 1. Không được chạy cursor kiểm tra và cảnh báo kho
CALL KiemTraVaCanhBaoKho();
 
-- 2. Không được chạy cursor xử lý lô quá hạn
CALL TuDongXuLyLoQuaHan();
 
-- 3. Không được chạy cursor rà soát hồ sơ trẻ em của hành chính
CALL QuetHoSoTreEmCanHoTro();
 
-- 4. Không được chạy cursor giám sát giao dịch lớn của ban quản lý
CALL GiamSatGiaoDichLon();
 
 
-- =============================================================
-- ========================= KẾT THÚC ==========================
-- =============================================================
 
RESET ROLE;
SELECT CURRENT_USER AS current_user_sau_demo, CURRENT_ROLE AS current_role_sau_demo;

