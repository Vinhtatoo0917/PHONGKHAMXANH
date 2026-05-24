import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NutCapNhatMatKhau extends StatelessWidget {
  final bool dangTaiDuLieu;
  final VoidCallback khiNhan;

  const NutCapNhatMatKhau({
    super.key,
    required this.dangTaiDuLieu,
    required this.khiNhan,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: 'Cập nhật mật khẩu',
      onPressed: dangTaiDuLieu ? null : khiNhan,
      isLoading: dangTaiDuLieu,
      icon: Icons.lock_reset_rounded,
    );
  }
}
