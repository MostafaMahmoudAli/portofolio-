import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/theme/app_colors.dart';

double luminance(Color color) {
  double linear(double channel) => channel <= 0.04045
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * linear(color.r) +
      0.7152 * linear(color.g) +
      0.0722 * linear(color.b);
}

double contrast(Color foreground, Color background) {
  final a = luminance(foreground);
  final b = luminance(background);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

void main() {
  for (final (name, palette) in [
    ('light', AppPalette.light),
    ('dark', AppPalette.dark),
  ]) {
    test('$name text and button contrast meets WCAG', () {
      expect(
        contrast(palette.text, palette.background),
        greaterThanOrEqualTo(7),
      );
      expect(
        contrast(palette.mutedText, palette.background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(palette.onAccent, palette.accent),
        greaterThanOrEqualTo(4.5),
      );
    });
  }
  test('mint is readable on graphite but not suitable as light-theme text', () {
    expect(
      contrast(AppPalette.dark.accent, AppPalette.dark.background),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(AppPalette.light.accent, AppPalette.light.background),
      lessThan(4.5),
    );
  });
}
