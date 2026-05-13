# HƯỚNG DẪN TEST API QUẢN LÝ BÁC SĨ

## 📌 Thông tin Server
- **Base URL**: `http://localhost:8000`
- **Database**: phongkham

---

## 🔐 BƯỚC 1: ĐĂNG NHẬP LẤY TOKEN ADMIN

### Request
```
POST http://localhost:8000/login
Content-Type: application/json
```

### Body (JSON)
```json
{
  "sdt": "967287418",
  "MatKhau": "Vinh0917641090@"
}
```

### Response mẫu
```json
{
  "success": true,
  "message": "Đăng nhập thành công",
  "data": {
    "token": "token_admin",
    "user": {
      "MaTaiKhoan": 1,
      "email": "admin@gmail.com",
      "sdt": 901234567,
      "VaiTro": "admin"
    }
  }
}
```

**⚠️ LƯU Ý: Copy token từ response để dùng cho các request tiếp theo!**

---

## 👨‍⚕️ BƯỚC 2: TEST API QUẢN LÝ BÁC SĨ

### 1️⃣ Lấy danh sách bác sĩ

#### Request
```
GET http://localhost:8000/admin/bac-si
Authorization: Bearer token_admin
```

#### Query Parameters (Optional)
- `search`: Tìm kiếm theo tên hoặc chuyên khoa
- `gioitinh`: Lọc theo giới tính (Nam/Nữ)
- `ChuyenKhoa`: Lọc theo chuyên khoa

#### Ví dụ với filter
```
GET http://localhost:8000/admin/bac-si?search=Tim&gioitinh=Nam
Authorization: Bearer token_admin
```

---

### 2️⃣ Xem chi tiết bác sĩ

#### Request
```
GET http://localhost:8000/admin/bac-si/1
Authorization: Bearer token_admin
```

---

### 3️⃣ Thêm bác sĩ mới

#### Request
```
POST http://localhost:8000/admin/bac-si
Authorization: Bearer token_admin
Content-Type: application/json
```

#### Body (JSON)
```json
{
  "ho": "Nguyễn Văn",
  "ten": "Test",
  "ngaysinh": "1985-05-15",
  "gioitinh": "Nam",
  "ChuyenKhoa": "Tim mạch",
  "BangCap": "Thạc sĩ",
  "KinhNghiem": "10 năm",
  "email": "bacsitest@gmail.com",
  "sdt": "987654321",
  "MatKhau": "123456"
}
```

#### Response mẫu
```json
{
  "success": true,
  "message": "Thêm bác sĩ thành công",
  "data": {
    "MaBacSi": 4,
    "MaTaiKhoan": 8
  }
}
```

---

### 4️⃣ Cập nhật thông tin bác sĩ

#### Request
```
PUT http://localhost:8000/admin/bac-si/4
Authorization: Bearer token_admin
Content-Type: application/json
```

#### Body (JSON) - Chỉ gửi các trường cần cập nhật
```json
{
  "ChuyenKhoa": "Nội khoa",
  "KinhNghiem": "12 năm",
  "BangCap": "Tiến sĩ"
}
```

---

### 5️⃣ Khóa/Mở khóa tài khoản bác sĩ

#### Request - Khóa tài khoản
```
PATCH http://localhost:8000/admin/bac-si/4/trang-thai
Authorization: Bearer token_admin
Content-Type: application/json
```

#### Body (JSON)
```json
{
  "trangthaihoatdong": "inactive"
}
```

#### Request - Mở khóa tài khoản
```json
{
  "trangthaihoatdong": "active"
}
```

---

### 6️⃣ Xóa bác sĩ

#### Request
```
DELETE http://localhost:8000/admin/bac-si/4
Authorization: Bearer token_admin
```

---

## 🎯 CÁCH TEST TRÊN THUNDER CLIENT

### Bước 1: Mở Thunder Client
1. Nhấn `Ctrl + Shift + P`
2. Gõ "Thunder Client"
3. Chọn "Thunder Client: New Request"

### Bước 2: Đăng nhập lấy token
1. Chọn method: **POST**
2. URL: `http://localhost:8000/login`
3. Tab **Body** → chọn **JSON**
4. Paste:
```json
{
  "sdt": "967287418",
  "MatKhau": "Vinh0917641090@"
}
```
5. Nhấn **Send**
6. **Copy token** từ response

### Bước 3: Test API bác sĩ
1. Tạo request mới
2. Chọn method tương ứng (GET/POST/PUT/DELETE/PATCH)
3. Nhập URL
4. Tab **Auth** → chọn **Bearer**
5. Paste token vào ô **Token**
6. Nếu cần Body → Tab **Body** → chọn **JSON** → paste data
7. Nhấn **Send**

---

## 📋 CHECKLIST TEST

- [ ] Đăng nhập thành công và lấy được token
- [ ] Lấy danh sách bác sĩ
- [ ] Tìm kiếm bác sĩ theo tên
- [ ] Lọc bác sĩ theo giới tính
- [ ] Xem chi tiết 1 bác sĩ
- [ ] Thêm bác sĩ mới thành công
- [ ] Kiểm tra lỗi khi thêm email trùng
- [ ] Kiểm tra lỗi khi thêm SĐT trùng
- [ ] Cập nhật thông tin bác sĩ
- [ ] Khóa tài khoản bác sĩ
- [ ] Mở khóa tài khoản bác sĩ
- [ ] Xóa bác sĩ thành công
- [ ] Kiểm tra không xóa được bác sĩ có lịch làm việc

---

## ⚠️ LƯU Ý

1. **Token hết hạn**: Nếu API trả về lỗi 401, đăng nhập lại để lấy token mới
2. **CORS Error**: Đảm bảo đã cấu hình CORS đúng
3. **Database**: Đảm bảo database đã import file SQL
4. **Server**: Đảm bảo server Laravel đang chạy (`php artisan serve`)

---

## 🐛 XỬ LÝ LỖI THƯỜNG GẶP

### Lỗi 401 Unauthorized
- Kiểm tra token có đúng không
- Kiểm tra đã thêm Bearer token chưa
- Đăng nhập lại để lấy token mới

### Lỗi 403 Forbidden
- Tài khoản không có quyền admin
- Đăng nhập bằng tài khoản admin

### Lỗi 404 Not Found
- Kiểm tra URL có đúng không
- Kiểm tra ID bác sĩ có tồn tại không

### Lỗi 422 Validation Error
- Kiểm tra dữ liệu gửi lên có đúng format không
- Đọc message lỗi để biết trường nào bị sai

### Lỗi 500 Internal Server Error
- Kiểm tra log Laravel: `storage/logs/laravel.log`
- Kiểm tra kết nối database
