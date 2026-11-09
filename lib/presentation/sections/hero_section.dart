import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/download_file.dart';
import '../../core/utils/open_link.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/animated_counter.dart';
import '../widgets/aurora_background.dart';
import '../widgets/profile_photo.dart';
import '../widgets/typewriter_text.dart';

/// The first screen: photo, name, cycling role, pitch, links and the four
/// stats. Everything fades and slides in, staggered, once on load.
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
      ScreenSize.phone => textTheme.displaySmall,
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
        const SizedBox(height: 16),
        entrance(0, Text(profile.name, style: nameStyle, textAlign: align)),
        const SizedBox(height: 12),
        entrance(
          1,
          TypewriterText(
            roles: roles,
            style: textTheme.headlineSmall?.copyWith(color: palette.text),
            textAlign: align,
          ),
        ),
        const SizedBox(height: 8),
        entrance(
          2,
          Text(
            profile.title.of(locale),
            style: textTheme.bodyLarge?.copyWith(color: palette.mutedText),
            textAlign: align,
          ),
        ),
        const SizedBox(height: 28),
        entrance(
          3,
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
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    downloadFile(profile.resumePdf, resumeFileName),
                icon: const Icon(Icons.download_rounded),
                label: Text(l10n.downloadResume),
              ),
              // Secondary links are icon-only: one filled action, one outlined
              // action, three quiet circles.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SocialButton(
                    icon: Icons.code_rounded,
                    tooltip: l10n.github,
                    onPressed: () => openLink(profile.github),
                  ),
                  const SizedBox(width: 8),
                  _SocialButton(
                    icon: Icons.work_outline_rounded,
                    tooltip: l10n.linkedin,
                    onPressed: () => openLink(profile.linkedin),
                  ),
                  const SizedBox(width: 8),
                  _SocialButton(
                    icon: Icons.mail_outline_rounded,
                    tooltip: l10n.email,
                    onPressed: () => openLink('mailto:${profile.email}'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        entrance(4, _Stats(counterDelay: _entranceDelay(4))),
      ],
    );

    final photo = ProfilePhoto(
      key: _photoKey,
      name: profile.name,
      photo: profile.photo,
      size: switch (screen) {
        ScreenSize.phone => 176,
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
          padding: const EdgeInsetsDirectional.fromSTEB(24, 104, 24, 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SizedBox(
                width: double.infinity,
                child: phone
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [photo, const SizedBox(height: 32), details],
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

/// A round, quiet action used for the social links in the hero.
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        backgroundColor: WidgetStatePropertyAll(palette.surface),
        foregroundColor: WidgetStatePropertyAll(palette.text),
        overlayColor: WidgetStatePropertyAll(
          palette.text.withValues(alpha: 0.04),
        ),
        shape: WidgetStateProperty.resolveWith<OutlinedBorder?>(
          (states) => CircleBorder(
            side: BorderSide(
              color:
                  states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.focused)
                  ? palette.accentInk
                  : palette.surfaceBorder,
            ),
          ),
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.counterDelay});

  final Duration counterDelay;

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).content.profile;
    final locale = Localizations.localeOf(context);
    final textTheme = Theme.of(context).textTheme;
    final phone = ScreenSize.of(context) == ScreenSize.phone;

    return Wrap(
      alignment: phone ? WrapAlignment.center : WrapAlignment.start,
      spacing: 24,
      runSpacing: 20,
      children: [
        for (final stat in profile.stats)
          SizedBox(
            width: phone ? 130 : 168,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: phone
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                AnimatedCounter(
                  value: stat.value,
                  suffix: stat.suffix,
                  style: textTheme.headlineMedium,
                  delay: counterDelay,
                ),
                const SizedBox(height: 4),
                Text(
                  stat.label.of(locale),
                  style: textTheme.bodySmall,
                  textAlign: phone ? TextAlign.center : TextAlign.start,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
