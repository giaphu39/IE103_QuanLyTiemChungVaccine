-- 1. Khởi tạo các Vai trò nghiệp vụ (Roles)
DROP ROLE IF EXISTS role_hanhchinh;
DROP ROLE IF EXISTS role_chuyenmon;
DROP ROLE IF EXISTS role_kho;
DROP ROLE IF EXISTS role_quanly;

CREATE ROLE role_hanhchinh;
CREATE ROLE role_chuyenmon;
CREATE ROLE role_kho;
CREATE ROLE role_quanly;

-- 2. Khởi tạo tài khoản người dùng (Users)
DROP USER IF EXISTS hc01;
DROP USER IF EXISTS bs01;
DROP USER IF EXISTS kho01;
DROP USER IF EXISTS admin01;

CREATE USER hc01 WITH LOGIN PASSWORD 'HC123';
CREATE USER bs01 WITH LOGIN PASSWORD 'BS123';
CREATE USER kho01 WITH LOGIN PASSWORD 'KHO123';
CREATE USER admin01 WITH LOGIN PASSWORD 'ADMIN123';

-- 3. Gán người dùng vào các Vai trò tương ứng
GRANT role_hanhchinh TO hc01;
GRANT role_chuyenmon TO bs01;
GRANT role_kho TO kho01;
GRANT role_quanly TO admin01;

-- 4. Cấu hình chặn truy cập vãng lai 
REVOKE CONNECT ON DATABASE "QuanLyTiemChung" FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- 5. Cấp quyền Xác thực chính thức cho các Role nghiệp vụ
GRANT CONNECT ON DATABASE "QuanLyTiemChung" TO role_hanhchinh, role_chuyenmon, role_kho, role_quanly;
GRANT USAGE ON SCHEMA public TO role_hanhchinh, role_chuyenmon, role_kho, role_quanly;



