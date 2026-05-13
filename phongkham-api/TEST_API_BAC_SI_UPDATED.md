# ✅ TEST API BÁC SĨ - CẬP NHẬT MỚI

## 🔄 THAY ĐỔI MỚI

### Khi thêm bác sĩ mới:
- ✅ **Trạng thái hoạt động**: Mặc định là `active`
- ✅ **Kinh nghiệm**: Mặc định là `0 năm` (nếu không gửi)

---

## 🧪 TEST TRÊN THUNDER CLIENT

### 1️⃣ Đăng nhập lấy token (như cũ)

```
Method: POST
URL: http://localhost:8000/login
Body (JSON):
{
  "sdt": "967287418",
  "MatKhau": "Vinh0917641090@"
}
```

**→ Copy token từ response**

---

### 2️⃣ Test thêm bác sĩ MỚI (không gửi KinhNghiem)

```
Method: POST
URL: http://localhost:8000/admin/bac-si
Auth: Bearer [PASTE_TOKEN]
Body (JSON):
{
  "ho": "Lê Văn",
  "ten": "Cường",
  "ngaysinh": "1992-08-10",
  "gioitinh": "Nam",
  "ChuyenKhoa": "Ngoại khoa",
  "BangCap": "Bác sĩ",
  "email": "bacsi3@gmail.com",
  "sdt": "934567890",
  "MatKhau": "123456"
}
```

**Lưu ý**: Không gửi trường `KinhNghiem`

**Kết quả mong đợi**:
```json
{
  "success": true,
  "message": "Thêm bác sĩ thành công",
  "data": {
    "MaBacSi": 2,
    "MaTaiKhoan": 9
  }
}
```

---

### 3️⃣ Kiểm tra bác sĩ vừa thêm

```
Method: GET
URL: http://localhost:8000/admin/bac-si/2
Auth: Bearer [PASTE_TOKEN]
```

**Kết quả mong đợi**:
```json
{
  "success": true,
  "data": {
    "MaBacSi": 2,
    "ho": "Lê Văn",
    "ten": "Cường",
    "ChuyenKhoa": "Ngoại khoa",
    "BangCap": "Bác sĩ",
    "KinhNghiem": "0 năm",           ← Mặc định
    "trangthaihoatdong": "active"    ← Mặc định
  }
}
```

---

### 4️⃣ Test thêm bác sĩ CÓ kinh nghiệm

```
Method: POST
URL: http://localhost:8000/admin/bac-si
Auth: Bearer [PASTE_TOKEN]
Body (JSON):
{
  "ho": "Phạm Thị",
  "ten": "Dung",
  "ngaysinh": "1988-12-25",
  "gioitinh": "Nữ",
  "ChuyenKhoa": "Sản khoa",
  "BangCap": "Thạc sĩ",
  "KinhNghiem": "8 năm",
  "email": "bacsi4@gmail.com",
  "sdt": "945678901",
  "MatKhau": "123456"
}
```

**Kết quả mong đợi**:
```json
{
  "success": true,
  "message": "Thêm bác sĩ thành công",
  "data": {
    "MaBacSi": 3,
    "MaTaiKhoan": 10
  }
}
```

---

### 5️⃣ Kiểm tra danh sách bác sĩ

```
Method: GET
URL: http://localhost:8000/admin/bac-si
Auth: Bearer [PASTE_TOKEN]
```

**Kết quả mong đợi**: Danh sách có 3 bác sĩ
- Bác sĩ 1: KinhNghiem = "15 năm" (đã cập nhật trước đó)
- Bác sĩ 2: KinhNghiem = "0 năm" (mặc định)
- Bác sĩ 3: KinhNghiem = "8 năm" (có gửi)

---

## 📋 CHECKLIST TEST

- [ ] Đăng nhập lấy token
- [ ] Thêm bác sĩ KHÔNG gửi KinhNghiem → Kiểm tra = "0 năm"
- [ ] Kiểm tra trangthaihoatdong = "active"
- [ ] Thêm bác sĩ CÓ gửi KinhNghiem → Kiểm tra = giá trị đã gửi
- [ ] Lấy danh sách bác sĩ → Kiểm tra tất cả

---

## 🎯 KẾT QUẢ MONG ĐỢI

### Trường hợp 1: Không gửi KinhNghiem
```json
{
  "KinhNghiem": "0 năm",
  "trangthaihoatdong": "active"
}
```

### Trường hợp 2: Có gửi KinhNghiem
```json
{
  "KinhNghiem": "8 năm",
  "trangthaihoatdong": "active"
}
```

---

## 💡 LƯU Ý

1. **KinhNghiem** là trường `nullable` → Không bắt buộc phải gửi
2. Nếu không gửi → Tự động = `"0 năm"`
3. Nếu có gửi → Dùng giá trị đã gửi
4. **trangthaihoatdong** luôn = `"active"` khi tạo mới

---

## 🚀 BẮT ĐẦU TEST

1. Mở Thunder Client
2. Đăng nhập lấy token
3. Test thêm bác sĩ không có KinhNghiem
4. Kiểm tra kết quả
5. Test thêm bác sĩ có KinhNghiem
6. So sánh kết quả

**Chúc bạn test thành công! ✅**
