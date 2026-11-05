import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_card.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_content.dart';
import '../widgets/section_title.dart';
import '../widgets/timeline_dot.dart';

class ExperienceSection extends StatefulWidget {
  const ExperienceSection({super.key});
  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> {
  final _timelineKey = GlobalKey();
  ScrollPosition? _position;
  double _progress = 0;
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_update);
      _position = position;
      _position?.addListener(_update);
    }
    _update();
  }

  void _update() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      final box = _timelineKey.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize || box.size.height == 0) return;
      final viewport =
          _position?.viewportDimension ?? MediaQuery.sizeOf(context).height;
      final progress =
          ((viewport * 0.8 - box.localToGlobal(Offset.zero).dy) /
                  box.size.height)
              .clamp(0.0, 1.0);
      if (_progress != progress) setState(() => _progress = progress);
    });
  }

  @override
  void dispose() {
    _position?.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).content.profile;
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    return SectionContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(l10n.navExperience),
          const SizedBox(height: 24),
          Stack(
            key: _timelineKey,
            children: [
              PositionedDirectional(
                start: 6,
                top: 0,
                bottom: 24,
                width: 2,
                child: Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: FractionallySizedBox(
                    heightFactor: MediaQuery.disableAnimationsOf(context)
                        ? 1
                        : _progress,
                    child: ColoredBox(
                      key: const ValueKey('timeline-line'),
                      color: palette.accentStart,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, entry) in profile.experience.indexed)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 24),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          PositionedDirectional(
                            start: 0,
                            top: 28,
                            child: TimelineDot(
                              key: ValueKey('timeline-dot-$index'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: 36,
                            ),
                            child: RevealOnScroll(
                              child: GlassCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.role.of(locale),
                                      style: text.titleLarge,
                                    ),
                                    Text(
                                      entry.company,
                                      style: text.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${entry.dates.of(locale)} · ${entry.mode.of(locale)}',
                                      style: text.bodyMedium?.copyWith(
                                        color: palette.mutedText,
                                      ),
                                    ),
                                    for (final bullet in entry.bullets)
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                              top: 12,
                                            ),
                                        child: Text('• ${bullet.of(locale)}'),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          SectionTitle(l10n.educationCertifications),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final item in [profile.education, ...profile.certifications])
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: RevealOnScroll(
                    child: GlassCard(child: Text(item.of(locale))),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
