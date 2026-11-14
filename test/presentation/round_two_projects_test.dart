import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/presentation/sections/featured_projects.dart';
import 'package:portfolio/presentation/widgets/glass_card.dart';
import 'package:portfolio/presentation/widgets/landscape_project_frame.dart';
import 'package:portfolio/presentation/widgets/phone_frame.dart';
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
}
