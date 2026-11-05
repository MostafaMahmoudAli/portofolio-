import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/theme/app_colors.dart';
import 'package:portfolio/core/theme/app_theme.dart';
import 'package:portfolio/presentation/pages/home_page.dart';
import 'package:portfolio/presentation/pages/project_page.dart';
import 'package:portfolio/presentation/widgets/glass_card.dart';
import 'package:portfolio/presentation/widgets/tech_chip.dart';
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
    for (final (location, page) in [
      ('/', HomePage),
      ('/projects/remix', ProjectPage),
    ]) {
      testWidgets(
        'no mint text on light $location in $language throughout scroll',
        (tester) async {
          await helpers.pumpPage(
            tester,
            location: location,
            language: language,
            reducedMotion: true,
          );
          final scroll = helpers.scrollOf(tester, page);
          for (var y = 0.0; y < scroll.maxScrollExtent + 500; y += 600) {
            scroll.jumpTo(y.clamp(0, scroll.maxScrollExtent));
            await helpers.frames(tester, 2);
            for (final element in find.byType(Text).evaluate()) {
              final text = element.widget as Text;
              final inherited = DefaultTextStyle.of(element).style;
              final style = text.style == null
                  ? inherited
                  : inherited.merge(text.style);
              expect(
                style.foreground?.color ?? style.color,
                isNot(AppPalette.light.accent),
                reason: '${text.data} at $y',
              );
            }
            for (final rich in tester.widgetList<RichText>(
              find.byType(RichText),
            )) {
              void check(InlineSpan span) {
                expect(
                  span.style?.foreground?.color ?? span.style?.color,
                  isNot(AppPalette.light.accent),
                );
                if (span is TextSpan) {
                  for (final child in span.children ?? <InlineSpan>[]) {
                    check(child);
                  }
                }
              }

              check(rich.text);
            }
            for (final element in find.byType(Icon).evaluate()) {
              final icon = element.widget as Icon;
              expect(
                icon.color ?? IconTheme.of(element).color,
                isNot(AppPalette.light.accent),
                reason: '${icon.icon} at $y',
              );
            }
            expect(tester.takeException(), isNull);
          }
          await helpers.unmount(tester);
        },
      );
    }
  }

  for (final brightness in Brightness.values) {
    test(
      '$brightness buttons use palette fills, labels and hover outlines',
      () {
        final theme = AppTheme.build(brightness, const Locale('en'));
        final palette = brightness == Brightness.dark
            ? AppPalette.dark
            : AppPalette.light;
        expect(theme.colorScheme.primary, palette.accent);
        expect(theme.colorScheme.onPrimary, palette.onAccent);
        expect(theme.colorScheme.surface, palette.background);
        expect(theme.colorScheme.onSurface, palette.text);
        final primary = theme.filledButtonTheme.style!;
        expect(primary.backgroundColor!.resolve({}), palette.accent);
        expect(primary.foregroundColor!.resolve({}), palette.onAccent);
        for (final secondary in [
          theme.textButtonTheme.style!,
          theme.outlinedButtonTheme.style!,
        ]) {
          expect(secondary.backgroundColor!.resolve({}), Colors.transparent);
          expect(secondary.foregroundColor!.resolve({}), palette.text);
          expect(secondary.side!.resolve({})!.color, palette.surfaceBorder);
          expect(
            secondary.side!.resolve({WidgetState.hovered})!.color,
            palette.accent,
          );
          expect(
            secondary.side!.resolve({WidgetState.focused})!.color,
            palette.accent,
          );
        }
      },
    );
  }

  for (final type in [GlassCard, TechChip]) {
    testWidgets('$type uses mint only on its hovered border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(Brightness.light, const Locale('en')),
          home: Scaffold(
            body: Center(
              child: type == GlassCard
                  ? const GlassCard(child: Text('Card'))
                  : const TechChip(label: 'Flutter'),
            ),
          ),
        ),
      );
      final target = find.byType(type);
      Color borderColor() {
        final decorations = tester.widgetList<DecoratedBox>(
          find.descendant(of: target, matching: find.byType(DecoratedBox)),
        );
        final box = decorations.first.decoration as BoxDecoration;
        return (box.border! as Border).top.color;
      }

      expect(borderColor(), AppPalette.light.surfaceBorder);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(target));
      await helpers.frames(tester, 2);
      expect(borderColor(), AppPalette.light.accent);
      await mouse.moveTo(Offset.zero);
      await helpers.frames(tester, 2);
      expect(borderColor(), AppPalette.light.surfaceBorder);
      await mouse.removePointer();
    });
  }
}
