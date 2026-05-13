import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// WIDGET: LoadingDangXuat - Loading khi đăng xuất
// ═══════════════════════════════════════════════════════════════
class LoadingDangXuat {
  LoadingDangXuat._();

  static Future<void> hienThi({
    required BuildContext context,
    required Color mauChinh,
    required Color mauBeMat,
    required Color mauChuChinh,
    required Color mauChuPhu,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return Center(
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 400),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [mauBeMat, mauBeMat.withValues(alpha: 0.95)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: mauChinh.withValues(alpha: 0.1),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(mauChinh),
                          strokeWidth: 3,
                        ),
                      ),
                      Icon(Icons.logout_rounded, color: mauChinh, size: 24),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Đang đăng xuất...',
                    style: TextStyle(
                      color: mauChuChinh,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng đợi trong giây lát',
                    style: TextStyle(color: mauChuPhu, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
