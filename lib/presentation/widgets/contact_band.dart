import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/open_link.dart';
import '../../l10n/app_localizations.dart';
import 'brand_icon.dart';
import 'glass_card.dart';

/// The digits of a phone number, as WhatsApp expects them.
String phoneDigits(String phone) => phone.replaceAll(RegExp(r'\D'), '');

/// The contact band: a large headline, the email with a copy button, the
/// phone number, and one button per way to get in touch.
class ContactBand extends StatelessWidget {
  const ContactBand({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).content.profile;
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final palette = AppPalette.of(context);
    final phone = profile.phone;

    return GlassCard(
      padding: const EdgeInsetsDirectional.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.contactCta,
            style: textTheme.displaySmall?.copyWith(color: palette.text),
          ),
          const SizedBox(height: 20),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                profile.email,
                style: textTheme.headlineSmall?.copyWith(color: palette.text),
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
              if (phone != null && phone.isNotEmpty)
                Text(
                  phone,
                  style: textTheme.titleMedium?.copyWith(
                    color: palette.mutedText,
                  ),
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
                icon: const Icon(Icons.mail_outline_rounded),
                label: Text(l10n.sendEmail),
              ),
              if (phone != null && phone.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () =>
                      openLink('https://wa.me/${phoneDigits(phone)}'),
                  icon: const BrandIcon(BrandMark.whatsapp, size: 18),
                  label: Text(l10n.whatsapp),
                ),
              OutlinedButton.icon(
                onPressed: () => openLink(profile.linkedin),
                icon: const BrandIcon(BrandMark.linkedin, size: 18),
                label: Text(l10n.linkedin),
              ),
              OutlinedButton.icon(
                onPressed: () => openLink(profile.github),
                icon: const BrandIcon(BrandMark.github, size: 18),
                label: Text(l10n.github),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
