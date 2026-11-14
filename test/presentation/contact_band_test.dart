import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/presentation/widgets/contact_band.dart';
import 'package:portfolio/presentation/pages/project_page.dart';
import 'package:portfolio/presentation/widgets/project_platform_gallery.dart';
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

  test('WhatsApp uses international digits from the profile', () {
    expect(phoneDigits(helpers.content.profile.phone!), '201015078567');
  });

  testWidgets('desktop media pins beside facts and omits repeated summary', (
    tester,
  ) async {
    final project = helpers.content.projects.first;
    await helpers.pumpPage(
      tester,
      location: '/projects/${project.slug}',
      reducedMotion: true,
    );
    expect(find.text(project.summary.en), findsNothing);
    expect(find.byKey(const ValueKey('project-quick-facts')), findsOneWidget);
    final gallery = find.byType(ProjectPlatformGallery);
    final scroll = helpers.scrollOf(tester, ProjectPage);
    scroll.jumpTo(160);
    await helpers.frames(tester);
    final top = tester.getTopLeft(gallery).dy;
    scroll.jumpTo(190);
    await helpers.frames(tester);
    expect(tester.getTopLeft(gallery).dy, closeTo(top, 1));
    expect(tester.takeException(), isNull);
    await helpers.unmount(tester);
  });

  testWidgets('every project ends with the shared contact band', (
    tester,
  ) async {
    for (final project in helpers.content.projects) {
      await helpers.pumpPage(
        tester,
        location: '/projects/${project.slug}',
        width: 375,
        reducedMotion: true,
      );
      await helpers.bottom(tester);
      expect(find.byType(ContactBand), findsOneWidget);
      expect(tester.getSize(find.byType(ContactBand)).width, 375 - 48);
      expect(find.text(helpers.content.profile.phone!), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ContactBand),
          matching: find.widgetWithText(OutlinedButton, 'WhatsApp'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await helpers.unmount(tester);
    }
  });
}
