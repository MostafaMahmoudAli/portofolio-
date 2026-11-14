import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app.dart';
import 'package:portfolio/core/data/content.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/localization/locale_controller.dart';
import 'package:portfolio/core/theme/theme_controller.dart';
import 'package:portfolio/presentation/widgets/glass_card.dart';
import 'package:portfolio/presentation/widgets/nav_bar.dart';
import 'package:portfolio/presentation/widgets/phone_frame.dart';
import 'package:portfolio/presentation/widgets/tech_chip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'project_video_player_test.dart' show FakeVideoPlatform;

late Content content;

Future<void> pumpFrames(WidgetTester tester, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> pumpApp(
  WidgetTester tester, {
  Size size = const Size(1440, 900),
  bool arabic = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'languageCode': arabic ? 'ar' : 'en',
  });
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

/// Unmount so video controllers and their timers are gone before the test ends.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await pumpFrames(tester, 2);
}

double centerX(WidgetTester tester, Finder finder) =>
    tester.getCenter(finder).dx;

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  content = await const ContentRepository().load();

  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });
  setUp(() => VideoPlayerPlatform.instance = FakeVideoPlatform());

  for (final width in [375.0, 768.0, 1440.0]) {
    for (final arabic in [false, true]) {
      testWidgets(
        'no layout errors anywhere on the page at $width px, ${arabic ? 'Arabic' : 'English'}',
        (tester) async {
          await pumpApp(tester, size: Size(width, 900), arabic: arabic);
          final scroll = tester
              .state<ScrollableState>(find.byType(Scrollable).first)
              .position;
          for (var y = 0.0; y < scroll.maxScrollExtent + 500; y += 500) {
            scroll.jumpTo(y.clamp(0, scroll.maxScrollExtent));
            await pumpFrames(tester, 4);
            expect(tester.takeException(), isNull, reason: 'at offset $y');
          }
          await unmount(tester);
        },
      );
    }
  }

  for (final arabic in [false, true]) {
    testWidgets(
      'the featured projects are a bento grid${arabic ? ', mirrored in Arabic' : ''}',
      (tester) async {
        await pumpApp(tester, arabic: arabic);
        await tester.ensureVisible(
          find.byType(PhoneFrame, skipOffstage: false).first,
        );
        await pumpFrames(tester);

        final frames = find.byType(PhoneFrame, skipOffstage: false);
        expect(frames.evaluate().length, greaterThanOrEqualTo(5));

        // The first tile is full width; the four small tiles share two columns.
        Finder cardOf(int index) => find
            .ancestor(of: frames.at(index), matching: find.byType(GlassCard))
            .first;
        expect(
          tester.getSize(cardOf(0)).width,
          greaterThan(tester.getSize(cardOf(1)).width),
        );

        final top1 = tester.getTopLeft(frames.at(1));
        final top2 = tester.getTopLeft(frames.at(2));
        final top3 = tester.getTopLeft(frames.at(3));
        // Tiles two and three share the first row, tile four starts the next.
        expect(top1.dy, closeTo(top2.dy, 1));
        expect(top3.dy, greaterThan(top1.dy));
        // And they sit in two columns.
        expect((top1.dx - top2.dx).abs(), greaterThan(100));
        await unmount(tester);
      },
    );
  }

  testWidgets('tech chips hug their label instead of filling the row', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.ensureVisible(
      find.byType(TechChip, skipOffstage: false).first,
    );
    await pumpFrames(tester);
    final chip = find.byType(TechChip).first;
    final label = find.descendant(of:chip,matching:find.byType(Text));
    expect(
      tester.getSize(chip).width,
      closeTo(tester.getSize(label).width + 26, 0.1),
    );
    await unmount(tester);
  });

  testWidgets('store links are grouped under their label', (tester) async {
    await pumpApp(tester);
    await tester.ensureVisible(find.text('Kuwait', skipOffstage: false));
    await pumpFrames(tester);
    // The consulate project is now a small tile: one city pair, all on its page.
    for (final city in ['Kuwait']) {
      expect(find.text(city), findsOneWidget);
    }
    expect(find.text('Google Play'), findsAtLeast(2));
    expect(find.text('App Store'), findsAtLeast(2));
    await unmount(tester);
  });

  testWidgets('the Projects nav link scrolls to the featured header', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(
      find.descendant(of: find.byType(NavBar), matching: find.text('Projects')),
    );
    await pumpFrames(tester, 20);
    final header = find.text('Featured Projects');
    expect(header, findsOneWidget);
    final top = tester.getTopLeft(header).dy;
    expect(top, inInclusiveRange(0, 300));
    await unmount(tester);
  });
}
