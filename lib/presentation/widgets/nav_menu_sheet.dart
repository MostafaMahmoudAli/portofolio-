import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/download_file.dart';
import '../../l10n/app_localizations.dart';
import '../pages/home_section.dart';
import 'language_toggle.dart';
import 'theme_toggle.dart';

/// Opens the phone and tablet menu: section links, then the language, theme and resume controls.
Future<void> showNavMenuSheet(
  BuildContext context, {
  required ValueChanged<HomeSection> onSectionTap,
  HomeSection? activeSection,
}) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) =>
        NavMenuSheet(onSectionTap: onSectionTap, activeSection: activeSection),
  );
}

class NavMenuSheet extends StatelessWidget {
  const NavMenuSheet({
    super.key,
    required this.onSectionTap,
    this.activeSection,
  });

  final ValueChanged<HomeSection> onSectionTap;
  final HomeSection? activeSection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: l10n.closeMenu,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            for (final s in HomeSection.values)
              ListTile(
                selected: activeSection == s,
                selectedColor: AppPalette.of(context).accentInk,
                trailing: activeSection == s
                    ? Icon(
                        Icons.check_rounded,
                        color: AppPalette.of(context).accentInk,
                      )
                    : null,
                title: Text(s.label(l10n), style: titleStyle),
                onTap: () {
                  Navigator.pop(context);
                  onSectionTap(s);
                },
              ),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LanguageToggle(),
                    SizedBox(width: 8),
                    ThemeToggle(),
                  ],
                ),
                OutlinedButton(
                  onPressed: () => downloadFile(
                    AppScope.of(context).content.profile.resumePdf,
                    resumeFileName,
                  ),
                  child: Text(l10n.resume),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
