import 'dart:math' as math;

import 'package:flutter/gestures.dart' show PointerHoverEvent;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scope.dart';
import '../../core/models/project.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_card.dart';
import '../widgets/project_media_frame.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_title.dart';
import '../widgets/store_badges.dart';
import '../widgets/tech_chip.dart';

/// Featured projects as slivers: a header, then one large card per featured
/// project (sorted by `order`) in a lazy list, so off-screen cards and their
/// video players are never built.
class FeaturedProjectsSection extends StatelessWidget {
  const FeaturedProjectsSection({super.key, this.headerKey});

  /// Put on the header, which always exists, so nav links can scroll to it.
  final Key? headerKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final featured = [
      ...AppScope.of(context).content.projects.where((p) => p.featured),
    ]..sort((a, b) => a.order.compareTo(b.order));

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
              child: SectionTitle(l10n.featuredProjects),
            ),
          ),
          SliverList.builder(
            itemCount: featured.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 18),
              child: RevealOnScroll(
                child: _FeaturedCard(project: featured[index], index: index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatefulWidget {
  const _FeaturedCard({required this.project, required this.index});

  final Project project;
  final int index;

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  late final Color _accent = Color(
    0xFF000000 | int.parse(widget.project.accent.substring(1), radix: 16),
  );

  /// Cursor position over the card, -0.5..0.5 on each axis; null when not hovered.
  final _tilt = ValueNotifier<Offset?>(null);

  @override
  void dispose() {
    _tilt.dispose();
    super.dispose();
  }

  void _onHover(PointerHoverEvent event) {
    final size = (context.findRenderObject()! as RenderBox).size;
    _tilt.value = Offset(
      event.localPosition.dx / size.width - 0.5,
      event.localPosition.dy / size.height - 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize.of(context);
    final video = widget.project.videos.firstOrNull;

    final videoSide = video == null
        ? null
        : ProjectMediaFrame(
            project: widget.project,
            video: video,
            width: switch (screen) {
              ScreenSize.phone => 240,
              ScreenSize.tablet => 260,
              ScreenSize.desktop => 300,
            },
            accent: _accent,
          );
    final text = _CardText(project: widget.project, accent: _accent);

    final Widget body;
    if (screen == ScreenSize.phone) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (videoSide != null) ...[
            Center(child: videoSide),
            const SizedBox(height: 24),
          ],
          text,
        ],
      );
    } else {
      final sides = [
        ?videoSide,
        if (videoSide != null) const SizedBox(width: 40),
        Expanded(child: text),
      ];
      body = Row(
        children: widget.index.isEven ? sides : sides.reversed.toList(),
      );
    }

    final card = GlassCard(
      padding: EdgeInsetsDirectional.all(screen == ScreenSize.phone ? 20 : 32),
      child: body,
    );

    if (screen != ScreenSize.desktop ||
        MediaQuery.disableAnimationsOf(context)) {
      return card;
    }

    // Only the transform and glow rebuild on hover, never the card or its video.
    return MouseRegion(
      onHover: _onHover,
      onExit: (_) => _tilt.value = null,
      child: ValueListenableBuilder<Offset?>(
        valueListenable: _tilt,
        child: card,
        builder: (context, tilt, child) {
          final hovered = tilt != null;
          final t = tilt ?? Offset.zero;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0008)
              ..translateByDouble(0, hovered ? -6 : 0, 0, 1)
              ..rotateX(-t.dy * 0.08)
              ..rotateY(t.dx * 0.08),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (hovered)
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.35),
                      blurRadius: 32,
                    ),
                ],
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _CardText extends StatelessWidget {
  const _CardText({required this.project, required this.accent});

  final Project project;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final textTheme = Theme.of(context).textTheme;
    final muted = AppPalette.of(context).mutedText;
    final status = project.status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(project.title.of(locale), style: textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          project.subtitle.of(locale),
          style: textTheme.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 16),
        Text(project.summary.of(locale), style: textTheme.bodyLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tech in project.tech)
              TechChip(label: tech, color: accent),
          ],
        ),
        if (status != null) ...[
          const SizedBox(height: 16),
          Text(
            status.of(locale),
            style: textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
        const SizedBox(height: 16),
        StoreBadges(links: project.links),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => context.go('/projects/${project.slug}'),
          // arrow_forward mirrors itself in RTL.
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(l10n.details),
        ),
      ],
    );
  }
}
