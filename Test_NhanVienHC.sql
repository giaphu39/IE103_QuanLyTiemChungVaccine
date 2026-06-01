-- =================================================================================
-- KỊCH BẢN KIỂM THỬ QUYỀN TRÊN TABLE - ROLE: NHÂN VIÊN HÀNH CHÍNH (role_hanhchinh)
-- =================================================================================
SELECT current_user;
SELECT current_role;

-- Đóng vai nhân viên hành chính
SET ROLE role_hanhchinh;

-- ---------------------------------------------------------------------------------
-- NHÓM 1: TOÀN QUYỀN CRUD (NHƯNG BỊ CHẶN DELETE)
-- Áp dụng cho: KhachHang, NguoiGiamHo, CHITIET_GIAMHO, SoTiemChung, HoaDon
-- ---------------------------------------------------------------------------------

-- 1A. Bảng KhachHang
-- [THÀNH CÔNG] Thêm mới khách hàng (Dùng năm sinh đủ 18 tuổi để không vướng Trigger Giám hộ)
INSERT INTO KhachHang (NgaySinh, GioiTinh, HoTen, DiaChi, SDT) 
VALUES ('2000-01-01', TRUE, 'Nguyễn Văn Demo', 'TP.HCM', '0901234567');

-- [THÀNH CÔNG] Truy vấn khách hàng
SELECT * FROM KhachHang WHERE SDT = '0901234567';

-- [THÀNH CÔNG] Cập nhật thông tin khách hàng
UPDATE KhachHang SET DiaChi = 'Hà Nội' WHERE SDT = '0901234567';

-- [THẤT BẠI] Xóa khách hàng (Hệ thống chặn - Permission Denied)
DELETE FROM KhachHang WHERE SDT = '0901234567';


-- 1B. Bảng HoaDon
-- [THÀNH CÔNG] Thêm hóa đơn thanh toán
INSERT INTO HoaDon (NgayLap, HTThanhToan, TongTien, MaKH, MaNV) 
VALUES (CURRENT_DATE, 'CHUYEN_KHOAN', 1500000, 1, 1);

-- [THÀNH CÔNG] Truy vấn và Cập nhật hóa đơn
SELECT * FROM HoaDon;
UPDATE HoaDon SET HTThanhToan = 'TIEN_MAT' WHERE MaHD = 1;

-- [THẤT BẠI] Xóa hóa đơn (Hệ thống chặn - Permission Denied)
DELETE FROM HoaDon WHERE MaHD = 1;


-- 1C. Bảng NguoiGiamHo
-- [THÀNH CÔNG] Thêm mới người giám hộ
INSERT INTO NguoiGiamHo (NgaySinh, GioiTinh, QHVoiNT, HoTen, DiaChi, SDT) 
VALUES ('1970-01-01', TRUE, 'CHA', 'Test Giám Hộ', 'HCM', '0999999999');

-- [THÀNH CÔNG] Truy vấn người giám hộ
SELECT * FROM NguoiGiamHo;

-- [THÀNH CÔNG] Cập nhật thông tin người giám hộ
UPDATE NguoiGiamHo SET DiaChi = 'Hà Nội' WHERE SDT = '0106530840';

-- [THẤT BẠI] Xóa người giám hộ (Hệ thống chặn - Permission Denied)
DELETE FROM NguoiGiamHo WHERE SDT = '0999999999'; 


-- 1D. Bảng SoTiemChung
-- [THÀNH CÔNG] Thêm mới sổ tiêm chủng
INSERT INTO SoTiemChung (NgayLapSo, GhiChu, TrangThai, MaKH, MaNV) 
VALUES (CURRENT_DATE, 'Sổ test', 'ACTIVE', 1, 1);

-- [THÀNH CÔNG] Truy vấn sổ tiêm chủng
SELECT * FROM SoTiemChung;

-- [THÀNH CÔNG] Cập nhật ghi chú sổ tiêm chủng
UPDATE SoTiemChung SET GhiChu = 'Sửa ghi chú' WHERE MaSo = 1;

-- [THẤT BẠI] Xóa sổ tiêm chủng (Hệ thống chặn - Permission Denied)
DELETE FROM SoTiemChung WHERE MaSo = 1; 

-- 1D. Bảng CHITIET_GIAMHO
-- [THÀNH CÔNG] Thêm, xem, sửa và [THẤT BẠI] xóa trên bảng CHITIET_GIAMHO
INSERT INTO CHITIET_GIAMHO (MaKH, MaNGH, MoiQuanHe) VALUES (1, 1, 'Cha ruột');

SELECT * FROM CHITIET_GIAMHO;

UPDATE CHITIET_GIAMHO SET MoiQuanHe = 'Cha' WHERE MaKH = 1 AND MaNGH = 1;

DELETE FROM CHITIET_GIAMHO WHERE MaKH = 1 AND MaNGH = 1;
-- ---------------------------------------------------------------------------------
-- NHÓM 2: QUYỀN THÊM VÀ XEM (BỊ CHẶN UPDATE, DELETE)
-- Áp dụng cho: LanTiem, LANTIEM_LOVACXIN (Lên lịch hẹn tiêm)
-- ---------------------------------------------------------------------------------

-- 2A. Bảng LanTiem
-- [THÀNH CÔNG] Lên lịch hẹn tiêm mới 
INSERT INTO LanTiem (NgayTiem, KetQua, MaNV, MaSo, MaPK, MaHD) 
VALUES (CURRENT_DATE, 'BINH_THUONG', 1, 1, 1, 1);

-- [THÀNH CÔNG] Xem danh sách lần tiêm
SELECT * FROM LanTiem;

-- [THẤT BẠI] Cố tình cập nhật kết quả tiêm (Quyền của bác sĩ)
UPDATE LanTiem SET KetQua = 'BINH_THUONG' WHERE MaLT = 1;

-- [THẤT BẠI] Xóa lịch tiêm
DELETE FROM LanTiem WHERE MaLT = 1;


-- 2B. Bảng LANTIEM_LOVACXIN
-- [THÀNH CÔNG] Lên chi tiết lô vaccine cho lần tiêm
INSERT INTO LANTIEM_LOVACXIN (MaLT, MaLo, MuiTiemThu) 
VALUES (1, 3, 1);

-- [THÀNH CÔNG] Xem danh sách chi tiết lô vaccine hẹn tiêm
SELECT * FROM LANTIEM_LOVACXIN;

-- [THẤT BẠI] Cố tình cập nhật lô vaccine
UPDATE LANTIEM_LOVACXIN SET MaLo = 2 WHERE MaLT = 1; 

-- [THẤT BẠI] Xóa chi tiết lô vaccine cho lần tiêm
DELETE FROM LANTIEM_LOVACXIN WHERE MaLT = 1; 


-- ---------------------------------------------------------------------------------
-- NHÓM 3: CHỈ ĐƯỢC XEM (BỊ CHẶN INSERT, UPDATE, DELETE)
-- Áp dụng cho: PhieuKhamSangLoc, VacXin, BenhPhongNgua, VACXIN_BENHPHONGNGUA, LoVacXin, NhanVienHanhChinh
-- ---------------------------------------------------------------------------------

-- 3A. Bảng PhieuKhamSangLoc (Hỗ trợ in phiếu/thu tiền)
-- [THÀNH CÔNG] Đọc dữ liệu phiếu khám
SELECT * FROM PhieuKhamSangLoc;

-- [THẤT BẠI] Cố tình thêm phiếu khám mới
INSERT INTO PhieuKhamSangLoc (NgayLap, NhietDo, ChieuCao, CanNang, KLCuaBS, TSDiUng, MaNV) 
VALUES (CURRENT_DATE, 37.0, 160.0, 50.0, 'DU_DIEU_KIEN', 'Không', 1);

-- [THẤT BẠI] Cố tình sửa kết luận của bác sĩ
UPDATE PhieuKhamSangLoc SET KLCuaBS = 'TAM_HOAN' WHERE MaPK = 1;


-- 3B. Bảng VacXin & LoVacXin (Xem danh mục vật tư)
-- [THÀNH CÔNG] Tra cứu loại vaccine và lô vaccine
SELECT * FROM VacXin;
SELECT * FROM LoVacXin;

-- [THẤT BẠI] Hành chính cố tình thay đổi số lượng tồn kho hoặc phác đồ
UPDATE LoVacXin SET SoLuongTon = 9999 WHERE MaLo = 1;
UPDATE VacXin SET PhacDo = 5 WHERE MaVX = 1;
DELETE FROM VacXin WHERE MaVX = 1;


-- 3C. Bảng NhanVienHanhChinh (Tài khoản cá nhân)
-- [THÀNH CÔNG] Tra cứu thông tin cá nhân/đồng nghiệp
SELECT * FROM NhanVienHanhChinh;

-- [THẤT BẠI] Cố tình đổi chức danh từ Lễ tân lên Quản lý (Quyền của Ban Quản lý)
UPDATE NhanVienHanhChinh SET ChucDanh = 'QUAN_LY' WHERE MaNV = 1;


-- 3D. Bảng BenhPhongNgua & VACXIN_BENHPHONGNGUA (Xem danh mục bệnh)
-- [THÀNH CÔNG] Tra cứu bệnh phòng ngừa và mapping vaccine
SELECT * FROM BenhPhongNgua;
SELECT * FROM VACXIN_BENHPHONGNGUA;

-- [THẤT BẠI] Cố tình thêm bệnh phòng ngừa mới vào danh mục
INSERT INTO BenhPhongNgua (TenBPN, MucDoNguyHiem) 
VALUES ('Bệnh Test', 'CAO');

--Dữ liệu bị cấm xem 
-- [THẤT BẠI] Cố tình xem danh sách Nhân viên chuyên môn
SELECT * FROM NhanVienChuyenMon;

-- =================================================================================
-- KỊCH BẢN KIỂM THỬ QUYỀN TRÊN PROCEDURE - ROLE: NHÂN VIÊN HÀNH CHÍNH (role_hanhchinh)
-- =================================================================================
-- ---------------------------------------------------------------------------------
-- NHÓM 1: CÁC THỦ TỤC ĐƯỢC PHÉP CHẠY (THÀNH CÔNG)
-- Bao gồm: Quản lý khách hàng, người giám hộ, hóa đơn, sổ tiêm và tạo lịch tiêm
-- ---------------------------------------------------------------------------------

-- 1A. Quản lý Khách hàng & Người giám hộ
-- [THÀNH CÔNG] Thêm mới thông tin khách hàng
CALL LuuThongTinKhachHang('1990-05-15', TRUE, 'Nguyễn Văn Test', 'TP.HCM', '0909090909');

-- [THÀNH CÔNG] Cập nhật thông tin khách hàng
CALL CapNhatKhachHang(1, 'Nguyễn Văn Test Update', '1990-05-15', TRUE, 'Hà Nội', '0909090909');

-- [THÀNH CÔNG] Thêm người giám hộ (dành cho trường hợp khách dưới 18 tuổi)
CALL LuuThongTinNguoiGiamHo('1965-01-01', TRUE, 'CHA', 'Trần Văn Giám Hộ', 'TP.HCM', '0808080808');

-- [THÀNH CÔNG] Móc nối chi tiết giám hộ với khách hàng
CALL TaoChiTietGiamHo(1, 5, 'Cha ruột');


-- 1B. Quản lý Sổ tiêm chủng & Hóa đơn
-- [THÀNH CÔNG] Tạo sổ tiêm chủng mới
CALL TaoSoTiemChung(CURRENT_DATE, 'Khách hàng mới tạo sổ', 'ACTIVE', 1, 1);

-- [THÀNH CÔNG] Cập nhật ghi chú và trạng thái sổ tiêm
CALL CapNhatSoTiem(1, 'Đã cập nhật ghi chú', 'ACTIVE');

-- [THÀNH CÔNG] Cập nhật trạng thái tổng thể của hồ sơ
CALL CapNhatTTHoSo(1, 'COMPLETED', 1, 1);

-- [THÀNH CÔNG] Tạo hóa đơn thu tiền
CALL TaoHoaDon(CURRENT_DATE, 'TIEN_MAT', 450000, 1, 1);

-- [THÀNH CÔNG] Cập nhật hình thức thanh toán của hóa đơn
CALL CapNhatThanhToanHoaDon(1, 'CHUYEN_KHOAN', 450000);


-- 1C. Quản lý Lịch hẹn tiêm
-- [THÀNH CÔNG] Tạo lịch tiêm mới (Trạng thái mặc định khi hẹn là CHUA_TIEM)
CALL TaoLanTiem(CURRENT_DATE, 'BINH_THUONG', 1, 1, 1, 1);

-- [THÀNH CÔNG] Trích xuất lô vaccine cho lần tiêm (Mũi tiêm thứ 1)
CALL TaoLanTiemLoVacXin(1, 5, 1);


-- ---------------------------------------------------------------------------------
-- NHÓM 2: CÁC THỦ TỤC BỊ CHẶN (THẤT BẠI - VƯỢT QUYỀN)
-- Hành chính cố tình gọi các hàm thuộc nghiệp vụ Chuyên môn, Kho hoặc Quản lý
-- ---------------------------------------------------------------------------------

-- 2A. Vượt quyền Chuyên môn (Bác sĩ)
-- [THẤT BẠI] Cố tình tạo phiếu khám sàng lọc
-- Kết quả mong đợi: ERROR: permission denied for procedure taophieukhamsangloc
CALL TaoPhieuKhamSangLoc(CURRENT_DATE, 37.0, 160.0, 50.0, 'DU_DIEU_KIEN', 'Không', 1);

-- [THẤT BẠI] Cố tình cập nhật kết luận của bác sĩ
CALL CapNhatKetLuanBacSi(1, 'TAM_HOAN');

-- [THẤT BẠI] Cố tình cập nhật kết quả phản ứng sau tiêm
CALL CapNhatKetQuaLanTiem(1, 'BINH_THUONG');


-- 2B. Vượt quyền Quản lý Kho
-- [THẤT BẠI] Cố tình thêm vaccine mới vào danh mục
-- Kết quả mong đợi: ERROR: permission denied for procedure taovacxin
CALL TaoVacXin('Vaccine Covid 19', 2, 'Pfizer');

-- [THẤT BẠI] Cố tình tạo lô vaccine mới để nhập kho
CALL TaoLoVacXin('2027-01-01', 'Mỹ', '2025-01-01', 1000, 1);

-- [THẤT BẠI] Cố tình sửa hạn sử dụng của lô vaccine
CALL CapNhatHSDxxLoVacXin(1, '2028-12-31');

-- [THẤT BẠI] Cố tình thêm hoặc cập nhật danh mục bệnh phòng ngừa
CALL LuuTenBenhPhongNgua('Bệnh Dại','CAO');
CALL TaoVacXinBenhPhongNgua(1, 1);
CALL CapNhatMucDoNguyHiemBenh(1, 'CAO');


-- 2C. Vượt quyền Ban Quản Lý (Admin)
-- [THẤT BẠI] Cố tình tạo tài khoản nhân sự mới (Hành chính tự cấp tài khoản)
-- Kết quả mong đợi: ERROR: permission denied for procedure themnvhanhchinh
CALL ThemNVHanhChinh('1995-01-01', FALSE, 'LE_TAN', 'Nhân viên Hack', 'HCM', '0111111111');

-- [THẤT BẠI] Cố tình cập nhật chức danh cho nhân viên chuyên môn
CALL CapNhatNVChuyenMon(1, 'BAC_SI', 'CC_FAKE_123');

-- [THẤT BẠI] Cố tình tạo tài khoản cho nhân viên chuyên môn
CALL ThemNVChuyenMon(
    '1990-01-01'::DATE,           -- 1. p_NgaySinh (ép kiểu DATE)
    TRUE,                         -- 2. p_GioiTinh (BOOLEAN)
    'BAC_SI'::ChucDanhCM,         -- 3. p_ChucDanh (ÉP KIỂU RÕ RÀNG VỀ ENUM ChucDanhCM)
    'CCHN123456',                 -- 4. p_CCHanhNghe (VARCHAR)
    'Nguyễn Văn A',               -- 5. p_HoTen (VARCHAR)
    '123 Đường ABC, TP.HCM',      -- 6. p_DiaChi (TEXT)
    '0901234567'                  -- 7. p_SDT (VARCHAR 10)
);
-- =================================================================================
-- KỊCH BẢN KIỂM THỬ QUYỀN TRÊN CURSOR PROCEDURE - ROLE: NHÂN VIÊN HÀNH CHÍNH
-- =================================================================================
-- ---------------------------------------------------------------------------------
-- NHÓM 1: CÁC CURSOR THỦ TỤC ĐƯỢC PHÉP CHẠY (THÀNH CÔNG)
-- Chức năng: Chăm sóc khách hàng và rà soát hồ sơ pháp lý
-- ---------------------------------------------------------------------------------

-- 1A. [THÀNH CÔNG] Chạy tiến trình tự động phân tích và gợi ý lịch hẹn tiêm tiếp theo 
-- (Truyền vào ID khách hàng hợp lệ, ví dụ: 1)
CALL TuDongGoiYHenLichTiem(1);

-- 1B. [THÀNH CÔNG] Chạy tiến trình rà soát hồ sơ trẻ em chưa có người giám hộ hợp lệ
CALL QuetHoSoTreEmCanHoTro();


-- ---------------------------------------------------------------------------------
-- NHÓM 2: CÁC CURSOR THỦ TỤC BỊ CHẶN (THẤT BẠI - VƯỢT QUYỀN)
-- Hành chính cố tình quét dữ liệu y tế, kho bãi hoặc tài chính cấp cao
-- ---------------------------------------------------------------------------------

-- 2A. Vượt quyền Kho
-- [THẤT BẠI] Cố tình chạy tiến trình kiểm tra và cảnh báo lô vaccine
-- Kết quả mong đợi: ERROR: permission denied for procedure kiemtravacanhbaokho
CALL KiemTraVaCanhBaoKho();

-- [THẤT BẠI] Cố tình chạy tiến trình tự động xử lý/cô lập lô vaccine quá hạn
-- Kết quả mong đợi: ERROR: permission denied for procedure tudongxulyloquahan
CALL TuDongXuLyLoQuaHan();


-- 2B. Vượt quyền Chuyên môn (Y Bác sĩ)
-- [THẤT BẠI] Cố tình quét hệ thống giám sát cấp cứu phản ứng sau tiêm
-- Kết quả mong đợi: ERROR: permission denied for procedure quetcapcuuphanungsautiem
CALL QuetCapCuuPhanUngSauTiem();


-- 2C. Vượt quyền Ban Quản lý (Kế toán trưởng / Admin)
-- [THẤT BẠI] Cố tình chạy hệ thống kiểm soát và đối soát các giao dịch tài chính lớn
-- Kết quả mong đợi: ERROR: permission denied for procedure giamsatgiaodichlon
CALL GiamSatGiaoDichLon();

-- =================================================================================
-- KỊCH BẢN KIỂM THỬ QUYỀN TRÊN FUNCTION - ROLE: NHÂN VIÊN HÀNH CHÍNH
-- =================================================================================
-- ---------------------------------------------------------------------------------
-- NHÓM 1: CÁC HÀM ĐƯỢC PHÉP THỰC THI (THÀNH CÔNG)
-- Phục vụ nghiệp vụ tính toán, tra cứu thông tin khách hàng, hóa đơn, vật tư cơ bản
-- ---------------------------------------------------------------------------------

-- 1A. [THÀNH CÔNG] Hàm tính toán giá trị đơn (Scalar Functions)
-- Tính tuổi khách hàng
SELECT fn_tinh_tuoi_khach_hang(1);

-- Đếm số mũi tiêm của khách hàng
SELECT fn_dem_so_mui_tiem_khach_hang(1);

-- Tính tổng tiền hóa đơn của khách hàng
SELECT fn_tong_tien_khach_hang(1);

-- Kiểm tra tổng tồn kho của một loại vaccine
SELECT fn_ton_kho_vacxin(1);


-- 1B. [THÀNH CÔNG] Hàm trả về dạng bảng (Table Functions)
-- Tra cứu lịch sử tiêm chủng chi tiết của khách hàng
SELECT * FROM fn_lich_su_tiem_khach_hang(1);

-- Tra cứu lịch sử tiêm (hàm bổ sung)
SELECT * FROM fn_tra_cuu_ls_tiem(1);

-- Tra cứu danh sách các lần tiêm của hệ thống
SELECT * FROM fn_tra_cuu_lan_tiem();

-- Tra cứu danh sách hóa đơn của khách hàng
SELECT * FROM fn_tra_cuu_hd(1);

-- Tra cứu tổng số lượng tồn kho theo từng loại vaccine (hỗ trợ tư vấn)
SELECT * FROM fn_tra_cuu_sl_vacxin(NULL);

-- Tra cứu thông tin danh bạ nhân sự trong hệ thống
SELECT * FROM fn_tra_cuu_thongtin_nv();

-- [Thành công] xem chi tiết kết luận khám bệnh của bác sĩ 
SELECT fn_kiem_tra_du_dieu_kien_tiem(1);
-- ---------------------------------------------------------------------------------
-- NHÓM 2: CÁC HÀM BỊ CHẶN (THẤT BẠI - VƯỢT QUYỀN)
-- Hành chính cố tình gọi các hàm thuộc nghiệp vụ Chuyên môn, Kho hoặc Quản lý
-- ---------------------------------------------------------------------------------

-- 2B. Vượt quyền Quản lý Kho
-- [THẤT BẠI] Cố tình xem danh sách các lô vaccine sắp hết hạn
-- Kết quả mong đợi: ERROR: permission denied for function fn_danh_sach_lo_sap_het_han
SELECT * FROM fn_danh_sach_lo_sap_het_han(30);

-- [THẤT BẠI] Cố tình xem thống kê chuyên sâu về số lần sử dụng vaccine
-- Kết quả mong đợi: ERROR: permission denied for function fn_thong_ke_su_dung_vacxin
SELECT * FROM fn_thong_ke_su_dung_vacxin('2026-01-01', '2026-12-31');

-- [THẤT BẠI] Cố tình tra cứu chi tiết thông tin các lô vaccine (NSX, HSD, Lô...)
-- Kết quả mong đợi: ERROR: permission denied for function fn_tra_cuu_lo_vacxin
SELECT * FROM fn_tra_cuu_lo_vacxin(NULL, NULL, NULL);

-- [THẤT BẠI] Cố tình xem thông tin đối tác/nhà cung cấp vaccine
-- Kết quả mong đợi: ERROR: permission denied for function fn_nha_cung_cap
SELECT * FROM fn_nha_cung_cap(NULL);


-- 2C. Vượt quyền Ban Quản lý
-- [THẤT BẠI] Cố tình tra cứu tổng doanh thu toàn hệ thống theo ngày
-- Kết quả mong đợi: ERROR: permission denied for function fn_tra_cuu_doanh_thu
SELECT * FROM fn_tra_cuu_doanh_thu();

-- [THẤT BẠI] Cố tình tra cứu tổng số lượng hóa đơn xuất ra theo ngày
-- Kết quả mong đợi: ERROR: permission denied for function fn_tra_cuu_sl_hd
SELECT * FROM fn_tra_cuu_sl_hd();

-- =================================================================================
-- KỊCH BẢN KIỂM THỬ QUYỀN TRÊN VIEW - ROLE: NHÂN VIÊN HÀNH CHÍNH (role_hanhchinh)
-- =================================================================================
-- ---------------------------------------------------------------------------------
-- NHÓM 1: CÁC VIEW ĐƯỢC PHÉP TRUY VẤN (THÀNH CÔNG)
-- Chức năng: Đọc và trích xuất báo cáo, thống kê, danh sách phục vụ nghiệp vụ
-- ---------------------------------------------------------------------------------

-- 1A. [THÀNH CÔNG] Xem chi tiết lịch sử tiêm chủng của khách hàng
SELECT * FROM v_LichSuTiemChung LIMIT 5;

-- 1B. [THÀNH CÔNG] Xem danh sách trẻ em (dưới 18 tuổi) kèm thông tin người giám hộ hợp pháp
SELECT * FROM v_DanhSachTreEmCanGiamHo LIMIT 5;

-- 1C. [THÀNH CÔNG] Xem báo cáo tổng hợp doanh thu chi tiết theo từng hóa đơn
SELECT * FROM v_BaoCaoDoanhThuTheoHoaDon LIMIT 5;

-- 1D. [THÀNH CÔNG] Xem thống kê tổng quan về trạng thái tồn kho của các loại vaccine
SELECT * FROM v_ton_kho_vacxin LIMIT 5;

-- 1E. [THÀNH CÔNG] Xem tiến độ và trạng thái hoàn thành phác đồ tiêm của khách hàng
SELECT * FROM v_TienDoPhacDo LIMIT 5;


-- ---------------------------------------------------------------------------------
-- NHÓM 2: CÁC THAO TÁC BỊ CHẶN (THẤT BẠI - VƯỢT QUYỀN)
-- Nhân viên hành chính chỉ được cấp quyền SELECT. Mọi thao tác DML đều bị chặn đứng.
-- ---------------------------------------------------------------------------------

-- 2A. [THẤT BẠI] Cố tình xóa dữ liệu hóa đơn thông qua View báo cáo doanh thu
-- Kết quả mong đợi: ERROR: permission denied for view v_baocaodoanhthutheohoadon
DELETE FROM v_BaoCaoDoanhThuTheoHoaDon WHERE MaHD = 1;

-- 2B. [THẤT BẠI] Cố tình cập nhật đổi tên trẻ em thông qua View danh sách giám hộ
-- Kết quả mong đợi: ERROR: permission denied for view v_danhsachtreemcangiamho
UPDATE v_DanhSachTreEmCanGiamHo SET HoTenTreEm = 'Tên Hack Cập Nhật' WHERE MaKH = 1;

-- 2C. [THẤT BẠI] Cố tình chèn thêm vật tư ảo thông qua View tồn kho
-- Kết quả mong đợi: ERROR: permission denied for view v_ton_kho_vacxin
INSERT INTO v_ton_kho_vacxin (MaVX, TenVX, HangSX, PhacDo) 
VALUES (999, 'Vaccine Lậu', 'Fake Pharma', 2);


-- =================================================================================
-- TRẢ LẠI QUYỀN TỐI CAO
-- =================================================================================
RESET ROLE;