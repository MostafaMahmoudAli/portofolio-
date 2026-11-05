import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../l10n/app_localizations.dart';
import 'theme_reveal.dart';

/// Sun / moon button. The icon spins and scales into the other one.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return IconButton(
      tooltip: isDark ? l10n.themeToLight : l10n.themeToDark,
      onPressed: () {
        void toggle() => AppScope.of(context).theme.toggle(brightness);
        final reveal = ThemeReveal.maybeOf(context);
        if (reveal == null) {
          toggle();
        } else {
          reveal.toggle(context, toggle);
        }
      },
      icon: AnimatedSwitcher(
        duration: Duration(milliseconds: reduceMotion ? 0 : 400),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween(begin: 0.5, end: 1.0).animate(animation),
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
        ),
      ),
    );
  }
}
