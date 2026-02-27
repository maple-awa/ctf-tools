import 'package:flutter/widgets.dart';

/// 全局响应式断点与辅助方法。
class Responsive {
  static const double mobileBreakpoint = 900;

  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < mobileBreakpoint;
  }

  static bool isMobileWidth(double width) {
    return width < mobileBreakpoint;
  }
}
