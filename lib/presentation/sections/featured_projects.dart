import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scope.dart';
import '../../core/models/project.dart';
import '../../core/models/project_videos.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_card.dart';
import '../widgets/project_media_frame.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_title.dart';
import '../widgets/store_badges.dart';
import '../widgets/tech_chip.dart';
import '../widgets/video_platform_picker.dart';

/// How a tile arranges its frame and its text.
enum _TileLayout { wide, stacked }

/// Featured projects as a bento grid: the first project gets a full-width
/// tile, the other four sit in a two by two grid (one column on a phone).
///
/// The tiles are slivers, so off-screen tiles and their video players are
/// never built.
class FeaturedProjectsSection extends StatelessWidget {
  const FeaturedProjectsSection({super.key, this.headerKey});

  /// Put on the header, which always exists, so nav links can scroll to it.
  final Key? headerKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final screen = ScreenSize.of(context);
    final featured = [
      ...AppScope.of(context).content.projects.where((p) => p.featured),
    ]..sort((a, b) => a.order.compareTo(b.order));

    final first = featured.first;
    final rest = featured.skip(1).toList();
    // Two columns once a tile can still hold a readable line of text.
    final columns = screen == ScreenSize.phone ? 1 : 2;
    final rows = <List<Project>>[
      for (var i = 0; i < rest.length; i += columns)
        rest.sublist(i, (i + columns).clamp(0, rest.length)),
    ];

    return SliverPadding(
      // Same 1200 max content width as the other sections.
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: math.max(24, (width - 1200) / 2),
      ),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              key: headerKey,
              padding: const EdgeInsetsDirectional.only(top: 96, bottom: 6),
              child: SectionTitle(
                l10n.featuredProjects,
                eyebrow: l10n.eyebrowProjects,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
              child: RevealOnScroll(
                child: _ProjectTile(
                  project: first,
                  hero: true,
                  layout: screen == ScreenSize.phone
                      ? _TileLayout.stacked
                      : _TileLayout.wide,
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];
              return Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < columns; i++) ...[
                      if (i > 0) const SizedBox(width: 16),
                      Expanded(
                        child: i < row.length
                            ? RevealOnScroll(
                                child: _ProjectTile(
                                  project: row[i],
                                  layout: screen == ScreenSize.desktop
                                      ? _TileLayout.wide
                                      : _TileLayout.stacked,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// One project tile: the phone frame, the impact line, the title, the
/// subtitle, the tech chips, the store badges and the details button.
class _ProjectTile extends StatefulWidget {
  const _ProjectTile({
    required this.project,
    required this.layout,
    this.hero = false,
  });

  final Project project;
  final _TileLayout layout;

  /// The full-width tile: it keeps the status line and every store badge.
  final bool hero;

  @override
  State<_ProjectTile> createState() => _ProjectTileState();
}

class _ProjectTileState extends State<_ProjectTile> {
  VideoPlatform? _selectedPlatform;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize.of(context);
    final project = widget.project;
    final accent = project.accentColor;
    final available = project.videos.available;
    final entry =
        available.where((entry) => entry.$1 == _selectedPlatform).firstOrNull ??
        project.videos.primary;
    final video = entry?.$2;

    // A frame narrower than 160 cannot hold three 48px video controls in a
    // row, so the small tiles keep their controls usable.
    final frameWidth = switch (widget.layout) {
      _TileLayout.wide => widget.hero
          ? (screen == ScreenSize.tablet ? 180.0 : 200.0)
          : 160.0,
      _TileLayout.stacked => 160.0,
    };

    final media = video == null
        ? null
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProjectMediaFrame(
                project: project,
                video: video,
                platform: entry!.$1,
                width: frameWidth,
                accent: accent,
              ),
              if (available.length > 1) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: frameWidth,
                  child: VideoPlatformPicker(
                    selected: entry.$1,
                    compact: true,
                    onChanged: (value) =>
                        setState(() => _selectedPlatform = value),
                  ),
                ),
              ],
            ],
          );

    final text = _TileText(
      project: project,
      platform: entry?.$1,
      hero: widget.hero,
    );

    final Widget body;
    if (widget.layout == _TileLayout.stacked) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (media != null) ...[
            Center(child: media),
            const SizedBox(height: 20),
          ],
          text,
        ],
      );
    } else {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (media != null) ...[
            media,
            const SizedBox(width: 24),
          ],
          Expanded(child: text),
        ],
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (_hovered)
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 32,
              ),
          ],
        ),
        child: GlassCard(
          padding: EdgeInsetsDirectional.all(
            screen == ScreenSize.phone ? 16 : 24,
          ),
          borderColor: accent.withValues(alpha: 0.45),
          hoverBorderColor: accent,
          child: body,
        ),
      ),
    );
  }
}

/// The text column of a tile: impact, title, subtitle, chips, badges and the
/// details button. The summary lives on the project page, not on the tile.
class _TileText extends StatelessWidget {
  const _TileText({
    required this.project,
    required this.hero,
    this.platform,
  });

  final Project project;
  final bool hero;
  final VideoPlatform? platform;

  /// At most four chips; the rest collapse into a "+N" chip.
  static const _maxChips = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final textTheme = Theme.of(context).textTheme;
    final muted = AppPalette.of(context).mutedText;
    final status = project.status;
    final chips = project.tech.take(_maxChips).toList();
    final extra = project.tech.length - chips.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (project.impact case final impact?) ...[
          Text(
            impact.of(locale),
            style: textTheme.titleMedium?.copyWith(
              color: AppPalette.of(context).accentInk,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(project.title.of(locale), style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          project.subtitle.of(locale),
          style: textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tech in chips) TechChip(label: tech),
            if (extra > 0) TechChip(label: '+$extra'),
          ],
        ),
        if (hero && status != null) ...[
          const SizedBox(height: 12),
          Text(
            status.of(locale),
            style: textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
        if (project.links.isNotEmpty) ...[
          const SizedBox(height: 14),
          // A small tile shows one city; the rest live on the project page.
          StoreBadges(links: project.links, maxGroups: hero ? null : 1),
        ],
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => context.go(
            Uri(
              path: '/projects/${project.slug}',
              queryParameters:
                  project.videos.available.length > 1 && platform != null
                  ? {'platform': platform!.name}
                  : null,
            ).toString(),
          ),
          // arrow_forward mirrors itself in RTL.
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(l10n.details),
        ),
      ],
    );
  }
}
