import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingDangXuat {
  LoadingDangXuat._();

  static Future<void> hienThi({
    required BuildContext context,
    // Legacy params kept for backward compat
    Color? mauChinh,
    Color? mauBeMat,
    Color? mauChuChinh,
    Color? mauChuPhu,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          margin: const EdgeInsets.symmetric(horizontal: 48),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.danger,
                  backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Đang đăng xuất...',
                style: AppText.headline.copyWith(decoration: TextDecoration.none),
              ),
              const SizedBox(height: 6),
              Text(
                'Vui lòng đợi trong giây lát',
                style: AppText.footnote.copyWith(decoration: TextDecoration.none),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
