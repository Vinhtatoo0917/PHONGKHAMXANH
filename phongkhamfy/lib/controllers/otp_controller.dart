import '../utils/loading_utils.dart';

// ═══════════════════════════════════════════════════════════════
// CLASS: ThongTinXacNhanOTP
// MÔ TẢ: Model chứa thông tin xác nhận OTP và mật khẩu mới
// ═══════════════════════════════════════════════════════════════
class ThongTinXacNhanOTP {
  final String email; // Email người dùng
  final String maOTP; // Mã OTP
  final String matKhauMoi; // Mật khẩu mới
  final String xacNhanMatKhau; // Xác nhận mật khẩu

  ThongTinXacNhanOTP({
    required this.email,
    required this.maOTP,
    required this.matKhauMoi,
    required this.xacNhanMatKhau,
  });
}

// ═══════════════════════════════════════════════════════════════
// CLASS: KetQuaXacNhanOTP
// MÔ TẢ: Model chứa kết quả xử lý xác nhận OTP
// ═══════════════════════════════════════════════════════════════
class KetQuaXacNhanOTP {
  final bool thanhCong; // Có thành công không?
  final String thongBao; // Thông báo kết quả
  final String? maLoi; // Mã lỗi (nếu có)

  KetQuaXacNhanOTP({
    required this.thanhCong,
    required this.thongBao,
    this.maLoi,
  });
}

// ═══════════════════════════════════════════════════════════════
// CLASS: DichVuXacNhanOTP
// MÔ TẢ: Service xử lý tất cả logic liên quan đến xác nhận OTP
// ═══════════════════════════════════════════════════════════════
class DichVuXacNhanOTP {
  // ═══════════════════════════════════════════════════════════════
  // HÀM KIỂM TRA THÔNG TIN
  // ═══════════════════════════════════════════════════════════════

  /// Kiểm tra thông tin xác nhận OTP có hợp lệ không
  ///
  /// Tham số:
  /// - thongTin: Thông tin xác nhận OTP cần kiểm tra
  ///
  /// Trả về:
  /// - KetQuaXacNhanOTP: Kết quả kiểm tra
  KetQuaXacNhanOTP kiemTraThongTin(ThongTinXacNhanOTP thongTin) {
    // ─────────────────────────────────────────────────────────────
    // KIỂM TRA MÃ OTP
    // ─────────────────────────────────────────────────────────────
    if (thongTin.maOTP.trim().isEmpty) {
      return KetQuaXacNhanOTP(
        thanhCong: false,
        thongBao: 'Vui lòng nhập mã xác nhận',
        maLoi: 'OTP_TRONG',
      );
    }

    if (thongTin.maOTP.trim().length != 6) {
      return KetQuaXacNhanOTP(
        thanhCong: false,
        thongBao: 'Mã xác nhận phải có 6 số',
        maLoi: 'OTP_KHONG_HOP_LE',
      );
    }

    // Kiểm tra mã OTP chỉ chứa số
    if (!RegExp(r'^\d{6}$').hasMatch(thongTin.maOTP.trim())) {
      return KetQuaXacNhanOTP(
        thanhCong: false,
        thongBao: 'Mã xác nhận chỉ được chứa số',
        maLoi: 'OTP_KHONG_HOP_LE',
      );
    }

    // ─────────────────────────────────────────────────────────────
    // KIỂM TRA MẬT KHẨU MỚI
    // ─────────────────────────────────────────────────────────────
    if (thongTin.matKhauMoi.isEmpty) {
      return KetQuaXacNhanOTP(
        thanhCong: false,
        thongBao: 'Vui lòng nhập mật khẩu mới',
        maLoi: 'MAT_KHAU_TRONG',
      );
    }

    if (thongTin.matKhauMoi.length < 6) {
      return KetQuaXacNhanOTP(
        thanhCong: false,
        thongBao: 'Mật khẩu mới phải có ít nhất 6 ký tự',
        maLoi: 'MAT_KHAU_QUA_NGAN',
      );
    }

    // Kiểm tra độ mạnh mật khẩu (có chữ và số)
    if (!_kiemTraDoManhMatKhau(thongTin.matKhauMoi)) {
      return KetQuaXacNhanOTP(
        thanhCong: false,
        thongBao: 'Mật khẩu phải chứa ít nhất 1 chữ cái và 1 số',
        maLoi: 'MAT_KHAU_YEU',
      );
    }

    // ─────────────────────────────────────────────────────────────
    // KIỂM TRA XÁC NHẬN MẬT KHẨU
    // ─────────────────────────────────────────────────────────────
    if (thongTin.xacNhanMatKhau.isEmpty) {
      return KetQuaXacNhanOTP(
        thanhCong: false,
        thongBao: 'Vui lòng xác nhận mật khẩu mới',
        maLoi: 'XAC_NHAN_MAT_KHAU_TRONG',
      );
    }

    if (thongTin.matKhauMoi != thongTin.xacNhanMatKhau) {
      return KetQuaXacNhanOTP(
        thanhCong: false,
        thongBao: 'Mật khẩu xác nhận không khớp',
        maLoi: 'MAT_KHAU_KHONG_KHOP',
      );
    }

    // ─────────────────────────────────────────────────────────────
    // TẤT CẢ THÔNG TIN HỢP LỆ
    // ─────────────────────────────────────────────────────────────
    return KetQuaXacNhanOTP(thanhCong: true, thongBao: 'Thông tin hợp lệ');
  }

  // ═══════════════════════════════════════════════════════════════
  // HÀM XÁC NHẬN OTP VÀ CẬP NHẬT MẬT KHẨU
  // ═══════════════════════════════════════════════════════════════

  /// Xác nhận OTP và cập nhật mật khẩu mới
  ///
  /// Tham số:
  /// - thongTin: Thông tin xác nhận OTP
  ///
  /// Trả về:
  /// - Future KetQuaXacNhanOTP: Kết quả xác nhận (bất đồng bộ)
  Future<KetQuaXacNhanOTP> xacNhanOTPVaCapNhatMatKhau(
    ThongTinXacNhanOTP thongTin,
  ) async {
    // ─────────────────────────────────────────────────────────────
    // BƯỚC 1: KIỂM TRA THÔNG TIN
    // ─────────────────────────────────────────────────────────────
    final ketQuaKiemTra = kiemTraThongTin(thongTin);
    if (!ketQuaKiemTra.thanhCong) {
      return ketQuaKiemTra;
    }

    // ─────────────────────────────────────────────────────────────
    // BƯỚC 2: GỌI API XÁC NHẬN OTP
    // ─────────────────────────────────────────────────────────────
    LoadingUtils.showLoading(message: 'Đang xác nhận mã OTP...');
    try {
      // ───────────────────────────────────────────────────────────
      // BƯỚC 3: KIỂM TRA MÃ OTP CÓ ĐÚNG KHÔNG (giả lập)
      // ───────────────────────────────────────────────────────────
      final otpDung = await _kiemTraOTPDung(thongTin.email, thongTin.maOTP);
      if (!otpDung) {
        return KetQuaXacNhanOTP(
          thanhCong: false,
          thongBao: 'Mã xác nhận không đúng hoặc đã hết hạn',
          maLoi: 'OTP_SAI',
        );
      }

      // ───────────────────────────────────────────────────────────
      // BƯỚC 4: CẬP NHẬT MẬT KHẨU MỚI (giả lập)
      // ───────────────────────────────────────────────────────────
      // TODO: Trong thực tế sẽ gọi API cập nhật mật khẩu

      // ───────────────────────────────────────────────────────────
      // BƯỚC 5: TRẢ VỀ KẾT QUẢ THÀNH CÔNG
      // ───────────────────────────────────────────────────────────
      return KetQuaXacNhanOTP(
        thanhCong: true,
        thongBao:
            'Cập nhật mật khẩu thành công! Bạn có thể đăng nhập với mật khẩu mới.',
      );
    } finally {
      LoadingUtils.hideLoading();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CÁC HÀM PRIVATE (chỉ dùng trong class này)
  // ═══════════════════════════════════════════════════════════════

  /// Kiểm tra độ mạnh mật khẩu (có chữ và số)
  bool _kiemTraDoManhMatKhau(String matKhau) {
    // Phải có ít nhất 1 chữ cái và 1 số
    final coChu = RegExp(r'[a-zA-Z]').hasMatch(matKhau);
    final coSo = RegExp(r'[0-9]').hasMatch(matKhau);
    return coChu && coSo;
  }

  /// Kiểm tra mã OTP có đúng không (giả lập)
  Future<bool> _kiemTraOTPDung(String email, String otp) async {
    // Giả lập độ trễ API
    await Future.delayed(const Duration(milliseconds: 500));

    // Giả lập: mã OTP đúng là "123456" cho tất cả email
    // Trong thực tế sẽ kiểm tra với database
    return otp == '123456';
  }
}
