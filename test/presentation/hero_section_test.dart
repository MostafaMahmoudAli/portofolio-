import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app.dart';
import 'package:portfolio/core/data/content.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/localization/locale_controller.dart';
import 'package:portfolio/core/theme/theme_controller.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/presentation/sections/hero_section.dart';
import 'package:portfolio/presentation/widgets/animated_counter.dart';
import 'package:portfolio/presentation/widgets/brand_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

late Content content;

/// Pumps [duration] in small steps: with motion enabled the aurora and the
/// typewriter never stop, so `pumpAndSettle` would wait forever.
Future<void> pumpFrames(
  WidgetTester tester, [
  Duration duration = const Duration(milliseconds: 900),
]) async {
  const step = Duration(milliseconds: 50);
  for (var elapsed = Duration.zero; elapsed < duration; elapsed += step) {
    await tester.pump(step);
  }
}

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
  if (reduceMotion) {
    await tester.pumpAndSettle();
  } else {
    await pumpFrames(tester);
  }
}

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  content = await const ContentRepository().load();

  setUpAll(() async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    // Measure the real typography, not Ahm's artificially wide test glyphs.
    for (final (family, file) in [
      ('Inter', 'Inter-Regular.ttf'),
      ('SpaceGrotesk', 'SpaceGrotesk-Bold.ttf'),
      ('IBMPlexSansArabic', 'IBMPlexSansArabic-Regular.ttf'),
      ('Tajawal', 'Tajawal-Bold.ttf'),
    ]) {
      await (FontLoader(
        family,
      )..addFont(rootBundle.load('assets/fonts/$file'))).load();
    }
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

    expect(find.text(profile.name.of(const Locale('en'))), findsOneWidget);
    expect(find.text(l10n.heroRoleMobile), findsOneWidget);
    // The role appears once: the typewriter replaces the static title line.
    expect(find.text(profile.title.of(const Locale('en'))), findsNothing);
    expect(find.text('View projects'), findsOneWidget);
    expect(find.text('Download resume'), findsOneWidget);
    // The three secondary links are icon-only, labelled by their tooltip.
    expect(find.byTooltip('GitHub'), findsOneWidget);
    expect(find.byTooltip('LinkedIn'), findsOneWidget);
    expect(find.byTooltip('Email'), findsOneWidget);
    // The social buttons carry the real brand marks.
    expect(find.byType(BrandIcon), findsNWidgets(2));

    // Final counter values, no count-up and no entrance animation in flight.
    expect(find.text('3+'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('310K+'), findsOneWidget);
    expect(find.text('57'), findsOneWidget);
    expect(find.byType(Animate), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('counters keep their value across the 600 px breakpoint', (
    tester,
  ) async {
    await pumpHome(tester, size: const Size(375, 812), reduceMotion: false);

    // On a phone the stats are below the fold, so bring them into view first.
    await tester.ensureVisible(find.byType(AnimatedCounter).last);
    await tester.pump();
    await pumpFrames(tester, const Duration(milliseconds: 2000));
    expect(find.text('310K+'), findsOneWidget);

    // Crossing the breakpoint swaps Column for Row. If the subtree were
    // rebuilt, the counters would restart from zero.
    tester.view.physicalSize = const Size(1440, 900);
    await tester.pump();
    await pumpFrames(tester, const Duration(milliseconds: 300));

    // The hero may now sit above the viewport (offstage sliver); check it anyway.
    expect(find.text('310K+', skipOffstage: false), findsOneWidget);
    expect(find.text('0K+', skipOffstage: false), findsNothing);
  });

  testWidgets('the phone first screen carries the name, role and stats', (
    tester,
  ) async {
    await pumpHome(tester, size: const Size(375, 812));

    // Name, both buttons and the whole stats band have to fit above the fold.
    final name = find.text(content.profile.name.of(const Locale('en')));
    final buttons = find.text('View projects');
    final lastStat = find.byType(AnimatedCounter).last;
    expect(tester.getBottomLeft(name).dy, lessThan(812));
    expect(tester.getBottomLeft(buttons).dy, lessThan(812));
    expect(tester.getBottomLeft(lastStat).dy, lessThan(812));
    expect(tester.takeException(), isNull);
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
