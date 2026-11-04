import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app.dart';
import 'package:portfolio/core/data/content.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/localization/locale_controller.dart';
import 'package:portfolio/core/theme/theme_controller.dart';
import 'package:portfolio/presentation/sections/about_section.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

late Content content;

Future<void> pumpHome(
  WidgetTester tester, {
  Size size = const Size(1440, 900),
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
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

Future<void> scrollToAbout(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(AboutSection));
  await tester.pumpAndSettle();
}

void main() async {
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

  testWidgets('about renders in Arabic, right to left', (tester) async {
    await pumpHome(tester, locale: const Locale('ar'));
    await scrollToAbout(tester);

    expect(
      Directionality.of(tester.element(find.byType(AboutSection))),
      TextDirection.rtl,
    );
    expect(
      find.text(content.profile.summary.of(const Locale('ar'))),
      findsOneWidget,
    );
    expect(find.text('المعمارية النظيفة'), findsOneWidget);
    expect(find.text('إصدارات المتاجر'), findsOneWidget);
    expect(find.text('الوسائط وFFmpeg'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet and desktop place the three tiles in one row', (
    tester,
  ) async {
    await pumpHome(tester, size: const Size(768, 900));
    await scrollToAbout(tester);

    final titles = ['Clean Architecture', 'Store releases', 'Media & FFmpeg'];
    final tops = [
      for (final title in titles) tester.getTopLeft(find.text(title)).dy,
    ];
    expect(tops.toSet(), hasLength(1), reason: 'one row at 768 px');
  });

  testWidgets('phones stack the tiles', (tester) async {
    await pumpHome(tester, size: const Size(375, 812));
    await scrollToAbout(tester);

    final titles = ['Clean Architecture', 'Store releases', 'Media & FFmpeg'];
    final tops = [
      for (final title in titles) tester.getTopLeft(find.text(title)).dy,
    ];
    expect(tops[0], lessThan(tops[1]));
    expect(tops[1], lessThan(tops[2]));
    expect(tester.takeException(), isNull);
  });
}
