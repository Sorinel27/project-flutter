import 'package:flutter/widgets.dart';

class Breakpoints {
  static const double phone = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

int responsiveGridColumns(double width) {
  if (width >= Breakpoints.desktop) return 5;
  if (width >= Breakpoints.tablet) return 4;
  if (width >= Breakpoints.phone) return 3;
  return 2;
}

/// Keeps content readable on large screens.
Widget maxWidthContainer({
  required Widget child,
  double maxWidth = 1100,
}) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
