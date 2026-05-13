# ⚡ QUICK START - TEST API NGAY LẬP TỨC

## 🎯 3 BƯỚC ĐƠN GIẢN

### BƯỚC 1: ĐĂNG NHẬP (2 phút)

```
1. Mở Thunder Client (icon ⚡ bên trái)
2. Nhấn "New Request"
3. Điền:
   - Method: POST
   - URL: http://localhost:8000/login
4. Tab "Body" → chọn "JSON" → paste:
   {
     "sdt": "967287418",
     "MatKhau": "Vinh0917641090@"
   }
5. Nhấn "Send"
6. COPY token từ response
```

### BƯỚC 2: LẤY DANH SÁCH BÁC SĨ (1 phút)

```
1. Nhấn "New Request"
2. Điền:
   - Method: GET
   - URL: http://localhost:8000/admin/bac-si
3. Tab "Auth" → chọn "Bearer" → PASTE token
4. Nhấn "Send"
```

### BƯỚC 3: THÊM BÁC SĨ (2 phút)

```
1. Nhấn "New Request"
2. Điền:
   - Method: POST
   - URL: http://localhost:8000/admin/bac-si
3. Tab "Auth" → chọn "Bearer" → PASTE token
4. Tab "Body" → chọn "JSON" → paste:
   {
     "ho": "Nguyễn Văn",
     "ten": "Test",
     "ngaysinh": "1985-05-15",
     "gioitinh": "Nam",
     "ChuyenKhoa": "Tim mạch",
     "BangCap": "Thạc sĩ",
     "KinhNghiem": "10 năm",
     "email": "test@gmail.com",
     "sdt": "912345678",
     "MatKhau": "123456"
   }
5. Nhấn "Send"
```

---

## 📋 COPY & PASTE - SẴN SÀNG DÙNG

### 1. Login Request
```
Method: POST
URL: http://localhost:8000/login
Body (JSON):
{
  "sdt": "967287418",
  "MatKhau": "Vinh0917641090@"
}
```

### 2. Get Danh Sách Bác Sĩ
```
Method: GET
URL: http://localhost:8000/admin/bac-si
Auth: Bearer [PASTE_TOKEN_VÀO_ĐÂY]
```

### 3. Thêm Bác Sĩ
```
Method: POST
URL: http://localhost:8000/admin/bac-si
Auth: Bearer [PASTE_TOKEN_VÀO_ĐÂY]
Body (JSON):
{
  "ho": "Trần Thị",
  "ten": "Bình",
  "ngaysinh": "1990-03-20",
  "gioitinh": "Nữ",
  "ChuyenKhoa": "Nhi khoa",
  "BangCap": "Bác sĩ",
  "email": "bacsi2@gmail.com",
  "sdt": "923456789",
  "MatKhau": "123456"
}
```

**Lưu ý**: 
- Trường `KinhNghiem` không bắt buộc, mặc định = "0 năm"
- Trạng thái hoạt động mặc định = "active"

### 4. Xem Chi Tiết Bác Sĩ
```
Method: GET
URL: http://localhost:8000/admin/bac-si/1
Auth: Bearer [PASTE_TOKEN_VÀO_ĐÂY]
```

### 5. Cập Nhật Bác Sĩ
```
Method: PUT
URL: http://localhost:8000/admin/bac-si/1
Auth: Bearer [PASTE_TOKEN_VÀO_ĐÂY]
Body (JSON):
{
  "ChuyenKhoa": "Nội khoa",
  "KinhNghiem": "15 năm"
}
```

### 6. Tìm Kiếm Bác Sĩ
```
Method: GET
URL: http://localhost:8000/admin/bac-si?search=Test
Auth: Bearer [PASTE_TOKEN_VÀO_ĐÂY]
```

### 7. Khóa Tài Khoản
```
Method: PATCH
URL: http://localhost:8000/admin/bac-si/1/trang-thai
Auth: Bearer [PASTE_TOKEN_VÀO_ĐÂY]
Body (JSON):
{
  "trangthaihoatdong": "inactive"
}
```

### 8. Xóa Bác Sĩ
```
Method: DELETE
URL: http://localhost:8000/admin/bac-si/1
Auth: Bearer [PASTE_TOKEN_VÀO_ĐÂY]
```

---

## 🎨 HÌNH ẢNH GIAO DIỆN THUNDER CLIENT

### Màn hình chính:
```
╔═══════════════════════════════════════════════════════════╗
║  Thunder Client                                     [+]   ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  [New Request]  [Collections]  [Env]  [Settings]         ║
║                                                           ║
║  ┌─────────────────────────────────────────────────────┐ ║
║  │ POST ▼  http://localhost:8000/login         [Send] │ ║
║  └─────────────────────────────────────────────────────┘ ║
║                                                           ║
║  ┌─ Tabs ──────────────────────────────────────────────┐ ║
║  │ Query  Auth  Headers  Body  Tests  Scripts          │ ║
║  └──────────────────────────────────────────────────────┘ ║
║                                                           ║
║  ┌─ Body ───────────────────────────────────────────────┐║
║  │ ○ None  ● JSON  ○ Form  ○ XML  ○ Text              │║
║  │                                                      │║
║  │ {                                                    │║
║  │   "sdt": "967287418",                                │║
║  │   "MatKhau": "Vinh0917641090@"                       │║
║  │ }                                                    │║
║  │                                                      │║
║  └──────────────────────────────────────────────────────┘║
║                                                           ║
║  ┌─ Response ───────────────────────────────────────────┐║
║  │ Status: 200 OK  |  Time: 245ms  |  Size: 1.2 KB     │║
║  │                                                      │║
║  │ {                                                    │║
║  │   "success": true,                                   │║
║  │   "message": "Đăng nhập thành công",                 │║
║  │   "data": {                                          │║
║  │     "token": "2d2924a324ceac524dd409854590a33b..."   │║
║  │   }                                                  │║
║  │ }                                                    │║
║  └──────────────────────────────────────────────────────┘║
╚═══════════════════════════════════════════════════════════╝
```

### Tab Auth (Bearer Token):
```
╔═══════════════════════════════════════════════════════════╗
║  ┌─ Auth ──────────────────────────────────────────────┐ ║
║  │                                                      │ ║
║  │  Auth Type: [Bearer ▼]                              │ ║
║  │                                                      │ ║
║  │  Token: ┌──────────────────────────────────────┐    │ ║
║  │         │ 2d2924a324ceac524dd409854590a33b...  │    │ ║
║  │         └──────────────────────────────────────┘    │ ║
║  │                                                      │ ║
║  └──────────────────────────────────────────────────────┘ ║
╚═══════════════════════════════════════════════════════════╝
```

---

## 💡 MẸO NHANH

### Lưu Request để dùng lại:
1. Sau khi tạo request, nhấn **"Save"** (góc trên bên phải)
2. Chọn **"New Collection"** → đặt tên "API Phòng Khám"
3. Lần sau chỉ cần click vào request đã lưu

### Sử dụng biến môi trường:
1. Nhấn icon **"Env"** (góc trên)
2. Tạo biến:
   ```json
   {
     "baseUrl": "http://localhost:8000",
     "token": "paste_token_vào_đây"
   }
   ```
3. Dùng trong request:
   - URL: `{{baseUrl}}/admin/bac-si`
   - Token: `{{token}}`

---

## ⚠️ LƯU Ý QUAN TRỌNG

1. **Server phải đang chạy**: `php artisan serve`
2. **Token hết hạn**: Đăng nhập lại để lấy token mới
3. **Luôn thêm Bearer token** cho các request `/admin/*`
4. **Chọn đúng Method**: GET/POST/PUT/DELETE/PATCH
5. **Body chỉ dùng cho**: POST, PUT, PATCH

---

## 🐛 LỖI THƯỜNG GẶP

| Lỗi | Nguyên nhân | Giải pháp |
|-----|-------------|-----------|
| Failed to fetch | Server không chạy | Chạy `php artisan serve` |
| 401 Unauthorized | Thiếu token hoặc token sai | Đăng nhập lại, copy token mới |
| 403 Forbidden | Không có quyền admin | Dùng tài khoản admin |
| 422 Validation | Dữ liệu sai format | Kiểm tra Body JSON |
| 500 Server Error | Lỗi server | Xem log: storage/logs/laravel.log |

---

## ✅ CHECKLIST TEST

Test theo thứ tự:

- [ ] 1. Login → Lấy token ✅
- [ ] 2. Get danh sách bác sĩ ✅
- [ ] 3. Thêm bác sĩ mới ✅
- [ ] 4. Xem chi tiết bác sĩ ✅
- [ ] 5. Cập nhật bác sĩ ✅
- [ ] 6. Tìm kiếm bác sĩ ✅
- [ ] 7. Khóa tài khoản ✅
- [ ] 8. Xóa bác sĩ ✅

---

## 🎯 BẮT ĐẦU NGAY!

1. Mở Thunder Client (icon ⚡)
2. Copy đoạn Login ở trên
3. Paste vào Thunder Client
4. Nhấn Send
5. Copy token
6. Test các API khác!

**Chúc bạn thành công! 🚀**
