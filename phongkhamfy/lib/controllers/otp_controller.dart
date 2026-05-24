import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../utils/loading_utils.dart';

class ThongTinXacNhanOTP {
  final String email;
  final String maOTP;
  final String matKhauMoi;
  final String xacNhanMatKhau;

  ThongTinXacNhanOTP({
    required this.email,
    required this.maOTP,
    required this.matKhauMoi,
    required this.xacNhanMatKhau,
  });
}

class KetQuaXacNhanOTP {
  final bool thanhCong;
  final String thongBao;
  final String? maLoi;

  KetQuaXacNhanOTP({
    required this.thanhCong,
    required this.thongBao,
    this.maLoi,
  });
}

class DichVuXacNhanOTP {
  final _dio = Dio();

  KetQuaXacNhanOTP kiemTraThongTin(ThongTinXacNhanOTP thongTin) {
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

    if (!RegExp(r'^\d{6}$').hasMatch(thongTin.maOTP.trim())) {
      return KetQuaXacNhanOTP(
        thanhCong: false,
        thongBao: 'Mã xác nhận chỉ được chứa số',
        maLoi: 'OTP_KHONG_HOP_LE',
      );
    }

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

    if (!_kiemTraDoManhMatKhau(thongTin.matKhauMoi)) {
      return KetQuaXacNhanOTP(
        thanhCong: false,
        thongBao: 'Mật khẩu phải chứa ít nhất 1 chữ cái và 1 số',
        maLoi: 'MAT_KHAU_YEU',
      );
    }

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

    return KetQuaXacNhanOTP(thanhCong: true, thongBao: 'Thông tin hợp lệ');
  }

  Future<KetQuaXacNhanOTP> xacNhanOTPVaCapNhatMatKhau(
    ThongTinXacNhanOTP thongTin,
  ) async {
    final ketQuaKiemTra = kiemTraThongTin(thongTin);
    if (!ketQuaKiemTra.thanhCong) return ketQuaKiemTra;

    LoadingUtils.showLoading(message: 'Đang xác nhận mã OTP...');
    try {
      final response = await _dio.post(
        ApiConfig.getFullUrl(ApiConfig.resetPassword),
        data: {
          'email': thongTin.email.trim(),
          'otp': thongTin.maOTP.trim(),
          'password': thongTin.matKhauMoi,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] == true;
      final message = (data['message'] ?? '').toString();

      if (success) {
        return KetQuaXacNhanOTP(
          thanhCong: true,
          thongBao: message.isNotEmpty
              ? message
              : 'Đặt lại mật khẩu thành công! Bạn có thể đăng nhập với mật khẩu mới.',
        );
      }

      if (response.statusCode == 422) {
        return KetQuaXacNhanOTP(
          thanhCong: false,
          thongBao: message.isNotEmpty ? message : 'Mã xác nhận không đúng hoặc đã hết hạn',
          maLoi: 'OTP_SAI',
        );
      }

      return KetQuaXacNhanOTP(
        thanhCong: false,
        thongBao: message.isNotEmpty ? message : 'Có lỗi xảy ra. Vui lòng thử lại.',
        maLoi: 'LOI_MANG',
      );
    } on DioException catch (e) {
      final message = (e.response?.data is Map)
          ? (e.response!.data['message'] ?? '').toString()
          : '';
      return KetQuaXacNhanOTP(
        thanhCong: false,
        thongBao: message.isNotEmpty ? message : 'Lỗi kết nối. Vui lòng kiểm tra mạng và thử lại.',
        maLoi: 'LOI_KET_NOI',
      );
    } finally {
      LoadingUtils.hideLoading();
    }
  }

  bool _kiemTraDoManhMatKhau(String matKhau) {
    final coChu = RegExp(r'[a-zA-Z]').hasMatch(matKhau);
    final coSo = RegExp(r'[0-9]').hasMatch(matKhau);
    return coChu && coSo;
  }
}
