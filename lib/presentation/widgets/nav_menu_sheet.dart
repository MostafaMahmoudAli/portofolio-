import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/utils/download_file.dart';
import '../../l10n/app_localizations.dart';
import '../pages/home_section.dart';
import 'language_toggle.dart';
import 'theme_toggle.dart';

/// Opens the phone and tablet menu: section links, then the language, theme and resume controls.
Future<void> showNavMenuSheet(
  BuildContext context, {
  required ValueChanged<HomeSection> onSectionTap,
}) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => NavMenuSheet(onSectionTap: onSectionTap),
  );
}

class NavMenuSheet extends StatelessWidget {
  const NavMenuSheet({super.key, required this.onSectionTap});

  final ValueChanged<HomeSection> onSectionTap;

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
                  children: [LanguageToggle(), ThemeToggle()],
                ),
                FilledButton(
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
