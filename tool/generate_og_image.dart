// flutter run -d chrome --target tool/generate_og_image.dart
// Downloads og-image.png; copy it to web/og-image.png.
import 'dart:js_interop';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/theme/app_colors.dart';
import 'package:web/web.dart' as web;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  for (final (family, file) in [
    ('SpaceGrotesk', 'SpaceGrotesk-Bold.ttf'),
    ('Inter', 'Inter-Regular.ttf'),
  ]) {
    await (FontLoader(
      family,
    )..addFont(rootBundle.load('assets/fonts/$file'))).load();
  }
  final content = await const ContentRepository().load();
  final key = GlobalKey();
  final palette = AppPalette.dark;
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: FittedBox(
          child: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: 1200,
              height: 630,
              child: ColoredBox(
                color: palette.background,
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 12,
                        decoration: BoxDecoration(color: palette.accent),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        content.profile.name,
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w700,
                          fontSize: 64,
                          color: palette.text,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        content.profile.title.of(const Locale('en')),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 36,
                          color: palette.mutedText,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await WidgetsBinding.instance.endOfFrame;
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final blob = web.Blob(
    [bytes!.buffer.asUint8List().toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  final url = web.URL.createObjectURL(blob);
  (web.HTMLAnchorElement()
        ..href = url
        ..download = 'og-image.png')
      .click();
  image.dispose();
}
