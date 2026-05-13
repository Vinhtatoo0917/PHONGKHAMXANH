// ═══════════════════════════════════════════════════════════════
// FILE: auth_controller.dart
// MÔ TẢ: Xử lý đăng nhập và check token với database
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/session_manager.dart';
import '../config/api_config.dart';

class KetQuaDangNhap {
  final bool thanhCong;
  final String? thongBaoLoi;
  final Map<String, dynamic>? thongTinNguoiDung;

  KetQuaDangNhap({
    required this.thanhCong,
    this.thongBaoLoi,
    this.thongTinNguoiDung,
  });
}

class DichVuXacThuc {
  final _sessionManager = SessionManager();

  // ═══════════════════════════════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════════════════════════════
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

  String? kiemTraMatKhau(String matKhau) {
    if (matKhau.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (matKhau.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  // ═══════════════════════════════════════════════════════════════
  // ĐĂNG NHẬP
  // ═══════════════════════════════════════════════════════════════
  Future<KetQuaDangNhap> dangNhap(String sdt, String matKhau) async {
    final loiSdt = kiemTraSoDienThoai(sdt);
    if (loiSdt != null) {
      return KetQuaDangNhap(thanhCong: false, thongBaoLoi: loiSdt);
    }

    final loiMatKhau = kiemTraMatKhau(matKhau);
    if (loiMatKhau != null) {
      return KetQuaDangNhap(thanhCong: false, thongBaoLoi: loiMatKhau);
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.login)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'sdt': sdt.trim(), 'MatKhau': matKhau}),
      );

      print('🔵 [API] URL: ${ApiConfig.getFullUrl(ApiConfig.login)}');
      print('🔵 [API] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['data']['user'];
        final token = responseData['data']['token'];

        // DEBUG: In ra response từ API
        print('🔵 [API] Response body: ${response.body}');
        print('🔵 [API] User data: $userData');
        print('🔵 [API] VaiTro: ${userData['VaiTro']}');

        // LƯU TOKEN VÀ USER INFO
        await _sessionManager.saveSession(token: token, userInfo: userData);

        userData['token'] = token;
        return KetQuaDangNhap(thanhCong: true, thongTinNguoiDung: userData);
      } else {
        final errorData = jsonDecode(response.body);
        return KetQuaDangNhap(
          thanhCong: false,
          thongBaoLoi: errorData['message'] ?? 'Đăng nhập thất bại',
        );
      }
    } catch (e) {
      print('❌ [API] Lỗi: $e');
      return KetQuaDangNhap(
        thanhCong: false,
        thongBaoLoi: 'Không thể kết nối đến server',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CHECK TOKEN VỚI DATABASE (GỌI API /me)
  // ═══════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> kiemTraToken() async {
    final token = await _sessionManager.getToken();

    if (token == null) {
      print('❌ [TOKEN] Không có token');
      return null;
    }

    try {
      // Gọi API /me để check token với database
      final response = await http.get(
        Uri.parse(ApiConfig.getFullUrl(ApiConfig.me)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('🔵 [TOKEN] Check URL: ${ApiConfig.getFullUrl(ApiConfig.me)}');
      print('🔵 [TOKEN] Check status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ [TOKEN] Token hợp lệ');
        return responseData['data'];
      } else {
        // Token không hợp lệ hoặc hết hạn
        print('❌ [TOKEN] Token không hợp lệ');
        await _sessionManager.clearSession();
        return null;
      }
    } catch (e) {
      print('❌ [TOKEN] Lỗi check token: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ĐĂNG XUẤT
  // ═══════════════════════════════════════════════════════════════
  Future<void> dangXuat() async {
    final token = await _sessionManager.getToken();

    if (token != null) {
      try {
        // Gọi API logout để xóa token trong database
        await http.post(
          Uri.parse(ApiConfig.getFullUrl(ApiConfig.logout)),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      } catch (e) {
        print('❌ [LOGOUT] Lỗi: $e');
      }
    }

    // Xóa token local
    await _sessionManager.clearSession();
    print('🚪 [AUTH] Đã đăng xuất');
  }

  // ═══════════════════════════════════════════════════════════════
  // LẤY THÔNG TIN USER TỪ LOCAL
  // ═══════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> layThongTinNguoiDung() async {
    return await _sessionManager.getUserInfo();
  }
}
