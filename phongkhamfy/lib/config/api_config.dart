// ═══════════════════════════════════════════════════════════════
// FILE: api_config.dart
// MÔ TẢ: Cấu hình API URL - Tự động phát hiện platform
// ═══════════════════════════════════════════════════════════════

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // ─────────────────────────────────────────────────────────────
  // TỰ ĐỘNG CHỌN URL DựA TRÊN PLATFORM
  // ─────────────────────────────────────────────────────────────
  static String get baseUrl {
    if (kIsWeb) {
      // Web (Chrome, Firefox, Safari...)
      return 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      // Android Emulator hoặc Device
      // 10.0.2.2 là địa chỉ đặc biệt của Android Emulator trỏ đến localhost của máy host
      return 'http://10.0.2.2:8000';

      // Nếu dùng Android Device thật, uncomment dòng dưới và thay IP của bạn:
      // return 'http://192.168.1.100:8000';
    } else if (Platform.isIOS) {
      // iOS Simulator
      return 'http://127.0.0.1:8000';
    } else {
      // Desktop (Windows, macOS, Linux)
      return 'http://127.0.0.1:8000';
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ENDPOINTS
  // ─────────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String me = '/me';

  // ─────────────────────────────────────────────────────────────
  // HELPER
  // ─────────────────────────────────────────────────────────────
  static String getFullUrl(String endpoint) {
    final url = '$baseUrl$endpoint';
    print('🌐 [API CONFIG] Platform: ${_getPlatformName()}');
    print('🌐 [API CONFIG] Base URL: $baseUrl');
    print('🌐 [API CONFIG] Full URL: $url');
    return url;
  }

  static String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
