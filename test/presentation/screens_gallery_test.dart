import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/models/localized_text.dart';
import 'package:portfolio/core/models/project_screen.dart';
import 'package:portfolio/core/theme/app_colors.dart';
import 'package:portfolio/core/theme/app_theme.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/presentation/pages/project_page.dart';
import 'package:portfolio/presentation/widgets/project_placeholder.dart';
import 'package:portfolio/presentation/widgets/screens_gallery.dart';
import 'package:portfolio/presentation/widgets/screens_viewer.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'project_page_test.dart' as helpers;
import 'project_video_player_test.dart' show FakeVideoPlatform;

List<ProjectScreen> screens([int count = 8]) => [
  for (var i = 0; i < count; i++)
    ProjectScreen(
      src: 'media/test/screens/$i.jpg',
      caption: i.isEven
          ? LocalizedText(en: 'Screen ${i + 1}', ar: 'الشاشة ${i + 1}')
          : null,
    ),
];

Future<void> pumpGallery(
  WidgetTester tester, {
  double width = 375,
  String language = 'en',
  bool reduced = true,
  int count = 8,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduced);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      theme: AppTheme.build(Brightness.light, Locale(language)),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsetsDirectional.all(24),
              sliver: SliverToBoxAdapter(
                child: ScreensGallery(screens: screens(count)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await helpers.frames(tester);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    await helpers.frames(tester, 2);
  });
}

Future<void> open(WidgetTester tester, int index) async {
  final thumb = find.byKey(ValueKey('screen-thumbnail-$index'));
  await tester.ensureVisible(thumb);
  await helpers.frames(tester, 2);
  await tester.tap(thumb);
  await helpers.frames(tester);
}

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  helpers.content = await const ContentRepository().load();
  setUp(() {
    VideoPlayerPlatform.instance = FakeVideoPlatform();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  testWidgets('non-featured project shows two screens and opens the second', (
    tester,
  ) async {
    final project = helpers.testProject(
      0,
      featured: false,
      screens: screens(2),
    );
    await helpers.pumpPage(
      tester,
      location: '/projects/${project.slug}',
      data: Content(profile: helpers.content.profile, projects: [
        helpers.content.projects.first,
        project,
      ]),
      reducedMotion: true,
    );
    await tester.ensureVisible(find.byType(ScreensGallery));
    await open(tester, 1);
    expect(find.byType(ScreensViewer), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await helpers.unmount(tester);
  });

  testWidgets(
    'third thumbnail opens at 3, missing image falls back, X restores focus',
    (tester) async {
      await pumpGallery(tester);
      final thumb = find.byKey(const ValueKey('screen-thumbnail-2'));
      final ink = tester.widget<InkWell>(
        find.descendant(of: thumb, matching: find.byType(InkWell)),
      );
      await open(tester, 2);
      expect(find.text('3 / 8'), findsOneWidget);
      expect(find.text('Screen 3'), findsOneWidget);
      expect(
        FocusManager.instance.primaryFocus!.debugLabel,
        'Screenshot viewer',
      );
      expect(
        find.descendant(
          of: find.byType(ScreensViewer),
          matching: find.byType(ProjectPlaceholder),
        ),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('close-screens')));
      await helpers.frames(tester);
      expect(find.byType(ScreensViewer), findsNothing);
      expect(ink.focusNode!.hasFocus, isTrue);
    },
  );

  for (final language in ['en', 'ar']) {
    testWidgets(
      'swipes, arrows, keyboard and semantics follow $language reading direction',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await pumpGallery(tester, language: language);
          await open(tester, 2);
          final l10n = AppLocalizations.of(
            tester.element(find.byType(ScreensViewer)),
          );
          expect(
            find.descendant(
              of: find.byType(ScreensViewer),
              matching: find.bySemanticsLabel(l10n.screenshotOf(3, 8)),
            ),
            findsOneWidget,
          );
          final rtl = language == 'ar';
          final prevX = tester
              .getCenter(find.byKey(const ValueKey('previous-screen')))
              .dx;
          final nextX = tester
              .getCenter(find.byKey(const ValueKey('next-screen')))
              .dx;
          expect(prevX < nextX, !rtl);
          await tester.drag(
            find.byKey(const ValueKey('screens-pages')),
            Offset(rtl ? 300 : -300, 0),
          );
          await helpers.frames(tester, 16);
          expect(find.text('4 / 8'), findsOneWidget);
          await tester.sendKeyEvent(
            rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft,
          );
          await helpers.frames(tester);
          expect(find.text('3 / 8'), findsOneWidget);
          await tester.sendKeyEvent(
            rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight,
          );
          await helpers.frames(tester);
          expect(find.text('4 / 8'), findsOneWidget);
          await tester.tap(find.byKey(const ValueKey('previous-screen')));
          await helpers.frames(tester);
          expect(find.text('3 / 8'), findsOneWidget);
          await tester.tap(find.byKey(const ValueKey('next-screen')));
          await helpers.frames(tester);
          expect(find.text('4 / 8'), findsOneWidget);
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await helpers.frames(tester);
          expect(find.byType(ScreensViewer), findsNothing);
        } finally {
          semantics.dispose();
        }
      },
    );

    testWidgets('arrows disappear at both ends in $language', (tester) async {
      await pumpGallery(tester, language: language);
      await open(tester, 0);
      expect(find.byKey(const ValueKey('previous-screen')), findsNothing);
      for (var i = 0; i < 7; i++) {
        await tester.sendKeyEvent(
          language == 'ar'
              ? LogicalKeyboardKey.arrowLeft
              : LogicalKeyboardKey.arrowRight,
        );
        await helpers.frames(tester, 2);
      }
      expect(find.text('8 / 8'), findsOneWidget);
      expect(find.byKey(const ValueKey('next-screen')), findsNothing);
      expect(find.byKey(const ValueKey('previous-screen')), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await helpers.frames(tester);
    });
  }

  testWidgets('browser/system Back closes the dialog, not the project', (
    tester,
  ) async {
    await pumpGallery(tester);
    await open(tester, 0);
    await tester.binding.handlePopRoute();
    await helpers.frames(tester);
    expect(find.byType(ScreensViewer), findsNothing);
    expect(find.byType(ScreensGallery), findsOneWidget);
  });

  for (final reduced in [false, true]) {
    testWidgets('viewer fade duration respects reduced motion $reduced', (
      tester,
    ) async {
      await pumpGallery(tester, reduced: reduced);
      await open(tester, 0);
      final route = ModalRoute.of(tester.element(find.byType(ScreensViewer)))!;
      expect(
        route.transitionDuration,
        reduced ? Duration.zero : const Duration(milliseconds: 200),
      );
      expect(route.reverseTransitionDuration, route.transitionDuration);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await helpers.frames(tester);
    });
  }

  testWidgets('thumbnail list is lazy, phone-shaped and mouse-draggable', (
    tester,
  ) async {
    await pumpGallery(tester, count: 1000);
    expect(
      find.byType(Image, skipOffstage: false).evaluate().length,
      lessThan(20),
    );
    final thumb = find.byKey(const ValueKey('screen-thumbnail-0'));
    final size = tester.getSize(thumb);
    expect(size.width / size.height, closeTo(9 / 19.5, 0.001));
    final list = find.byKey(const ValueKey('screen-thumbnails'));
    final scroll = tester.widget<ListView>(list).controller!;
    final mouse = await tester.startGesture(
      tester.getCenter(list),
      kind: PointerDeviceKind.mouse,
    );
    await mouse.moveBy(const Offset(-30, 0));
    await helpers.frames(tester, 2);
    await mouse.moveBy(const Offset(-190, 0));
    await mouse.up();
    await helpers.frames(tester);
    expect(scroll.offset, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('thumbnail hover and keyboard focus use accent ink', (
    tester,
  ) async {
    await pumpGallery(tester);
    final thumb = find.byKey(const ValueKey('screen-thumbnail-0'));
    Color border() =>
        (tester
                    .widget<DecoratedBox>(
                      find
                          .descendant(
                            of: thumb,
                            matching: find.byWidgetPredicate(
                              (widget) =>
                                  widget is DecoratedBox &&
                                  widget.decoration is BoxDecoration &&
                                  (widget.decoration as BoxDecoration).border !=
                                      null,
                            ),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration)
            .border!
            .top
            .color;
    expect(border(), AppPalette.light.surfaceBorder);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(thumb));
    await helpers.frames(tester, 2);
    expect(border(), AppPalette.light.accentInk);
    await mouse.removePointer();
    await helpers.frames(tester, 2);
    final focus = tester
        .widget<InkWell>(
          find.descendant(of: thumb, matching: find.byType(InkWell)),
        )
        .focusNode!;
    focus.requestFocus();
    await helpers.frames(tester, 2);
    expect(border(), AppPalette.light.accentInk);
  });

  for (final width in [375.0, 768.0, 1440.0]) {
    for (final language in ['en', 'ar']) {
      testWidgets('project screens and viewer fit $width in $language', (
        tester,
      ) async {
        final project = helpers.testProject(2, screens: screens());
        await helpers.pumpPage(
          tester,
          location: '/projects/${project.slug}',
          width: width,
          language: language,
          reducedMotion: true,
          data: Content(profile: helpers.content.profile, projects: [project]),
        );
        final gallery = find.byType(ScreensGallery);
        final scroll = helpers.scrollOf(tester, ProjectPage);
        for (var pass = 0; pass < 30 && gallery.evaluate().isEmpty; pass++) {
          scroll.jumpTo((scroll.pixels + 400).clamp(0, scroll.maxScrollExtent));
          await helpers.frames(tester, 2);
        }
        await Scrollable.ensureVisible(tester.element(gallery), alignment: 0.5);
        await helpers.frames(tester);
        expect(tester.takeException(), isNull);
        await open(tester, 2);
        expect(find.text('3 / 8'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const ValueKey('close-screens')));
        await helpers.frames(tester);
        await helpers.unmount(tester);
      });
    }
  }

  testWidgets('empty project screens omit the entire section', (tester) async {
    await helpers.pumpPage(tester);
    expect(find.byType(ScreensGallery), findsNothing);
    await helpers.unmount(tester);
  });
}
