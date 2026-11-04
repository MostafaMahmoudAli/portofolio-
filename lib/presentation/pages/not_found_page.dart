import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/gradient_text.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final palette = AppPalette.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GradientText('404', style: textTheme.displayLarge),
              const SizedBox(height: 16),
              Text(l10n.notFoundTitle, style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                l10n.notFoundBody,
                style: textTheme.bodyLarge?.copyWith(color: palette.mutedText),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: () => context.go('/'), child: Text(l10n.backHome)),
            ],
          ),
        ),
      ),
    );
  }
}
