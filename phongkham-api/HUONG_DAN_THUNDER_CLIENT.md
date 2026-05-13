# 🚀 HƯỚNG DẪN TEST API TRÊN THUNDER CLIENT (CHI TIẾT)

## 📌 BƯỚC 1: CÀI ĐẶT THUNDER CLIENT

1. Mở VS Code
2. Nhấn `Ctrl + Shift + X` (mở Extensions)
3. Tìm kiếm: **Thunder Client**
4. Nhấn **Install**
5. Sau khi cài xong, bạn sẽ thấy icon ⚡ ở thanh bên trái

---

## 📌 BƯỚC 2: MỞ THUNDER CLIENT

1. Nhấn vào icon ⚡ **Thunder Client** ở thanh bên trái
2. Hoặc nhấn `Ctrl + Shift + P` → gõ "Thunder Client" → chọn "Thunder Client: New Request"

---

## 📌 BƯỚC 3: ĐĂNG NHẬP LẤY TOKEN (QUAN TRỌNG!)

### 3.1. Tạo Request Đăng Nhập

1. Trong Thunder Client, nhấn nút **"New Request"**
2. Đặt tên: `Login Admin`

### 3.2. Cấu hình Request

**Ở phần trên cùng:**
- **Method**: Chọn `POST` (dropdown bên trái)
- **URL**: Nhập `http://localhost:8000/login`

### 3.3. Thêm Body

1. Nhấn vào tab **"Body"** (ở giữa màn hình)
2. Chọn **"JSON"** (radio button)
3. Paste đoạn này vào ô lớn bên dưới:

```json
{
  "sdt": "967287418",
  "MatKhau": "Vinh0917641090@"
}
```

### 3.4. Gửi Request

1. Nhấn nút **"Send"** (màu xanh, góc phải)
2. Đợi vài giây
3. Bạn sẽ thấy kết quả ở phần **Response** bên dưới

### 3.5. Copy Token

Trong Response, bạn sẽ thấy:
```json
{
  "success": true,
  "message": "Đăng nhập thành công",
  "data": {
    "token": "2d2924a324ceac524dd409854590a33bf3440399fd2c66b170e22cb7225d39c8",
    "user": { ... }
  }
}
```

**👉 COPY cái token này (chuỗi dài dài)**: `2d2924a324ceac524dd409854590a33bf3440399fd2c66b170e22cb7225d39c8`

---

## 📌 BƯỚC 4: LẤY DANH SÁCH BÁC SĨ

### 4.1. Tạo Request Mới

1. Nhấn **"New Request"** lần nữa
2. Đặt tên: `Get Danh Sách Bác Sĩ`

### 4.2. Cấu hình Request

- **Method**: Chọn `GET`
- **URL**: Nhập `http://localhost:8000/admin/bac-si`

### 4.3. Thêm Token (QUAN TRỌNG!)

1. Nhấn vào tab **"Auth"** (ở giữa màn hình)
2. Trong dropdown **"Auth Type"**, chọn **"Bearer"**
3. Ô **"Token"** sẽ hiện ra
4. **PASTE token** bạn vừa copy ở bước 3.5 vào đây

### 4.4. Gửi Request

1. Nhấn **"Send"**
2. Bạn sẽ thấy danh sách bác sĩ (có thể rỗng nếu chưa có dữ liệu)

---

## 📌 BƯỚC 5: THÊM BÁC SĨ MỚI

### 5.1. Tạo Request Mới

1. Nhấn **"New Request"**
2. Đặt tên: `Thêm Bác Sĩ`

### 5.2. Cấu hình Request

- **Method**: Chọn `POST`
- **URL**: Nhập `http://localhost:8000/admin/bac-si`

### 5.3. Thêm Token

1. Tab **"Auth"** → chọn **"Bearer"**
2. Paste token vào

### 5.4. Thêm Body

1. Tab **"Body"** → chọn **"JSON"**
2. Paste:

```json
{
  "ho": "Nguyễn Văn",
  "ten": "An",
  "ngaysinh": "1985-05-15",
  "gioitinh": "Nam",
  "ChuyenKhoa": "Tim mạch",
  "BangCap": "Thạc sĩ",
  "KinhNghiem": "10 năm",
  "email": "bacsi1@gmail.com",
  "sdt": "912345678",
  "MatKhau": "123456"
}
```

### 5.5. Gửi Request

1. Nhấn **"Send"**
2. Nếu thành công, bạn sẽ thấy:

```json
{
  "success": true,
  "message": "Thêm bác sĩ thành công",
  "data": {
    "MaBacSi": 1,
    "MaTaiKhoan": 8
  }
}
```

---

## 📌 BƯỚC 6: XEM CHI TIẾT BÁC SĨ

### 6.1. Tạo Request Mới

1. **"New Request"**
2. Đặt tên: `Chi Tiết Bác Sĩ`

### 6.2. Cấu hình

- **Method**: `GET`
- **URL**: `http://localhost:8000/admin/bac-si/1` (1 là MaBacSi)
- **Auth**: Bearer → paste token

### 6.3. Gửi Request

Nhấn **"Send"** → Xem thông tin chi tiết bác sĩ

---

## 📌 BƯỚC 7: CẬP NHẬT THÔNG TIN BÁC SĨ

### 7.1. Tạo Request Mới

1. **"New Request"**
2. Đặt tên: `Cập Nhật Bác Sĩ`

### 7.2. Cấu hình

- **Method**: `PUT`
- **URL**: `http://localhost:8000/admin/bac-si/1`
- **Auth**: Bearer → paste token

### 7.3. Thêm Body

Tab **"Body"** → **"JSON"**:

```json
{
  "ChuyenKhoa": "Nội khoa",
  "KinhNghiem": "15 năm",
  "BangCap": "Tiến sĩ"
}
```

### 7.4. Gửi Request

Nhấn **"Send"** → Thông tin bác sĩ sẽ được cập nhật

---

## 📌 BƯỚC 8: TÌM KIẾM BÁC SĨ

### 8.1. Tạo Request Mới

1. **"New Request"**
2. Đặt tên: `Tìm Kiếm Bác Sĩ`

### 8.2. Cấu hình

- **Method**: `GET`
- **URL**: `http://localhost:8000/admin/bac-si?search=An`
- **Auth**: Bearer → paste token

### 8.3. Gửi Request

Nhấn **"Send"** → Kết quả tìm kiếm

---

## 📌 BƯỚC 9: KHÓA TÀI KHOẢN BÁC SĨ

### 9.1. Tạo Request Mới

1. **"New Request"**
2. Đặt tên: `Khóa Tài Khoản Bác Sĩ`

### 9.2. Cấu hình

- **Method**: `PATCH`
- **URL**: `http://localhost:8000/admin/bac-si/1/trang-thai`
- **Auth**: Bearer → paste token

### 9.3. Thêm Body

Tab **"Body"** → **"JSON"**:

```json
{
  "trangthaihoatdong": "inactive"
}
```

### 9.4. Gửi Request

Nhấn **"Send"** → Tài khoản bị khóa

**Để mở khóa**, đổi thành:
```json
{
  "trangthaihoatdong": "active"
}
```

---

## 📌 BƯỚC 10: XÓA BÁC SĨ

### 10.1. Tạo Request Mới

1. **"New Request"**
2. Đặt tên: `Xóa Bác Sĩ`

### 10.2. Cấu hình

- **Method**: `DELETE`
- **URL**: `http://localhost:8000/admin/bac-si/1`
- **Auth**: Bearer → paste token

### 10.3. Gửi Request

Nhấn **"Send"** → Bác sĩ bị xóa

---

## 🎯 MẸO HAY

### 1. Lưu Request vào Collection

1. Sau khi tạo request, nhấn **"Save"**
2. Chọn **"New Collection"**
3. Đặt tên: `API Phòng Khám`
4. Tất cả request sẽ được lưu lại, không mất

### 2. Sử dụng Environment Variables

1. Nhấn vào icon **"Env"** (góc trên bên phải)
2. Nhấn **"New Environment"**
3. Đặt tên: `Local`
4. Thêm biến:

```json
{
  "baseUrl": "http://localhost:8000",
  "token": "paste_token_của_bạn_vào_đây"
}
```

5. Khi tạo request, dùng:
   - URL: `{{baseUrl}}/admin/bac-si`
   - Token: `{{token}}`

### 3. Xem Response đẹp hơn

Sau khi nhận response, nhấn vào tab **"Preview"** để xem JSON được format đẹp

---

## ❌ XỬ LÝ LỖI

### Lỗi: "Failed to fetch"
- ✅ Kiểm tra server Laravel đã chạy chưa: `php artisan serve`
- ✅ Kiểm tra URL có đúng không

### Lỗi: 401 Unauthorized
- ✅ Token sai hoặc hết hạn
- ✅ Đăng nhập lại để lấy token mới
- ✅ Kiểm tra đã paste token vào Auth chưa

### Lỗi: 403 Forbidden
- ✅ Tài khoản không có quyền admin
- ✅ Đăng nhập bằng tài khoản admin

### Lỗi: 422 Validation Error
- ✅ Kiểm tra dữ liệu trong Body
- ✅ Đọc message lỗi để biết trường nào sai

### Lỗi: 500 Internal Server Error
- ✅ Lỗi server
- ✅ Xem log: `storage/logs/laravel.log`

---

## 📸 HÌNH ẢNH MINH HỌA

### Giao diện Thunder Client:
```
┌─────────────────────────────────────────────────┐
│  POST  http://localhost:8000/login       [Send] │
├─────────────────────────────────────────────────┤
│  Query   Auth   Headers   Body   Tests          │
│                                                  │
│  ● JSON                                          │
│  ┌───────────────────────────────────────────┐  │
│  │ {                                         │  │
│  │   "sdt": "967287418",                     │  │
│  │   "MatKhau": "Vinh0917641090@"            │  │
│  │ }                                         │  │
│  └───────────────────────────────────────────┘  │
├─────────────────────────────────────────────────┤
│  Response (200 OK) - 245ms                      │
│  ┌───────────────────────────────────────────┐  │
│  │ {                                         │  │
│  │   "success": true,                        │  │
│  │   "message": "Đăng nhập thành công",      │  │
│  │   "data": {                               │  │
│  │     "token": "2d2924a324ceac..."          │  │
│  │   }                                       │  │
│  │ }                                         │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

---

## ✅ CHECKLIST

Làm theo thứ tự này:

- [ ] Cài đặt Thunder Client
- [ ] Mở Thunder Client
- [ ] Tạo request Login
- [ ] Gửi request Login → Copy token
- [ ] Tạo request Get Danh Sách Bác Sĩ
- [ ] Thêm Bearer token vào Auth
- [ ] Gửi request → Xem kết quả
- [ ] Tạo request Thêm Bác Sĩ
- [ ] Thêm token + Body JSON
- [ ] Gửi request → Thêm thành công
- [ ] Test các API còn lại

---

## 🎓 KẾT LUẬN

Bây giờ bạn đã biết cách test API trên Thunder Client! 

**Nhớ:**
1. Luôn đăng nhập trước để lấy token
2. Thêm Bearer token vào mọi request admin
3. Chọn đúng Method (GET/POST/PUT/DELETE/PATCH)
4. Thêm Body JSON cho POST/PUT/PATCH

**Chúc bạn test thành công! 🚀**
