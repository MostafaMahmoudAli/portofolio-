import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_card.dart';
import '../widgets/marked_text.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_content.dart';
import '../widgets/section_title.dart';
import '../widgets/tech_chip.dart';
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
          SectionTitle(l10n.navExperience, eyebrow: l10n.eyebrowExperience),
          const SizedBox(height: 24),
          Stack(
            key: _timelineKey,
            children: [
              PositionedDirectional(
                // The line runs through the middle of the company badges.
                start: 15,
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
                      color: palette.accentInk,
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
                            top: 22,
                            child: TimelineDot(
                              key: ValueKey('timeline-dot-$index'),
                              initial: entry.company.substring(0, 1),
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
                                        child: MarkedText(
                                          '• ${bullet.of(locale)}',
                                        ),
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
          // Three labeled rows: education, certifications and languages.
          _LabeledRow(
            label: l10n.educationRow,
            children: [
              RevealOnScroll(
                child: GlassCard(child: Text(profile.education.of(locale))),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _LabeledRow(
            label: l10n.certificationsRow,
            equalWidth: true,
            children: [
              for (final item in profile.certifications)
                RevealOnScroll(
                  child: GlassCard(child: Text(item.of(locale))),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _LabeledRow(
            label: l10n.languages,
            children: [
              for (final language in profile.languages)
                TechChip(label: language.of(locale)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A row of cards under a small label. With [equalWidth] the cards share one
/// width, so a row of them reads as a row.
class _LabeledRow extends StatelessWidget {
  const _LabeledRow({
    required this.label,
    required this.children,
    this.equalWidth = false,
  });

  final String label;
  final List<Widget> children;
  final bool equalWidth;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = AppPalette.of(context);

    final Widget content;
    if (equalWidth) {
      content = LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720 ? children.length : 1;
          final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final child in children)
                SizedBox(width: width, child: child),
            ],
          );
        },
      );
    } else {
      content = Wrap(spacing: 16, runSpacing: 16, children: children);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.titleMedium?.copyWith(color: palette.mutedText),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
}
