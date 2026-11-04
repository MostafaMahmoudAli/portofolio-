import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../l10n/app_localizations.dart';

/// Sun / moon button. The icon spins and scales into the other one.
// shortcut: no circular theme reveal yet (spec section 3), add in Phase 7 polish.
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
      onPressed: () => AppScope.of(context).theme.toggle(brightness),
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
