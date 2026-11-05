import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/theme/app_colors.dart';

void main() {
  test('lerp moves from dark to light background', () {
    expect(
      AppPalette.dark.lerp(AppPalette.light, 0).background,
      AppPalette.dark.background,
    );
    expect(
      AppPalette.dark.lerp(AppPalette.light, 1).background,
      AppPalette.light.background,
    );
  });

  test('copyWith replaces only the given token', () {
    const color = Color(0xFF123456);
    final copy = AppPalette.dark.copyWith(text: color);
    expect(copy.text, color);
    expect(copy.background, AppPalette.dark.background);
    expect(copy.accent, const Color(0xFF34D399));
    expect(copy.onAccent, const Color(0xFF15191A));
  });

  test('mint and its foreground stay identical across theme interpolation', () {
    final middle = AppPalette.dark.lerp(AppPalette.light, 0.5);
    expect(middle.accent, AppPalette.light.accent);
    expect(middle.onAccent, AppPalette.light.onAccent);
  });
}
