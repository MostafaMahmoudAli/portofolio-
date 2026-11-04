import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/app_scope.dart';
import 'core/data/content_repository.dart';
import 'core/localization/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'l10n/app_localizations.dart';
import 'presentation/widgets/language_flip.dart';

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({
    super.key,
    required this.content,
    required this.themeController,
    required this.localeController,
  });

  final Content content;
  final ThemeController themeController;
  final LocaleController localeController;

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      content: widget.content,
      theme: widget.themeController,
      locale: widget.localeController,
      child: ListenableBuilder(
        listenable: Listenable.merge([widget.themeController, widget.localeController]),
        builder: (context, _) {
          final locale = widget.localeController.value;
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.build(Brightness.light, locale),
            darkTheme: AppTheme.build(Brightness.dark, locale),
            themeMode: widget.themeController.value,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: _router,
            // The background stays still while the page flips over it.
            builder: (context, child) => ColoredBox(
              color: AppPalette.of(context).background,
              child: LanguageFlip(child: child!),
            ),
          );
        },
      ),
    );
  }
}
