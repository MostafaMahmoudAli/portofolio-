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
    required this.onAccent,
  });

  final Color background;
  final Color surface;
  final Color surfaceBorder;
  final Color text;
  final Color mutedText;
  final Color accent;
  final Color onAccent;

  static const dark = AppPalette(
    background: Color(0xFF15191A),
    surface: Color(0x0AFFFFFF), // white 4%
    surfaceBorder: Color(0x14FFFFFF), // white 8%
    text: Color(0xFFDCE1DD),
    mutedText: Color(0xFF8E9691),
    accent: Color(0xFF34D399),
    onAccent: Color(0xFF15191A),
  );

  static const light = AppPalette(
    background: Color(0xFFF3F4F1),
    surface: Color(0xB3FFFFFF), // white 70%
    surfaceBorder: Color(0x1423272A), // graphite 8%
    text: Color(0xFF23272A),
    mutedText: Color(0xFF5F6763),
    accent: Color(0xFF34D399),
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
    Color? onAccent,
  }) => AppPalette(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceBorder: surfaceBorder ?? this.surfaceBorder,
    text: text ?? this.text,
    mutedText: mutedText ?? this.mutedText,
    accent: accent ?? this.accent,
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
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}
