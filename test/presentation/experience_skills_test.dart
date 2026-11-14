import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/presentation/sections/experience_section.dart';
import 'package:portfolio/presentation/sections/skills_section.dart';
import 'package:portfolio/presentation/sections/about_section.dart';
import 'package:portfolio/presentation/widgets/timeline_dot.dart';
import 'package:portfolio/presentation/widgets/glass_card.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'project_page_test.dart' as helpers;
import 'project_video_player_test.dart' show FakeVideoPlatform;

/// Every span of a rich text, however deep they are nested.
List<TextSpan> allSpans(InlineSpan span) => [
  if (span is TextSpan) ...[
    span,
    for (final child in span.children ?? const <InlineSpan>[])
      ...allSpans(child),
  ],
];

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  helpers.content = await const ContentRepository().load();
  setUpAll(
    () => VisibilityDetectorController.instance.updateInterval = Duration.zero,
  );
  setUp(() => VideoPlayerPlatform.instance = FakeVideoPlatform());

  testWidgets('the bullets mark the key number in bold', (tester) async {
    await helpers.pumpPage(
      tester,
      location: '/',
      width: 1440,
      language: 'en',
      reducedMotion: true,
    );
    await tester.scrollUntilVisible(find.byType(ExperienceSection), 500);
    await helpers.frames(tester, 4);

    // The bullet that names the test suite count carries a bold span.
    final bullet = find.textContaining('57 test suites', findRichText: true);
    expect(bullet, findsOneWidget);
    final rich = tester.widget<RichText>(bullet);
    // The markers are gone from the text.
    expect(rich.text.toPlainText(), isNot(contains('**')));
    expect(
      allSpans(rich.text).any(
        (span) =>
            span.text == '57 test suites' &&
            span.style?.fontWeight == FontWeight.w700,
      ),
      isTrue,
    );
    await helpers.unmount(tester);
  });

  testWidgets('each timeline dot carries the company initial', (tester) async {
    await helpers.pumpPage(
      tester,
      location: '/',
      width: 1440,
      language: 'en',
      reducedMotion: true,
    );
    await tester.scrollUntilVisible(find.byType(ExperienceSection), 500);
    await helpers.frames(tester, 4);

    final initials = helpers.content.profile.experience
        .map((entry) => entry.company.substring(0, 1))
        .toList();
    for (final initial in initials) {
      expect(
        find.descendant(
          of: find.byType(TimelineDot),
          matching: find.text(initial),
        ),
        findsOneWidget,
      );
    }
    await helpers.unmount(tester);
  });

  testWidgets('languages move under About summary and education disappears', (
    tester,
  ) async {
    await helpers.pumpPage(
      tester,
      location: '/',
      width: 1440,
      language: 'en',
      reducedMotion: true,
    );
    await tester.scrollUntilVisible(find.byType(AboutSection), 500);
    await helpers.frames(tester, 4);

    expect(
      find.descendant(
        of: find.byType(AboutSection),
        matching: find.text('Languages'),
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.byType(ExperienceSection), 500);
    await helpers.frames(tester, 4);
    expect(find.text('Education'), findsNothing);
    expect(find.text('Certifications'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(ExperienceSection),
        matching: find.text('Languages'),
      ),
      findsNothing,
    );

    // The languages moved out of the skills section.
    await tester.scrollUntilVisible(find.byType(SkillsSection), 500);
    await helpers.frames(tester, 4);
    expect(
      find.descendant(
        of: find.byType(SkillsSection),
        matching: find.text('Languages'),
      ),
      findsNothing,
    );
    await helpers.unmount(tester);
  });

  testWidgets('a skill group shows five chips and expands on demand', (
    tester,
  ) async {
    await helpers.pumpPage(
      tester,
      location: '/',
      width: 1440,
      language: 'en',
      reducedMotion: true,
    );
    await tester.scrollUntilVisible(find.byType(SkillsSection), 500);
    await helpers.frames(tester, 4);

    final group = helpers.content.profile.skillGroups.firstWhere(
      (group) => group.chips.length > 5,
    );
    // The first five chips are there, the sixth is not.
    expect(find.text(group.chips[0]), findsOneWidget);
    expect(find.text(group.chips[4]), findsOneWidget);
    expect(find.text(group.chips[5]), findsNothing);

    await tester.tap(find.text('Show all').first);
    await helpers.frames(tester, 4);
    expect(find.text(group.chips[5]), findsOneWidget);
    await helpers.unmount(tester);
  });

  for (final width in [375.0, 800.0, 1440.0]) {
    testWidgets('skill cards retain grid width at $width px', (tester) async {
      await helpers.pumpPage(
        tester,
        location: '/',
        width: width,
        reducedMotion: true,
      );
      await tester.scrollUntilVisible(find.byType(SkillsSection), 500);
      await helpers.frames(tester, 4);
      final cards = find.descendant(
        of: find.byType(SkillsSection),
        matching: find.byType(GlassCard),
      );
      expect(cards, findsNWidgets(9));
      expect(
        tester.getSize(cards.last).width,
        closeTo(tester.getSize(cards.first).width, 0.01),
      );
      await helpers.unmount(tester);
    });
  }
}
