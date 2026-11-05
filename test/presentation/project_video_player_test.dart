import 'dart:async';

import 'package:flutter/material.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/models/project_video.dart';
import 'package:portfolio/core/theme/app_colors.dart';
import 'package:portfolio/presentation/widgets/project_video_player.dart';
import 'package:video_player/video_player.dart' show VideoPlayer;
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Records what the player asks the platform to do; never touches a real video.
class FakeVideoPlatform extends VideoPlayerPlatform {
  bool failCreate = false;
  int created = 0;
  final live = <int>{};
  final calls = <String>[];
  final volumes = <double>[];
  final _events = <int, StreamController<VideoEvent>>{};

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    if (failCreate) throw PlatformException(code: 'load_failed');
    final id = created++;
    live.add(id);
    _events[id] = StreamController<VideoEvent>()
      ..add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: const Duration(seconds: 10),
          size: const Size(9, 16),
        ),
      );
    return id;
  }

  @override
  Future<int?> create(DataSource dataSource) => createWithOptions(
    VideoCreationOptions(
      dataSource: dataSource,
      viewType: VideoViewType.textureView,
    ),
  );

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => _events[playerId]!.stream;

  @override
  Future<void> dispose(int playerId) async => live.remove(playerId);

  @override
  Future<void> play(int playerId) async => calls.add('play');

  @override
  Future<void> pause(int playerId) async => calls.add('pause');

  @override
  Future<void> setVolume(int playerId, double volume) async =>
      volumes.add(volume);

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const SizedBox.expand();

  @override
  Widget buildView(int playerId) => const SizedBox.expand();
}

late FakeVideoPlatform platform;

/// Players stacked below a 1000 px spacer, in an 800 px tall viewport.
Future<ScrollController> pumpPlayers(
  WidgetTester tester, {
  int count = 1,
  bool reduceMotion = false,
  bool lazy = true,
}) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduceMotion);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  final scroll = ScrollController();
  addTearDown(scroll.dispose);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(extensions: const [AppPalette.light]),
      home: (lazy ? ListView.new : _eagerList)(
        controller: scroll,
        children: [
          const SizedBox(height: 1000),
          for (var i = 0; i < count; i++)
            SizedBox(
              height: 600,
              child: ProjectVideoPlayer(
                video: ProjectVideo(
                  src: 'media/v$i/demo.mp4',
                  poster: 'media/v$i/poster.jpg',
                  caption: null,
                ),
                title: 'Video $i',
                accentColor: Colors.purple,
              ),
            ),
          const SizedBox(height: 1000),
        ],
      ),
    ),
  );
  await settle(tester);
  return scroll;
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> scrollTo(
  WidgetTester tester,
  ScrollController scroll,
  double y,
) async {
  scroll.jumpTo(y);
  await settle(tester);
}

/// A non-lazy list: every child stays mounted, however far off screen.
Widget _eagerList({
  ScrollController? controller,
  required List<Widget> children,
}) => SingleChildScrollView(
  controller: controller,
  child: Column(children: children),
);

/// Unmount so every controller (and its position timer) is disposed in-test.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await settle(tester);
  VideoControllerManager.instance.disposeAll();
}

void main() {
  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  setUp(() {
    platform = FakeVideoPlatform();
    VideoPlayerPlatform.instance = platform;
  });

  testWidgets('no controller until visible, then autoplays muted', (
    tester,
  ) async {
    final scroll = await pumpPlayers(tester);
    expect(platform.created, 0);

    await scrollTo(tester, scroll, 800);
    expect(platform.created, 1);
    expect(platform.volumes, contains(0.0));
    expect(platform.calls, contains('play'));
    await unmount(tester);
  });

  testWidgets('pauses when scrolled away', (tester) async {
    final scroll = await pumpPlayers(tester);
    await scrollTo(tester, scroll, 800);
    await scrollTo(tester, scroll, 0);
    expect(platform.calls.last, 'pause');
    await unmount(tester);
  });

  testWidgets(
    'never more than two controllers; an evicted player drops back to its poster',
    (tester) async {
      // Not lazy, so player 0 stays mounted and must be evicted, not unmounted.
      final scroll = await pumpPlayers(tester, count: 3, lazy: false);
      for (final y in [800.0, 1400.0, 2000.0]) {
        await scrollTo(tester, scroll, y);
        // The controller's dispose finishes on a real-time tick, not fake time.
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        expect(platform.live.length, lessThanOrEqualTo(2));
      }
      expect(platform.created, 3);
      expect(VideoControllerManager.instance.controllerCount, 2);
      // Player 0 was evicted: its VideoPlayer is gone, so at most 2 remain.
      expect(
        find.byType(VideoPlayer, skipOffstage: false).evaluate().length,
        lessThanOrEqualTo(2),
      );
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets('a tap unmutes', (tester) async {
    final scroll = await pumpPlayers(tester);
    await scrollTo(tester, scroll, 800);
    await tester.tap(find.byType(ProjectVideoPlayer));
    await settle(tester);
    expect(platform.volumes.last, 1.0);
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a failed video shows the placeholder, not an error', (
    tester,
  ) async {
    platform.failCreate = true;
    final scroll = await pumpPlayers(tester);
    await scrollTo(tester, scroll, 800);
    expect(find.byType(VideoPlayer), findsNothing);
    expect(find.text('Video 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('reduced motion does not autoplay and offers a play button', (
    tester,
  ) async {
    final scroll = await pumpPlayers(tester, reduceMotion: true);
    await scrollTo(tester, scroll, 800);
    expect(platform.created, 1);
    expect(platform.calls, isNot(contains('play')));
    expect(find.byIcon(Icons.play_circle_rounded), findsOneWidget);
    await unmount(tester);
  });
}
