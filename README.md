# portfolio

Mostafa Mahmoud — Flutter Developer portfolio

## Sharing image and performance

Regenerate the committed 1200×630 preview with Flutter 3.41.6 and the bundled fonts:

```sh
flutter test tool/generate_og_image.dart
```

The standalone Flutter tool writes `web/og-image.png`, the favicon and PWA icons
directly using bundled fonts. It runs separately from the normal test suite.

## Adding a project

Add an entry to `assets/data/projects.json` with a unique kebab-case `slug`, the
existing bilingual title/subtitle/summary, order, featured flag, tech and links.
Media paths are relative to `web/` (never begin them with `/`, so Pages subpaths work).

```json
{
  "cover": "media/my-app/cover.jpg",
  "screens": [
    {
      "src": "media/my-app/screens/01.jpg",
      "caption": { "en": "Home screen", "ar": "الشاشة الرئيسية" }
    },
    { "src": "media/my-app/screens/02.webp" }
  ],
  "videos": {
    "ios": {
      "src": "media/my-app/ios.mp4",
      "poster": "media/my-app/ios.jpg",
      "caption": { "en": "iOS walkthrough", "ar": "جولة على iOS" }
    },
    "android": {
      "src": "media/my-app/android.mp4",
      "poster": "media/my-app/android.jpg",
      "caption": { "en": "Android walkthrough", "ar": "جولة على أندرويد" }
    }
  }
}
```

`screens` is optional, allows any number of images, and defaults to `[]`. Screen
captions are optional. `videos` is an optional object, not an array: omit either
platform when unavailable, or use `{}`/omit `videos` for no demos. Only `ios`,
`android` and `web` keys are allowed. `web` is one landscape demo for a web or
desktop project (`media/<slug>/web.mp4` + `web.jpg`), shown in the wide frame. A configured video requires `src` and `poster`; its
caption is optional. iOS is primary when present, otherwise Android. Only add an
iOS demo for an app that actually supports iOS; never add unrelated placeholder media.

To add project images, set one `cover` path in `assets/data/projects.json` for the
card thumbnail, and add any number of `{ "src": "media/my-app/screens/01.jpg" }`
entries to `screens` for its project page. Put the files under `web/media/`.

Put files under:

```text
web/media/my-app/
  cover.jpg
  ios.mp4
  ios.jpg
  android.mp4
  android.jpg
  screens/
    01.jpg
    02.webp
```

Images/posters: JPG or WebP, at most 1280 px on the long side. Videos must be under
10 MB each. Use the encoding commands from `docs/PORTFOLIO_PLAN.md`, section 5,
for each platform (substitute `ios` for `android` for the iOS recording):

```sh
ffmpeg -i raw.mp4 -vf "scale=-2:1280,fps=30" -c:v libx264 -crf 28 -preset slow -c:a aac -b:a 96k -movflags +faststart android.mp4
ffmpeg -ss 1 -i android.mp4 -frames:v 1 -q:v 3 android.jpg
node tool/check_media.mjs
```

The check prints missing cover, screen, video and poster paths grouped by project
and exits nonzero while files are missing or videos exceed the size budget.

On project pages, tablet shows both platform demos side by side; desktop/phones
show a platform picker when both exist. Home cards start with the primary demo
and let visitors switch platforms. The details link carries that choice so only
the matching static phone frame participates in the Hero transition. A missing
platform is omitted, not replaced by a duplicate demo.

Video controls provide play/pause, ±5-second seeking, a scrubber and mute. Focus
the player to use Space and Left/Right. The timeline stays LTR with Western-digit
clocks in either language. Controls stay visible while paused and hide three
seconds after the last interaction while playing. Narrow frames use two rows
and omit clock labels below 220px; touch targets remain at least 48×48.

Projects with `screens` show a lazy, horizontally scrollable thumbnail row after
the videos. Mouse drag and trackpad scrolling are supported. A thumbnail opens a
full-screen viewer at that image: swipe, use the side arrows or Left/Right keys
to browse (reading direction follows Arabic); Escape, browser Back and X close
it. Focus returns to the thumbnail. Neighbor images are prefetched, missing
images show the designed placeholder, and reduced motion removes the 200ms fade.

## Local performance checks

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
