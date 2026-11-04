import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app.dart';
import 'package:portfolio/core/data/content.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/localization/locale_controller.dart';
import 'package:portfolio/core/theme/theme_controller.dart';
import 'package:portfolio/presentation/widgets/nav_bar.dart';
import 'package:portfolio/presentation/widgets/nav_menu_sheet.dart';
import 'package:portfolio/presentation/widgets/section_title.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

late SharedPreferences prefs;
late Content content;

Future<void> pumpApp(
  WidgetTester tester, {
  Size size = const Size(1440, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // These tests care about layout and scrolling, not motion.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
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
  await tester.pumpAndSettle();
}

ScrollPosition homeScroll(WidgetTester tester) =>
    tester.state<ScrollableState>(find.byType(Scrollable).first).position;

// Section titles on the page share these labels, so finders stay inside the nav bar.
Finder navText(String label) =>
    find.descendant(of: find.byType(NavBar), matching: find.text(label));

// Reads the real JSON files once, outside every test's fake-async zone.
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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('desktop: nav links are shown and scroll to their section', (
    tester,
  ) async {
    await pumpApp(tester);
    for (final label in [
      'About',
      'Projects',
      'Experience',
      'Skills',
      'Contact',
    ]) {
      expect(navText(label), findsOneWidget);
    }
    // Content box is 1200 wide centered in 1440, so the start edge is at 120 (+24 padding outside it).
    expect(
      tester
          .getTopLeft(find.byType(SectionTitle, skipOffstage: false).first)
          .dx,
      lessThanOrEqualTo(145),
    );

    await tester.tap(navText('Skills'));
    await tester.pumpAndSettle();
    expect(homeScroll(tester).pixels, greaterThan(0));
  });

  testWidgets('phone: links live in the menu sheet, which closes and scrolls', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(375, 812));
    expect(navText('About'), findsNothing);

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    final aboutInSheet = find.descendant(
      of: find.byType(NavMenuSheet),
      matching: find.text('About'),
    );
    expect(aboutInSheet, findsOneWidget);

    await tester.tap(aboutInSheet);
    await tester.pumpAndSettle();
    expect(find.byType(NavMenuSheet), findsNothing);
    expect(homeScroll(tester).pixels, greaterThan(0));
  });

  testWidgets('arabic: labels are Arabic and the layout is right-to-left', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'languageCode': 'ar'});
    prefs = await SharedPreferences.getInstance();

    await pumpApp(tester);
    expect(navText('نبذة'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(NavBar))),
      TextDirection.rtl,
    );
  });
}
