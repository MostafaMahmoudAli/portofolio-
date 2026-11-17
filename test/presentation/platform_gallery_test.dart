import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/models/project_videos.dart';
import 'package:portfolio/presentation/pages/project_page.dart';
import 'package:portfolio/presentation/widgets/phone_frame.dart';
import 'package:portfolio/presentation/widgets/project_media_frame.dart';
import 'package:portfolio/presentation/widgets/project_platform_gallery.dart';
import 'package:portfolio/presentation/widgets/project_video_player.dart';
import 'package:portfolio/presentation/widgets/video_platform_picker.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'project_page_test.dart' as helpers;
import 'project_video_player_test.dart' show FakeVideoPlatform;

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  helpers.content = await const ContentRepository().load();
  late FakeVideoPlatform platform;
  setUp(() {
    platform = FakeVideoPlatform();
    VideoPlayerPlatform.instance = platform;
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  for (final language in ['en', 'ar']) {
    testWidgets(
      'desktop side column selects one platform with matching Hero in $language',
      (tester) async {
        final project = helpers.testProject(2);
        await helpers.pumpPage(
          tester,
          location: '/projects/${project.slug}?platform=android',
          language: language,
          data: Content(profile: helpers.content.profile, projects: [project]),
        );
        final gallery = find.byType(ProjectPlatformGallery);
        await tester.ensureVisible(gallery);
        await helpers.frames(tester, 16);
        final frames = find.descendant(
          of: gallery,
          matching: find.byType(ProjectMediaFrame),
        );
        expect(frames, findsOneWidget);
        final list = tester.widgetList<ProjectMediaFrame>(frames).toList();
        expect(list.map((frame) => frame.platform), [VideoPlatform.android]);
        expect(
          list.where((frame) => frame.hero).single.platform,
          VideoPlatform.android,
        );
        expect(find.byType(VideoPlatformPicker), findsOneWidget);
        expect(VideoControllerManager.instance.controllerCount, 1);
        expect(platform.live.length, lessThanOrEqualTo(2));
        expect(tester.takeException(), isNull);
        await helpers.unmount(tester);
      },
    );

    testWidgets(
      '375px toggle switches platform and preserves Hero identity in $language',
      (tester) async {
        final project = helpers.testProject(2);
        await helpers.pumpPage(
          tester,
          location: '/projects/${project.slug}',
          width: 375,
          language: language,
          data: Content(profile: helpers.content.profile, projects: [project]),
        );
        final picker = find.byType(VideoPlatformPicker);
        await Scrollable.ensureVisible(tester.element(picker), alignment: 0.5);
        await helpers.frames(tester);
        await tester.tap(
          find.descendant(of: picker, matching: find.text('Android')),
        );
        await helpers.frames(tester);
        final frame = tester.widget<ProjectMediaFrame>(
          find.descendant(
            of: find.byType(ProjectPlatformGallery),
            matching: find.byType(ProjectMediaFrame),
          ),
        );
        expect(frame.platform, VideoPlatform.android);
        expect(frame.hero, isFalse); // Home's primary frame remains iOS.
        expect(tester.takeException(), isNull);
        await helpers.unmount(tester);
      },
    );
  }

  for (final count in [0, 1]) {
    testWidgets('$count platform has no picker and empty gallery is omitted', (
      tester,
    ) async {
      final project = helpers.testProject(count);
      await helpers.pumpPage(
        tester,
        location: '/projects/${project.slug}',
        width: 375,
        data: Content(profile: helpers.content.profile, projects: [project]),
      );
      expect(find.byType(VideoPlatformPicker), findsNothing);
      expect(
        find.byType(ProjectPlatformGallery),
        count == 0 ? findsNothing : findsOneWidget,
      );
      await helpers.unmount(tester);
    });
  }

  testWidgets('home platform choice travels to the matching page Hero', (
    tester,
  ) async {
    final project = helpers.testProject(2);
    final router = await helpers.pumpPage(
      tester,
      location: '/',
      data: Content(profile: helpers.content.profile, projects: [project]),
    );
    final frame = find.byType(ProjectMediaFrame, skipOffstage: false).first;
    await tester.ensureVisible(frame);
    await helpers.frames(tester);
    final picker = find.byType(VideoPlatformPicker).first;
    await Scrollable.ensureVisible(tester.element(picker), alignment: 0.5);
    await helpers.frames(tester);
    await tester.tap(
      find.descendant(of: picker, matching: find.text('Android')),
    );
    await helpers.frames(tester);
    final slug = project.slug;
    final homeFrame = tester.widget<ProjectMediaFrame>(
      find.byType(ProjectMediaFrame).first,
    );
    expect(homeFrame.platform, VideoPlatform.android);
    // The details action carries the selected platform through the URL.
    final details = find.text('Details').first;
    await Scrollable.ensureVisible(tester.element(details), alignment: 0.5);
    await helpers.frames(tester);
    await tester.tap(details);
    await helpers.frames(tester, 16);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['platform'],
      'android',
    );
    expect(tester.widget<ProjectPage>(find.byType(ProjectPage)).slug, slug);
    final pageFrames = tester.widgetList<ProjectMediaFrame>(
      find.descendant(
        of: find.byType(ProjectPlatformGallery),
        matching: find.byType(ProjectMediaFrame),
      ),
    );
    expect(
      pageFrames.where((frame) => frame.hero).single.platform,
      VideoPlatform.android,
    );
    await helpers.unmount(tester);
  });

  testWidgets('physical cameras and corners do not mirror in RTL', (
    tester,
  ) async {
    for (final direction in TextDirection.values) {
      final project = helpers.testProject(2);
      await helpers.pumpPage(
        tester,
        location: '/projects/${project.slug}',
        data: Content(profile: helpers.content.profile, projects: [project]),
        width: 800,
        language: direction == TextDirection.rtl ? 'ar' : 'en',
      );
      final gallery = find.byType(ProjectPlatformGallery);
      await tester.scrollUntilVisible(gallery, 500);
      await helpers.frames(tester);
      for (final platform in VideoPlatform.values) {
        final phone = find.descendant(
          of: gallery,
          matching: find.byWidgetPredicate(
            (widget) => widget is PhoneFrame && widget.platform == platform,
          ),
        );
        final camera = find.descendant(
          of: phone,
          matching: find.byKey(ValueKey('camera-${platform.name}')),
        );
        expect(
          tester.getCenter(camera).dx,
          closeTo(tester.getCenter(phone).dx, 0.01),
        );
        expect(
          tester.getSize(camera).width,
          platform == VideoPlatform.ios ? 44 : 10,
        );
      }
      await helpers.unmount(tester);
    }
  });
}
