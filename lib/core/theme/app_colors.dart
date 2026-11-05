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
    required this.accentStart,
    required this.accentEnd,
    required this.highlight,
  });

  final Color background;
  final Color surface;
  final Color surfaceBorder;
  final Color text;
  final Color mutedText;
  final Color accentStart;
  final Color accentEnd;
  final Color highlight;

  static const dark = AppPalette(
    background: Color(0xFF0A0A12),
    surface: Color(0x0FFFFFFF), // white 6%
    surfaceBorder: Color(0x1AFFFFFF), // white 10%
    text: Color(0xFFEDEDF5),
    mutedText: Color(0xFF9A9AB0),
    accentStart: Color(0xFF7C5CFF),
    accentEnd: Color(0xFF22D3EE),
    highlight: Color(0xFFFF5C8A),
  );

  static const light = AppPalette(
    background: Color(0xFFF6F6FB),
    surface: Color(0xB3FFFFFF), // white 70%
    surfaceBorder: Color(0x0F000000), // black 6%
    text: Color(0xFF14141C),
    mutedText: Color(0xFF5C5C70),
    accentStart: Color(0xFF6D4BFF),
    accentEnd: Color(0xFF0EA5C6),
    highlight: Color(0xFFE8457A),
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>()!;

  LinearGradient get accentGradient =>
      LinearGradient(colors: [accentStart, accentEnd]);

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceBorder,
    Color? text,
    Color? mutedText,
    Color? accentStart,
    Color? accentEnd,
    Color? highlight,
  }) => AppPalette(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceBorder: surfaceBorder ?? this.surfaceBorder,
    text: text ?? this.text,
    mutedText: mutedText ?? this.mutedText,
    accentStart: accentStart ?? this.accentStart,
    accentEnd: accentEnd ?? this.accentEnd,
    highlight: highlight ?? this.highlight,
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
      accentStart: Color.lerp(accentStart, other.accentStart, t)!,
      accentEnd: Color.lerp(accentEnd, other.accentEnd, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
    );
  }
}
