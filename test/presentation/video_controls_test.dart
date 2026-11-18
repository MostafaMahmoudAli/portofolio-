import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/models/project_video.dart';
import 'package:portfolio/core/theme/app_theme.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/presentation/widgets/project_video_controls.dart';
import 'package:portfolio/presentation/widgets/project_video_player.dart';
import 'package:video_player/video_player.dart' show VideoPlayer;
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'project_video_player_test.dart' show FakeVideoPlatform;
import 'project_page_test.dart' show frames;

late FakeVideoPlatform platform;

Future<void> pumpPlayer(
  WidgetTester tester, {
  double width = 300,
  String language = 'en',
  bool reduced = true,
  Brightness brightness = Brightness.light,
}) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduced);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.build(brightness, Locale(language)),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            height: 400,
            child: const ProjectVideoPlayer(
              video: ProjectVideo(
                src: 'media/test/android.mp4',
                poster: 'media/test/android.jpg',
                caption: null,
              ),
              title: 'Demo',
            ),
          ),
        ),
      ),
    ),
  );
  await frames(tester);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    await frames(tester, 2);
    VideoControllerManager.instance.disposeAll();
  });
}

void main() {
  setUp(() {
    platform = FakeVideoPlatform()..duration = const Duration(seconds: 45);
    VideoPlayerPlatform.instance = platform;
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  test('Western clocks support minutes and hours', () {
    expect(formatVideoTime(const Duration(seconds: 5)), '0:05');
    expect(
      formatVideoTime(const Duration(hours: 1, minutes: 2, seconds: 3)),
      '1:02:03',
    );
  });

  testWidgets('play pause and mute call platform', (tester) async {
    await pumpPlayer(tester);
    expect(platform.calls, isNot(contains('play')));
    await tester.tap(find.byTooltip('Play video'));
    await frames(tester, 2);
    expect(platform.calls.last, 'play');
    await tester.tap(find.byTooltip('Pause video'));
    await frames(tester, 2);
    expect(platform.calls.last, 'pause');
    await tester.tap(find.byTooltip('Unmute video'));
    await frames(tester, 2);
    expect(platform.volumes.last, 1);
  });

  testWidgets('five-second seeks clamp at both ends', (tester) async {
    await pumpPlayer(tester);
    final controller = VideoControllerManager.instance.controllerFor(
      'media/test/android.mp4',
    )!;
    await controller.seekTo(const Duration(seconds: 12));
    await frames(tester, 2);
    platform.seeks.clear();
    await tester.tap(find.byTooltip('Forward 5 seconds'));
    await frames(tester, 2);
    expect(platform.seeks.last.$2, const Duration(seconds: 17));
    await tester.tap(find.byTooltip('Back 5 seconds'));
    await frames(tester, 2);
    expect(platform.seeks.last.$2, const Duration(seconds: 12));
    await controller.seekTo(const Duration(seconds: 2));
    await tester.tap(find.byTooltip('Back 5 seconds'));
    await frames(tester, 2);
    expect(platform.seeks.last.$2, Duration.zero);
    await controller.seekTo(const Duration(seconds: 43));
    await tester.tap(find.byTooltip('Forward 5 seconds'));
    await frames(tester, 2);
    expect(platform.seeks.last.$2, const Duration(seconds: 45));
  });

  testWidgets(
    'drag labels update without seeking until release, then seek once',
    (tester) async {
      await pumpPlayer(tester, reduced: false);
      final slider = find.byKey(const ValueKey('video-position'));
      platform.seeks.clear();
      final rect = tester.getRect(slider);
      final gesture = await tester.startGesture(
        Offset(rect.left + rect.width * 0.3, rect.center.dy),
      );
      await gesture.moveBy(const Offset(35, 0));
      await frames(tester, 2);
      expect(platform.seeks, isEmpty);
      final dragged = tester.widget<Slider>(slider).value;
      expect(dragged, greaterThan(0));
      platform.reportPosition(const Duration(seconds: 2));
      await frames(tester, 6);
      expect(tester.widget<Slider>(slider).value, dragged);
      expect(platform.seeks, isEmpty);
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('video-current-time')))
            .data,
        formatVideoTime(Duration(milliseconds: dragged.round())),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(
        location: tester.getCenter(find.byType(ProjectVideoControls)),
      );
      await mouse.moveTo(Offset.zero);
      await tester.pump(const Duration(seconds: 2));
      expect(
        tester
            .widget<AnimatedOpacity>(
              find.byKey(const ValueKey('video-controls-bar')),
            )
            .opacity,
        1,
      );
      await mouse.removePointer();
      await gesture.up();
      await frames(tester, 2);
      expect(platform.seeks, hasLength(1));
      expect(platform.seeks.single.$2, Duration(milliseconds: dragged.round()));
    },
  );

  for (final exit in [true, false]) {
    testWidgets(
      'paused drag ${exit ? 'hides after a mouse exit' : 'keeps controls without one'}',
      (tester) async {
        await pumpPlayer(tester);
        double opacity() => tester
            .widget<AnimatedOpacity>(
              find.byKey(const ValueKey('video-controls-bar')),
            )
            .opacity;
        final rect = tester.getRect(
          find.byKey(const ValueKey('video-position')),
        );
        final gesture = await tester.startGesture(
          Offset(rect.left + rect.width * 0.3, rect.center.dy),
        );
        await gesture.moveBy(const Offset(35, 0));
        await frames(tester, 2);
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(
          location: tester.getCenter(find.byType(ProjectVideoControls)),
        );
        if (exit) await mouse.moveTo(Offset.zero);
        await frames(tester, 2);
        expect(opacity(), 1);
        await gesture.up();
        await frames(tester, 2);
        expect(opacity(), exit ? 0 : 1);
        await mouse.removePointer();
      },
    );
  }

  testWidgets('position ticks update labels live', (tester) async {
    await pumpPlayer(tester, reduced: false);
    platform.reportPosition(const Duration(seconds: 12));
    await frames(tester, 6);
    expect(find.text('0:12'), findsOneWidget);
  });

  testWidgets('poster and video contain their natural shape on black', (
    tester,
  ) async {
    await pumpPlayer(tester, reduced: false);
    final poster = tester.widget<Image>(
      find.descendant(
        of: find.byType(ProjectVideoPlayer),
        matching: find.byType(Image),
      ),
    );
    expect(poster.fit, BoxFit.contain);
    final video = find.byType(VideoPlayer);
    final fitted = find.ancestor(of: video, matching: find.byType(FittedBox));
    expect(tester.widget<FittedBox>(fitted).fit, BoxFit.contain);
    final controller = VideoControllerManager.instance.controllerFor(
      'media/test/android.mp4',
    )!;
    expect(tester.getSize(video), controller.value.size);
    for (final media in [video, find.byWidget(poster)]) {
      final background = find.ancestor(
        of: media,
        matching: find.byType(ColoredBox),
      );
      expect(tester.widget<ColoredBox>(background.first).color, Colors.black);
    }
  });

  testWidgets(
    'controls hide after 1s or mouse exit and stay paused while hovered',
    (tester) async {
      await pumpPlayer(tester, reduced: false);
      double opacity() => tester
          .widget<AnimatedOpacity>(
            find.byKey(const ValueKey('video-controls-bar')),
          )
          .opacity;
      // Start the idle interval from a known interaction.
      await tester.tapAt(tester.getCenter(find.byType(ProjectVideoControls)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      expect(opacity(), 1);
      await tester.pump(const Duration(milliseconds: 101));
      expect(opacity(), 0);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byType(ProjectVideoControls)));
      await frames(tester, 2);
      expect(opacity(), 1);
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(opacity(), 0);
      await mouse.moveTo(tester.getCenter(find.byType(ProjectVideoControls)));
      await tester.pump();
      expect(opacity(), 1);
      await tester.tap(find.byTooltip('Pause video'));
      await frames(tester, 2);
      await tester.pump(const Duration(seconds: 4));
      expect(opacity(), 1);
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(opacity(), 0);
      await tester.tapAt(tester.getCenter(find.byType(ProjectVideoControls)));
      await tester.pump();
      expect(opacity(), 1);
      await mouse.removePointer();
    },
  );

  testWidgets('Space and arrows control the focused player', (tester) async {
    await pumpPlayer(tester);
    await tester.tapAt(
      tester.getCenter(find.byType(ProjectVideoControls)) - const Offset(0, 70),
    );
    await frames(tester, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await frames(tester, 2);
    expect(platform.calls.last, 'play');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await frames(tester, 2);
    expect(platform.seeks.last.$2, const Duration(seconds: 5));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await frames(tester, 2);
    expect(platform.seeks.last.$2, Duration.zero);
  });

  for (final brightness in Brightness.values) {
    testWidgets('transparent controls stay white in $brightness', (
      tester,
    ) async {
      await pumpPlayer(tester, brightness: brightness);
      final controls = find.byType(ProjectVideoControls);
      final material = find.descendant(
        of: controls,
        matching: find.byType(Material),
      );
      expect(tester.widget<Material>(material.first).color, Colors.transparent);
      for (final icon in tester.widgetList<Icon>(
        find.descendant(of: controls, matching: find.byType(Icon)),
      )) {
        expect(icon.color, Colors.white);
        expect(icon.shadows, isNotEmpty);
      }
      final text = tester.widget<Text>(
        find.byKey(const ValueKey('video-current-time')),
      );
      expect(text.style!.color, Colors.white);
      expect(text.style!.shadows, isNotEmpty);
      final slider = tester.widget<SliderTheme>(
        find.descendant(of: controls, matching: find.byType(SliderTheme)),
      );
      expect(slider.data.thumbColor, Colors.white);
      expect(slider.data.activeTrackColor, Colors.white);
      expect(
        slider.data.inactiveTrackColor,
        Colors.white.withValues(alpha: 0.4),
      );
    });
  }

  for (final language in ['en', 'ar']) {
    testWidgets(
      '200px controls fit, use LTR order and 48px targets in $language',
      (tester) async {
        await pumpPlayer(tester, width: 200, language: language);
        expect(find.byKey(const ValueKey('video-current-time')), findsNothing);
        final buttons = find.descendant(
          of: find.byType(ProjectVideoControls),
          matching: find.byType(IconButton),
        );
        for (final button in buttons.evaluate()) {
          final size = tester.getSize(find.byWidget(button.widget));
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));
        }
        expect(
          tester.getTopLeft(find.byIcon(Icons.replay_5)).dx,
          lessThan(tester.getTopLeft(find.byIcon(Icons.forward_5)).dx),
        );
        expect(
          Directionality.of(
            tester.element(find.byKey(const ValueKey('video-position'))),
          ),
          TextDirection.ltr,
        );
        expect(
          tester
              .widget<AnimatedOpacity>(
                find.byKey(const ValueKey('video-controls-bar')),
              )
              .duration,
          Duration.zero,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('hour labels remain Western in Arabic', (tester) async {
    platform.duration = const Duration(hours: 1, minutes: 2, seconds: 3);
    await pumpPlayer(tester, language: 'ar');
    expect(find.text('1:02:03'), findsOneWidget);
  });
}
