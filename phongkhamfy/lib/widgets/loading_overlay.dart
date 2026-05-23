import 'package:flutter/material.dart';
import 'package:phongkhamfy/widgets/loading_view.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          LoadingView(
            message: message ?? 'Đang xử lý...',
            isOverlay: true,
          ),
      ],
    );
  }
}
