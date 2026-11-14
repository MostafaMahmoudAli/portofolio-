import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/models/skill_group.dart';
import '../../core/utils/breakpoints.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_card.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_content.dart';
import '../widgets/section_title.dart';
import '../widgets/tech_chip.dart';

/// The skills, one card per group. A card shows the group's title and its
/// first five chips; a "Show all" control reveals the rest of that group.
class SkillsSection extends StatefulWidget {
  const SkillsSection({super.key});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
  /// The chips a group shows before it is expanded.
  static const _visibleChips = 5;

  final _expanded = <String>{};

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).content.profile;
    final l10n = AppLocalizations.of(context);
    final screen = ScreenSize.of(context);
    // Three across on a desktop, two on a tablet, one on a phone.
    final columns = switch (screen) {
      ScreenSize.phone => 1,
      ScreenSize.tablet => 2,
      ScreenSize.desktop => 3,
    };
    final groups = profile.skillGroups;
    final rows = <List<SkillGroup>>[
      for (var i = 0; i < groups.length; i += columns)
        groups.sublist(i, (i + columns).clamp(0, groups.length)),
    ];

    return SectionContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(l10n.navSkills, eyebrow: l10n.eyebrowSkills),
          const SizedBox(height: 24),
          // The chips are grouped, not repeated: one list, once.
          for (final row in rows)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < row.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(
                      child: _SkillGroupCard(
                        group: row[i],
                        expanded: _expanded.contains(row[i].title.en),
                        onToggle: () => setState(() {
                          if (!_expanded.remove(row[i].title.en)) {
                            _expanded.add(row[i].title.en);
                          }
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One skill group: its title, its first five chips and a control that shows
/// the rest.
class _SkillGroupCard extends StatelessWidget {
  const _SkillGroupCard({
    required this.group,
    required this.expanded,
    required this.onToggle,
  });

  final SkillGroup group;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final textTheme = Theme.of(context).textTheme;
    final chips = expanded
        ? group.chips
        : group.chips.take(_SkillsSectionState._visibleChips).toList();

    return RevealOnScroll(
      child: GlassCard(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.title.of(locale),
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final chip in chips) TechChip(label: chip)],
            ),
            if (group.chips.length > _SkillsSectionState._visibleChips) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onToggle,
                icon: Icon(
                  expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                ),
                label: Text(expanded ? l10n.showLess : l10n.showAll),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
