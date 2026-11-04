import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_scope.dart';
import '../../core/utils/open_link.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_card.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_content.dart';
import '../widgets/section_title.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});
  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).content.profile;
    final l10n = AppLocalizations.of(context);
    return SectionContent(
      child: RevealOnScroll(
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(l10n.navContact),
              const SizedBox(height: 16),
              Text(
                l10n.contactCta,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    tooltip: l10n.copyEmail,
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: profile.email),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l10n.emailCopied)));
                    },
                    icon: const Icon(Icons.copy_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => openLink('mailto:${profile.email}'),
                    icon: const Icon(Icons.mail_outline),
                    label: Text(l10n.sendEmail),
                  ),
                  OutlinedButton(
                    onPressed: () => openLink(profile.linkedin),
                    child: Text(l10n.linkedin),
                  ),
                  OutlinedButton(
                    onPressed: () => openLink(profile.github),
                    child: Text(l10n.github),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
