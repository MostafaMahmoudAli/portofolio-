import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/theme/app_text_styles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Arabic headings use Tajawal, body retains IBM Plex Sans Arabic', () {
    final theme = AppTextStyles.textTheme(
      const Locale('ar'),
      Colors.black,
      Colors.grey,
    );
    expect(theme.displayLarge!.fontFamily, 'Tajawal');
    expect(theme.headlineLarge!.fontFamily, 'Tajawal');
    expect(theme.bodyMedium!.fontFamily, 'IBMPlexSansArabic');
  });

  for (final (path, width, height) in [
    ('web/favicon.png', 32, 32),
    ('web/icons/Icon-192.png', 192, 192),
    ('web/icons/Icon-512.png', 512, 512),
    ('web/icons/Icon-maskable-192.png', 192, 192),
    ('web/icons/Icon-maskable-512.png', 512, 512),
    ('web/og-image.png', 1200, 630),
  ]) {
    test('$path has expected dimensions and graphite/mint artwork', () async {
      final codec = await ui.instantiateImageCodec(
        await File(path).readAsBytes(),
      );
      final image = (await codec.getNextFrame()).image;
      expect(image.width, width);
      expect(image.height, height);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final rgba = data!.buffer.asUint8List();
      expect(rgba.sublist(0, 4), [0x15, 0x19, 0x1A, 255]);
      var mintPixels = 0;
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          final i = (y * width + x) * 4;
          if (rgba[i] == 0x34 && rgba[i + 1] == 0xD3 && rgba[i + 2] == 0x99) {
            mintPixels++;
          }
          if (path.contains('maskable') &&
              (rgba[i] != 0x15 || rgba[i + 1] != 0x19 || rgba[i + 2] != 0x1A)) {
            final dx = x + 0.5 - width / 2;
            final dy = y + 0.5 - height / 2;
            expect(
              dx * dx + dy * dy,
              lessThanOrEqualTo(width * width * 0.16),
              reason: 'Maskable artwork outside the 80% safe circle at $x,$y',
            );
          }
        }
      }
      expect(mintPixels, greaterThan(0));
      image.dispose();
      codec.dispose();
    });
  }
}
