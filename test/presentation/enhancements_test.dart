import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/utils/download_file_stub.dart' as downloads;
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/presentation/pages/home_page.dart';
import 'package:portfolio/presentation/sections/hero_section.dart';
import 'package:portfolio/presentation/widgets/glass_card.dart';
import 'package:portfolio/presentation/widgets/nav_bar.dart';
import 'package:portfolio/presentation/widgets/nav_menu_sheet.dart';
import 'package:portfolio/presentation/widgets/phone_frame.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'project_page_test.dart' as helpers;
import 'project_video_player_test.dart' show FakeVideoPlatform;

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  helpers.content = await const ContentRepository().load();
  // Measure the real typography, not Ahem's artificially wide test glyphs.
  setUpAll(() async {
    for (final (family, file) in [
      ('Inter', 'Inter-Regular.ttf'),
      ('SpaceGrotesk', 'SpaceGrotesk-Bold.ttf'),
      ('IBMPlexSansArabic', 'IBMPlexSansArabic-Regular.ttf'),
    ]) {
      await (FontLoader(
        family,
      )..addFont(rootBundle.load('assets/fonts/$file'))).load();
    }
  });
  setUp(() {
    downloads.downloadCalls.clear();
    VideoPlayerPlatform.instance = FakeVideoPlatform();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  for (final language in ['en', 'ar']) {
    for (final source in ['hero', 'desktop nav', 'phone menu']) {
      testWidgets('$source downloads resume in $language', (tester) async {
        await helpers.pumpPage(
          tester,
          location: '/',
          width: source == 'phone menu' ? 375 : 1440,
          language: language,
          reducedMotion: true,
        );
        final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
        if (source == 'phone menu') {
          await tester.tap(find.byTooltip(l10n.menu));
          await helpers.frames(tester);
        }
        final button = find.descendant(
          of: find.byType(switch (source) {
            'hero' => HeroSection,
            'desktop nav' => NavBar,
            _ => NavMenuSheet,
          }),
          matching: find.text(
            source == 'hero' ? l10n.downloadResume : l10n.resume,
          ),
        );
        if (source == 'hero') {
          // Keep the target below the sticky navigation bar.
          await Scrollable.ensureVisible(
            tester.element(button),
            alignment: 0.5,
          );
        }
        await helpers.frames(tester);
        await tester.tap(button);
        await helpers.frames(tester, 2);
        expect(downloads.downloadCalls, [
          (path: 'resume.pdf', fileName: 'Mostafa-Mahmoud-Resume.pdf'),
        ]);
        await helpers.unmount(tester);
      });
    }

    testWidgets('first featured card fits 520 px at 1440x900 in $language', (
      tester,
    ) async {
      await helpers.pumpPage(
        tester,
        location: '/',
        width: 1440,
        language: language,
        reducedMotion: true,
      );
      final frame = find.byType(PhoneFrame, skipOffstage: false).first;
      await tester.ensureVisible(frame);
      await helpers.frames(tester);
      final card = find
          .ancestor(of: frame, matching: find.byType(GlassCard))
          .first;
      expect(tester.getSize(card).height, lessThanOrEqualTo(520));
      expect(tester.takeException(), isNull);
      await helpers.unmount(tester);
    });
  }
}
