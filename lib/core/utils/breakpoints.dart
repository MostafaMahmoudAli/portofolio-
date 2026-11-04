import 'package:flutter/widgets.dart';

/// Spec breakpoints: phone < 600, tablet 600–1024, desktop > 1024.
enum ScreenSize {
  phone,
  tablet,
  desktop;

  static ScreenSize fromWidth(double width) {
    if (width < 600) return phone;
    if (width <= 1024) return tablet;
    return desktop;
  }

  static ScreenSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);
}
