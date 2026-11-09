import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/theme/app_colors.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/presentation/pages/home_page.dart';
import 'package:portfolio/presentation/pages/home_section.dart';
import 'package:portfolio/presentation/widgets/nav_bar.dart';
import 'package:portfolio/presentation/widgets/nav_menu_sheet.dart';
import 'package:portfolio/presentation/widgets/section_title.dart';
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

  for (final language in ['en', 'ar']) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'scroll spy and progress follow navigation in $language $brightness',
        (tester) async {
          await helpers.pumpPage(
            tester,
            location: '/',
            language: language,
            brightness: brightness,
            reducedMotion: true,
          );
          NavBar nav() => tester.widget<NavBar>(find.byType(NavBar));
          expect(nav().activeSection, isNull);
          expect(nav().scrollProgress, 0);
          for (final section in HomeSection.values) {
            nav().onSectionTap(section);
            await helpers.frames(tester, 16);
            expect(nav().activeSection, section);
            expect(nav().scrollProgress, greaterThan(0));
            expect(nav().scrollProgress, lessThanOrEqualTo(1));
            final label = find.descendant(
              of: find.byType(NavBar),
              matching: find.text(
                section.label(
                  AppLocalizations.of(tester.element(find.byType(HomePage))),
                ),
              ),
            );
            final text = tester.widget<Text>(label);
            expect(
              text.style!.color,
              brightness == Brightness.light
                  ? AppPalette.light.accentInk
                  : AppPalette.dark.accentInk,
            );
            expect(text.style!.decoration, TextDecoration.underline);
          }
          final scroll = helpers.scrollOf(tester, HomePage);
          for (var i = 0; i < 4; i++) {
            scroll.jumpTo(scroll.maxScrollExtent);
            await helpers.frames(tester, 2);
          }
          expect(nav().scrollProgress, 1);
          expect(nav().activeSection, HomeSection.contact);
          nav().onLogoTap();
          await helpers.frames(tester);
          expect(nav().scrollProgress, 0);
          expect(nav().activeSection, isNull);
          expect(tester.takeException(), isNull);
          await helpers.unmount(tester);
        },
      );
    }

    testWidgets('phone menu reflects active section in $language', (
      tester,
    ) async {
      await helpers.pumpPage(
        tester,
        location: '/',
        width: 375,
        language: language,
        reducedMotion: true,
      );
      tester
          .widget<NavBar>(find.byType(NavBar))
          .onSectionTap(HomeSection.skills);
      await helpers.frames(tester, 16);
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await helpers.frames(tester);
      expect(
        tester.widget<NavMenuSheet>(find.byType(NavMenuSheet)).activeSection,
        HomeSection.skills,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is ListTile && widget.selected,
        ),
        findsOneWidget,
      );
      await helpers.unmount(tester);
    });

    testWidgets(
      'localized availability, proof and eyebrows are visible in $language',
      (tester) async {
        await helpers.pumpPage(
          tester,
          location: '/',
          language: language,
          reducedMotion: true,
        );
        final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
        expect(find.text(l10n.availability), findsOneWidget);
        final impact = helpers.content.projects.first.impact!;
        tester
            .widget<NavBar>(find.byType(NavBar))
            .onSectionTap(HomeSection.projects);
        await helpers.frames(tester, 16);
        expect(find.text(impact.of(Locale(language))), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) => widget is SectionTitle && widget.eyebrow != null,
          ),
          findsWidgets,
        );
        expect(tester.takeException(), isNull);
        await helpers.unmount(tester);
      },
    );
  }
}
