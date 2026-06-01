-- =============================================================
-- ========================= PROCEDURE =========================
-- =============================================================


-- Tạo vaccine
SELECT * FROM VacXin
--1. Hợp lệ
CALL TaoVacXin('Pfizer-BioNTech Comirnaty', 25, 'BioNTech');
--2. Tên vắc-xin rỗng
CALL TaoVacXin('', 17, 'MSD');
--3. Tên hãng xản xuất rỗng
CALL TaoVacXin('Engerix-B ', 20, '');
--4. Phác độ âm
CALL TaoVacXin('Infanrix Hexa ', -1, 'GSK');
--5. Trùng tên và nhà sản xuất ( không tự động update )
CALL TaoVacXin('Pfizer-BioNTech Comirnaty', 16, 'BioNTech');


-- Tạo lô vaccine ( HSD, NoiSX, NgaySX, SoLuong, MaVX )
SELECT * FROM LoVacXin
--1. Hợp Lệ
CALL TaoLoVacXin('2028-12-31', 'Germany', '2026-03-02', 5000000, 13);
--2. Ngày sản xuất ở tương lai 
CALL TaoLoVacXin('2028-12-31', 'United States', '2028-04-09', 400000, 2);
--3. Hạn ngày sử dụng < ngày sản xuất
CALL TaoLoVacXin('2022-12-31', 'Belgium', '2026-02-03', 120000, 3);
--4. MaVX không tồn tại hoặc số lượng âm
CALL TaoLoVacXin('2028-12-31', 'Belgium', '2026-01-02', -1, 1);
--5. Trùng nơi sản xuất và mã vacxin ( không tự động update )  
CALL TaoLoVacXin('2028-12-31', 'Nha May Co So 7', '2026-04-03', 100000, 7);


-- Lưu tên bệnh phòng ngừa ( TenBPN, MucDoNguyHiem )
SELECT * FROM BenhPhongNgua
--1. Hợp lệ 
CALL LuuTenBenhPhongNgua('COVID-19', 'THAP');
--2. Trống tên 
CALL LuuTenBenhPhongNgua('', 'THAP');
--3. Mức độ nguy hiểm không hợp lệ
CALL LuuTenBenhPhongNgua('Viem gan B', 'U_LA_TROI_NGUY_HIEM_DA_MAN');
--4. Tên bệnh đã tồn tại
CALL LuuTenBenhPhongNgua('COVID-19', 'TRUNG_BINH');


-- Tạo vaccine bệnh phòng ngừa (MaVX, MaBPN)
SELECT * FROM BenhPhongNgua
SELECT * FROM VacXin
--1. Hợp lệ ( Liên kết Pfizer và COVID )
CALL TaoVacXinBenhPhongNgua(13, 11); 
--2. Vắc-xin không tồn tại
CALL TaoVacXinBenhPhongNgua(36, 2);
--3. Bệnh phòng ngừa không tồn tại
CALL TaoVacXinBenhPhongNgua(2, 36);
--4. Liên kết đã tồn tại
CALL TaoVacXinBenhPhongNgua(13,11);


-- Cập nhật mức độ nguy hiểm bệnh
-- Cập nhật mức độ nguy hiểm bệnh ( MaBPN, MucDoNguyeHiem )
SELECT * FROM BenhPhongNgua
--1. Hợp lệ
CALL CapNhatMucDoNguyHiemBenh(11, 'TRUNG_BINH');
--2. Mã bệnh không tồn tại
CALL CapNhatMucDoNguyHiemBenh(67, 'THAP');
--3. Mức độ nguy hiểm không hợp lệ
CALL CapNhatMucDoNguyHiemBenh(1, 'GAN_CAO');


-- Cập nhật hạn sử dụng lô vaccine
SELECT * FROM LoVacXin
--1. Hợp lệ
CALL CapNhatHSDLoVacXin(5004, '2030-12-06');
--2. Hạn sử dụng không được nhỏ hơn ngày hiện tại
CALL CapNhatHSDLoVacXin(5004, '1999-10-26');
--3. Mã lô vắc-xin không tồn tại
CALL CapNhatHSDLoVacXin(6736, '2031-10-01');


-- =============================================================
-- ========================= FUNCTION ==========================
-- =============================================================


--Hàm kiểm tra tổng tồn kho của một loại vaccine ( MaVX )
--1. Hợp lệ
SELECT fn_ton_kho_vacxin(1);
--2. Sai mã vacxin
SELECT fn_ton_kho_vacxin(123);
--3. Để trống
SELECT fn_ton_kho_vacxin();


-- Hàm tìm tổng số lượng vacxin ( TenVX )
--1. Tìm tất cả
SELECT * FROM fn_tra_cuu_sl_vacxin(NULL);
--2. Tìm dựa theo tên
SELECT * FROM fn_tra_cuu_sl_vacxin('Pfizer');
--3. Vaccine không tồn tại
SELECT * FROM fn_tra_cuu_sl_vacxin('Thuoc La');


-- Hàm liệt kê các lô vaccine sắp hết hạn
--1. 10 tháng
SELECT * FROM fn_danh_sach_lo_sap_het_han(230);
--2. 1 năm
SELECT * FROM fn_danh_sach_lo_sap_het_han(365);
--3. Thời gian bị âm
SELECT * FROM fn_danh_sach_lo_sap_het_han(-1);
--4. Còn hạn trong > 1 năm
SELECT * FROM fn_danh_sach_lo_sap_het_han(1000);


-- Hàm thống kê số lần sử dụng từng loại vaccine (TuNgay, DenNgay)
--1. Hợp lệ
SELECT * FROM fn_thong_ke_su_dung_vacxin('2025-01-01', '2025-12-31');
--2. Rỗng -> Trả về tất cả
SELECT * FROM fn_thong_ke_su_dung_vacxin();
--3. DenNgay bị rỗng --> Trả về các loại vaccine đã sử dụng từ TuNgay trở đi
SELECT *FROM fn_thong_ke_su_dung_vacxin('2025-06-01', NULL);
--4. TuNgay bị rỗng --> Trả về các loại vaccine đã sử dụng từ DenNgay trở về trước
SELECT * FROM fn_thong_ke_su_dung_vacxin(NULL, '2025-06-30');
--5. DenNgay < TuNgay
SELECT * FROM fn_thong_ke_su_dung_vacxin('2025-12-31', '2025-01-01');


-- Hàm tra cứu danh sách tất cả các lô vaccine trong hệ thống (TenVX, ChiConTon, p_ChiConHan)
-- ConTon: Số lượng còn lại
-- ConHan: Hạn sử dụng
--1. Hợp lệ
SELECT * FROM fn_tra_cuu_lo_vacxin('BCG (Viet Nam)', TRUE, TRUE);
--2. Rỗng --> Tìm tất cả
SELECT * FROM fn_tra_cuu_lo_vacxin();
--3. Số lượng > 0 và còn hạn
SELECT * FROM fn_tra_cuu_lo_vacxin('Imojev', TRUE, TRUE);
--4. Hết hạn và Số lượng < 0
SELECT * FROM fn_tra_cuu_lo_vacxin('Synflorix', FALSE, FALSE);


-- Tìm nhà cung cấp ( NoiSX )
--1. Hợp lệ
SELECT * FROM fn_nha_cung_cap('Germany');
--2. Rỗng --> Trả về tất cả
SELECT * FROM fn_nha_cung_cap();
--3. Không có nhà cung cấp này
SELECT * FROM fn_nha_cung_cap('France');


-- =============================================================
-- =========================== VIEW ============================
-- =============================================================

-- Thống kê tình trạng tồn kho của từng loại vắc xin
SELECT * FROM v_ton_kho_vacxin

-- =============================================================
-- ========================== CURSOR ===========================
-- =============================================================

-- Cursor
-- KiemTraVaCanhBaoKho: quét toàn bộ kho vaccine và in ra các cảnh báo về tình trạng từng lô vaccine.
CALL KiemTraVaCanhBaoKho();

-- TuDongXuLyLoQuaHan: mô phỏng một quy trình tự động xử lý các lô vaccine đã hết hạn trong kho.
CALL TuDongXuLyLoQuaHan();



