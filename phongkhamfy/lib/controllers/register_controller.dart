// ═══════════════════════════════════════════════════════════════
// FILE: register_controller.dart
// MÔ TẢ: Service quản lý đăng ký tài khoản
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/loading_utils.dart';

// ═══════════════════════════════════════════════════════════════
// MODEL: KetQuaDangKy
// ═══════════════════════════════════════════════════════════════
class KetQuaDangKy {
  final bool thanhCong;
  final String? thongBaoLoi;
  final Map<String, dynamic>? thongTinTaiKhoan;

  KetQuaDangKy({
    required this.thanhCong,
    this.thongBaoLoi,
    this.thongTinTaiKhoan,
  });
}

// ═══════════════════════════════════════════════════════════════
// CLASS: DichVuDangKy
// ═══════════════════════════════════════════════════════════════
class DichVuDangKy {
  String? kiemTraSoDienThoai(String sdt) {
    sdt = sdt.trim();
    if (sdt.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (!RegExp(r'^[0-9]+$').hasMatch(sdt)) {
      return 'Số điện thoại chỉ được chứa chữ số';
    }
    if (sdt.length < 9 || sdt.length > 11) {
      return 'Số điện thoại phải có 9-11 chữ số';
    }
    return null;
  }

  String? kiemTraEmail(String email) {
    email = email.trim();
    if (email.isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  String? kiemTraMatKhau(String matKhau) {
    if (matKhau.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (matKhau.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';

    if (!RegExp(r'[A-Z]').hasMatch(matKhau)) {
      return 'Mật khẩu phải có ít nhất 1 chữ cái viết hoa';
    }

    if (!RegExp(r'[a-z]').hasMatch(matKhau)) {
      return 'Mật khẩu phải có ít nhất 1 chữ cái viết thường';
    }

    // Kiểm tra có số
    if (!RegExp(r'[0-9]').hasMatch(matKhau)) {
      return 'Mật khẩu phải có ít nhất 1 chữ số';
    }

    return null;
  }

  String? kiemTraXacNhanMatKhau(String matKhau, String xacNhanMatKhau) {
    if (xacNhanMatKhau.isEmpty) return 'Vui lòng nhập lại mật khẩu';
    if (matKhau != xacNhanMatKhau) return 'Mật khẩu nhập lại không khớp';
    return null;
  }

  Future<KetQuaDangKy> dangKy({
    required String sdt,
    required String email,
    required String matKhau,
    required String xacNhanMatKhau,
  }) async {
    final loiSdt = kiemTraSoDienThoai(sdt);
    if (loiSdt != null) {
      return KetQuaDangKy(thanhCong: false, thongBaoLoi: loiSdt);
    }

    final loiEmail = kiemTraEmail(email);
    if (loiEmail != null) {
      return KetQuaDangKy(thanhCong: false, thongBaoLoi: loiEmail);
    }

    final loiMatKhau = kiemTraMatKhau(matKhau);
    if (loiMatKhau != null) {
      return KetQuaDangKy(thanhCong: false, thongBaoLoi: loiMatKhau);
    }

    final loiXacNhan = kiemTraXacNhanMatKhau(matKhau, xacNhanMatKhau);
    if (loiXacNhan != null) {
      return KetQuaDangKy(thanhCong: false, thongBaoLoi: loiXacNhan);
    }

    final requestBody = {
      'sdt': sdt.trim(),
      'email': email.trim(),
      'MatKhau': matKhau,
    };

    LoadingUtils.showLoading(message: 'Đang tạo tài khoản mới...');
    try {
      // GỌI API
      final url = Uri.parse(ApiConfig.getFullUrl(ApiConfig.register));

      print('🔵 [REGISTER] Đang gọi: $url');
      print('🔵 [REGISTER] Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('🔵 [REGISTER] Status Code: ${response.statusCode}');
      print('🔵 [REGISTER] Response: ${response.body}');

      // XỬ LÝ RESPONSE
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ [REGISTER] Đăng ký thành công!');

        // Laravel trả về: {success: true, message: "...", data: {token, user}}
        if (responseData['success'] == true) {
          final userData = responseData['data']['user'];
          final token = responseData['data']['token'];

          // Thêm token vào user data
          userData['token'] = token;

          return KetQuaDangKy(thanhCong: true, thongTinTaiKhoan: userData);
        } else {
          return KetQuaDangKy(
            thanhCong: false,
            thongBaoLoi: responseData['message'] ?? 'Đăng ký thất bại',
          );
        }
      } else if (response.statusCode == 422) {
        // Lỗi validation - email hoặc SĐT đã tồn tại
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? 'Dữ liệu không hợp lệ';
          print('❌ [REGISTER] Lỗi validation: $errorMessage');
          return KetQuaDangKy(thanhCong: false, thongBaoLoi: errorMessage);
        } catch (e) {
          return KetQuaDangKy(
            thanhCong: false,
            thongBaoLoi: 'Email hoặc số điện thoại đã được sử dụng',
          );
        }
      } else if (response.statusCode == 409) {
        // Tài khoản đã tồn tại
        return KetQuaDangKy(
          thanhCong: false,
          thongBaoLoi: 'Số điện thoại hoặc email đã được sử dụng',
        );
      } else {
        print('❌ [REGISTER] Lỗi server: ${response.statusCode}');
        return KetQuaDangKy(
          thanhCong: false,
          thongBaoLoi: 'Lỗi server (${response.statusCode})',
        );
      }
    } catch (e) {
      print('❌ [REGISTER] Lỗi kết nối: $e');
      return KetQuaDangKy(
        thanhCong: false,
        thongBaoLoi: 'Không thể kết nối đến server. Lỗi: $e',
      );
    } finally {
      LoadingUtils.hideLoading();
    }
  }
}
