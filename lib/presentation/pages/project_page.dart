import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scope.dart';
import '../../core/models/project_link.dart';
import '../../core/models/project_videos.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/open_link.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../sections/footer_section.dart';
import '../widgets/brand_icon.dart';
import '../widgets/contact_band.dart';
import '../widgets/glass_card.dart';
import '../widgets/nav_bar.dart';
import '../widgets/page_title.dart';
import '../widgets/project_platform_gallery.dart';
import '../widgets/screens_gallery.dart';
import '../widgets/store_badges.dart';
import '../widgets/tech_chip.dart';
import '../widgets/video_platform_picker.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key, required this.slug, this.platform});

  final String slug;
  final VideoPlatform? platform;

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final _scroll = ScrollController();
  final _galleryKey = GlobalKey();

  void _top() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(0);
    } else {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = [...AppScope.of(context).content.projects]
      ..sort((a, b) => a.order.compareTo(b.order));
    final index = projects.indexWhere((p) => p.slug == widget.slug);
    final project = projects[index];
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final desktop = ScreenSize.of(context) == ScreenSize.desktop;
    final previous = projects[(index - 1 + projects.length) % projects.length];
    final next = projects[(index + 1) % projects.length];
    final platforms = <VideoPlatform>{
      for (final entry in project.videos.available) entry.$1,
      for (final link in project.links)
        if (link.type == ProjectLinkType.appStore)
          VideoPlatform.ios
        else if (link.type == ProjectLinkType.playStore)
          VideoPlatform.android,
    };
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(project.title.of(locale), style: text.headlineLarge),
        const SizedBox(height: 8),
        Text(
          project.subtitle.of(locale),
          style: text.titleMedium?.copyWith(color: palette.mutedText),
        ),
        const SizedBox(height: 16),
        Wrap(
          key: const ValueKey('project-quick-facts'),
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final platform in platforms)
              TechChip(label: videoPlatformLabel(l10n, platform)),
            if (project.status case final status?)
              TechChip(label: status.of(locale)),
            for (final tech in project.tech) TechChip(label: tech),
          ],
        ),
      ],
    );
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, bullet) in project.bullets.indexed)
                Padding(
                  padding: EdgeInsetsDirectional.only(top: i == 0 ? 0 : 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_rounded, color: palette.text, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(bullet.of(locale))),
                    ],
                  ),
                ),
              if (project.links.isNotEmpty) ...[
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
                        icon: link.type == ProjectLinkType.github
                            ? const BrandIcon(BrandMark.github, size: 18)
                            : const Icon(Icons.open_in_new),
                        label: Text(
                          link.type == ProjectLinkType.github
                              ? l10n.viewOnGitHub
                              : l10n.viewLive,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (project.screens.isNotEmpty) ...[
          const SizedBox(height: 32),
          ScreensGallery(
            key: ValueKey('screens-${widget.slug}'),
            screens: project.screens,
          ),
        ],
      ],
    );
    final gallery = project.videos.primary == null
        ? null
        : ProjectPlatformGallery(
            key: _galleryKey,
            project: project,
            heroPlatform: widget.platform,
            singlePlatform: desktop,
          );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [header, const SizedBox(height: 24), body],
    );

    return PageTitle(
      title:
          '${project.title.of(locale)} — '
          '${AppScope.of(context).content.profile.pageTitleOf(locale)}',
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scroll,
              key: ValueKey('project-scroll-${widget.slug}'),
              slivers: [
                SliverPadding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    math.max(24, (MediaQuery.sizeOf(context).width - 1200) / 2),
                    88,
                    math.max(24, (MediaQuery.sizeOf(context).width - 1200) / 2),
                    48,
                  ),
                  sliver: SliverList.list(
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: BackButton(
                          onPressed: () => context.canPop()
                              ? context.pop()
                              : context.go('/'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (desktop && gallery != null)
                        _StickyColumns(
                          scroll: _scroll,
                          media: gallery,
                          details: details,
                        )
                      else ...[
                        header,
                        if (gallery != null) ...[
                          const SizedBox(height: 24),
                          gallery,
                        ],
                        const SizedBox(height: 24),
                        body,
                      ],
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
                      const SizedBox(height: 48),
                      const ContactBand(),
                    ],
                  ),
                ),
                SliverToBoxAdapter(child: FooterSection(onBackToTop: _top)),
              ],
            ),
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: NavBar(
                onSectionTap: (section) =>
                    context.go('/?section=${section.name}'),
                onLogoTap: () => context.go('/?top=1'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scroll-derived pinning, bounded by the text column: no nested scroll view,
/// timer or animation. Short viewports retain access to the full media.
class _StickyColumns extends StatefulWidget {
  const _StickyColumns({
    required this.scroll,
    required this.media,
    required this.details,
  });

  final ScrollController scroll;
  final Widget media;
  final Widget details;

  @override
  State<_StickyColumns> createState() => _StickyColumnsState();
}

class _StickyColumnsState extends State<_StickyColumns> {
  final _row = GlobalKey();
  final _media = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Row(
      key: _row,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 380,
          child: AnimatedBuilder(
            animation: widget.scroll,
            child: SizedBox(key: _media, child: widget.media),
            builder: (context, child) {
              final row = _row.currentContext?.findRenderObject();
              final media = _media.currentContext?.findRenderObject();
              var offset = 0.0;
              if (row is RenderBox &&
                  media is RenderBox &&
                  row.hasSize &&
                  media.hasSize) {
                final top = math.min(
                  88.0,
                  MediaQuery.sizeOf(context).height - media.size.height - 16,
                );
                final start = RenderAbstractViewport.of(
                  row,
                ).getOffsetToReveal(row, 0).offset;
                offset = (widget.scroll.offset - start + top).clamp(
                  0.0,
                  math.max(0.0, row.size.height - media.size.height),
                );
              }
              return Transform.translate(
                offset: Offset(0, offset),
                child: child,
              );
            },
          ),
        ),
        const SizedBox(width: 32),
        Expanded(child: widget.details),
      ],
    );
  }
}
