import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/app.dart';
import 'package:portfolio/core/data/content.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/localization/locale_controller.dart';
import 'package:portfolio/core/theme/app_colors.dart';
import 'package:portfolio/presentation/widgets/nav_menu_sheet.dart';
import 'package:portfolio/core/theme/theme_controller.dart';
import 'package:portfolio/presentation/pages/home_page.dart';
import 'package:portfolio/presentation/pages/not_found_page.dart';
import 'package:portfolio/presentation/pages/project_page.dart';
import 'package:portfolio/presentation/widgets/language_flip.dart';
import 'package:portfolio/presentation/widgets/language_toggle.dart';
import 'package:portfolio/presentation/widgets/theme_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

late SharedPreferences prefs;
late Content content;

/// Pumps [duration] in small steps. The aurora and typewriter never stop, so
/// `pumpAndSettle` would wait forever; this drains frames at a fixed pace.
Future<void> pumpFrames(
  WidgetTester tester, [
  Duration duration = const Duration(milliseconds: 900),
]) async {
  const step = Duration(milliseconds: 50);
  for (var elapsed = Duration.zero; elapsed < duration; elapsed += step) {
    await tester.pump(step);
  }
}

Future<void> pumpApp(WidgetTester tester, {bool reduceMotion = false}) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduceMotion);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  await tester.pumpWidget(
    PortfolioApp(
      content: content,
      themeController: ThemeController(prefs),
      localeController: LocaleController(
        prefs,
        platformLocale: const Locale('en'),
      ),
    ),
  );
  await tester.pump();
  await pumpFrames(tester);
}

TextDirection directionOf(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(HomePage)));

ScrollPosition homeScroll(WidgetTester tester) =>
    tester.state<ScrollableState>(find.byType(Scrollable).first).position;

// The real JSON files load once here, outside every test's fake-async zone.
Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  content = await const ContentRepository().load();

  // Fire visibility callbacks at the end of each frame instead of on a timer.
  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });
  tearDownAll(() {
    VisibilityDetectorController.instance.updateInterval = const Duration(
      milliseconds: 500,
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets(
    'language flip switches to Arabic at the midpoint and keeps scroll',
    (tester) async {
      await pumpApp(tester);
      homeScroll(tester).jumpTo(500);
      await tester.pump();

      await tester.tap(find.byType(LanguageToggle));
      await tester.pump(); // the animation clock starts on this frame
      await tester.pump(const Duration(milliseconds: 150));
      expect(
        directionOf(tester),
        TextDirection.ltr,
        reason: 'still turning away',
      );
      expect(
        tester.state<LanguageFlipState>(find.byType(LanguageFlip)).isFlipping,
        isTrue,
      );

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      expect(
        directionOf(tester),
        TextDirection.rtl,
        reason: 'switched while edge-on',
      );

      await pumpFrames(tester, const Duration(milliseconds: 800));
      expect(
        tester.state<LanguageFlipState>(find.byType(LanguageFlip)).isFlipping,
        isFalse,
      );
      expect(homeScroll(tester).pixels, 500);
      expect(prefs.getString('languageCode'), 'ar');
    },
  );

  testWidgets('taps during the flip are ignored', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byType(LanguageToggle));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byType(LanguageToggle), warnIfMissed: false);
    await pumpFrames(tester, const Duration(milliseconds: 800));
    expect(directionOf(tester), TextDirection.rtl);
  });

  testWidgets('reduced motion: crossfade finishes in about 200 ms', (
    tester,
  ) async {
    await pumpApp(tester, reduceMotion: true);
    await tester.tap(find.byType(LanguageToggle));
    await tester.pump(); // first half starts
    await tester.pump(
      const Duration(milliseconds: 110),
    ); // first half done, locale set
    await tester.pump(); // second half starts
    await tester.pump(const Duration(milliseconds: 110));
    expect(directionOf(tester), TextDirection.rtl);
    expect(
      tester.state<LanguageFlipState>(find.byType(LanguageFlip)).isFlipping,
      isFalse,
    );
  });

  testWidgets('theme toggle flips the theme and remembers it', (tester) async {
    await pumpApp(tester); // test platform brightness is light
    expect(
      Theme.of(tester.element(find.byType(HomePage))).brightness,
      Brightness.light,
    );
    await tester.tap(find.byType(ThemeToggle));
    await pumpFrames(tester, const Duration(milliseconds: 600));
    expect(
      Theme.of(tester.element(find.byType(HomePage))).brightness,
      Brightness.dark,
    );
    expect(prefs.getString('themeMode'), 'dark');
  });

  testWidgets('open menu sheet follows a theme switch', (tester) async {
    await pumpApp(tester, reduceMotion: true);
    tester.view.physicalSize = const Size(375, 812);
    await pumpFrames(tester, const Duration(milliseconds: 500));
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await pumpFrames(tester, const Duration(milliseconds: 500));

    Color sheetColor() => tester
        .widget<Material>(
          find
              .ancestor(
                of: find.byType(NavMenuSheet),
                matching: find.byType(Material),
              )
              .first,
        )
        .color!;
    expect(sheetColor(), AppPalette.light.background);

    await tester.tap(
      find.descendant(
        of: find.byType(NavMenuSheet),
        matching: find.byType(ThemeToggle),
      ),
    );
    await pumpFrames(tester, const Duration(milliseconds: 600));
    expect(sheetColor(), AppPalette.dark.background);
  });

  testWidgets('routes: project page and unknown path', (tester) async {
    await pumpApp(tester, reduceMotion: true);
    final router = GoRouter.of(tester.element(find.byType(HomePage)));

    router.go('/projects/remix');
    await pumpFrames(tester, const Duration(milliseconds: 800));
    expect(find.byType(ProjectPage), findsOneWidget);
    expect(find.text('Remix'), findsWidgets);

    router.go('/nope');
    await pumpFrames(tester, const Duration(milliseconds: 800));
    expect(find.byType(NotFoundPage), findsOneWidget);
  });
}
