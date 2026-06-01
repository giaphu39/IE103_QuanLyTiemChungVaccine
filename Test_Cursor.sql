Test cursor số 2 xử lý lô quá hạn
-- 1. Bắt đầu Transaction
BEGIN;

-- 2. Thêm từ khóa OVERRIDING SYSTEM VALUE để ép Postgres nhận ID giả lập của bạn
INSERT INTO VacXin (MaVX, TenVX) 
OVERRIDING SYSTEM VALUE 
VALUES (9991, 'Vắc-xin Thử Nghiệm A');

INSERT INTO VacXin (MaVX, TenVX) 
OVERRIDING SYSTEM VALUE 
VALUES (9992, 'Vắc-xin Thử Nghiệm B');

-- 3. Chèn dữ liệu Lô quá hạn (Đề phòng cột MaLo cũng là IDENTITY nên ta thêm sẵn từ khóa này luôn)
INSERT INTO LoVacXin (MaLo, MaVX, SoLuongTon, HSD) 
OVERRIDING SYSTEM VALUE
VALUES (8881, 9991, 150, CURRENT_DATE - INTERVAL '5 days');

INSERT INTO LoVacXin (MaLo, MaVX, SoLuongTon, HSD) 
OVERRIDING SYSTEM VALUE
VALUES (8882, 9992, 0, CURRENT_DATE - INTERVAL '10 days');

-- 4. Gọi thủ tục để xem Cursor in kết quả RAISE NOTICE
--CALL TuDongXuLyLoQuaHan();

-- 5. Xóa sạch dữ liệu test vừa rồi để không ảnh hưởng dữ liệu thật
ROLLBACK;
Test cursor số 3 quét phản ứng sau tiêm
-- 1. Bắt đầu Transaction
BEGIN;

-- 2. Tạo một Nhân viên chuyên môn giả lập
INSERT INTO NhanVienChuyenMon (MaNV, HoTen)
OVERRIDING SYSTEM VALUE
VALUES (99901, 'Bác sĩ Trần Thị Hoàng Yến');

-- 3. Tạo hai Khách hàng giả lập
INSERT INTO KhachHang (MaKH, HoTen)
OVERRIDING SYSTEM VALUE
VALUES 
(99901, 'Nguyễn Văn An'),
(99902, 'Lê Thị Bình');

-- 4. Tạo Sổ tiêm chủng liên kết với Khách hàng trên
INSERT INTO SoTiemChung (MaSo, MaKH)
OVERRIDING SYSTEM VALUE
VALUES 
(99901, 99901),
(99902, 99902);

-- 5. Tạo Lượt tiêm diễn ra vào HÔM NAY (CURRENT_DATE)
-- Sử dụng đúng 2 giá trị Enum để test cả 2 nhánh [MÃ ĐỎ] và [MÃ VÀNG]
INSERT INTO LanTiem (MaLT, MaSo, MaNV, NgayTiem, KetQua)
OVERRIDING SYSTEM VALUE
VALUES 
-- Trường hợp Sốc phản vệ (Nhánh IF)
(88801, 99901, 99901, CURRENT_DATE, 'SOC_PHAN_VE'::KetQuaTiemEnum),

-- Trường hợp Sốt cao (Nhánh ELSE)
(88802, 99902, 99901, CURRENT_DATE, 'SOT_CAO'::KetQuaTiemEnum);


-- 6. Thực thi thủ tục quét để xem kết quả nhảy vào cả 2 nhánh RAISE NOTICE
--CALL QuetCapCuuPhanUngSauTiem();


-- 7. Xóa sạch toàn bộ dữ liệu giả lập vừa chèn, trả lại database nguyên vẹn
ROLLBACK;
Test cursor số 6 giám sát giao dịch lớn
-- 1. Bắt đầu một Transaction
BEGIN;

-- 2. Tạm thời xóa View thật của hệ thống 
-- (Đừng lo, lệnh ROLLBACK ở cuối cùng sẽ cứu lại View thật này nguyên vẹn)
DROP VIEW IF EXISTS v_BaoCaoDoanhThuTheoHoaDon;

-- 3. Tạo một View giả lập cùng tên với đầy đủ các cột và kiểu dữ liệu để "đút" dữ liệu test vào Cursor
CREATE VIEW v_BaoCaoDoanhThuTheoHoaDon AS
SELECT 
    1001 AS MaHD, 
    'TIEN_MAT'::TEXT AS HTThanhToan, 
    2500000.00::NUMERIC(15,2) AS TongTien, 
    'Nguyễn Văn Khách A'::VARCHAR(100) AS HoTenKhachHang, 
    'Thu Ngân Tuyết'::VARCHAR(100) AS TenNhanVienThuNgan
UNION ALL
-- Trường hợp Chuyển khoản và lớn hơn 2 triệu (Test nhánh ELSIF)
SELECT 1002, 'CHUYEN_KHOAN'::TEXT, 3200000.00, 'Lê Thị Khách B', 'Thu Ngân Nam'
UNION ALL
-- Trường hợp Thẻ tín dụng và lớn hơn 2 triệu (Test nhánh ELSE)
SELECT 1003, 'THE_TIN_DUNG'::TEXT, 4500000.00, 'Trần Văn Khách C', 'Thu Ngân Nam'
UNION ALL
-- Trường hợp số tiền nhỏ hơn 2 triệu để kiểm tra xem điều kiện WHERE >= 2000000.00 trong Cursor của bạn có lọc chuẩn không (Dòng này sẽ KHÔNG được in ra)
SELECT 1004, 'TIEN_MAT'::TEXT, 500000.00, 'Phạm Văn Khách D', 'Thu Ngân Tuyết';


-- 4. Gọi thủ tục để xem Cursor in kết quả đối soát tài chính
--CALL GiamSatGiaoDichLon();


-- 5. QUAN TRỌNG NHẤT: Trả lại View thật cho database, xóa sạch toàn bộ kịch bản test vừa rồi
ROLLBACK;

