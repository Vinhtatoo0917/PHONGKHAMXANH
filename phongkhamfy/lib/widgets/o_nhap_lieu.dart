// ═══════════════════════════════════════════════════════════════
// FILE: o_nhap_lieu.dart
// MÔ TẢ: Widget TextField tùy chỉnh có thể tái sử dụng
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// CLASS: ONhapLieu
// MÔ TẢ: TextField tùy chỉnh với icon, hint, và hỗ trợ password
// LOẠI: StatelessWidget
// ═══════════════════════════════════════════════════════════════
class ONhapLieu extends StatelessWidget {
  // ─────────────────────────────────────────────────────────────
  // CÁC THUỘC TÍNH
  // ─────────────────────────────────────────────────────────────
  
  // final = không thay đổi sau khi khởi tạo
  // TextEditingController - Quản lý nội dung text (lấy giá trị, xóa text, v.v.)
  final TextEditingController boQuanLy;
  
  // String - Chuỗi text gợi ý (placeholder)
  final String goiY;
  
  // IconData - Icon hiển thị bên trái TextField
  final IconData iconTrai;
  
  // bool - Có phải trường mật khẩu không? (true/false)
  final bool laMatKhau;
  
  // bool - Mật khẩu có đang hiển thị không?
  final bool hienThiMatKhau;
  
  // VoidCallback? - Hàm callback khi nhấn nút hiện/ẩn mật khẩu
  // ? = có thể null (không bắt buộc)
  final VoidCallback? khiBatTatHienThiMatKhau;
  
  // TextInputType? - Loại bàn phím (email, số, text, v.v.)
  final TextInputType? loaiBanPhim;
  
  // bool - Có kích hoạt (enable) TextField không?
  final bool kichHoat;

  // ─────────────────────────────────────────────────────────────
  // CONSTRUCTOR - Hàm khởi tạo
  // ─────────────────────────────────────────────────────────────
  const ONhapLieu({
    super.key, // Key để Flutter quản lý widget
    required this.boQuanLy,          // required = bắt buộc phải truyền
    required this.goiY,
    required this.iconTrai,
    this.laMatKhau = false,          // Giá trị mặc định = false
    this.hienThiMatKhau = false,
    this.khiBatTatHienThiMatKhau,    // Không required = tùy chọn
    this.loaiBanPhim,
    this.kichHoat = true,            // Mặc định = true (kích hoạt)
  });

  // ─────────────────────────────────────────────────────────────
  // MÀU SẮC
  // ─────────────────────────────────────────────────────────────
  // static const = Hằng số dùng chung cho tất cả instance
  static const Color mauChinh = Color(0xFF3DAA70);        // Màu xanh lá chính
  static const Color mauNen = Color(0xFFF0FAF5);          // Màu nền xanh nhạt
  static const Color mauChuChinh = Color(0xFF1A3D2E);     // Màu chữ đậm
  static const Color mauChuPhu = Color(0xFF5A8A70);       // Màu chữ nhạt
  static const Color mauVien = Color(0xFFB2DFC8);         // Màu viền

  // ═══════════════════════════════════════════════════════════════
  // HÀM BUILD - Xây dựng giao diện
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // TextFormField - Widget nhập liệu có thể validate
    return TextFormField(
      // Gắn controller để quản lý nội dung
      controller: boQuanLy,
      
      // enabled - Có kích hoạt TextField không?
      enabled: kichHoat,
      
      // obscureText - Ẩn text (dùng cho mật khẩu)
      // && = toán tử AND (cả 2 điều kiện đều đúng)
      // ! = toán tử NOT (phủ định)
      // Ẩn text NẾU là password VÀ chưa bật hiển thị
      obscureText: laMatKhau && !hienThiMatKhau,
      
      // Loại bàn phím hiển thị (email, số, text, v.v.)
      keyboardType: loaiBanPhim,
      
      // Style cho text người dùng nhập
      style: TextStyle(
        fontSize: 16,                    // Tăng kích thước chữ cho web
        color: mauChuChinh,              // Màu chữ
        fontWeight: FontWeight.w500,     // Độ đậm (w500 = medium)
      ),
      
      // ─────────────────────────────────────────────────────────
      // DECORATION - Trang trí cho TextField
      // ─────────────────────────────────────────────────────────
      decoration: InputDecoration(
        // ───────────────────────────────────────────────────────
        // HINT TEXT (Text gợi ý)
        // ───────────────────────────────────────────────────────
        hintText: goiY, // Text gợi ý (ví dụ: "Nhập email...")
        hintStyle: TextStyle(
          // withValues(alpha: 0.5) = Độ trong suốt 50%
          color: mauChuPhu.withValues(alpha: 0.5),
          fontSize: 15,                  // Tăng kích thước hint
        ),
        
        // ───────────────────────────────────────────────────────
        // PREFIX ICON (Icon bên trái)
        // ───────────────────────────────────────────────────────
        prefixIcon: Padding(
          // EdgeInsets.only - Padding tùy chỉnh từng cạnh
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(
            iconTrai,          // Icon truyền vào
            color: mauChinh,   // Màu xanh lá
            size: 20,          // Kích thước 20px
          ),
        ),
        // Constraints cho icon (không giới hạn kích thước tối thiểu)
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        
        // ───────────────────────────────────────────────────────
        // SUFFIX ICON (Icon bên phải - chỉ cho password)
        // ───────────────────────────────────────────────────────
        // Toán tử ? : (ternary operator)
        // Cú pháp: điều_kiện ? giá_trị_nếu_đúng : giá_trị_nếu_sai
        suffixIcon: laMatKhau
            ? IconButton( // NẾU là password → hiện nút mắt
                icon: Icon(
                  // Đổi icon tùy theo trạng thái hiển thị
                  hienThiMatKhau
                      ? Icons.visibility_off_outlined  // Mắt gạch (đang hiện)
                      : Icons.visibility_outlined,     // Mắt thường (đang ẩn)
                  color: mauChuPhu,
                  size: 20,
                ),
                // Khi nhấn nút → gọi hàm khiBatTatHienThiMatKhau
                onPressed: khiBatTatHienThiMatKhau,
              )
            : null, // KHÔNG phải password → không hiện gì
        
        // ───────────────────────────────────────────────────────
        // BACKGROUND (Màu nền)
        // ───────────────────────────────────────────────────────
        filled: true,              // Bật màu nền
        fillColor: mauNen,         // Màu nền xanh nhạt
        
        // Padding bên trong TextField
        // symmetric - Padding đối xứng (ngang và dọc)
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18, // Tăng padding ngang
          vertical: 18,   // Tăng padding dọc
        ),
        
        // ───────────────────────────────────────────────────────
        // BORDERS (Viền trong các trạng thái khác nhau)
        // ───────────────────────────────────────────────────────
        
        // Border mặc định
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), // Bo góc 14px
          borderSide: const BorderSide(
            color: mauVien,  // Màu viền
            width: 1.5,      // Độ dày 1.5px
          ),
        ),
        
        // Border khi KHÔNG focus (không click vào)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: mauVien, width: 1.5),
        ),
        
        // Border khi ĐANG focus (đang click vào, đang nhập)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: mauChinh, // Màu xanh lá
            width: 2,        // Dày hơn (2px)
          ),
        ),
        
        // Border khi CÓ LỖI (validation fail)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.redAccent, // Màu đỏ
            width: 1.5,
          ),
        ),
        
        // Border khi CÓ LỖI VÀ ĐANG focus
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.redAccent, // Màu đỏ
            width: 2,                // Dày hơn
          ),
        ),
      ),
    );
  }
}
