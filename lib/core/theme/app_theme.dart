import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData build(Brightness brightness, Locale locale) {
    final palette = brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.accentStart,
      brightness: brightness,
    ).copyWith(
      primary: palette.accentStart,
      secondary: palette.accentEnd,
      tertiary: palette.highlight,
      surface: palette.background,
      onSurface: palette.text,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      textTheme: AppTextStyles.textTheme(locale, palette.text, palette.mutedText),
      iconTheme: IconThemeData(color: palette.text),
      extensions: [palette],
    );
  }
}
