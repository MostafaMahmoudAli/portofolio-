import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_scope.dart';
import '../../core/models/stat.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/download_file.dart';
import '../../core/utils/open_link.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/animated_counter.dart';
import '../widgets/aurora_background.dart';
import '../widgets/brand_icon.dart';
import '../widgets/glass_card.dart';
import '../widgets/profile_photo.dart';
import '../widgets/social_button.dart';
import '../widgets/typewriter_text.dart';

/// The first screen: photo, name, cycling role, links and the four stats.
/// Everything fades and slides in, staggered, once on load.
///
/// The details column and the photo keep their state when the width crosses a
/// breakpoint and the layout switches between a Column and a Row, so the
/// entrance animation and the counters never replay.
class HeroSection extends StatefulWidget {
  const HeroSection({super.key, required this.onViewProjects});

  final VoidCallback onViewProjects;

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final _detailsKey = GlobalKey();
  final _photoKey = GlobalKey();

  static Duration _entranceDelay(int order) =>
      Duration(milliseconds: 100 * order);

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).content.profile;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final screen = ScreenSize.of(context);
    final phone = screen == ScreenSize.phone;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final nameStyle = switch (screen) {
      // A phone first screen has to carry the name, the role, both buttons
      // and the stats band, so the name drops one step down there.
      ScreenSize.phone => textTheme.headlineMedium,
      ScreenSize.tablet => textTheme.displayMedium,
      ScreenSize.desktop => textTheme.displayLarge,
    };
    final align = phone ? TextAlign.center : TextAlign.start;
    final crossAlign = phone
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    final roles = [
      l10n.heroRoleMobile,
      l10n.heroRoleCrossPlatform,
      l10n.heroRoleCleanCode,
    ];

    Widget entrance(int order, Widget child) {
      if (reduceMotion) return child;
      final delay = _entranceDelay(order);
      return child
          .animate()
          .fadeIn(duration: 500.ms, delay: delay, curve: Curves.easeOut)
          .slideY(
            begin: 0.12,
            end: 0,
            duration: 500.ms,
            delay: delay,
            curve: Curves.easeOutCubic,
          );
    }

    final details = Column(
      key: _detailsKey,
      crossAxisAlignment: crossAlign,
      children: [
        Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: palette.accentInk),
          ),
          child: Text(
            l10n.availability,
            textAlign: align,
            style: textTheme.labelMedium?.copyWith(color: palette.accentInk),
          ),
        ),
        SizedBox(height: phone ? 10 : 16),
        entrance(
          0,
          Text(profile.name.of(locale), style: nameStyle, textAlign: align),
        ),
        SizedBox(height: phone ? 6 : 12),
        // The typewriter is the only place the role appears. Under reduced
        // motion it shows the first role in full.
        entrance(
          1,
          TypewriterText(
            roles: roles,
            style: textTheme.headlineSmall?.copyWith(color: palette.text),
            textAlign: align,
          ),
        ),
        SizedBox(height: phone ? 16 : 28),
        entrance(
          2,
          Wrap(
            alignment: phone ? WrapAlignment.center : WrapAlignment.start,
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: widget.onViewProjects,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(l10n.viewProjects),
                // On a phone both actions share one row.
                style: phone
                    ? FilledButton.styleFrom(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 14,
                        ),
                      )
                    : null,
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    downloadFile(profile.resumePdf, resumeFileName),
                icon: const Icon(Icons.download_rounded),
                label: Text(l10n.downloadResume),
                style: phone
                    ? OutlinedButton.styleFrom(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 14,
                        ),
                      )
                    : null,
              ),
              // Secondary links are icon-only: one filled action, one outlined
              // action, three quiet circles.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SocialButton(
                    icon: const BrandIcon(BrandMark.github, size: 20),
                    tooltip: l10n.github,
                    onPressed: () => openLink(profile.github),
                  ),
                  const SizedBox(width: 8),
                  SocialButton(
                    icon: const BrandIcon(BrandMark.linkedin, size: 20),
                    tooltip: l10n.linkedin,
                    onPressed: () => openLink(profile.linkedin),
                  ),
                  const SizedBox(width: 8),
                  SocialButton(
                    icon: const Icon(Icons.mail_outline_rounded, size: 20),
                    tooltip: l10n.email,
                    onPressed: () => openLink('mailto:${profile.email}'),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: phone ? 16 : 32),
        entrance(3, _StatsBand(counterDelay: _entranceDelay(3))),
      ],
    );

    final photo = ProfilePhoto(
      key: _photoKey,
      name: profile.name.of(locale),
      photo: profile.photo,
      size: switch (screen) {
        ScreenSize.phone => 96,
        ScreenSize.tablet => 200,
        ScreenSize.desktop => 260,
      },
    );

    return AuroraBackground(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // The nav bar floats over the page, so a full viewport height would
          // leave a band of empty space under the stats on a desktop window.
          minHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24, phone ? 84 : 104, 24, 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SizedBox(
                width: double.infinity,
                child: phone
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [photo, const SizedBox(height: 16), details],
                      )
                    : Row(
                        children: [
                          Expanded(child: details),
                          const SizedBox(width: 48),
                          photo,
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The four stats as one band: a large number, a small label, and thin
/// dividers between the cells. Four across on desktop and tablet, two by two
/// on a phone.
///
/// The cells are laid out in one [Wrap] with a stable order, so crossing the
/// phone breakpoint re-flows them without rebuilding the counters.
class _StatsBand extends StatelessWidget {
  const _StatsBand({required this.counterDelay});

  final Duration counterDelay;

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).content.profile;
    final phone = ScreenSize.of(context) == ScreenSize.phone;
    final stats = profile.stats;
    final columns = phone ? 2 : 4;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / columns;
          return Wrap(
            spacing: 0,
            runSpacing: 0,
            children: [
              for (var index = 0; index < stats.length; index++)
                SizedBox(
                  width: cellWidth,
                  child: _StatCell(
                    stat: stats[index],
                    delay: counterDelay,
                    showStartDivider: index % columns != 0,
                    showTopDivider: index >= columns,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// One cell of the stats band: the number over its label.
class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.stat,
    required this.delay,
    required this.showStartDivider,
    required this.showTopDivider,
  });

  final Stat stat;
  final Duration delay;
  final bool showStartDivider;
  final bool showTopDivider;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: showStartDivider
              ? BorderSide(color: palette.surfaceBorder)
              : BorderSide.none,
          top: showTopDivider
              ? BorderSide(color: palette.surfaceBorder)
              : BorderSide.none,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCounter(
              value: stat.value,
              suffix: stat.suffix,
              style: textTheme.headlineMedium,
              delay: delay,
            ),
            const SizedBox(height: 2),
            Text(stat.label.of(locale), style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
