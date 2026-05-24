import 'package:flutter/material.dart';
import 'package:phongkhamfy/theme/app_theme.dart';

class NewsDetailView extends StatelessWidget {
  final String tieuDe;
  final String moTa;

  const NewsDetailView({
    super.key,
    required this.tieuDe,
    required this.moTa,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.label),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Tin tức', style: AppText.title3.copyWith(color: AppColors.label)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.article_rounded, color: AppColors.primary, size: 64),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                tieuDe,
                style: AppText.title2.copyWith(color: AppColors.label),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  moTa,
                  style: AppText.body.copyWith(color: AppColors.subLabel),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Chi tiết',
                style: AppText.title3.copyWith(color: AppColors.label),
              ),
              const SizedBox(height: 12),
              Text(
                'Đây là một tin tức quan trọng từ Phòng Khám FY. Vui lòng đọc kỹ thông tin và tuân thủ các hướng dẫn được cung cấp để đảm bảo sức khỏe tốt nhất của bạn.',
                style: AppText.body.copyWith(
                  color: AppColors.subLabel,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
