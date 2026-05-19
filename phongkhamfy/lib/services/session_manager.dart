// ═══════════════════════════════════════════════════════════════
// FILE: session_manager.dart
// MÔ TẢ: Lưu và đọc token đăng nhập - ĐỠN GIẢN
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Singleton
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  // Keys
  static const String _keyToken = 'access_token';
  static const String _keyUserInfo = 'user_info';

  // ═══════════════════════════════════════════════════════════════
  // LƯU TOKEN VÀ THÔNG TIN USER
  // ═══════════════════════════════════════════════════════════════
  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> userInfo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserInfo, jsonEncode(userInfo));
    print('✅ [SESSION] Đã lưu token và user info');
  }

  // ═══════════════════════════════════════════════════════════════
  // LẤY TOKEN
  // ═══════════════════════════════════════════════════════════════
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Static method để dễ sử dụng
  static Future<String?> getTokenStatic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // ═══════════════════════════════════════════════════════════════
  // LẤY THÔNG TIN USER
  // ═══════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString(_keyUserInfo);

    if (userInfoString != null) {
      return jsonDecode(userInfoString);
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════
  // KIỂM TRA CÓ TOKEN KHÔNG
  // ═══════════════════════════════════════════════════════════════
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════════════
  // XÓA TOKEN (ĐĂNG XUẤT)
  // ═══════════════════════════════════════════════════════════════
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserInfo);
    print('🚪 [SESSION] Đã xóa token');
  }
}
