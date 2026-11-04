import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/theme/app_colors.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/presentation/pages/home_page.dart';
import 'package:portfolio/presentation/sections/contact_section.dart';
import 'package:portfolio/presentation/sections/experience_section.dart';
import 'package:portfolio/presentation/sections/footer_section.dart';
import 'package:portfolio/presentation/sections/skills_section.dart';
import 'package:portfolio/presentation/widgets/nav_bar.dart';
import 'package:portfolio/presentation/widgets/nav_menu_sheet.dart';
import 'package:portfolio/presentation/widgets/project_placeholder.dart';
import 'package:portfolio/presentation/widgets/skills_marquee.dart';
import 'package:portfolio/presentation/widgets/timeline_dot.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'project_page_test.dart' as helpers;
import 'project_video_player_test.dart' show FakeVideoPlatform;

Future<void> navigate(
  WidgetTester tester,
  String label, {
  bool phone = false,
}) async {
  if (phone) {
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await helpers.frames(tester);
  }
  await tester.tap(
    find.descendant(
      of: find.byType(phone ? NavMenuSheet : NavBar),
      matching: find.text(label),
    ),
  );
  await helpers.frames(tester, 32);
}

double lineHeight(WidgetTester tester) =>
    tester.getSize(find.byKey(const ValueKey('timeline-line'))).height;
double translation(WidgetTester tester) => tester
    .widget<Transform>(
      find.byKey(const ValueKey('marquee-translation'), skipOffstage: false),
    )
    .transform
    .storage[12];
double dotScale(WidgetTester tester, Finder dot) => tester
    .widget<AnimatedScale>(
      find.descendant(of: dot, matching: find.byType(AnimatedScale)),
    )
    .scale;

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  helpers.content = await const ContentRepository().load();
  setUpAll(
    () => VisibilityDetectorController.instance.updateInterval = Duration.zero,
  );
  setUp(() => VideoPlayerPlatform.instance = FakeVideoPlatform());

  for (final language in ['en', 'ar']) {
    testWidgets(
      'timeline scroll growth, one-shot dots and start side in $language',
      (tester) async {
        await helpers.pumpPage(tester, location: '/', language: language);
        final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
        await navigate(tester, l10n.navExperience);
        final scroll = helpers.scrollOf(tester, HomePage);
        final initial = lineHeight(tester);
        final lineX = tester
            .getCenter(find.byKey(const ValueKey('timeline-line')))
            .dx;
        final sectionX = tester.getCenter(find.byType(ExperienceSection)).dx;
        expect(language == 'ar' ? lineX > sectionX : lineX < sectionX, isTrue);
        final dots = find.byType(TimelineDot);
        expect(dotScale(tester, dots.first), 1);
        final start = scroll.pixels;
        scroll.jumpTo(start + 350);
        await helpers.frames(tester);
        expect(lineHeight(tester), greaterThan(initial));
        final grown = lineHeight(tester);
        await helpers.frames(tester, 16);
        expect(
          lineHeight(tester),
          grown,
          reason: 'scroll-driven, not time-driven',
        );
        for (var i = 0; i < helpers.content.profile.experience.length; i++) {
          await tester.ensureVisible(dots.at(i));
          await helpers.frames(tester);
          expect(dotScale(tester, dots.at(i)), 1);
        }
        scroll.jumpTo(0);
        await helpers.frames(tester);
        scroll.jumpTo(start);
        await tester.pump();
        for (final dot in dots.evaluate()) {
          expect(dotScale(tester, find.byWidget(dot.widget)), 1);
        }
        await helpers.unmount(tester);
      },
    );

    testWidgets(
      'marquee moves in reading direction and pauses offscreen in $language',
      (tester) async {
        await helpers.pumpPage(tester, location: '/', language: language);
        final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
        await navigate(tester, l10n.navSkills);
        final before = translation(tester);
        await helpers.frames(tester);
        expect(
          translation(tester),
          language == 'ar' ? greaterThan(before) : lessThan(before),
        );
        final scroll = helpers.scrollOf(tester, HomePage);
        scroll.jumpTo(0);
        await helpers.frames(tester, 2);
        final paused = translation(tester);
        await helpers.frames(tester, 20);
        expect(translation(tester), paused);
        await helpers.unmount(tester);
      },
    );

    testWidgets('copy email and localized footer in $language', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await helpers.pumpPage(tester, location: '/', language: language);
      final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
      await navigate(tester, l10n.navContact);
      await tester.tap(find.byTooltip(l10n.copyEmail));
      await helpers.frames(tester);
      expect(copied, helpers.content.profile.email);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text(l10n.emailCopied),
        ),
        findsOneWidget,
      );
      await tester.ensureVisible(find.byType(FooterSection));
      await helpers.frames(tester);
      expect(find.text(l10n.footerCredit(DateTime.now().year)), findsOneWidget);
      await tester.tap(find.text(l10n.backToTop));
      await helpers.frames(tester, 16);
      expect(helpers.scrollOf(tester, HomePage).pixels, 0);
      await helpers.unmount(tester);
    });
  }

  testWidgets('reduced motion draws full timeline and static wrapping skills', (
    tester,
  ) async {
    await helpers.pumpPage(tester, location: '/', reducedMotion: true);
    await navigate(tester, 'Experience');
    final line = find.byKey(const ValueKey('timeline-line'));
    final factor = tester.widget<FractionallySizedBox>(
      find
          .ancestor(of: line, matching: find.byType(FractionallySizedBox))
          .first,
    );
    expect(factor.heightFactor, 1);
    for (final dot in find.byType(TimelineDot).evaluate()) {
      expect(dotScale(tester, find.byWidget(dot.widget)), 1);
    }
    await navigate(tester, 'Skills');
    expect(find.byKey(const ValueKey('marquee-translation')), findsNothing);
    final wrap = find.descendant(
      of: find.byType(SkillsMarquee),
      matching: find.byType(Wrap),
    );
    expect(wrap, findsOneWidget);
    final rect = tester.getRect(wrap);
    await helpers.frames(tester, 20);
    expect(tester.getRect(wrap), rect);
    await helpers.unmount(tester);
  });

  for (final width in [375.0, 1440.0]) {
    testWidgets('home nav reaches lower sections at $width', (tester) async {
      await helpers.pumpPage(tester, location: '/', width: width);
      for (final (label, type) in [
        ('Experience', ExperienceSection),
        ('Skills', SkillsSection),
        ('Contact', ContactSection),
      ]) {
        await navigate(tester, label, phone: width < 600);
        final rect = tester.getRect(find.byType(type));
        expect(rect.top, lessThan(900));
        expect(rect.bottom, greaterThan(72));
        expect(find.byType(NavMenuSheet), findsNothing);
      }
      await helpers.unmount(tester);
    });
  }

  testWidgets('project to skills consumes query and keeps Skills visible', (
    tester,
  ) async {
    final router = await helpers.pumpPage(tester);
    router.go('/?section=skills');
    await helpers.frames(tester, 40);
    expect(router.routeInformationProvider.value.uri.toString(), '/');
    expect(
      tester.getRect(find.byType(SkillsSection)).top,
      inInclusiveRange(-1, 899),
    );
    await helpers.unmount(tester);
  });

  testWidgets('yellow and purple placeholder titles contrast with accent', (
    tester,
  ) async {
    for (final (accent, foreground) in [
      (const Color(0xFFFFD600), AppPalette.light.text),
      (const Color(0xFF7C5CFF), AppPalette.dark.text),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: ProjectPlaceholder(accentColor: accent, title: 'Project'),
        ),
      );
      expect(
        tester.widget<Text>(find.text('Project')).style!.color,
        foreground,
      );
    }
  });

  for (final width in [375.0, 768.0, 1440.0]) {
    for (final language in ['en', 'ar']) {
      for (final brightness in Brightness.values) {
        testWidgets(
          'whole page fits $width $language $brightness without phone text',
          (tester) async {
            await helpers.pumpPage(
              tester,
              location: '/',
              width: width,
              language: language,
              brightness: brightness,
            );
            final scroll = helpers.scrollOf(tester, HomePage);
            final phone = helpers.content.profile.phone!;
            for (var y = 0.0; y < scroll.maxScrollExtent + 500; y += 700) {
              scroll.jumpTo(y.clamp(0, scroll.maxScrollExtent));
              await helpers.frames(tester, 2);
              expect(tester.takeException(), isNull, reason: 'offset $y');
              expect(
                find.byWidgetPredicate(
                  (w) =>
                      w is Text &&
                      (w.data ?? w.textSpan?.toPlainText() ?? '').contains(
                        phone,
                      ),
                ),
                findsNothing,
              );
            }
            await helpers.unmount(tester);
          },
        );
      }
    }
  }
}
