SET ROLE role_hanhchinh;

--- Vi phạm Quy tắc 1 tại trigger trg_chk_khachhang_giamho
-- Chạy độc lập câu INSERT này (không kèm thao tác chèn vào bảng giám hộ).
-- Do ràng buộc DEFERRABLE, lỗi sẽ văng ra ngay sau khi transaction kết thúc (hoặc kết thúc câu lệnh nếu chạy Auto-commit).
INSERT INTO KhachHang (NgaySinh, GioiTinh, HoTen, DiaChi, SDT)
VALUES (CURRENT_DATE - INTERVAL '10 years', true, 'Test Tre Em', 'HCM', '0999999999');


--- Vi phạm Quy tắc 1 tại trigger trg_chk_khachhang_giamho
-- Lấy 1 khách hàng đang là người lớn (>= 18 tuổi) và chưa có người giám hộ, cố tình sửa tuổi thành trẻ em (< 18 tuổi).
UPDATE KhachHang
SET NgaySinh = CURRENT_DATE - INTERVAL '5 years'
WHERE MaKH = (
    SELECT MaKH FROM KhachHang
    WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, NgaySinh)) >= 18
      AND MaKH NOT IN (SELECT MaKH FROM CHITIET_GIAMHO)
    LIMIT 1
);


--- Vi phạm Quy tắc 1 tại trigger trg_delete_update_chitiet_giamho
-- Cố tình xóa người giám hộ duy nhất của một khách hàng trẻ em (< 18 tuổi).
DELETE FROM CHITIET_GIAMHO 
WHERE MaKH = (
    SELECT kh.MaKH FROM KhachHang kh
    JOIN CHITIET_GIAMHO ct ON kh.MaKH = ct.MaKH
    WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, kh.NgaySinh)) < 18
    GROUP BY kh.MaKH HAVING COUNT(ct.MaNGH) = 1
    LIMIT 1
);

--- Vi phạm Quy tắc 1 tại trigger trg_delete_update_chitiet_giamho (Test UPDATE)
-- Cố tình đổi (chuyển) người giám hộ duy nhất của một khách hàng trẻ em sang cho người khác.
UPDATE CHITIET_GIAMHO 
SET MaKH = (
    -- Lấy đại 1 khách hàng người lớn nào đó để chuyển người giám hộ sang
    SELECT MaKH FROM KhachHang 
    WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, NgaySinh)) >= 18 
    LIMIT 1
)
WHERE MaKH = (
    -- Tìm bé dưới 18 tuổi chỉ có đúng 1 người giám hộ
    SELECT kh.MaKH FROM KhachHang kh
    JOIN CHITIET_GIAMHO ct ON kh.MaKH = ct.MaKH
    WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, kh.NgaySinh)) < 18
    GROUP BY kh.MaKH HAVING COUNT(ct.MaNGH) = 1
    LIMIT 1
);


--- Vi phạm Quy tắc 2 tại trigger trg_chk_lantiem_ins_upd
-- Lấy 1 lần tiêm ngẫu nhiên, cố tình cập nhật ngày tiêm lùi về thời điểm diễn ra TRƯỚC ngày khách hàng này mở sổ tiêm chủng.
UPDATE LanTiem 
SET NgayTiem = (
    SELECT st.NgayLapSo - INTERVAL '5 days' 
    FROM SoTiemChung st 
    WHERE st.MaSo = LanTiem.MaSo
)
WHERE MaLT = (SELECT MaLT FROM LanTiem LIMIT 1);


--- Vi phạm Quy tắc 3 tại trigger trg_chk_lantiem_ins_upd
-- Cập nhật ngày tiêm lùi về thời điểm diễn ra TRƯỚC ngày lập phiếu khám sàng lọc.
UPDATE LanTiem 
SET NgayTiem = (
    SELECT pk.NgayLap - INTERVAL '2 days' 
    FROM PhieuKhamSangLoc pk 
    WHERE pk.MaPK = LanTiem.MaPK
)
WHERE MaLT = (SELECT MaLT FROM LanTiem WHERE MaPK IS NOT NULL LIMIT 1);


--- Vi phạm Quy tắc 4 tại trigger trg_chk_lantiem_ins_upd
-- Tìm 1 phiếu khám đã bị bác sĩ kết luận 'TAM_HOAN' hoặc 'CHONG_CHI_DINH', nhưng lại cố tình sửa kết quả lần tiêm thành 'SOT_CAO' (chứng tỏ đã tiêm).
UPDATE LanTiem 
SET KetQua = 'SOT_CAO'
WHERE MaPK = (
    SELECT MaPK FROM PhieuKhamSangLoc 
    WHERE KLCuaBS IN ('TAM_HOAN', 'CHONG_CHI_DINH') 
    LIMIT 1
);


--- Vi phạm Quy tắc 9 tại trigger trg_chk_lantiem_ins_upd
-- Gắn một hóa đơn thanh toán của khách hàng (A) vào lượt tiêm (nằm trong cuốn sổ) của một khách hàng (B) khác.
UPDATE LanTiem 
SET MaHD = (
    SELECT hd.MaHD FROM HoaDon hd 
    WHERE hd.MaKH != (SELECT stc.MaKH FROM SoTiemChung stc WHERE stc.MaSo = LanTiem.MaSo) 
    LIMIT 1
)
WHERE MaLT = (SELECT MaLT FROM LanTiem LIMIT 1);


--- Vi phạm Quy tắc 6 tại trigger trg_prevent_delete_lantiem
-- Cố tình xóa vật lý một Lần tiêm đã được chốt và liên kết với Hóa đơn (MaHD IS NOT NULL).
DELETE FROM LanTiem 
WHERE MaLT = (
    SELECT MaLT FROM LanTiem WHERE MaHD IS NOT NULL LIMIT 1
);


--- Vi phạm Quy tắc 5 tại trigger trg_lantiem_lovacxin
-- Cố tình tiêm mũi có số thứ tự lớn hơn số mũi quy định trong phác đồ của loại vaccine đó.
INSERT INTO LANTIEM_LOVACXIN (MaLT, MaLo, MuiTiemThu)
SELECT 
    (SELECT MaLT FROM LanTiem LIMIT 1),
    lv.MaLo,
    vx.PhacDo + 1
FROM LoVacXin lv
JOIN VacXin vx ON lv.MaVX = vx.MaVX
LIMIT 1;


--- Vi phạm Quy tắc 7 tại trigger trg_lantiem_lovacxin
-- Trích xuất một lô vaccine đã hết hạn (HSD < Ngày tiêm của lần tiêm) để tiêm cho khách.
-- Bước 1: Sửa lại cả Ngày sản xuất và Hạn sử dụng lùi về quá khứ để lách Check Constraint
UPDATE LoVacXin 
SET NSX = '2000-01-01', HSD = '2000-12-31' 
WHERE MaLo = (SELECT MaLo FROM LoVacXin LIMIT 1);

-- Bước 2: Chạy lại lệnh INSERT để test trigger trg_lantiem_lovacxin
-- Cố tình đem lô thuốc (HSD: năm 2000) đi tiêm cho một Lần tiêm ở hiện tại/tương lai
INSERT INTO LANTIEM_LOVACXIN (MaLT, MaLo, MuiTiemThu)
VALUES (
    (SELECT MaLT FROM LanTiem WHERE NgayTiem > '2000-12-31' LIMIT 1),
    (SELECT MaLo FROM LoVacXin WHERE HSD = '2000-12-31' LIMIT 1),
    1
);


--- Quy tắc 8 tại trigger trg_lantiem_lovacxin
SELECT 
    ll.MaLT AS "MaLT_DangDung",
    ll.MaLo AS "MaLo_Cu",
    ll.MuiTiemThu,
    lv1.SoLuongTon AS "TonKho_LoCu",
    lv1.MaVX,
    (SELECT lv2.MaLo FROM LoVacXin lv2 WHERE lv2.MaVX = lv1.MaVX AND lv2.MaLo != ll.MaLo AND lv2.SoLuongTon > 0 LIMIT 1) AS "MaLo_Moi_De_Update"
FROM LANTIEM_LOVACXIN ll
JOIN LoVacXin lv1 ON ll.MaLo = lv1.MaLo
LIMIT 1;

-- 1. Thực hiện XÓA (Thay số ID thực tế truy vấn phía trên)
DELETE FROM LANTIEM_LOVACXIN WHERE MaLT = 2 AND MaLo = 2792;

-- 2. Kiểm tra lại tồn kho
-- KẾT QUẢ MONG ĐỢI: Số lượng tồn của lô cũ phải TĂNG LÊN 1 (Ví dụ: 150 -> 151)
SELECT MaLo, SoLuongTon FROM LoVacXin WHERE MaLo = 2792;

-- 1. Thực hiện THÊM LẠI (Thay bằng ID thực tế của bạn)
INSERT INTO LANTIEM_LOVACXIN (MaLT, MaLo, MuiTiemThu) VALUES (2, 2792, 1);

-- 2. Kiểm tra lại tồn kho
-- KẾT QUẢ MONG ĐỢI: Số lượng tồn của lô cũ phải GIẢM ĐI 1 (Ví dụ: Về lại 150)
SELECT MaLo, SoLuongTon FROM LoVacXin WHERE MaLo = 2792;

SELECT MaLo, SoLuongTon FROM LoVacXin WHERE MaLo = 7;
-- 1. Thực hiện ĐỔI LÔ (Thay số bằng ID thực tế của bạn)
UPDATE LANTIEM_LOVACXIN 
SET MaLo = 7
WHERE MaLT = 2 AND MaLo = 2792;

-- 2. Kiểm tra tồn kho của cả 2 lô
SELECT MaLo, SoLuongTon FROM LoVacXin WHERE MaLo IN (2792, 7);


--- Vi phạm Quy tắc 2 tại trigger trg_chk_update_sotiemchung
-- Cố tình dời ngày lập sổ (NgayLapSo) về một mốc thời gian muộn hơn ngày mà khách hàng đã thực hiện một lần tiêm trong cuốn sổ đó.
UPDATE SoTiemChung
SET NgayLapSo = (
    SELECT lt.NgayTiem + INTERVAL '5 days'
    FROM LanTiem lt 
    WHERE lt.MaSo = SoTiemChung.MaSo 
    LIMIT 1
)
WHERE MaSo = (SELECT MaSo FROM LanTiem LIMIT 1);


--- Vi phạm Quy tắc 9 tại trigger trg_chk_update_sotiemchung
-- Cố tình thay đổi người sở hữu (MaKH) của một cuốn sổ tiêm chủng, trong khi sổ này đã phát sinh các lần tiêm và được chốt hóa đơn thanh toán.
UPDATE SoTiemChung
SET MaKH = (
    SELECT kh.MaKH FROM KhachHang kh 
    WHERE kh.MaKH != SoTiemChung.MaKH 
    LIMIT 1
)
WHERE MaSo = (
    SELECT lt.MaSo FROM LanTiem lt 
    WHERE lt.MaHD IS NOT NULL 
    LIMIT 1
);


--- Vi phạm Quy tắc 3 tại trigger trg_chk_update_phieukham
-- Cố tình dời ngày lập phiếu khám sàng lọc về một mốc thời gian diễn ra sau ngày mà lần tiêm (có gắn phiếu này) đã được thực hiện.
UPDATE PhieuKhamSangLoc
SET NgayLap = (
    SELECT lt.NgayTiem + INTERVAL '2 days'
    FROM LanTiem lt 
    WHERE lt.MaPK = PhieuKhamSangLoc.MaPK 
    LIMIT 1
)
WHERE MaPK = (SELECT MaPK FROM LanTiem WHERE MaPK IS NOT NULL LIMIT 1);


--- Vi phạm Quy tắc 4 tại trigger trg_chk_update_phieukham
-- Cố tình đổi kết luận bác sĩ từ "DU_DIEU_KIEN" sang "TAM_HOAN" đối với một khách hàng đã thực sự tiêm (Lần tiêm có kết quả khác CHUA_TIEM).
UPDATE PhieuKhamSangLoc
SET KLCuaBS = 'TAM_HOAN'
WHERE MaPK = (
    SELECT pk.MaPK FROM PhieuKhamSangLoc pk
    JOIN LanTiem lt ON pk.MaPK = lt.MaPK
    WHERE pk.KLCuaBS = 'DU_DIEU_KIEN' AND lt.KetQua != 'CHUA_TIEM'
    LIMIT 1
);


--- Vi phạm Quy tắc 5 tại trigger trg_chk_update_vacxin
-- Cố tình giảm số lượng phác đồ của một loại Vaccine xuống thấp hơn số thứ tự mũi tiêm lớn nhất mà một khách hàng nào đó đã từng tiêm.
UPDATE VacXin
SET PhacDo = (
    SELECT ltlv.MuiTiemThu - 1
    FROM LANTIEM_LOVACXIN ltlv
    JOIN LoVacXin lv ON ltlv.MaLo = lv.MaLo
    WHERE lv.MaVX = VacXin.MaVX
    ORDER BY ltlv.MuiTiemThu DESC
    LIMIT 1
)
WHERE MaVX = (
    SELECT lv.MaVX FROM LANTIEM_LOVACXIN ltlv
    JOIN LoVacXin lv ON ltlv.MaLo = lv.MaLo
    WHERE ltlv.MuiTiemThu > 1
    LIMIT 1
);


--- Vi phạm Quy tắc 9 tại trigger trg_chk_update_hoadon
-- Cố tình thay đổi người thanh toán (MaKH) trên một hóa đơn đã được chốt và liên kết cứng với một cuốn sổ tiêm chủng (thông qua lần tiêm).
UPDATE HoaDon
SET MaKH = (
    SELECT kh.MaKH FROM KhachHang kh 
    WHERE kh.MaKH != HoaDon.MaKH 
    LIMIT 1
)
WHERE MaHD = (SELECT MaHD FROM LanTiem WHERE MaHD IS NOT NULL LIMIT 1);


--- Vi phạm Quy tắc 6 tại trigger trg_chk_update_hoadon
-- Cố tình dời ngày lập hóa đơn (NgayLap) về sau ngày khách hàng đã thực hiện tiêm thực tế.
UPDATE HoaDon
SET NgayLap = (
    SELECT lt.NgayTiem + INTERVAL '5 days'
    FROM LanTiem lt 
    WHERE lt.MaHD = HoaDon.MaHD 
    LIMIT 1
)
WHERE MaHD = (SELECT MaHD FROM LanTiem WHERE MaHD IS NOT NULL LIMIT 1);


--- Vi phạm Quy tắc 8 tại trigger trg_chk_update_lovacxin
-- Cố tình thay đổi trực tiếp số lượng tồn kho của một lô vaccine (hành động bị cấm vì phải do hệ thống tự động trừ lùi/hoàn kho khi có thao tác mũi tiêm).
UPDATE LoVacXin
SET SoLuongTon = SoLuongTon + 100
WHERE MaLo = (SELECT MaLo FROM LoVacXin LIMIT 1);


--- Vi phạm Quy tắc 7 tại trigger trg_chk_update_lovacxin
-- Thủ kho cố tình rút ngắn hạn sử dụng (HSD) của một lô thuốc về mốc thời gian mà trước đó hệ thống đã ghi nhận có mũi tiêm dùng lô thuốc này.
UPDATE LoVacXin
SET HSD = (
    SELECT lt.NgayTiem - INTERVAL '10 days'
    FROM LANTIEM_LOVACXIN ltlv
    JOIN LanTiem lt ON ltlv.MaLT = lt.MaLT
    WHERE ltlv.MaLo = LoVacXin.MaLo
    ORDER BY lt.NgayTiem DESC
    LIMIT 1
)
WHERE MaLo = (SELECT MaLo FROM LANTIEM_LOVACXIN LIMIT 1);


--- Vi phạm Quy tắc 10 tại trigger trg_chk_update_lovacxin
-- Cố tình đổi sai mã Vaccine (MaVX) của một lô thuốc sang một mã khác, mà sự thay đổi này vô tình gây ra lỗi trùng lặp mũi tiêm trong một cuốn sổ đã trích xuất lô này.
UPDATE LoVacXin
SET MaVX = (
    SELECT lv2.MaVX
    FROM LANTIEM_LOVACXIN ltlv1
    JOIN LanTiem lt1 ON ltlv1.MaLT = lt1.MaLT
    JOIN LanTiem lt2 ON lt1.MaSo = lt2.MaSo
    JOIN LANTIEM_LOVACXIN ltlv2 ON lt2.MaLT = ltlv2.MaLT
    JOIN LoVacXin lv2 ON ltlv2.MaLo = lv2.MaLo
    WHERE ltlv1.MaLo = LoVacXin.MaLo
      AND ltlv1.MuiTiemThu = ltlv2.MuiTiemThu
      AND ltlv1.MaLT != ltlv2.MaLT
    LIMIT 1
)
WHERE MaLo = (
    SELECT ltlv1.MaLo
    FROM LANTIEM_LOVACXIN ltlv1
    JOIN LanTiem lt1 ON ltlv1.MaLT = lt1.MaLT
    JOIN LanTiem lt2 ON lt1.MaSo = lt2.MaSo
    JOIN LANTIEM_LOVACXIN ltlv2 ON lt2.MaLT = ltlv2.MaLT
    WHERE ltlv1.MuiTiemThu = ltlv2.MuiTiemThu
      AND ltlv1.MaLT != ltlv2.MaLT
    LIMIT 1
);

