import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/language_toggle.dart';
import '../widgets/theme_toggle.dart';

// shortcut: placeholder; Task 3 of Phase 1 replaces it with the nav bar and sections.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(actions: const [LanguageToggle(), ThemeToggle()]),
      body: ListView(
        children: [
          for (var i = 0; i < 20; i++)
            SizedBox(height: 200, child: Center(child: Text(l10n.sectionComingSoon))),
        ],
      ),
    );
  }
}
