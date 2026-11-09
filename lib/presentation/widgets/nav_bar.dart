import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/download_file.dart';
import '../../l10n/app_localizations.dart';
import '../pages/home_section.dart';
import 'language_toggle.dart';
import 'nav_menu_sheet.dart';
import 'theme_toggle.dart';

/// Sticky glass bar. Desktop shows the links inline; phone and tablet use a menu sheet.
class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.onSectionTap,
    required this.onLogoTap,
    this.activeSection,
    this.scrollProgress = 0,
  });

  final ValueChanged<HomeSection> onSectionTap;
  final VoidCallback onLogoTap;
  final HomeSection? activeSection;
  final double scrollProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final desktop = ScreenSize.of(context) == ScreenSize.desktop;

    return Stack(
      children: [
        SizedBox(
          height: 72,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.surface,
                  border: Border(
                    bottom: BorderSide(color: palette.surfaceBorder),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: desktop ? 24 : 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: onLogoTap,
                            child: Text('MM', style: textTheme.headlineSmall),
                          ),
                          const Spacer(),
                          if (desktop) ...[
                            for (final s in HomeSection.values)
                              TextButton(
                                onPressed: () => onSectionTap(s),
                                child: Semantics(
                                  selected: activeSection == s,
                                  child: Text(
                                    s.label(l10n),
                                    style: textTheme.labelLarge?.copyWith(
                                      color: activeSection == s
                                          ? palette.accentInk
                                          : palette.text,
                                      decoration: activeSection == s
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                      decorationColor: palette.accentInk,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            const LanguageToggle(),
                            const ThemeToggle(),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => downloadFile(
                                AppScope.of(context).content.profile.resumePdf,
                                resumeFileName,
                              ),
                              child: Text(l10n.resume),
                            ),
                          ] else
                            IconButton(
                              icon: const Icon(Icons.menu_rounded),
                              tooltip: l10n.menu,
                              onPressed: () => showNavMenuSheet(
                                context,
                                onSectionTap: onSectionTap,
                                activeSection: activeSection,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 0,
          child: ExcludeSemantics(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: scrollProgress.clamp(0.0, 1.0),
                child: ColoredBox(
                  color: palette.accentInk,
                  child: const SizedBox(height: 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
