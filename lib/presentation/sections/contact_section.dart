import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/contact_band.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_content.dart';
import '../widgets/section_title.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(l10n.navContact, eyebrow: l10n.eyebrowContact),
          const SizedBox(height: 16),
          const RevealOnScroll(child: ContactBand()),
        ],
      ),
    );
  }
}
