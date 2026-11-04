import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app.dart';
import 'package:portfolio/core/data/content.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/localization/locale_controller.dart';
import 'package:portfolio/core/theme/theme_controller.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/presentation/sections/hero_section.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

late Content content;

Future<void> pumpHome(
  WidgetTester tester, {
  Size size = const Size(1440, 900),
  Locale locale = const Locale('en'),
  bool reduceMotion = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduceMotion);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  SharedPreferences.setMockInitialValues({'languageCode': locale.languageCode});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    PortfolioApp(
      content: content,
      themeController: ThemeController(prefs),
      localeController: LocaleController(prefs, platformLocale: locale),
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  content = await const ContentRepository().load();

  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });
  tearDownAll(() {
    VisibilityDetectorController.instance.updateInterval = const Duration(
      milliseconds: 500,
    );
  });

  testWidgets('reduced motion: the hero is fully shown and nothing animates', (
    tester,
  ) async {
    await pumpHome(tester);
    final l10n = AppLocalizations.of(tester.element(find.byType(HeroSection)));
    final profile = content.profile;

    expect(find.text(profile.name), findsOneWidget);
    expect(find.text(l10n.heroRoleMobile), findsOneWidget);
    expect(find.text(profile.title.of(const Locale('en'))), findsOneWidget);
    expect(find.text('View projects'), findsOneWidget);
    expect(find.text('Download resume'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('LinkedIn'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);

    // Final counter values, no count-up and no entrance animation in flight.
    expect(find.text('3+'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('310K+'), findsOneWidget);
    expect(find.text('57'), findsOneWidget);
    expect(find.byType(Animate), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  for (final width in [375.0, 768.0, 1440.0]) {
    for (final language in ['en', 'ar']) {
      final locale = Locale(language);
      testWidgets(
        'hero fits at ${width.toInt()} px in ${language == 'ar' ? 'Arabic' : 'English'}',
        (tester) async {
          await pumpHome(tester, size: Size(width, 900), locale: locale);
          expect(tester.takeException(), isNull);

          if (language == 'ar') {
            expect(
              Directionality.of(tester.element(find.byType(HeroSection))),
              TextDirection.rtl,
            );
          }

          // Scroll the whole page to lay out and paint every section.
          final scroll = tester
              .state<ScrollableState>(find.byType(Scrollable).first)
              .position;
          scroll.jumpTo(scroll.maxScrollExtent);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
