import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String message;
  /// When true, renders as a semi-transparent overlay (for Get.dialog).
  /// When false (default), renders as an opaque full-page loader.
  final bool isOverlay;

  const LoadingView({
    super.key,
    this.message = 'Hệ thống đang xử lý...',
    this.isOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isOverlay
        ? Colors.black.withValues(alpha: 0.4)
        : const Color(0xFFF0FAF5);

    return Material(
      color: Colors.transparent,
      child: Container(
        color: bgColor,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isOverlay ? 0.95 : 1.0),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3DAA70).withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSpinner(),
                const SizedBox(height: 24),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A3D2E),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Vui lòng chờ trong giây lát...',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5A8A70),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpinner() {
    return Stack(
      alignment: Alignment.center,
      children: [
        const SizedBox(
          width: 72,
          height: 72,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3DAA70)),
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF3DAA70).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_hospital_rounded,
            size: 28,
            color: Color(0xFF3DAA70),
          ),
        ),
      ],
    );
  }
}
