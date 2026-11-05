import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ThemeRevealPainter extends CustomPainter {
  ThemeRevealPainter(this.image, this.center, this.progress);

  final ui.Image image;
  final Offset center;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final radius =
        math.sqrt(
          math.pow(math.max(center.dx, size.width - center.dx), 2) +
              math.pow(math.max(center.dy, size.height - center.dy), 2),
        ) *
        Curves.easeInOut.transform(progress);
    final mask = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.save();
    canvas.clipPath(mask);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & size,
      Paint(),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(ThemeRevealPainter oldDelegate) =>
      image != oldDelegate.image ||
      center != oldDelegate.center ||
      progress != oldDelegate.progress;
}
