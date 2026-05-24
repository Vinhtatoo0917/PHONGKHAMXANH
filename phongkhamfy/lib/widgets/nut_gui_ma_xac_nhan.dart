import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NutGuiMaXacNhan extends StatelessWidget {
  final bool dangTaiDuLieu;
  final VoidCallback khiNhan;

  const NutGuiMaXacNhan({
    super.key,
    required this.dangTaiDuLieu,
    required this.khiNhan,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: 'Gửi mã xác nhận',
      onPressed: dangTaiDuLieu ? null : khiNhan,
      isLoading: dangTaiDuLieu,
      icon: Icons.send_rounded,
    );
  }
}
