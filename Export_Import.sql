-- =====================================================
-- EXPORT DỮ LIỆU BẢNG VACXIN RA FILE CSV
-- =====================================================

COPY VacXin(MaVX, TenVX, PhacDo, HangSX)
TO 'D:/vacxin_export.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ',',
    ENCODING 'UTF8'
);

-- =====================================================
-- IMPORT DỮ LIỆU MỚI VÀO BẢNG VACXIN
-- File CSV không cần cột MaVX vì MaVX tự tăng
-- =====================================================

COPY VacXin(TenVX, PhacDo, HangSX)
FROM 'D:/vacxin_import.csv'
WITH (
FORMAT CSV,
HEADER TRUE,
DELIMITER ',',
ENCODING 'UTF8'
); 

-- =====================================================
-- KIỂM TRA DỮ LIỆU SAU IMPORT
-- =====================================================

SELECT *
FROM VacXin
ORDER BY MaVX DESC
LIMIT 10;

SELECT COUNT(*) AS SoLuongVacXin
FROM VacXin;

SELECT *
FROM VacXin
WHERE PhacDo <= 0;
