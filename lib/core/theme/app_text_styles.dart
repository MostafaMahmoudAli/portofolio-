import 'package:flutter/material.dart';

/// Text theme per locale: Space Grotesk headings and Inter body for Latin text,
/// IBM Plex Sans Arabic for both in Arabic (the Latin fonts have no Arabic letters).
abstract final class AppTextStyles {
  static const arabicFamily = 'IBMPlexSansArabic';

  static TextTheme textTheme(Locale locale, Color text, Color muted) {
    final arabic = locale.languageCode == 'ar';
    final heading = arabic ? arabicFamily : 'SpaceGrotesk';
    final body = arabic ? arabicFamily : 'Inter';
    // Arabic script needs more line height than Latin headings.
    final headingHeight = arabic ? 1.4 : 1.15;

    TextStyle h(double size) => TextStyle(
          fontFamily: heading,
          fontSize: size,
          fontWeight: FontWeight.w700,
          height: headingHeight,
          color: text,
        );
    TextStyle b(double size, {FontWeight weight = FontWeight.w400, Color? color}) =>
        TextStyle(
          fontFamily: body,
          fontSize: size,
          fontWeight: weight,
          height: 1.5,
          color: color ?? text,
        );

    return TextTheme(
      displayLarge: h(64),
      displayMedium: h(48),
      displaySmall: h(36),
      headlineLarge: h(32),
      headlineMedium: h(28),
      headlineSmall: h(24),
      titleLarge: h(20),
      titleMedium: b(16, weight: FontWeight.w600),
      titleSmall: b(14, weight: FontWeight.w600),
      bodyLarge: b(18),
      bodyMedium: b(16),
      bodySmall: b(14, color: muted),
      labelLarge: b(15, weight: FontWeight.w500),
      labelMedium: b(13, weight: FontWeight.w500),
      labelSmall: b(12, weight: FontWeight.w500, color: muted),
    );
  }
}
