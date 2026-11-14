import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app.dart';
import 'package:portfolio/core/data/content.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/localization/locale_controller.dart';
import 'package:portfolio/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

late Content content;

Future<void> pumpFrames(WidgetTester tester, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> pumpApp(
  WidgetTester tester, {
  Size size = const Size(1440, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'languageCode': 'en'});
  final prefs = await SharedPreferences.getInstance();
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
  await pumpFrames(tester);
}

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  content = await const ContentRepository().load();

  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  testWidgets('the more-projects grid shows four cards and expands in place', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.scrollUntilVisible(find.text('Show all'), 400);
    await pumpFrames(tester);

    // Seven small projects, four of them shown first.
    expect(find.text('View on GitHub'), findsNWidgets(3));
    expect(find.text('RehlatiUAE'), findsOneWidget);
    expect(
      find.text('Shipped to Google Play; listing since retired'),
      findsOneWidget,
    );
    // Bring the button to the middle of the viewport, clear of the floating
    // nav bar, then tap it.
    final scroll = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    scroll.jumpTo(
      scroll.pixels + tester.getTopLeft(find.text('Show all')).dy - 400,
    );
    await pumpFrames(tester);
    await tester.tap(find.text('Show all'));
    await pumpFrames(tester, 4);
    expect(tester.takeException(), isNull);
    expect(find.text('View on GitHub'), findsNWidgets(6));
    expect(find.text('Show all'), findsNothing);
  });
}
