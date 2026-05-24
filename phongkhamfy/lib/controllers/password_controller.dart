import 'package:dio/dio.dart';
import '../config/api_config.dart';

class KetQuaQuenMatKhau {
  final bool thanhCong;
  final String thongBao;
  final String? maLoi;

  KetQuaQuenMatKhau({
    required this.thanhCong,
    required this.thongBao,
    this.maLoi,
  });
}

class DichVuQuenMatKhau {
  final _dio = Dio();

  KetQuaQuenMatKhau kiemTraEmail(String email) {
    if (email.trim().isEmpty) {
      return KetQuaQuenMatKhau(
        thanhCong: false,
        thongBao: 'Vui lòng nhập email',
        maLoi: 'EMAIL_TRONG',
      );
    }

    if (!_kiemTraDinhDangEmail(email.trim())) {
      return KetQuaQuenMatKhau(
        thanhCong: false,
        thongBao: 'Email không đúng định dạng',
        maLoi: 'EMAIL_KHONG_HOP_LE',
      );
    }

    return KetQuaQuenMatKhau(thanhCong: true, thongBao: 'Email hợp lệ');
  }

  Future<KetQuaQuenMatKhau> guiMaXacNhan(String email) async {
    final ketQuaKiemTra = kiemTraEmail(email);
    if (!ketQuaKiemTra.thanhCong) return ketQuaKiemTra;

    try {
      final response = await _dio.post(
        ApiConfig.getFullUrl(ApiConfig.forgotPassword),
        data: {'email': email.trim()},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final success = data['success'] == true;
      final message = (data['message'] ?? '').toString();

      if (success) {
        return KetQuaQuenMatKhau(thanhCong: true, thongBao: message);
      }

      if (response.statusCode == 404) {
        return KetQuaQuenMatKhau(
          thanhCong: false,
          thongBao: message.isNotEmpty ? message : 'Email này chưa được đăng ký trong hệ thống',
          maLoi: 'EMAIL_KHONG_TON_TAI',
        );
      }

      return KetQuaQuenMatKhau(
        thanhCong: false,
        thongBao: message.isNotEmpty ? message : 'Không thể gửi mã xác nhận. Vui lòng thử lại.',
        maLoi: 'LOI_MANG',
      );
    } on DioException catch (e) {
      final message = (e.response?.data is Map)
          ? (e.response!.data['message'] ?? '').toString()
          : '';
      return KetQuaQuenMatKhau(
        thanhCong: false,
        thongBao: message.isNotEmpty ? message : 'Lỗi kết nối. Vui lòng kiểm tra mạng và thử lại.',
        maLoi: 'LOI_KET_NOI',
      );
    }
  }

  bool _kiemTraDinhDangEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}
