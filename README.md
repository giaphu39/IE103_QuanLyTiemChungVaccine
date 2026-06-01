# IE103_QuanLyTiemChungVaccine

# Hệ Thống Quản Lý Tiêm Chủng Vaccine

## Thành viên thực hiện

| MSSV     | Họ và tên             |
| -------- | --------------------- |
| 24521365 | Trần Gia Phú          |
| 24521331 | Đinh Thanh Phong      |
| 24521326 | Võ Nguyễn Nhật Phi    |
| 24521391 | Nguyễn Huỳnh Bảo Phúc |
| 24521988 | Nguyễn Ngọc Tường Vi  |
| 24520721 | Hồ Tấn Khải           |

---

## Giới thiệu đề tài

Hệ thống Quản lý Tiêm chủng Vaccine được xây dựng nhằm hỗ trợ các cơ sở tiêm chủng trong việc quản lý tập trung dữ liệu khách hàng, nhân sự, vaccine và toàn bộ quy trình tiêm chủng. Đề tài hướng tới việc số hóa các nghiệp vụ đang được thực hiện thủ công hoặc bán thủ công, giúp nâng cao hiệu quả quản lý, giảm thiểu sai sót và đảm bảo tính chính xác của dữ liệu y tế.

Hệ thống mô phỏng quy trình vận hành thực tế tại một trung tâm tiêm chủng, bao gồm các hoạt động tiếp nhận khách hàng, khám sàng lọc, thực hiện tiêm chủng, quản lý kho vaccine và xử lý thanh toán.

---

## Lý do chọn đề tài

Trong thực tế, nhiều cơ sở tiêm chủng vẫn lưu trữ hồ sơ khách hàng, lịch sử tiêm chủng và thông tin người giám hộ theo phương thức rời rạc hoặc thủ công. Điều này gây khó khăn trong việc tra cứu, đối chiếu thông tin và làm tăng nguy cơ sai sót trong quá trình chăm sóc sức khỏe.

Bên cạnh đó, hoạt động tiêm chủng bao gồm nhiều nghiệp vụ liên kết chặt chẽ như tiếp nhận hành chính, khám sàng lọc, tiêm chủng, quản lý hóa đơn và quản lý kho vaccine. Việc xây dựng một hệ thống cơ sở dữ liệu tập trung giúp quản lý hiệu quả các luồng thông tin này, đồng thời nâng cao chất lượng dịch vụ và đảm bảo an toàn cho người bệnh.

---

## Mục tiêu của đề tài

* Xây dựng cơ sở dữ liệu quản lý tập trung thông tin khách hàng, người giám hộ, nhân viên và vaccine.
* Số hóa quy trình tiêm chủng từ tiếp nhận, khám sàng lọc, tiêm chủng đến thanh toán.
* Hỗ trợ lưu trữ và tra cứu lịch sử tiêm chủng nhanh chóng, chính xác.
* Đảm bảo tính toàn vẹn và an toàn dữ liệu thông qua các ràng buộc nghiệp vụ.
* Quản lý hiệu quả kho vaccine, nhà cung cấp, lô vaccine và hạn sử dụng.
* Hỗ trợ thống kê, báo cáo và ra quyết định cho ban quản lý cơ sở tiêm chủng.

---

## Đối tượng sử dụng

### Nhân viên hành chính

* Tiếp nhận khách hàng.
* Quản lý thông tin người giám hộ.
* Lập sổ tiêm chủng.
* Quản lý hóa đơn thanh toán.

### Nhân viên chuyên môn (Bác sĩ / Điều dưỡng)

* Khám sàng lọc trước tiêm.
* Ghi nhận các chỉ số sức khỏe.
* Thực hiện và cập nhật thông tin tiêm chủng.

### Nhân viên quản lý kho

* Quản lý danh mục vaccine.
* Theo dõi nhập xuất kho.
* Kiểm soát số lượng tồn kho và hạn sử dụng vaccine.

### Ban quản lý

* Quản lý nhân sự.
* Giám sát hoạt động của trung tâm.
* Truy xuất báo cáo và thống kê tổng hợp.

---

## Phạm vi đề tài

### Phạm vi nghiệp vụ

Hệ thống hỗ trợ quản lý:

* Thông tin khách hàng và người giám hộ.
* Quy trình tiêm chủng khép kín từ tiếp nhận đến thanh toán.
* Danh mục vaccine và các bệnh phòng ngừa.
* Quản lý kho vaccine và nhà cung cấp.
* Thông tin nhân viên hành chính và nhân viên chuyên môn.

### Phạm vi dữ liệu

Các thực thể chính được quản lý gồm:

* Khách hàng
* Người giám hộ
* Nhân viên
* Sổ tiêm chủng
* Phiếu khám sàng lọc
* Lần tiêm
* Vaccine
* Lô vaccine
* Nhà cung cấp
* Hóa đơn
* Bệnh phòng ngừa

Hệ thống áp dụng các ràng buộc toàn vẹn dữ liệu nhằm đảm bảo tính chính xác và nhất quán của thông tin.

### Phạm vi vận hành

* Hệ thống được thiết kế cho một cơ sở tiêm chủng đơn lẻ.
* Chưa hỗ trợ kết nối hoặc đồng bộ dữ liệu giữa nhiều cơ sở.
* Chỉ nhân sự nội bộ được phép truy cập và sử dụng hệ thống.
* Khách hàng và người giám hộ chỉ là đối tượng được quản lý dữ liệu, không tham gia vận hành hệ thống.

---

## Công nghệ sử dụng

* **Hệ quản trị cơ sở dữ liệu:** PostgreSQL
* **Ngôn ngữ truy vấn:** SQL (DDL, DML)
* **Xử lý nghiệp vụ:** Stored Procedure, Function, Trigger, Cursor, View
* **Bảo mật:** Phân quyền người dùng, xác thực và sao lưu dữ liệu

---

## Chức năng nổi bật

* Quản lý khách hàng và người giám hộ.
* Quản lý hồ sơ tiêm chủng.
* Quản lý khám sàng lọc trước tiêm.
* Quản lý vaccine, lô vaccine và kho vaccine.
* Quản lý nhân sự.
* Quản lý hóa đơn và doanh thu.
* Thống kê, báo cáo và truy xuất dữ liệu.
* Phân quyền và bảo mật hệ thống.

---

## Kết luận

Đề tài xây dựng một hệ thống quản lý tiêm chủng vaccine với cơ sở dữ liệu được thiết kế chặt chẽ, hỗ trợ quản lý hiệu quả các nghiệp vụ tại cơ sở tiêm chủng. Hệ thống góp phần nâng cao khả năng lưu trữ, tra cứu và xử lý dữ liệu, đồng thời tạo nền tảng cho việc mở rộng và phát triển các chức năng nâng cao trong tương lai.
