import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/open_link.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/animated_counter.dart';
import '../widgets/gradient_text.dart';
import '../widgets/profile_photo.dart';
import '../widgets/typewriter_text.dart';

/// The first screen: photo, name, cycling role, pitch, links and the four
/// stats. Everything fades and slides in, staggered, once on load.
class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.onViewProjects});

  final VoidCallback onViewProjects;

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
      final delay = Duration(milliseconds: 100 * order);
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
      crossAxisAlignment: crossAlign,
      children: [
        entrance(
          0,
          GradientText(profile.name, style: nameStyle, textAlign: align),
        ),
        const SizedBox(height: 12),
        entrance(
          1,
          TypewriterText(
            roles: roles,
            style: textTheme.headlineSmall?.copyWith(color: palette.accentEnd),
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
            children: [
              FilledButton.icon(
                onPressed: onViewProjects,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(l10n.viewProjects),
              ),
              OutlinedButton.icon(
                onPressed: () => openLink(profile.resumePdf),
                icon: const Icon(Icons.download_rounded),
                label: Text(l10n.downloadResume),
              ),
              TextButton.icon(
                onPressed: () => openLink(profile.github),
                icon: const Icon(Icons.code_rounded),
                label: Text(l10n.github),
              ),
              TextButton.icon(
                onPressed: () => openLink(profile.linkedin),
                icon: const Icon(Icons.work_outline_rounded),
                label: Text(l10n.linkedin),
              ),
              TextButton.icon(
                onPressed: () => openLink('mailto:${profile.email}'),
                icon: const Icon(Icons.mail_outline_rounded),
                label: Text(l10n.email),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        entrance(4, _Stats()),
      ],
    );

    final photo = ProfilePhoto(
      name: profile.name,
      photo: profile.photo,
      size: switch (screen) {
        ScreenSize.phone => 176,
        ScreenSize.tablet => 200,
        ScreenSize.desktop => 260,
      },
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height),
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
    );
  }
}

class _Stats extends StatelessWidget {
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
            width: phone ? 130 : 150,
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
