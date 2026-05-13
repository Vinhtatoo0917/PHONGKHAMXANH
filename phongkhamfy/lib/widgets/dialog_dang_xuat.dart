import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// WIDGET: DialogDangXuat - Dialog xác nhận đăng xuất
// ═══════════════════════════════════════════════════════════════
class DialogDangXuat {
  DialogDangXuat._();

  static Future<void> hienThi({
    required BuildContext context,
    required VoidCallback onXacNhan,
    required Color mauChinh,
    required Color mauError,
    required Color mauBeMat,
    required Color mauChuChinh,
    required Color mauChuPhu,
    required Color mauVien,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [mauBeMat, mauBeMat.withValues(alpha: 0.95)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: mauError.withValues(alpha: 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Transform.rotate(
                        angle: (1 - value) * 0.5,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          mauError.withValues(alpha: 0.15),
                          mauError.withValues(alpha: 0.08),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: mauError.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: mauError,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: mauChuChinh,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Bạn có chắc chắn muốn đăng xuất?\nDữ liệu chưa lưu sẽ bị mất.',
                  style: TextStyle(fontSize: 14, color: mauChuPhu, height: 1.6),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: mauVien),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: mauChuChinh,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onXacNhan();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mauError,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Đăng xuất'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
