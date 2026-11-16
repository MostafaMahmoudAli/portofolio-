import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/presentation/sections/featured_projects.dart';
import 'package:portfolio/presentation/widgets/glass_card.dart';
import 'package:portfolio/presentation/widgets/landscape_project_frame.dart';
import 'package:portfolio/presentation/widgets/phone_frame.dart';
import 'package:portfolio/presentation/widgets/lazy_project_cover.dart';
import 'package:portfolio/presentation/widgets/project_poster.dart';
import 'package:portfolio/presentation/widgets/project_placeholder.dart';
import 'package:portfolio/presentation/widgets/project_video_player.dart';
import 'package:portfolio/presentation/pages/project_page.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'project_page_test.dart' as helpers;
import 'project_video_player_test.dart' show FakeVideoPlatform;

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  helpers.content = await const ContentRepository().load();
  setUp(() {
    VideoPlayerPlatform.instance = FakeVideoPlatform();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  testWidgets('landscape playback belongs only to the settled current route', (
    tester,
  ) async {
    final router = await helpers.pumpPage(tester, location: '/');
    final frame = find.byType(LandscapeProjectFrame);
    await tester.scrollUntilVisible(frame, 500);
    await Scrollable.ensureVisible(tester.element(frame), alignment: 0.5);
    await helpers.frames(tester);
    Finder players() => find.descendant(
      of: find.byType(LandscapeProjectFrame, skipOffstage: false),
      matching: find.byType(ProjectVideoPlayer, skipOffstage: false),
      skipOffstage: false,
    );
    expect(players(), findsOneWidget);
    router.go('/projects/responsive-dashboard');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(players(), findsNothing);
    await helpers.frames(tester, 16);
    expect(players(), findsOneWidget);
    expect(
      find.byType(LandscapeProjectFrame, skipOffstage: false),
      findsNWidgets(2),
    );
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(players(), findsNothing);
    await helpers.frames(tester, 16);
    expect(players(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await helpers.unmount(tester);
  });

  for (final width in [375.0, 800.0, 1440.0]) {
    testWidgets('last bento tile fills its row with a wide frame at $width', (
      tester,
    ) async {
      await helpers.pumpPage(
        tester,
        location: '/',
        width: width,
        reducedMotion: true,
      );
      await tester.scrollUntilVisible(find.byType(LandscapeProjectFrame), 500);
      await helpers.frames(tester);
      final frame = find.byType(LandscapeProjectFrame);
      final card = find
          .ancestor(of: frame, matching: find.byType(GlassCard))
          .first;
      expect(
        tester.getSize(card).width,
        closeTo(width > 1248 ? 1200 : width - 48, 0.1),
      );
      expect(
        tester.getSize(frame).width,
        greaterThan(tester.getSize(frame).height),
      );
      expect(
        find.ancestor(
          of: frame,
          matching: find.byType(FeaturedProjectsSection),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await helpers.unmount(tester);
    });

    testWidgets('dashboard page uses landscape rather than phone at $width', (
      tester,
    ) async {
      await helpers.pumpPage(
        tester,
        location: '/projects/responsive-dashboard',
        width: width,
        reducedMotion: true,
      );
      expect(find.byType(LandscapeProjectFrame), findsOneWidget);
      expect(find.byType(PhoneFrame), findsNothing);
      final size = tester.getSize(find.byType(LandscapeProjectFrame));
      expect(size.width, greaterThan(size.height));
      expect(tester.takeException(), isNull);
      await helpers.unmount(tester);
    });
  }

  testWidgets(
    'non-featured title and thumbnail open the project with keyboard focus',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await helpers.pumpPage(tester, location: '/', reducedMotion: true);
      final target = find.byKey(const ValueKey('more-open-rick-and-morty-app'));
      await tester.scrollUntilVisible(target, 500);
      await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
      await helpers.frames(tester);
      expect(
        find.bySemanticsLabel('View project: Rick & Morty App'),
        findsOneWidget,
      );
      final ink = tester.widget<InkWell>(target);
      ink.onFocusChange!(true);
      await tester.pump();
      final ring = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('more-focus-rick-and-morty-app')),
      );
      expect(
        (ring.decoration as BoxDecoration).border!.top.color,
        isNot(Colors.transparent),
      );
      Focus.of(
        tester.element(
          find.descendant(of: target, matching: find.byType(Text)).first,
        ),
      ).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await helpers.frames(tester, 16);
      expect(
        tester.widget<ProjectPage>(find.byType(ProjectPage)).slug,
        'rick-and-morty-app',
      );
      semantics.dispose();
      await helpers.unmount(tester);
    },
  );

  testWidgets(
    'cover request starts only when visible and preserves tinted fallback',
    (tester) async {
      await helpers.pumpPage(tester, location: '/', reducedMotion: true);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Image &&
              w.image is NetworkImage &&
              (w.image as NetworkImage).url.endsWith(
                '/rick-and-morty-app/cover.jpg',
              ),
        ),
        findsNothing,
      );
      final cover = find.byWidgetPredicate(
        (w) =>
            w is LazyProjectCover &&
            w.path == 'media/rick-and-morty-app/cover.jpg',
        skipOffstage: false,
      );
      await tester.scrollUntilVisible(cover, 500);
      await Scrollable.ensureVisible(tester.element(cover), alignment: 0.5);
      await helpers.frames(tester, 16);
      final poster = find.descendant(
        of: cover,
        matching: find.byType(ProjectPoster),
      );
      expect(poster, findsOneWidget);
      final image = tester.widget<Image>(
        find.descendant(of: cover, matching: find.byType(Image)),
      );
      expect(
        (image.image as NetworkImage).url,
        Uri.base.resolve('media/rick-and-morty-app/cover.jpg').toString(),
      );
      final context = tester.element(poster);
      const decoded = SizedBox(key: ValueKey('decoded-cover'));
      expect(image.frameBuilder!(context, decoded, 0, true), same(decoded));
      final fallback =
          image.errorBuilder!(context, Exception('missing cover'), null)
              as ProjectPlaceholder;
      expect(
        fallback.accent,
        helpers.content.projects
            .singleWhere((p) => p.slug == 'rick-and-morty-app')
            .accentColor,
      );
      expect(tester.takeException(), isNull);
      await helpers.unmount(tester);
    },
  );
}
