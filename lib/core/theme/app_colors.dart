import 'package:flutter/material.dart';

/// Color tokens from the spec (section 3). Read with `AppPalette.of(context)`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceBorder,
    required this.text,
    required this.mutedText,
    required this.accent,
    required this.accentInk,
    required this.onAccent,
  });

  final Color background;
  final Color surface;
  final Color surfaceBorder;
  final Color text;
  final Color mutedText;

  /// Fill color: buttons, chips, rings. Mint in both themes.
  final Color accent;

  /// Ink color: text, lines, borders, focus rings. Deep mint in light theme so
  /// it clears WCAG AA on the light background; mint in dark theme.
  final Color accentInk;

  final Color onAccent;

  static const dark = AppPalette(
    background: Color(0xFF15191A),
    surface: Color(0x0DFFFFFF), // white 5%
    surfaceBorder: Color(0x1CFFFFFF), // white 11%
    text: Color(0xFFDCE1DD),
    mutedText: Color(0xFF8E9691),
    accent: Color(0xFF34D399),
    accentInk: Color(0xFF34D399),
    onAccent: Color(0xFF15191A),
  );

  static const light = AppPalette(
    background: Color(0xFFF3F4F1),
    surface: Color(0xE0FFFFFF), // white 88%
    surfaceBorder: Color(0x2423272A), // graphite 14%
    text: Color(0xFF23272A),
    mutedText: Color(0xFF5F6763),
    accent: Color(0xFF34D399),
    accentInk: Color(0xFF0B6E4A),
    onAccent: Color(0xFF15191A),
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>()!;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceBorder,
    Color? text,
    Color? mutedText,
    Color? accent,
    Color? accentInk,
    Color? onAccent,
  }) => AppPalette(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceBorder: surfaceBorder ?? this.surfaceBorder,
    text: text ?? this.text,
    mutedText: mutedText ?? this.mutedText,
    accent: accent ?? this.accent,
    accentInk: accentInk ?? this.accentInk,
    onAccent: onAccent ?? this.onAccent,
  );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      text: Color.lerp(text, other.text, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}
