import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/models/project_link.dart';
import '../../core/models/project.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/open_link.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_card.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_title.dart';
import '../widgets/tech_chip.dart';

/// The "More projects" section: a grid of small glass cards for the
/// non-featured projects, plus a "More on GitHub" button under the grid.
class MoreProjectsSection extends StatelessWidget {
  const MoreProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final content = AppScope.of(context).content;
    final l10n = AppLocalizations.of(context);
    final screen = ScreenSize.of(context);

    final more = List<Project>.of(content.projects.where((p) => !p.featured))
      ..sort((a, b) => a.order.compareTo(b.order));

    final cardWidth = switch (screen) {
      ScreenSize.phone => 300.0,
      ScreenSize.tablet => 300.0,
      ScreenSize.desktop => 250.0,
    };

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
                  SectionTitle(l10n.moreProjects),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final project in more)
                        SizedBox(
                          width: cardWidth,
                          child: _MoreCard(project: project),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final tech in project.tech) TechChip(label: tech)],
          ),
          const SizedBox(height: 14),
          if (githubLink != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => openLink(githubLink.url),
                icon: const Icon(Icons.code_rounded, size: 16),
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
        icon: const Icon(Icons.code_rounded, size: 18),
        label: Text(l10n.moreOnGithub),
      ),
    );
  }
}
