# portfolio

Mostafa Mahmoud — Flutter Developer portfolio

## Sharing image and performance

Regenerate the committed 1200×630 preview with Flutter 3.41.6 and the bundled fonts:

```sh
flutter run -d chrome --target tool/generate_og_image.dart
```

The standalone Flutter tool downloads `og-image.png`; copy that file into `web/`.
It renders at exactly 1200×630 regardless of the browser size and is not part of
`flutter test`.

```sh
flutter build web --wasm --release
node tool/serve.mjs
# In another terminal:
npx lighthouse http://127.0.0.1:8080 --preset=desktop --output=html --output-path=build/lighthouse-desktop.html
npx lighthouse http://127.0.0.1:8080 --output=html --output-path=build/lighthouse-mobile.html
```

The local server supplies JavaScript and Wasm MIME types without COOP/COEP,
matching GitHub Pages' single-threaded Wasm environment. Preview metadata stays
English; the document language and direction follow the selected locale.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
