import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'language_flip.dart';

/// `EN | ع` button: shows the other language and flips the page to it.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // Plex Arabic has Latin letters too, so one bundled font covers "EN", "ع" and
    // both tooltips (no runtime fallback-font download).
    const family = AppTextStyles.arabicFamily;

    return Tooltip(
      message: l10n.languageToggleTooltip,
      textStyle: TextStyle(
        fontFamily: family,
        color: AppPalette.of(context).background,
        fontSize: 13,
      ),
      child: IconButton(
        style: ButtonStyle(
          side: WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              color:
                  Localizations.localeOf(context).languageCode == 'ar' ||
                      states.contains(WidgetState.focused)
                  ? AppPalette.of(context).accent
                  : Colors.transparent,
            ),
          ),
        ),
        onPressed: () => LanguageFlip.of(context).flip(),
        icon: AnimatedSwitcher(
          duration: Duration(milliseconds: reduceMotion ? 0 : 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: Text(
            l10n.languageToggleLabel,
            key: ValueKey(l10n.languageToggleLabel),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontFamily: family,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
