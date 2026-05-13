import 'constants.dart';

// ═══════════════════════════════════════════════════════════════
// FILE: validators.dart
// MÔ TẢ: Các hàm validate dùng chung
// ═══════════════════════════════════════════════════════════════

class Validators {
  Validators._();

  // Validate email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  // Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  // Validate required
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    return null;
  }
}
