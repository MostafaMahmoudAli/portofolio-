import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../pages/home_section.dart';
import 'section_title.dart';

/// Stands in for a home section until its real content lands in a later phase.
class SectionPlaceholder extends StatelessWidget {
  const SectionPlaceholder({super.key, required this.section});

  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 600),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 96, 24, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            // Full width, so the column's start edge is the content box's start edge.
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(section.label(l10n)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.sectionComingSoon,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: palette.mutedText),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
