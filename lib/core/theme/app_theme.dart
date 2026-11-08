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
          seedColor: palette.accent,
          brightness: brightness,
        ).copyWith(
          primary: palette.accent,
          onPrimary: palette.onAccent,
          secondary: palette.accent,
          onSecondary: palette.onAccent,
          tertiary: palette.accent,
          onTertiary: palette.onAccent,
          surface: palette.background,
          onSurface: palette.text,
          surfaceTint: Colors.transparent,
          outline: palette.surfaceBorder,
        );

    final outline = WidgetStateProperty.resolveWith<BorderSide>(
      (states) => BorderSide(
        color:
            states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)
            ? palette.accent
            : palette.surfaceBorder,
      ),
    );
    final secondaryStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      foregroundColor: WidgetStatePropertyAll(palette.text),
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      overlayColor: WidgetStatePropertyAll(
        palette.text.withValues(alpha: 0.04),
      ),
      side: outline,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      // The shared page color stays behind route transitions.
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: AppTextStyles.textTheme(
        locale,
        palette.text,
        palette.mutedText,
      ),
      iconTheme: IconThemeData(color: palette.text),
      focusColor: palette.accent.withValues(alpha: 0.15),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: palette.text,
          borderRadius: const BorderRadiusDirectional.all(Radius.circular(4)),
        ),
        textStyle: TextStyle(color: palette.background),
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      iconButtonTheme: IconButtonThemeData(
        style: secondaryStyle.copyWith(
          side: WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              color: states.contains(WidgetState.focused)
                  ? palette.accent
                  : Colors.transparent,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: secondaryStyle),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          backgroundColor: WidgetStatePropertyAll(palette.accent),
          foregroundColor: WidgetStatePropertyAll(palette.onAccent),
          side: outline,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryStyle),
      // From the theme, not the call site, so an open sheet follows a theme switch.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.background,
        modalBackgroundColor: palette.background,
      ),
      extensions: [palette],
    );
  }
}
