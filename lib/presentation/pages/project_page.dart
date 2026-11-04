import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

// shortcut: placeholder until Phase 5 builds the real project page.
class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(24),
          child: Text(
            AppLocalizations.of(context).projectComingSoon(slug),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
    );
  }
}
