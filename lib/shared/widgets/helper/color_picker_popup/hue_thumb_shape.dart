import 'package:flutter/material.dart';

class HueThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(24, 24);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow
      }) {
    final canvas = context.canvas;

    canvas.drawCircle(center, 17, Paint()..color = Colors.grey ..style = PaintingStyle.stroke ..strokeWidth = 2);
    canvas.drawCircle(center, 16, Paint()..color = sliderTheme.thumbColor ?? Colors.white);
  }
}