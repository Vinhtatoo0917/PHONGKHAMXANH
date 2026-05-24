import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LogoPhongKham extends StatelessWidget {
  final double size;
  const LogoPhongKham({super.key, this.size = 88});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cross vertical bar
              Container(
                width: size * 0.12,
                height: size * 0.44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * 0.06),
                ),
              ),
              // Cross horizontal bar
              Container(
                width: size * 0.44,
                height: size * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * 0.06),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'PHÒNG KHÁM FY',
          style: AppText.title3.copyWith(
            color: AppColors.primary,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Chăm sóc sức khỏe toàn diện',
          style: AppText.footnote.copyWith(color: AppColors.subLabel),
        ),
      ],
    );
  }
}
