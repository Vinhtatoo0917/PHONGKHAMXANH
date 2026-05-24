import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NutDangNhap extends StatelessWidget {
  final bool dangTaiDuLieu;
  final VoidCallback khiNhan;

  const NutDangNhap({
    super.key,
    required this.dangTaiDuLieu,
    required this.khiNhan,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: 'Đăng Nhập',
      onPressed: dangTaiDuLieu ? null : khiNhan,
      isLoading: dangTaiDuLieu,
    );
  }
}
