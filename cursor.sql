--Cursor kiểm tra và cảnh báo kho
CREATE OR REPLACE PROCEDURE KiemTraVaCanhBaoKho()
LANGUAGE plpgsql
AS $$
DECLARE
-- Cursor tham chiếu đến bảng LoVacXin
    cur_kho_vaccine CURSOR FOR 
        SELECT lvx.MaLo, vx.TenVX, lvx.HSD, lvx.SoLuongTon 
        FROM LoVacXin lvx
        JOIN VacXin vx ON lvx.MaVX = vx.MaVX;
        
    v_MaLo INT;
    v_TenVX VARCHAR(100);
    v_HSD DATE;
    v_SoLuongTon INT;
BEGIN
    RAISE NOTICE '=== BẮT ĐẦU QUÉT KIỂM TRA TOÀN BỘ KHO VACCINE ===';
    
    OPEN cur_kho_vaccine;
    
    LOOP
        FETCH NEXT FROM cur_kho_vaccine INTO v_MaLo, v_TenVX, v_HSD, v_SoLuongTon;
        EXIT WHEN NOT FOUND;
        
        IF v_HSD < CURRENT_DATE OR v_SoLuongTon = 0 THEN
            RAISE NOTICE '[NGUY HIỂM] Lô hàng mã % (Vaccine: %) ĐÃ HẾT HẠN (HSD: %) hoặc HẾT SỐ LƯỢNG (Tồn: %). Cấm trích xuất!', 
                         v_MaLo, v_TenVX, v_HSD, v_SoLuongTon;
                         
        ELSIF v_HSD BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '30 days') THEN
            RAISE NOTICE '[CẢNH BÁO ĐỎ] Lô hàng mã % (Vaccine: %) SẮP HẾT HẠN (HSD: %). Chỉ còn % ngày sử dụng!', 
                         v_MaLo, v_TenVX, v_HSD, (v_HSD - CURRENT_DATE);
                         
        ELSE
            RAISE NOTICE '[AN TOÀN] Lô hàng mã % (Vaccine: %) trạng thái ổn định. (Tồn: %, HSD: %)', 
                         v_MaLo, v_TenVX, v_SoLuongTon, v_HSD;
        END IF;
        
    END LOOP;
    
    CLOSE cur_kho_vaccine;
    RAISE NOTICE '=== HOÀN TẤT TIẾN TRÌNH KIỂM TRA KHO ===';
END;
$$;

-- CALL KiemTraVaCanhBaoKho(); 

CREATE OR REPLACE PROCEDURE TuDongXuLyLoQuaHan()
LANGUAGE plpgsql
AS $$
DECLARE
    -- Sử dụng JOIN để lấy thông tin lô và tên vắc-xin tương ứng
    cur_xu_ly_kho CURSOR FOR 
        SELECT lv.MaLo, vx.TenVX, lv.SoLuongTon, lv.HSD 
        FROM LoVacXin lv
        JOIN VacXin vx ON lv.MaVX = vx.MaVX
        WHERE lv.HSD < CURRENT_DATE; 
        
    v_MaLo INT;
    v_TenVX VARCHAR(100);
    v_Ton INT;
    v_HSD DATE;
BEGIN
    RAISE NOTICE '=== TIẾN TRÌNH TỰ ĐỘNG XỬ LÝ LÔ VẮC-XIN QUÁ HẠN ===';
    
    OPEN cur_xu_ly_kho;
    LOOP
        FETCH NEXT FROM cur_xu_ly_kho INTO v_MaLo, v_TenVX, v_Ton, v_HSD;
        EXIT WHEN NOT FOUND;
        
        IF v_Ton > 0 THEN
            RAISE NOTICE '[HÀNH ĐỘNG] Lô % của Vắc-xin % đã hết hạn vào ngày %. Tiến hành cô lập % liều còn lại để tiêu hủy!', 
                         v_MaLo, v_TenVX, v_HSD, v_Ton;
        ELSE
            RAISE NOTICE '[HỆ THỐNG] Lô % của Vắc-xin % đã hết hạn nhưng số lượng tồn bằng 0. Tự động đóng lô.', 
                         v_MaLo, v_TenVX;
        END IF;
        
    END LOOP;
    CLOSE cur_xu_ly_kho;
    RAISE NOTICE '=== HOÀN TẤT XỬ LÝ KHO ===';
END;
$$;

-- Thực thi thủ tục
-- CALL TuDongXuLyLoQuaHan();


-- Cursor quét phản ứng sau tiêm
CREATE OR REPLACE PROCEDURE QuetCapCuuPhanUngSauTiem()
LANGUAGE plpgsql
AS $$
DECLARE
    -- Cursor duyệt trên bảng gốc LanTiem kết nối KhachHang
    cur_phay_ung_nang CURSOR FOR     
        SELECT lt.MaLT, kh.HoTen, lt.NgayTiem, lt.KetQua, nv.HoTen AS TenYBacSi
        FROM LanTiem lt
        JOIN SoTiemChung stc ON lt.MaSo = stc.MaSo
        JOIN KhachHang kh ON stc.MaKH = kh.MaKH
        JOIN NhanVienChuyenMon nv ON lt.MaNV = nv.MaNV
        WHERE lt.KetQua IN ('SOT_CAO'::KetQuaTiemEnum, 'SOC_PHAN_VE'::KetQuaTiemEnum)
          AND lt.NgayTiem = CURRENT_DATE; 
          
    v_MaLT INT;
    v_HoTenKhach VARCHAR(100);
    v_NgayTiem DATE;
    v_KetQua TEXT;
    v_TenYBacSi VARCHAR(100);
BEGIN
    RAISE NOTICE '=== HỆ THỐNG GIÁM SÁT AN TOÀN LÂM SÀNG - PHẢN ỨNG SAU TIÊM ===';
    
    OPEN cur_phay_ung_nang;
    LOOP
        FETCH NEXT FROM cur_phay_ung_nang INTO v_MaLT, v_HoTenKhach, v_NgayTiem, v_KetQua, v_TenYBacSi;
        EXIT WHEN NOT FOUND;
        
        IF v_KetQua = 'SOC_PHAN_VE' THEN
            RAISE NOTICE '[MÃ ĐỎ - CẤP CỨU KHẨN CẤP]: Lượt tiêm mã % | Bệnh nhân: % gặp sự cố SỐC PHẢN VỆ! Điều dưỡng phụ trách: % -> Kích hoạt phác đồ xử trí cấp cứu!', 
                         v_MaLT, v_HoTenKhach, v_TenYBacSi;
        ELSE
            RAISE NOTICE '[MÃ VÀNG - THEO DÕI SÁT]: Lượt tiêm mã % | Bệnh nhân: % bị SỐT CAO sau tiêm. Bác sĩ phụ trách: % -> Yêu cầu phát thuốc hạ sốt và chườm ấm!', 
                         v_MaLT, v_HoTenKhach, v_TenYBacSi;
        END IF;
        
    END LOOP;
    CLOSE cur_phay_ung_nang;
    RAISE NOTICE '=== KẾT THÚC LƯỢT QUÉT GIÁM SÁT Y TẾ ===';
END;
$$;

--Thực thi
-- CALL QuetCapCuuPhanUngSauTiem();


-- Cursor gợi ý lịch hẹn
CREATE OR REPLACE PROCEDURE TuDongGoiYHenLichTiem(p_MaKH INT)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Cursor lấy lịch sử tiêm của một khách hàng cụ thể 
    cur_lich_su_tiem CURSOR FOR
        SELECT lt.NgayTiem, ltlv.MuiTiemThu, vx.TenVX, vx.PhacDo
        FROM LanTiem lt
        JOIN SoTiemChung stc ON lt.MaSo = stc.MaSo
        JOIN LANTIEM_LOVACXIN ltlv ON lt.MaLT = ltlv.MaLT
        JOIN LoVacXin lvx ON ltlv.MaLo = lvx.MaLo
        JOIN VacXin vx ON lvx.MaVX = vx.MaVX
        WHERE stc.MaKH = p_MaKH
        ORDER BY lt.NgayTiem DESC; 
        
    v_NgayTiem DATE;
    v_MuiTiemThu INT;
    v_TenVX VARCHAR(100);
    v_PhacDo INT;
    v_NgayHenTiem DATE;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE MaKH = p_MaKH) THEN
        RAISE EXCEPTION 'Khách hàng mã % không tồn tại trên hệ thống.', p_MaKH;
    END IF;

    OPEN cur_lich_su_tiem;
    FETCH FIRST FROM cur_lich_su_tiem INTO v_NgayTiem, v_MuiTiemThu, v_TenVX, v_PhacDo;
    
    IF NOT FOUND THEN
        RAISE NOTICE 'Khách hàng này chưa từng thực hiện mũi tiêm nào tại trung tâm.';
    ELSE
        RAISE NOTICE '--- PHÂN TÍCH TIẾN ĐỘ PHÁC ĐỒ CỦA KHÁCH HÀNG ---';
        
        IF v_MuiTiemThu < v_PhacDo THEN
            v_NgayHenTiem := v_NgayTiem + INTERVAL '28 days'; -- Tính toán ngày dự kiến tiếp theo
            RAISE NOTICE '[GỢI Ý HẸN LỊCH]: Khách hàng chưa hoàn thành phác đồ. Vui lòng hẹn lịch tiêm Mũi thứ % vào ngày %', 
                         (v_MuiTiemThu + 1), v_NgayHenTiem;
        ELSE
            RAISE NOTICE '[HOÀN THÀNH]: Khách hàng đã hoàn thành trọn vẹn phác đồ % mũi của loại vắc-xin %.', 
                         v_PhacDo, v_TenVX;
        END IF;
    END IF;
    
    CLOSE cur_lich_su_tiem;
END;
$$;

-- CALL TuDongGoiYHenLichTiem(1);

-- Cursor trẻ em cần giám hộ
CREATE OR REPLACE PROCEDURE QuetHoSoTreEmCanHoTro()
LANGUAGE plpgsql
AS $$
DECLARE
    -- Cursor duyệt trên View danh sách trẻ em cần người giám hộ
    cur_ho_so_tre_em CURSOR FOR 
        SELECT MaKH, HoTenTreEm, HoTenNguoiGiamHo, SDTNguoiGiamHo, MoiQuanHe
        FROM v_DanhSachTreEmCanGiamHo;
        
    v_MaKH INT;
    v_HoTenTreEm VARCHAR(100);
    v_HoTenNguoiGiamHo VARCHAR(100);
    v_SDT VARCHAR(10);
    v_MoiQuanHe VARCHAR(20);
BEGIN
    RAISE NOTICE '=== TIẾN TRÌNH RÀ SOÁT HỒ SƠ PHÁP LÝ TRẺ EM ===';
    
    OPEN cur_ho_so_tre_em;
    LOOP
        FETCH NEXT FROM cur_ho_so_tre_em INTO v_MaKH, v_HoTenTreEm, v_HoTenNguoiGiamHo, v_SDT, v_MoiQuanHe;
        EXIT WHEN NOT FOUND;
        
        IF UPPER(v_MoiQuanHe) = 'KHAC' OR v_SDT IS NULL OR LENGTH(TRIM(v_SDT)) < 10 THEN
            RAISE NOTICE '[CẦN LIÊN HỆ]: Trẻ em: % (Mã KH: %) | Người giám hộ: % (SĐT: %) | Quan hệ: % -> Hồ sơ chưa chuẩn hóa!', 
                         v_HoTenTreEm, v_MaKH, v_HoTenNguoiGiamHo, COALESCE(v_SDT, 'TRỐNG'), v_MoiQuanHe;
        ELSE
            RAISE NOTICE '[HỢP LỆ]: Hồ sơ bé % (Mã KH: %) đã đầy đủ thông tin pháp lý.', v_HoTenTreEm, v_MaKH;
        END IF;
        
    END LOOP;
    CLOSE cur_ho_so_tre_em;
    RAISE NOTICE '=== HOÀN TẤT TIẾN TRÌNH RÀ SOÁT ===';
END;
$$;

-- CALL QuetHoSoTreEmCanHoTro(); 

-- Cursor giám sát giao dịch lớn
CREATE OR REPLACE PROCEDURE GiamSatGiaoDichLon()
LANGUAGE plpgsql
AS $$
DECLARE
    -- Cursor lọc các hóa đơn giá trị cao trực tiếp trên View doanh thu
    cur_hoa_don_lon CURSOR FOR
        SELECT MaHD, HTThanhToan, TongTien, HoTenKhachHang, TenNhanVienThuNgan
        FROM v_BaoCaoDoanhThuTheoHoaDon
        WHERE TongTien >= 2000000.00;
        
    v_MaHD INT;
    v_HTThanhToan TEXT; 
    v_TongTien NUMERIC(15,2);
    v_TenKH VARCHAR(100);
    v_TenThuNgan VARCHAR(100);
BEGIN
    RAISE NOTICE '=== HỆ THỐNG KIỂM SOÁT GIAO DỊCH GIÁ TRỊ CAO (>= 2.000.000 VNĐ) ===';
    
    OPEN cur_hoa_don_lon;
    LOOP
        FETCH NEXT FROM cur_hoa_don_lon INTO v_MaHD, v_HTThanhToan, v_TongTien, v_TenKH, v_TenThuNgan;
        EXIT WHEN NOT FOUND;
        
        IF v_HTThanhToan::TEXT = 'TIEN_MAT' THEN
            RAISE NOTICE '[ĐỐI SOÁT KIỂM QUỸ]: Hóa đơn % | Khách: % | Số tiền: % VNĐ | Thu ngân: % -> Yêu cầu kiểm đếm tiền mặt trong két!', 
                         v_MaHD, v_TenKH, v_TongTien, v_TenThuNgan;
        ELSIF v_HTThanhToan::TEXT = 'CHUYEN_KHOAN' OR v_HTThanhToan::TEXT = 'VI_DIEN_TU' THEN
            RAISE NOTICE '[ĐỐI SOÁT BANKING]: Hóa đơn % | Khách: % | Số tiền: % VNĐ | Thu ngân: % -> Yêu cầu tra soát lệnh chuyển khoản khớp App!', 
                         v_MaHD, v_TenKH, v_TongTien, v_TenThuNgan;
        ELSE
            RAISE NOTICE '[GHI NHẬN]: Hóa đơn % | Khách: % | Số tiền: % VNĐ | Hình thức: %', 
                         v_MaHD, v_TenKH, v_TongTien, v_HTThanhToan;
        END IF;
        
    END LOOP;
    CLOSE cur_hoa_don_lon;
    RAISE NOTICE '=== KẾT THÚC TIẾN TRÌNH KIỂM SOÁT TÀI CHÍNH ===';
END;
$$;

-- CALL GiamSatGiaoDichLon(); 
