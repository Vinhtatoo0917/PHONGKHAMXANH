import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// FILE: constants.dart
// MÔ TẢ: Tất cả hằng số của app (màu, size, text) trong 1 file
// ═══════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════
// MÀU SẮC
// ═══════════════════════════════════════════════════════════════
class AppColors {
  AppColors._();

  // Màu chính
  static const Color primary = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF0A2D6B);

  // Màu nền
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);

  // Màu chữ
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Màu trạng thái
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Màu khác
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
}

// ═══════════════════════════════════════════════════════════════
// KÍCH THƯỚC
// ═══════════════════════════════════════════════════════════════
class AppSizes {
  AppSizes._();

  // Padding
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;

  // Icon
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;

  // Button
  static const double buttonHeight = 52.0;
}

// ═══════════════════════════════════════════════════════════════
// TEXT/STRING
// ═══════════════════════════════════════════════════════════════
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Phòng Khám FY';

  // Common
  static const String cancel = 'Hủy';
  static const String confirm = 'Xác nhận';
  static const String save = 'Lưu';
  static const String delete = 'Xóa';

  // Auth
  static const String login = 'Đăng nhập';
  static const String register = 'Đăng ký';
  static const String logout = 'Đăng xuất';
  static const String email = 'Email';
  static const String password = 'Mật khẩu';
  static const String forgotPassword = 'Quên mật khẩu?';

  // Validation
  static const String fieldRequired = 'Trường này không được để trống';
  static const String emailInvalid = 'Email không hợp lệ';
  static const String passwordTooShort = 'Mật khẩu phải có ít nhất 6 ký tự';
}
