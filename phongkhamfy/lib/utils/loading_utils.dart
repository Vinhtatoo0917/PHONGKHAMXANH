import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/loading_view.dart';

/// Loading utility dùng OverlayEntry (không phải Get.dialog) để tránh việc
/// dialog bị "treo" khi được mở từ trong bottom sheet hoặc khi route stack
/// thay đổi sau khi gọi hideLoading. OverlayEntry nằm ngoài route stack nên
/// không bị ảnh hưởng bởi pop/push của Navigator.
class LoadingUtils {
  static OverlayEntry? _entry;

  static void showLoading({String message = 'Hệ thống đang xử lý...'}) {
    if (_entry != null) return;

    final ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) return;

    final overlay = Overlay.maybeOf(ctx, rootOverlay: true);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (_) => AbsorbPointer(
        absorbing: true,
        child: LoadingView(message: message),
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  static void hideLoading() {
    final entry = _entry;
    _entry = null;
    if (entry == null) return;
    if (entry.mounted) {
      entry.remove();
    }
  }
}
