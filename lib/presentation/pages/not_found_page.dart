import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

// shortcut: minimal version; Task 3 of Phase 1 styles it.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.notFoundTitle, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => context.go('/'), child: Text(l10n.backHome)),
          ],
        ),
      ),
    );
  }
}
