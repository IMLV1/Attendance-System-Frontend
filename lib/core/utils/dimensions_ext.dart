import 'package:attendance_system/core/utils/responsive.dart';
import 'package:flutter/cupertino.dart';

extension ResponsiveNum on num {
  double r(BuildContext context) {
    final scale = Responsive.scale(context);
    return (this * scale);
  }
}