import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NutDangKy extends StatelessWidget {
  final bool dangTaiDuLieu;
  final VoidCallback khiNhan;

  const NutDangKy({
    super.key,
    required this.dangTaiDuLieu,
    required this.khiNhan,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: 'Đăng Ký',
      onPressed: dangTaiDuLieu ? null : khiNhan,
      isLoading: dangTaiDuLieu,
    );
  }
}
