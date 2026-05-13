// ═══════════════════════════════════════════════════════════════
// FILE: dich_vu_quen_mat_khau.dart
// MÔ TẢ: Service xử lý logic quên mật khẩu
// ═══════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════
// CLASS: KetQuaQuenMatKhau
// MÔ TẢ: Model chứa kết quả xử lý quên mật khẩu
// ═══════════════════════════════════════════════════════════════
class KetQuaQuenMatKhau {
  final bool thanhCong; // Có thành công không?
  final String thongBao; // Thông báo kết quả
  final String? maLoi; // Mã lỗi (nếu có)

  KetQuaQuenMatKhau({
    required this.thanhCong,
    required this.thongBao,
    this.maLoi,
  });
}

// ═══════════════════════════════════════════════════════════════
// CLASS: DichVuQuenMatKhau
// MÔ TẢ: Service xử lý tất cả logic liên quan đến quên mật khẩu
// ═══════════════════════════════════════════════════════════════
class DichVuQuenMatKhau {
  // ═══════════════════════════════════════════════════════════════
  // HÀM KIỂM TRA EMAIL
  // ═══════════════════════════════════════════════════════════════

  /// Kiểm tra email có hợp lệ không
  ///
  /// Tham số:
  /// - email: Email cần kiểm tra
  ///
  /// Trả về:
  /// - KetQuaQuenMatKhau: Kết quả kiểm tra
  KetQuaQuenMatKhau kiemTraEmail(String email) {
    // ─────────────────────────────────────────────────────────────
    // KIỂM TRA TRỐNG
    // ─────────────────────────────────────────────────────────────
    if (email.trim().isEmpty) {
      return KetQuaQuenMatKhau(
        thanhCong: false,
        thongBao: 'Vui lòng nhập email',
        maLoi: 'EMAIL_TRONG',
      );
    }

    // ─────────────────────────────────────────────────────────────
    // KIỂM TRA ĐỊNH DẠNG EMAIL
    // ─────────────────────────────────────────────────────────────
    if (!_kiemTraDinhDangEmail(email.trim())) {
      return KetQuaQuenMatKhau(
        thanhCong: false,
        thongBao: 'Email không đúng định dạng',
        maLoi: 'EMAIL_KHONG_HOP_LE',
      );
    }

    // ─────────────────────────────────────────────────────────────
    // EMAIL HỢP LỆ
    // ─────────────────────────────────────────────────────────────
    return KetQuaQuenMatKhau(thanhCong: true, thongBao: 'Email hợp lệ');
  }

  // ═══════════════════════════════════════════════════════════════
  // HÀM GỬI MÃ XÁC NHẬN
  // ═══════════════════════════════════════════════════════════════

  /// Gửi mã xác nhận đến email
  ///
  /// Tham số:
  /// - email: Email nhận mã xác nhận
  ///
  /// Trả về:
  /// - Future KetQuaQuenMatKhau: Kết quả gửi mã (bất đồng bộ)
  Future<KetQuaQuenMatKhau> guiMaXacNhan(String email) async {
    // ─────────────────────────────────────────────────────────────
    // BƯỚC 1: KIỂM TRA EMAIL
    // ─────────────────────────────────────────────────────────────
    final ketQuaKiemTra = kiemTraEmail(email);
    if (!ketQuaKiemTra.thanhCong) {
      return ketQuaKiemTra;
    }

    // ─────────────────────────────────────────────────────────────
    // BƯỚC 2: GIẢ LẬP GỌI API (2 giây)
    // ─────────────────────────────────────────────────────────────
    await Future.delayed(const Duration(seconds: 2));

    // ─────────────────────────────────────────────────────────────
    // BƯỚC 3: KIỂM TRA EMAIL CÓ TỒN TẠI TRONG HỆ THỐNG KHÔNG
    // ─────────────────────────────────────────────────────────────
    final emailTonTai = await _kiemTraEmailTonTaiTrongHeThong(email.trim());
    if (!emailTonTai) {
      return KetQuaQuenMatKhau(
        thanhCong: false,
        thongBao: 'Email này chưa được đăng ký trong hệ thống',
        maLoi: 'EMAIL_KHONG_TON_TAI',
      );
    }

    // ─────────────────────────────────────────────────────────────
    // BƯỚC 4: GỬI MÃ XÁC NHẬN (giả lập)
    // ─────────────────────────────────────────────────────────────
    // TODO: Trong thực tế sẽ gọi API gửi email

    // ─────────────────────────────────────────────────────────────
    // BƯỚC 5: TRẢ VỀ KẾT QUẢ THÀNH CÔNG
    // ─────────────────────────────────────────────────────────────
    return KetQuaQuenMatKhau(
      thanhCong: true,
      thongBao:
          'Mã xác nhận đã được gửi đến email ${email.trim()}. Vui lòng kiểm tra hộp thư của bạn.',
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CÁC HÀM PRIVATE (chỉ dùng trong class này)
  // ═══════════════════════════════════════════════════════════════

  /// Kiểm tra định dạng email
  bool _kiemTraDinhDangEmail(String email) {
    // Regex pattern cho email cơ bản
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Kiểm tra email có tồn tại trong hệ thống không (giả lập)
  Future<bool> _kiemTraEmailTonTaiTrongHeThong(String email) async {
    // Giả lập độ trễ API
    await Future.delayed(const Duration(milliseconds: 500));

    // Giả lập: một số email có sẵn trong hệ thống
    final emailsCoSan = [
      'admin@phongkham.vn',
      'user@gmail.com',
      'test@example.com',
      'doctor@phongkham.vn',
    ];

    return emailsCoSan.contains(email.toLowerCase());
  }
}
