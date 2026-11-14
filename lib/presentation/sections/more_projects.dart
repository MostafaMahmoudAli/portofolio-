import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/models/project_link.dart';
import '../../core/models/project.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/open_link.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/brand_icon.dart';
import '../widgets/glass_card.dart';
import '../widgets/project_placeholder.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_title.dart';
import '../widgets/tech_chip.dart';

/// The "More projects" section: a grid of equal-height cards for the
/// non-featured projects. The first four are shown; the rest sit behind a
/// "Show all" button that expands the grid in place.
class MoreProjectsSection extends StatefulWidget {
  const MoreProjectsSection({super.key});

  @override
  State<MoreProjectsSection> createState() => _MoreProjectsSectionState();
}

class _MoreProjectsSectionState extends State<MoreProjectsSection> {
  /// How many cards are shown before the grid is expanded.
  static const _collapsedCount = 4;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final content = AppScope.of(context).content;
    final l10n = AppLocalizations.of(context);
    final screen = ScreenSize.of(context);

    final more = List<Project>.of(content.projects.where((p) => !p.featured))
      ..sort((a, b) => a.order.compareTo(b.order));
    final shown = _expanded
        ? more
        : more.take(_collapsedCount).toList(growable: false);

    // Four across on a desktop, two on a tablet, one on a phone.
    final columns = switch (screen) {
      ScreenSize.phone => 1,
      ScreenSize.tablet => 2,
      ScreenSize.desktop => 4,
    };

    final rows = <List<Project>>[
      for (var i = 0; i < shown.length; i += columns)
        shown.sublist(i, (i + columns).clamp(0, shown.length)),
    ];

    return RevealOnScroll(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    l10n.moreProjects,
                    eyebrow: l10n.eyebrowProjects,
                  ),
                  const SizedBox(height: 16),
                  for (final row in rows)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 16),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < row.length; i++) ...[
                              if (i > 0) const SizedBox(width: 16),
                              // The last row shares its width between fewer
                              // cards, so the grid has no hole.
                              Expanded(child: _MoreCard(project: row[i])),
                            ],
                          ],
                        ),
                      ),
                    ),
                  if (!_expanded && more.length > _collapsedCount)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _expanded = true),
                        icon: const Icon(Icons.expand_more_rounded),
                        label: Text(l10n.showAll),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _MoreOnGitHubButton(content.profile.github, l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoreCard extends StatelessWidget {
  const _MoreCard({required this.project});

  final Project project;

  /// The height of the cover thumbnail area at the top of the card.
  static const _coverHeight = 88.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final textTheme = Theme.of(context).textTheme;
    final palette = AppPalette.of(context);
    final title = project.title.of(locale);
    final summary = project.summary.of(locale);
    final githubLink = project.links
        .where((link) => link.type == ProjectLinkType.github)
        .firstOrNull;

    return GlassCard(
      padding: const EdgeInsetsDirectional.all(16),
      borderColor: project.accentColor.withValues(alpha: 0.35),
      hoverBorderColor: project.accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The cover area renders the placeholder, tinted with the project's
          // own accent.
          SizedBox(
            height: _coverHeight,
            width: double.infinity,
            child: ProjectPlaceholder(accent: project.accentColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            summary,
            style: textTheme.bodySmall?.copyWith(color: palette.mutedText),
            // Three lines, so a short summary is not cut off with an ellipsis.
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final tech in project.tech) TechChip(label: tech)],
          ),
          const SizedBox(height: 12),
          // The link sits at the bottom of every card, whatever the card height.
          const Spacer(),
          if (githubLink != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => openLink(githubLink.url),
                icon: const BrandIcon(BrandMark.github, size: 18),
                label: Text(l10n.viewOnGitHub),
              ),
            ),
        ],
      ),
    );
  }
}

class _MoreOnGitHubButton extends StatelessWidget {
  const _MoreOnGitHubButton(this.githubUrl, this.l10n);

  final String githubUrl;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FilledButton.icon(
        onPressed: () => openLink(githubUrl),
        icon: const BrandIcon(BrandMark.github, size: 18),
        label: Text(l10n.moreOnGithub),
      ),
    );
  }
}
