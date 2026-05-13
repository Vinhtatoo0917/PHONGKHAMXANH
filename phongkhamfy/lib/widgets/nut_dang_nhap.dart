import 'package:flutter/material.dart';

class NutDangNhap extends StatelessWidget {
  final bool dangTaiDuLieu;
  final VoidCallback khiNhan;

  const NutDangNhap({
    super.key,
    required this.dangTaiDuLieu,
    required this.khiNhan,
  });

  static const Color _mauChinh = Color(0xFF3DAA70);
  static const Color _mauChinhNhat = Color(0xFF6DC896);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: dangTaiDuLieu ? null : khiNhan,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: _mauChinh,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _mauChinhNhat,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: _mauChinh.withValues(alpha: 0.4),
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) return 0;
                return 6;
              }),
            ),
        child: dangTaiDuLieu
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Đăng Nhập',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
