import 'package:flutter/cupertino.dart';

class Responsive {
  // Breakpoints (Material-ish)
  static const double mobileMax = 600;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMax;

  // Scale factor for fonts & spacing
  static double scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width / 375);
  }

  static double scaleFromWidth({
    required double currentWidth,
    double baseWidth = 375, // design width
  }) {
    return currentWidth / baseWidth;
  }

  // Content max width (important for web)
  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 420;
    return double.infinity;
  }
}