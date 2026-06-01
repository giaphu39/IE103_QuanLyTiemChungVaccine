---- Tra cứu LichSuTiemChung
CREATE OR REPLACE VIEW v_LichSuTiemChung AS
SELECT
    kh.MaKH,
    kh.HoTen AS HoTenKhachHang,
    lt.NgayTiem,

    CASE
        WHEN lt.KetQua = 'CHUA_TIEM' THEN 'Chưa tiêm - không dùng vắc xin'
        ELSE COALESCE(vx.TenVX, 'Thiếu liên kết vắc xin')
    END::VARCHAR(100) AS TenVacXin,

    CASE
        WHEN lt.KetQua = 'CHUA_TIEM' THEN NULL
        ELSE ltlvx.MuiTiemThu
    END AS MuiTiemThu,

    pksl.NhietDo,
    pksl.CanNang,
    lt.KetQua AS KetQuaSauTiem,
    pksl.KLCuaBS AS KetLuanBacSi,
    fn_kiem_tra_du_dieu_kien_tiem(pksl.MaPK) AS KetLuan,
    nv_kham.HoTen AS TenBacSiKhamSangLoc,
    nv_tiem.HoTen AS TenNhanVienTiem
FROM KhachHang kh
JOIN SoTiemChung stc ON kh.MaKH = stc.MaKH
JOIN LanTiem lt ON stc.MaSo = lt.MaSo
LEFT JOIN PhieuKhamSangLoc pksl ON lt.MaPK = pksl.MaPK
LEFT JOIN NhanVienChuyenMon nv_kham ON pksl.MaNV = nv_kham.MaNV
LEFT JOIN NhanVienChuyenMon nv_tiem ON lt.MaNV = nv_tiem.MaNV
LEFT JOIN LANTIEM_LOVACXIN ltlvx ON lt.MaLT = ltlvx.MaLT
LEFT JOIN LoVacXin lvx ON ltlvx.MaLo = lvx.MaLo
LEFT JOIN VacXin vx ON lvx.MaVX = vx.MaVX;

--================v_DanhSachTreEmCanGiamHo
CREATE OR REPLACE VIEW v_DanhSachTreEmCanGiamHo AS
SELECT
    kh.MaKH,
    kh.HoTen AS HoTenTreEm,
	CASE
        WHEN kh.GioiTinh = TRUE THEN 'Nam'
        WHEN kh.GioiTinh = FALSE THEN 'Nu'
        ELSE 'Chua xac dinh'
    END AS GioiTinh,
    kh.NgaySinh AS NgaySinhTreEm,
    fn_tinh_tuoi_khach_hang(kh.MaKH) AS Tuoi,
    ngh.MaNGH,
    ngh.HoTen AS HoTenNguoiGiamHo,
    ngh.SDT AS SDTNguoiGiamHo,
    ctgh.MoiQuanHe
FROM KhachHang kh
JOIN CHITIET_GIAMHO ctgh
    ON kh.MaKH = ctgh.MaKH
JOIN NguoiGiamHo ngh
    ON ctgh.MaNGH = ngh.MaNGH
WHERE fn_tinh_tuoi_khach_hang(kh.MaKH) < 18;

--===============Tra cứu BaoCaoDoanhThuTheoHoaDon
CREATE OR REPLACE VIEW v_BaoCaoDoanhThuTheoHoaDon AS
SELECT
    hd.MaHD,
    hd.NgayLap,
    hd.HTThanhToan,
    hd.TongTien,
    kh.MaKH,
    kh.HoTen AS HoTenKhachHang,
    nvhc.MaNV,
    nvhc.HoTen AS TenNhanVienThuNgan
FROM HoaDon hd
JOIN KhachHang kh
    ON hd.MaKH = kh.MaKH
JOIN NhanVienHanhChinh nvhc
    ON hd.MaNV = nvhc.MaNV;

--===========================View thống kê tồn kho vaccine

CREATE OR REPLACE VIEW v_ton_kho_vacxin AS
SELECT 
    vx.MaVX,
    vx.TenVX,
    vx.HangSX,
    vx.PhacDo,
    COUNT(lvx.MaLo) AS SoLoVacXin,
    fn_ton_kho_vacxin(vx.MaVX) AS TongSoLuongTon,
    MIN(CASE WHEN lvx.SoLuongTon > 0 THEN lvx.HSD END) AS HanSuDungGanNhat
FROM VacXin vx
LEFT JOIN LoVacXin lvx 
    ON vx.MaVX = lvx.MaVX
GROUP BY 
    vx.MaVX,
    vx.TenVX,
    vx.HangSX,
    vx.PhacDo;



--===============v_TienDoPhacDo
CREATE OR REPLACE VIEW v_TienDoPhacDo AS
SELECT 
    kh.MaKH, 
    kh.HoTen AS HoTenKhachHang, 
    kh.SDT,
    vx.MaVX, 
    vx.TenVX, 
    vx.PhacDo AS TongSoMuiYeuCau,
    COUNT(DISTINCT ltlv.MuiTiemThu) AS SoMuiDaTiem,
    MAX(lt.NgayTiem) AS NgayTiemGanNhat,
    CASE
        WHEN COUNT(ltlv.MuiTiemThu) >= vx.PhacDo THEN 'HOAN_THANH'
        ELSE 'DANG_TIEM'
    END AS TrangThaiPhacDo
FROM KhachHang kh
JOIN SoTiemChung stc ON kh.MaKH = stc.MaKH
JOIN LanTiem lt ON stc.MaSo = lt.MaSo
JOIN LANTIEM_LOVACXIN ltlv ON lt.MaLT = ltlv.MaLT
JOIN LoVacXin lv ON ltlv.MaLo = lv.MaLo
JOIN VacXin vx ON lv.MaVX = vx.MaVX
GROUP BY 
    kh.MaKH, kh.HoTen, kh.SDT, vx.MaVX, vx.TenVX, vx.PhacDo;

 ---========
SELECT * FROM v_LichSuTiemChung ;

SELECT * FROM v_DanhSachTreEmCanGiamHo;

SELECT * FROM v_BaoCaoDoanhThuTheoHoaDon;

SELECT * FROM v_ton_kho_vacxin;

SELECT * FROM v_TienDoPhacDo;




