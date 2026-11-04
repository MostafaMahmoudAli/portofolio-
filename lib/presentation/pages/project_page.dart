import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scope.dart';
import '../../core/models/project_link.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/open_link.dart';
import '../../core/utils/project_accent.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_card.dart';
import '../widgets/nav_bar.dart';
import '../widgets/page_title.dart';
import '../widgets/project_poster.dart';
import '../widgets/project_video_gallery.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/store_badges.dart';
import '../widgets/tech_chip.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final projects = [...AppScope.of(context).content.projects]
      ..sort((a, b) => a.order.compareTo(b.order));
    final index = projects.indexWhere((p) => p.slug == slug);
    final project = projects[index];
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final accent = project.accentColor;
    final previous = projects[(index - 1 + projects.length) % projects.length];
    final next = projects[(index + 1) % projects.length];
    final padding = EdgeInsetsDirectional.symmetric(
      horizontal: math.max(24, (MediaQuery.sizeOf(context).width - 1200) / 2),
    );
    return PageTitle(
      title: '${project.title.of(locale)} — ${l10n.appTitle}',
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              key: ValueKey('project-scroll-$slug'),
              slivers: [
                SliverPadding(
                  padding: padding.add(
                    const EdgeInsetsDirectional.only(top: 88, bottom: 48),
                  ),
                  sliver: SliverList.list(
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: BackButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/');
                            }
                          },
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadiusDirectional.all(
                          Radius.circular(20),
                        ),
                        child: SizedBox(
                          height: 180,
                          child: ProjectPoster(
                            path: project.cover,
                            accentColor: accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        project.title.of(locale),
                        style: textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project.subtitle.of(locale),
                        style: textTheme.titleMedium?.copyWith(
                          color: palette.mutedText,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ProjectVideoGallery(
                        key: ValueKey(slug),
                        project: project,
                      ),
                      const SizedBox(height: 32),
                      RevealOnScroll(
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.summary.of(locale),
                                style: textTheme.bodyLarge,
                              ),
                              if (project.status case final status?) ...[
                                const SizedBox(height: 16),
                                Text(
                                  status.of(locale),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: palette.mutedText,
                                  ),
                                ),
                              ],
                              for (final bullet in project.bullets)
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    top: 16,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.check_rounded,
                                        color: accent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(bullet.of(locale))),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final tech in project.tech)
                                    TechChip(label: tech, color: accent),
                                ],
                              ),
                              const SizedBox(height: 24),
                              StoreBadges(links: project.links),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  for (final link in project.links.where(
                                    (link) =>
                                        link.type == ProjectLinkType.github ||
                                        link.type == ProjectLinkType.live,
                                  ))
                                    OutlinedButton.icon(
                                      onPressed: () => openLink(link.url),
                                      icon: Icon(
                                        link.type == ProjectLinkType.github
                                            ? Icons.code
                                            : Icons.open_in_new,
                                      ),
                                      label: Text(
                                        link.type == ProjectLinkType.github
                                            ? l10n.viewOnGitHub
                                            : l10n.viewLive,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          OutlinedButton.icon(
                            key: const ValueKey('previous-project'),
                            onPressed: () =>
                                context.go('/projects/${previous.slug}'),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: Text(
                              '${l10n.previousProject}\n${previous.title.of(locale)}',
                            ),
                          ),
                          OutlinedButton.icon(
                            key: const ValueKey('next-project'),
                            onPressed: () =>
                                context.go('/projects/${next.slug}'),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text(
                              '${l10n.nextProject}\n${next.title.of(locale)}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: NavBar(
                onSectionTap: (section) =>
                    context.go('/?section=${section.name}'),
                onLogoTap: () => context.go('/'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
