# API Documentation - Phòng Khám Management System

## Base URL
```
http://localhost:8000/admin
```

---

## 1. QUẢN LÝ KHOA (Department Management)

### 1.1 Lấy danh sách tất cả khoa
**GET** `/khoa`

**Query Parameters:**
- `search` (optional): Tìm kiếm theo tên khoa

**Response:**
```json
{
  "success": true,
  "message": "Lấy danh sách khoa thành công",
  "data": [
    {
      "MaKhoa": "K001",
      "TenKhoa": "Tim mạch"
    }
  ]
}
```

### 1.2 Lấy chi tiết khoa
**GET** `/khoa/{MaKhoa}`

**Response:**
```json
{
  "success": true,
  "message": "Lấy chi tiết khoa thành công",
  "data": {
    "MaKhoa": "K001",
    "TenKhoa": "Tim mạch"
  }
}
```

### 1.3 Thêm khoa mới
**POST** `/khoa`

**Request Body:**
```json
{
  "MaKhoa": "K001",
  "TenKhoa": "Tim mạch"
}
```

**Response:** `201 Created`

### 1.4 Cập nhật khoa
**PUT** `/khoa/{MaKhoa}`

**Request Body:**
```json
{
  "TenKhoa": "Tim mạch - Cập nhật"
}
```

**Response:** `200 OK`

### 1.5 Xóa khoa
**DELETE** `/khoa/{MaKhoa}`

**Response:** `200 OK`

---

## 2. QUẢN LÝ BỆNH (Disease Management)

### 2.1 Lấy danh sách tất cả bệnh
**GET** `/benh`

**Query Parameters:**
- `search` (optional): Tìm kiếm theo tên bệnh hoặc mã bệnh

**Response:**
```json
{
  "success": true,
  "message": "Lấy danh sách bệnh thành công",
  "data": [
    {
      "MaBenh": "B001",
      "TenBenh": "Bệnh tim",
      "MoTa": "Mô tả bệnh tim"
    }
  ]
}
```

### 2.2 Lấy chi tiết bệnh
**GET** `/benh/{MaBenh}`

**Response:**
```json
{
  "success": true,
  "message": "Lấy chi tiết bệnh thành công",
  "data": {
    "MaBenh": "B001",
    "TenBenh": "Bệnh tim",
    "MoTa": "Mô tả bệnh tim",
    "dichVuLienQuan": [
      {
        "MaDichVu": "DV001",
        "TenDichVu": "Siêu âm tim",
        "Gia": 500000
      }
    ]
  }
}
```

### 2.3 Thêm bệnh mới
**POST** `/benh`

**Request Body:**
```json
{
  "MaBenh": "B001",
  "TenBenh": "Bệnh tim",
  "MoTa": "Mô tả bệnh tim"
}
```

**Response:** `201 Created`

### 2.4 Cập nhật bệnh
**PUT** `/benh/{MaBenh}`

**Request Body:**
```json
{
  "TenBenh": "Bệnh tim - Cập nhật",
  "MoTa": "Mô tả mới"
}
```

**Response:** `200 OK`

### 2.5 Xóa bệnh
**DELETE** `/benh/{MaBenh}`

**Response:** `200 OK`

### 2.6 Liên kết bệnh với dịch vụ
**POST** `/benh/{MaBenh}/dich-vu`

**Request Body:**
```json
{
  "MaDichVu": "DV001"
}
```

**Response:** `201 Created`

### 2.7 Hủy liên kết bệnh với dịch vụ
**DELETE** `/benh/{MaBenh}/dich-vu/{MaDichVu}`

**Response:** `200 OK`

---

## 3. QUẢN LÝ DỊCH VỤ (Service Management)

### 3.1 Lấy danh sách tất cả dịch vụ
**GET** `/dich-vu`

**Query Parameters:**
- `search` (optional): Tìm kiếm theo tên dịch vụ hoặc mã dịch vụ
- `MaKhoa` (optional): Lọc theo khoa

**Response:**
```json
{
  "success": true,
  "message": "Lấy danh sách dịch vụ thành công",
  "data": [
    {
      "MaDichVu": "DV001",
      "TenDichVu": "Siêu âm tim",
      "Gia": 500000,
      "MaKhoa": "K001",
      "TenKhoa": "Tim mạch"
    }
  ]
}
```

### 3.2 Lấy chi tiết dịch vụ
**GET** `/dich-vu/{MaDichVu}`

**Response:**
```json
{
  "success": true,
  "message": "Lấy chi tiết dịch vụ thành công",
  "data": {
    "MaDichVu": "DV001",
    "TenDichVu": "Siêu âm tim",
    "Gia": 500000,
    "MaKhoa": "K001",
    "TenKhoa": "Tim mạch",
    "benhLienQuan": [
      {
        "MaBenh": "B001",
        "TenBenh": "Bệnh tim",
        "MoTa": "Mô tả bệnh tim"
      }
    ]
  }
}
```

### 3.3 Thêm dịch vụ mới
**POST** `/dich-vu`

**Request Body:**
```json
{
  "MaDichVu": "DV001",
  "TenDichVu": "Siêu âm tim",
  "Gia": 500000,
  "MaKhoa": "K001"
}
```

**Response:** `201 Created`

### 3.4 Cập nhật dịch vụ
**PUT** `/dich-vu/{MaDichVu}`

**Request Body:**
```json
{
  "TenDichVu": "Siêu âm tim - Cập nhật",
  "Gia": 550000,
  "MaKhoa": "K001"
}
```

**Response:** `200 OK`

### 3.5 Xóa dịch vụ
**DELETE** `/dich-vu/{MaDichVu}`

**Response:** `200 OK`

### 3.6 Lấy danh sách dịch vụ theo khoa
**GET** `/dich-vu/khoa/{MaKhoa}`

**Response:**
```json
{
  "success": true,
  "message": "Lấy danh sách dịch vụ theo khoa thành công",
  "data": [
    {
      "MaDichVu": "DV001",
      "TenDichVu": "Siêu âm tim",
      "Gia": 500000,
      "MaKhoa": "K001"
    }
  ]
}
```

### 3.7 Lấy danh sách dịch vụ theo bệnh
**GET** `/dich-vu/benh/{MaBenh}`

**Response:**
```json
{
  "success": true,
  "message": "Lấy danh sách dịch vụ theo bệnh thành công",
  "data": [
    {
      "MaDichVu": "DV001",
      "TenDichVu": "Siêu âm tim",
      "Gia": 500000,
      "MaKhoa": "K001"
    }
  ]
}
```

---

## Error Responses

### 404 Not Found
```json
{
  "success": false,
  "message": "Khoa không tồn tại"
}
```

### 422 Validation Error
```json
{
  "success": false,
  "message": "Dữ liệu không hợp lệ",
  "errors": {
    "TenKhoa": ["The TenKhoa field is required."]
  }
}
```

### 400 Bad Request
```json
{
  "success": false,
  "message": "Không thể xóa khoa vì có dịch vụ liên quan"
}
```

### 500 Server Error
```json
{
  "success": false,
  "message": "Lỗi: [error message]"
}
```

---

## Notes

1. **Khoa (Department)**: Quản lý các khoa trong bệnh viện
2. **Bệnh (Disease)**: Quản lý danh sách bệnh, có thể liên kết với dịch vụ
3. **Dịch Vụ (Service)**: Quản lý các dịch vụ y tế, có thể thuộc một khoa

### Relationships:
- Khoa → Dịch Vụ (1:N)
- Bệnh ↔ Dịch Vụ (N:N) - thông qua bảng `dichvu_benh`
- Bệnh → Kết Luận Khám (1:N)
- Dịch Vụ → Chi Tiết Lịch Khám (1:N)
- Dịch Vụ → Chi Tiết Phiếu Chỉ Định (1:N)

### Validation Rules:
- **MaKhoa/MaBenh/MaDichVu**: Bắt buộc, duy nhất, chuỗi
- **TenKhoa/TenBenh/TenDichVu**: Bắt buộc, tối đa 255 ký tự
- **Gia**: Bắt buộc, số, >= 0
- **MoTa**: Tùy chọn, chuỗi
