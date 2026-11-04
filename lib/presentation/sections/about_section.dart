import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_card.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_title.dart';

/// Short summary plus three highlight tiles on glass cards.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).content.profile;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final phone = ScreenSize.of(context) == ScreenSize.phone;

    final tiles = [
      _HighlightTile(
        icon: Icons.layers_rounded,
        title: l10n.highlightArchitectureTitle,
        body: l10n.highlightArchitectureBody,
      ),
      _HighlightTile(
        icon: Icons.rocket_launch_rounded,
        title: l10n.highlightReleasesTitle,
        body: l10n.highlightReleasesBody,
      ),
      _HighlightTile(
        icon: Icons.movie_filter_rounded,
        title: l10n.highlightMediaTitle,
        body: l10n.highlightMediaBody,
      ),
    ];

    return RevealOnScroll(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 96, 24, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(l10n.navAbout),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Text(
                      profile.summary.of(locale),
                      style: textTheme.bodyLarge?.copyWith(
                        color: palette.mutedText,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (phone)
                    Column(
                      children: [
                        for (final (index, tile) in tiles.indexed) ...[
                          if (index > 0) const SizedBox(height: 16),
                          tile,
                        ],
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final (index, tile) in tiles.indexed) ...[
                          if (index > 0) const SizedBox(width: 16),
                          Expanded(child: tile),
                        ],
                      ],
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

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: palette.accentEnd, size: 28),
          const SizedBox(height: 16),
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            body,
            style: textTheme.bodyMedium?.copyWith(color: palette.mutedText),
          ),
        ],
      ),
    );
  }
}
