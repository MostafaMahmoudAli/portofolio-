import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/localization/document_locale_stub.dart'
    as document;
import 'package:portfolio/core/localization/locale_controller.dart';
import 'package:portfolio/core/theme/app_colors.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/presentation/pages/home_page.dart';
import 'package:portfolio/presentation/pages/project_page.dart';
import 'package:portfolio/presentation/widgets/theme_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../app_test.dart' as app;
import 'project_page_test.dart' as helpers;
import 'project_video_player_test.dart' show FakeVideoPlatform;

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  app.content = helpers.content = await const ContentRepository().load();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    app.prefs = await SharedPreferences.getInstance();
    VideoPlayerPlatform.instance = FakeVideoPlatform();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  test(
    'locale controller synchronizes VM document adapter on init and change',
    () {
      final controller = LocaleController(
        app.prefs,
        platformLocale: const Locale('ar'),
      );
      expect(
        (document.documentLanguage, document.documentDirection),
        ('ar', 'rtl'),
      );
      controller.set(LocaleController.english);
      expect(
        (document.documentLanguage, document.documentDirection),
        ('en', 'ltr'),
      );
      controller.set(LocaleController.arabic);
      expect(
        (document.documentLanguage, document.documentDirection),
        ('ar', 'rtl'),
      );
      controller.dispose();
    },
  );

  test('muted body text on composited glass surface meets AA', () {
    for (final palette in [AppPalette.light, AppPalette.dark]) {
      final surface = Color.alphaBlend(palette.surface, palette.background);
      final a = palette.mutedText.computeLuminance();
      final b = surface.computeLuminance();
      final ratio = a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
      expect(ratio, greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('whole app reduced motion becomes idle on home and project', (
    tester,
  ) async {
    await app.pumpApp(tester, reduceMotion: true);
    expect(tester.binding.hasScheduledFrame, isFalse);
    final router = GoRouter.of(tester.element(find.byType(HomePage)));
    router.go('/projects/remix');
    await helpers.frames(tester, 12);
    expect(find.byType(ProjectPage), findsOneWidget);
    expect(find.byType(Hero), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
    await helpers.unmount(tester);
  });

  for (final reduced in [false, true]) {
    testWidgets('theme snapshot overlay lifecycle reduced=$reduced', (
      tester,
    ) async {
      await app.pumpApp(tester, reduceMotion: reduced);
      // Raster capture completes outside the fake-async clock.
      await tester.runAsync(() async {
        await tester.tap(find.byType(ThemeToggle));
        await Future<void>.delayed(const Duration(milliseconds: 60));
      });
      await tester.pump();
      final overlay = find.byKey(const ValueKey('theme-reveal-overlay'));
      expect(overlay, reduced ? findsNothing : findsOneWidget);
      if (!reduced) {
        await tester.tap(find.byType(ThemeToggle));
        await tester.pump();
      }
      await helpers.frames(tester, 12);
      expect(overlay, findsNothing);
      expect(app.prefs.getString('themeMode'), 'dark');
      await helpers.unmount(tester);
    });
  }

  for (final language in ['en', 'ar']) {
    testWidgets('keyboard traversal follows nav then toggles in $language', (
      tester,
    ) async {
      app.prefs.setString('languageCode', language);
      await app.pumpApp(tester, reduceMotion: true);
      final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
      final labels = <String>[];
      for (var i = 0; i < 14; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final focus = FocusManager.instance.primaryFocus;
        expect(focus, isNotNull);
        final context = focus!.context;
        if (context != null) {
          ButtonStyleButton? button;
          context.visitAncestorElements((element) {
            if (element.widget is ButtonStyleButton) {
              button = element.widget as ButtonStyleButton;
              return false;
            }
            return true;
          });
          final icon = context.findAncestorWidgetOfExactType<IconButton>();
          final tooltip = context.findAncestorWidgetOfExactType<Tooltip>();
          final texts = button == null
              ? <String>[]
              : tester
                    .widgetList<Text>(
                      find.descendant(
                        of: find.byWidget(button!),
                        matching: find.byType(Text),
                      ),
                    )
                    .map((text) => text.data ?? '')
                    .toList();
          labels.add(icon?.tooltip ?? tooltip?.message ?? texts.join());
        }
      }
      expect(labels, [
        'MM',
        l10n.navAbout,
        l10n.navProjects,
        l10n.navExperience,
        l10n.navSkills,
        l10n.navContact,
        l10n.languageToggleTooltip,
        l10n.themeToDark,
        l10n.resume,
        l10n.viewProjects,
        l10n.downloadResume,
        l10n.github,
        l10n.linkedin,
        l10n.email,
      ]);
      await helpers.unmount(tester);
    });
  }
}
