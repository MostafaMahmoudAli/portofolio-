import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/presentation/pages/project_page.dart';
import 'package:portfolio/presentation/widgets/contact_band.dart';
import 'package:portfolio/presentation/widgets/language_toggle.dart';
import 'package:portfolio/presentation/widgets/theme_toggle.dart';
import 'package:portfolio/presentation/widgets/store_badges.dart';
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
    for (final location in ['/', '/projects/egypt-abroad']) {
      testWidgets('375px email stays one LTR line on $location in $language', (
        tester,
      ) async {
        await helpers.pumpPage(
          tester,
          location: location,
          width: 375,
          language: language,
          reducedMotion: true,
        );
        final scroll = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.byType(ContactBand),
          500,
          scrollable: scroll,
        );
        await helpers.frames(tester);
        final email = find.byKey(const ValueKey('contact-email'));
        final text = tester.widget<Text>(email);
        expect(text.maxLines, 1);
        expect(text.softWrap, isFalse);
        expect(text.textDirection, TextDirection.ltr);
        final paragraph = tester.renderObject<RenderParagraph>(email);
        expect(
          paragraph.getBoxesForSelection(
            TextSelection(baseOffset: 0, extentOffset: text.data!.length),
          ),
          hasLength(1),
        );
        final fitted = find
            .ancestor(of: email, matching: find.byType(FittedBox))
            .first;
        expect(tester.getSize(fitted).width, lessThanOrEqualTo(279));
        expect(tester.takeException(), isNull);
        await helpers.unmount(tester);
      });
    }

    for (final width in [375.0, 1440.0]) {
      testWidgets('toggle highlights have an 8px gap at $width in $language', (
        tester,
      ) async {
        await helpers.pumpPage(
          tester,
          location: '/',
          width: width,
          language: language,
          reducedMotion: true,
        );
        if (width < 600) {
          await tester.tap(
            find.byTooltip(language == 'ar' ? 'القائمة' : 'Menu'),
          );
          await helpers.frames(tester);
        }
        final languageRect = tester.getRect(find.byType(LanguageToggle));
        final themeRect = tester.getRect(find.byType(ThemeToggle));
        final gap = languageRect.left < themeRect.left
            ? themeRect.left - languageRect.right
            : languageRect.left - themeRect.right;
        expect(gap, greaterThanOrEqualTo(8));
        expect(tester.takeException(), isNull);
        await helpers.unmount(tester);
      });
    }

    for (final location in ['/', '/projects/egypt-consulate-apps']) {
      testWidgets(
        'city labels and badge pairs share each phone row on $location in $language',
        (tester) async {
          await helpers.pumpPage(
            tester,
            location: location,
            width: 375,
            language: language,
            reducedMotion: true,
          );
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('store-city-Kuwait')),
            500,
            scrollable: find.byType(Scrollable).first,
          );
          await helpers.frames(tester);
          for (final city in ['Kuwait', 'Riyadh', 'Jeddah', 'Milan']) {
            final row = find.byKey(ValueKey('store-city-$city'));
            final badges = find.descendant(
              of: row,
              matching: find.byType(StoreBadge),
            );
            expect(badges, findsNWidgets(2));
            expect(
              tester.getTopLeft(badges.first).dy,
              closeTo(tester.getTopLeft(badges.last).dy, 0.1),
            );
            expect(tester.getSize(row).height, greaterThanOrEqualTo(48));
          }
          if (location != '/') expect(find.byType(ProjectPage), findsOneWidget);
          expect(tester.takeException(), isNull);
          await helpers.unmount(tester);
        },
      );
    }
  }
}
