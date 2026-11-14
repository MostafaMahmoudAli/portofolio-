// Regenerate all brand PNGs with the real bundled fonts:
// flutter test tool/generate_og_image.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/theme/app_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generate graphite and mint brand assets', () async {
    for (final (family, file) in [
      ('SpaceGrotesk', 'SpaceGrotesk-Bold.ttf'),
      ('Inter', 'Inter-Regular.ttf'),
    ]) {
      await (FontLoader(
        family,
      )..addFont(rootBundle.load('assets/fonts/$file'))).load();
    }
    final content = await const ContentRepository().load();
    final palette = AppPalette.dark;

    void text(
      Canvas canvas,
      String value,
      Offset offset,
      double size,
      Color color, {
      String font = 'SpaceGrotesk',
      double maxWidth = double.infinity,
    }) {
      final painter = TextPainter(
        text: TextSpan(
          text: value,
          style: TextStyle(
            fontFamily: font,
            fontWeight: font == 'Inter' ? FontWeight.w400 : FontWeight.w700,
            fontSize: size,
            height: 1.15,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);
      painter.paint(canvas, offset);
      painter.dispose();
    }

    Future<void> png(String path, Size size, void Function(Canvas) draw) async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawColor(palette.background, BlendMode.src);
      draw(canvas);
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(path).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
      picture.dispose();
    }

    for (final (path, size) in [
      ('web/favicon.png', 32),
      ('web/icons/Icon-192.png', 192),
      ('web/icons/Icon-512.png', 512),
      ('web/icons/Icon-maskable-192.png', 192),
      ('web/icons/Icon-maskable-512.png', 512),
    ]) {
      await png(path, Size.square(size.toDouble()), (canvas) {
        // Even the square monogram bounds fit within the maskable safe circle
        // (radius 40% of the icon). All variants use identical safe artwork.
        final painter = TextPainter(
          text: TextSpan(
            text: 'MM',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
              fontSize: size * 0.34,
              color: palette.accent,
              height: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(
          canvas,
          Offset((size - painter.width) / 2, (size - painter.height) / 2),
        );
        painter.dispose();
      });
    }

    await png('web/og-image.png', const Size(1200, 630), (canvas) {
      canvas.drawRect(
        const Rect.fromLTWH(64, 215, 180, 10),
        Paint()..color = palette.accent,
      );
      text(
        canvas,
        content.profile.name.of(const Locale('en')),
        const Offset(64, 257),
        64,
        palette.text,
        maxWidth: 740,
      );
      text(
        canvas,
        content.profile.title.of(const Locale('en')),
        const Offset(64, 355),
        36,
        palette.mutedText,
        font: 'Inter',
      );
      text(canvas, 'MM', const Offset(840, 228), 180, palette.accent);
    });
  });
}
