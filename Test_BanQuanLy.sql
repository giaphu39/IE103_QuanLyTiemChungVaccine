-- =========================================================================
--  KIỂM THỬ - ROLE BAN QUẢN LÝ
-- =========================================================================
SET ROLE role_quanly;
SELECT current_user; 

-- =========================================================================
-- PHẦN 1: PROCEDURE 
-- =========================================================================

-- 1.1. [THÀNH CÔNG] – Ban quản lý thêm mới thông tin một Nhân viên Hành chính vào hệ thống
CALL ThemNVHanhChinh(
    '1995-08-15'::DATE, 
    true::BOOLEAN, 
    'LE_TAN'::ChucDanhHC, 
    'Nguyễn Văn Mạnh Tuấn'::VARCHAR(100), 
    'Hà Nội'::TEXT, 
    '0912345678'::VARCHAR(10)
);

-- 1.2. [THÀNH CÔNG] - Thêm mới thông tin một Nhân viên Chuyên môn (Bác sĩ/Điều dưỡng)
CALL ThemNVChuyenMon(
    '1992-04-23'::DATE, 
    false::BOOLEAN, 
    'BAC_SI'::ChucDanhCM, 
    'CCH-123456'::VARCHAR(100),
    'Trần Thị Ngân Anh'::VARCHAR(100), 
    'TP.HCM'::TEXT,
    '0987654321'::VARCHAR(10)
);
-- 1.3. [THÀNH CÔNG] - Cập nhật thông tin hồ sơ của Nhân viên Chuyên môn vừa tạo 
CALL CapNhatNVChuyenMon(4, 'DIEU_DUONG', 'CC9999569');

-- 1.4. [THẤT BẠI] - Ban quản lý cố tình thực thi thủ tục tạo một lượt tiêm chủng mới
-- Thẩm quyền thuộc về Nhân viên Chuyên môn (Bác sĩ/Điều dưỡng) 
CALL TaoLanTiem(CURRENT_DATE, 'BINH_THUONG', 1, 1, 1, 1);

-- 1.5. [THẤT BẠI] - Ban quản lý cố tình chạy thủ tục tạo hóa đơn bán hàng
-- Thẩm quyền thuộc về Nhân viên Hành chính 
CALL TaoHoaDon('2026-02-08', 'CHUYEN_KHOAN', 300000, 1, 1);

-- =========================================================================
-- PHẦN 2: FUNCTION 
-- =========================================================================

-- HỒ SƠ & LỊCH SỬ Y TẾ

-- 2.1. [THÀNH CÔNG] - Gọi hàm tính tuổi của một khách hàng (MaKH = 1)
SELECT fn_tinh_tuoi_khach_hang(1);

-- 2.2. [THÀNH CÔNG] - Gọi hàm đếm số mũi tiêm chủng thực tế của khách hàng (MaKH = 1)
SELECT fn_dem_so_mui_tiem_khach_hang(1);

-- 2.3. [THÀNH CÔNG] - Gọi hàm tra cứu lịch sử tiêm chủng đầy đủ của một khách hàng
SELECT * FROM fn_lich_su_tiem_khach_hang(1);

-- KẾ TOÁN & DOANH THU

-- 2.4. [THÀNH CÔNG] - Ban quản lý gọi hàm tính toán tổng doanh thu hệ thống 
SELECT * FROM fn_tra_cuu_doanh_thu();

-- 2.5. [THÀNH CÔNG] - Tính tổng tiền toàn bộ hóa đơn của một khách hàng cụ thể (MaKH = 1)
SELECT fn_tong_tien_khach_hang(1::INT) AS TongTienDaThanhToan;

-- 2.6. [THÀNH CÔNG] - Tra cứu danh sách toàn bộ các hóa đơn giao dịch của khách hàng (MaKH = 1)
SELECT * FROM fn_tra_cuu_hd(1::INT);

-- QUẢN LÍ KHO & VẬT TƯ

-- 2.7. [THÀNH CÔNG] - Kiểm tra tổng lượng tồn kho thực tế của một loại vaccine dựa trên mã vaccine (MaVX = 1)
SELECT fn_ton_kho_vacxin(1::INT) AS TongSoLuongTonKho;

-- 2.8. [THÀNH CÔNG] - Liệt kê danh sách các lô vaccine sắp hết hạn trong vòng 30 ngày tới
SELECT * FROM fn_danh_sach_lo_sap_het_han(30::INT);

-- 2.13. [THÀNH CÔNG] - Thống kê tình trạng quản lý hạn sử dụng của các lô hàng theo từng cơ sở sản xuất / nhà cung cấp
SELECT * FROM fn_nha_cung_cap(NULL::VARCHAR); -- Truyền NULL để hiển thị toàn bộ nhà sản xuất

-- NHÂN SỰ

-- 2.14. [THÀNH CÔNG] - Ban quản lý kiểm tra danh sách toàn bộ hồ sơ nhân sự của trung tâm
SELECT * FROM fn_tra_cuu_thongtin_nv();

-- =========================================================================
-- PHẦN 3: VIEW 
-- =========================================================================

-- 3.1. [THÀNH CÔNG] - Ban quản lý truy vấn View tổng hợp báo cáo doanh thu tài chính theo từng hóa đơn
SELECT * FROM v_BaoCaoDoanhThuTheoHoaDon LIMIT 5;

-- 3.2. [THÀNH CÔNG] - Ban quản lý truy vấn View kiểm tra tiến độ và tỷ lệ % hoàn thành phác đồ
SELECT * FROM v_TienDoPhacDo LIMIT 5;

-- 3.3. [THÀNH CÔNG] - Ban quản lý truy vấn View kiểm kê tổng số lượng liều vaccine đang tồn kho
SELECT * FROM v_ton_kho_vacxin;

-- 3.4. [THÀNH CÔNG] - Ban quản lý truy vấn View xem lịch sử tiêm chủng tổng hợp của hệ thống
SELECT * FROM v_LichSuTiemChung;

-- 3.5. [THÀNH CÔNG] - Ban quản lý truy vấn View rà soát danh sách trẻ em (dưới 18 tuổi) bắt buộc phải có người giám hộ
SELECT * FROM v_DanhSachTreEmCanGiamHo;


-- =========================================================================
-- PHẦN 4: CURSOR 
-- =========================================================================

-- 4.1. [THÀNH CÔNG] – Ban quản lý thực thi giám sát giao dịch lớn (Đúng ma trận)
CALL GiamSatGiaoDichLon();

-- 4.2. [THÀNH CÔNG] – Ban quản lý giám sát các ca tiêm chủng để phát hiện sốc phản vệ
CALL QuetCapCuuPhanUngSauTiem();

-- 4.3. [THÀNH CÔNG] – Ban quản lý tìm kiếm các đối tượng trẻ em bị trễ lịch tiêm để hỗ trợ
CALL QuetHoSoTreEmCanHoTro();

-- 4.4. [THÀNH CÔNG] - Ban quản lý kích hoạt thủ tục kiểm tra và phát ra cảnh báo đối với các lô vaccine sắp hết hạn hoặc hết hàng trong kho
CALL KiemTraVaCanhBaoKho();

-- 4.4. [THẤT BẠI] - Ban quản lý cố tình can thiệp quy trình tự động nhắc lịch hẹn tiêm
-- Việc này thuộc phân hệ tự động/Hành chính nhắc khách 
CALL TuDongGoiYHenLichTiem(1);

-- 4.5. [THẤT BẠI] - Ban quản lý cố tình can thiệp tiến trình tự động hủy lô hàng quá hạn của Kho
-- Việc này thuộc trách nhiệm Thủ kho -> Kỳ vọng: Permission Denied
CALL TuDongXuLyLoQuaHan();


-- =========================================================================
-- KẾT THÚC
-- =========================================================================
RESET ROLE;
SELECT current_user; 













