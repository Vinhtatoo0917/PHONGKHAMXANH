import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingView extends StatelessWidget {
  final String message;
  final bool isOverlay;

  const LoadingView({
    super.key,
    this.message = 'Hệ thống đang xử lý...',
    this.isOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOverlay
          ? Colors.black.withValues(alpha: 0.35)
          : AppColors.bg,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: AppText.headline.copyWith(
                  color: AppColors.label,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Vui lòng chờ trong giây lát...',
                style: AppText.footnote.copyWith(
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
