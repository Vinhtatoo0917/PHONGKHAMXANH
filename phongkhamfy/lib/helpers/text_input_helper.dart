// ═══════════════════════════════════════════════════════════════
// FILE: text_input_helper.dart
// MÔ TẢ: Helper functions để xử lý nhập liệu tiếng Việt
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tạo TextField hỗ trợ nhập tiếng Việt
class TextInputHelper {
  /// Tạo TextField cơ bản với hỗ trợ tiếng Việt
  static Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    Color? iconColor,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    int maxLines = 1,
    bool obscureText = false,
    VoidCallback? onEditingComplete,
  }) {
    return TextField(
      controller: controller,
      enableInteractiveSelection: true,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onEditingComplete: onEditingComplete,
      // Cho phép tất cả ký tự Unicode (bao gồm tiếng Việt)
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\u0000-\uFFFF]')),
      ],
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: iconColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: (iconColor ?? Colors.grey).withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: iconColor ?? Colors.grey, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  /// Tạo TextField cho số điện thoại
  static Widget buildPhoneTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    Color? iconColor,
  }) {
    return TextField(
      controller: controller,
      enableInteractiveSelection: true,
      maxLines: 1,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
      ],
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: iconColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: (iconColor ?? Colors.grey).withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: iconColor ?? Colors.grey, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  /// Tạo TextField cho email
  static Widget buildEmailTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    Color? iconColor,
  }) {
    return TextField(
      controller: controller,
      enableInteractiveSelection: true,
      maxLines: 1,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: iconColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: (iconColor ?? Colors.grey).withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: iconColor ?? Colors.grey, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  /// Tạo TextField cho số (chỉ cho phép chữ số)
  static Widget buildNumberTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    Color? iconColor,
  }) {
    return TextField(
      controller: controller,
      enableInteractiveSelection: true,
      maxLines: 1,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: iconColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: (iconColor ?? Colors.grey).withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: iconColor ?? Colors.grey, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
