import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData build(Brightness brightness, Locale locale) {
    final palette = brightness == Brightness.dark
        ? AppPalette.dark
        : AppPalette.light;
    final scheme =
        ColorScheme.fromSeed(
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
      // The aurora in MaterialApp.builder paints the background; pages are
      // transparent so it shows through.
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: AppTextStyles.textTheme(
        locale,
        palette.text,
        palette.mutedText,
      ),
      iconTheme: IconThemeData(color: palette.text),
      // From the theme, not the call site, so an open sheet follows a theme switch.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.background,
        modalBackgroundColor: palette.background,
      ),
      extensions: [palette],
    );
  }
}
