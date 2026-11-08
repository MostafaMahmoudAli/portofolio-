import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/section_content.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key, required this.onBackToTop});
  final VoidCallback onBackToTop;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionContent(
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 16,
        children: [
          Text(l10n.footerCredit(DateTime.now().year)),
          TextButton.icon(
            onPressed: onBackToTop,
            icon: const Icon(Icons.arrow_upward_rounded),
            label: Text(l10n.backToTop),
          ),
        ],
      ),
    );
  }
}
