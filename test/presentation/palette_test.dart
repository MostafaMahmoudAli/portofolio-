import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/theme/app_colors.dart';
import 'package:portfolio/core/theme/app_theme.dart';
import 'package:portfolio/presentation/pages/home_page.dart';
import 'package:portfolio/presentation/pages/project_page.dart';
import 'package:portfolio/presentation/widgets/glass_card.dart';
import 'package:portfolio/presentation/widgets/project_placeholder.dart';
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
        // Text buttons are links: no border at rest.
        final link = theme.textButtonTheme.style!;
        expect(link.side!.resolve({})!.style, BorderStyle.none);
        expect(
          link.side!.resolve({WidgetState.hovered})!.style,
          BorderStyle.none,
        );
        expect(
          link.side!.resolve({WidgetState.focused})!.color,
          palette.accentInk,
        );
        // Outlined buttons keep the hairline.
        final outlined = theme.outlinedButtonTheme.style!;
        expect(outlined.backgroundColor!.resolve({}), Colors.transparent);
        expect(outlined.foregroundColor!.resolve({}), palette.text);
        expect(outlined.side!.resolve({})!.color, palette.surfaceBorder);
        expect(
          outlined.side!.resolve({WidgetState.hovered})!.color,
          palette.accentInk,
        );
        expect(
          outlined.side!.resolve({WidgetState.focused})!.color,
          palette.accentInk,
        );
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
        final box = decorations
            .map((widget) => widget.decoration)
            .whereType<BoxDecoration>()
            .firstWhere((box) => box.border != null);
        return (box.border! as Border).top.color;
      }

      expect(borderColor(), AppPalette.light.surfaceBorder);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(target));
      await helpers.frames(tester, 2);
      expect(borderColor(), AppPalette.light.accentInk);
      await mouse.moveTo(Offset.zero);
      await helpers.frames(tester, 2);
      expect(borderColor(), AppPalette.light.surfaceBorder);
      await mouse.removePointer();
    });
  }

  for (final brightness in Brightness.values) {
    testWidgets('placeholder is opaque over the static poster in $brightness', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(brightness, const Locale('en')),
          home: const Scaffold(body: ProjectPlaceholder(title: 'Project')),
        ),
      );
      final box = tester.widget<Container>(
        find.descendant(
          of: find.byType(ProjectPlaceholder),
          matching: find.byType(Container),
        ),
      );
      expect((box.decoration as BoxDecoration).color!.a, 1);
    });
    testWidgets('card shadow is outside its clip in $brightness', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(brightness, const Locale('en')),
          home: const Scaffold(
            body: Center(child: GlassCard(child: Text('Card'))),
          ),
        ),
      );
      final clip = find.descendant(
        of: find.byType(GlassCard),
        matching: find.byType(ClipRRect),
      );
      final outer = tester.widget<DecoratedBox>(
        find.ancestor(of: clip, matching: find.byType(DecoratedBox)).first,
      );
      final shadow = (outer.decoration as BoxDecoration).boxShadow!.single;
      expect(
        shadow.color,
        brightness == Brightness.light
            ? const Color(0x0F23272A)
            : const Color(0x59000000),
      );
      expect(shadow.blurRadius, 24);
      expect(shadow.offset, const Offset(0, 6));
    });
  }
}
