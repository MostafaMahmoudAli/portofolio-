import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_content.dart';
import '../widgets/section_title.dart';
import '../widgets/skills_marquee.dart';
import '../widgets/tech_chip.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});
  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).content.profile;
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context);
    final marquee = SkillsMarquee(
      chips: [for (final group in profile.skillGroups) ...group.chips],
    );
    return SectionContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(l10n.navSkills),
          const SizedBox(height: 24),
          if (MediaQuery.disableAnimationsOf(context))
            marquee
          else
            SizedBox(height: 48, child: marquee),
          for (final group in profile.skillGroups)
            RevealOnScroll(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(top: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.title.of(locale),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final chip in group.chips) TechChip(label: chip),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 28),
          SectionTitle(l10n.languages),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
