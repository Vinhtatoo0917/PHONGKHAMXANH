import 'package:flutter/material.dart';

/// Helper class để xác định giao diện phù hợp dựa trên kích thước màn hình
class ResponsiveHelper {
  /// Kiểm tra xem có phải là giao diện desktop không
  /// Desktop: width >= 1200px
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// Kiểm tra xem có phải là giao diện tablet không
  /// Tablet: 600px <= width < 1200px
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  /// Kiểm tra xem có phải là giao diện mobile không
  /// Mobile: width < 600px
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Lấy kích thước màn hình
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Lấy chiều rộng màn hình
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Lấy chiều cao màn hình
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Lấy padding phù hợp dựa trên kích thước màn hình
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(24);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(12);
    }
  }

  /// Lấy font size phù hợp dựa trên kích thước màn hình
  static double getResponsiveFontSize(
    BuildContext context, {
    double mobileSize = 14,
    double tabletSize = 16,
    double desktopSize = 18,
  }) {
    if (isDesktop(context)) {
      return desktopSize;
    } else if (isTablet(context)) {
      return tabletSize;
    } else {
      return mobileSize;
    }
  }
}
