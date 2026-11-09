---
title: Task 4 lazy screens viewer routes RTL and focus lifecycle
author: Moustafa-Mahmoud9
date: 2026-11-09
branch: media
cost: { minutes: 30, tokens: 648726 }
touches:
  - README.md
  - lib/l10n/app_ar.arb
  - lib/l10n/app_en.arb
  - lib/l10n/app_localizations.dart
  - lib/l10n/app_localizations_ar.dart
  - lib/l10n/app_localizations_en.dart
  - lib/presentation/widgets/project_video_controls.dart
  - lib/presentation/widgets/project_video_player.dart
  - test/presentation/project_video_player_test.dart
  - test/presentation/video_controls_test.dart
---

## Decided
Task 4 adds ScreensGallery only for nonempty Project.screens after the platform demos. The horizontal ListView.builder is lazy and enables mouse drag without losing touch/trackpad defaults. Thumbnails use a 9:19.5 outer aspect, palette surfaces and accentInk hover/focus outlines. showScreensViewer pushes a real showGeneralDialog route with a dark palette, PageView starting at the tapped index, captions, counter, directional arrows and localized screenshot semantics. Its focus node handles reading-direction Left/Right and Escape; Back/X close it and focus returns to the owning thumbnail. Fade duration is 200ms, zero under reduced motion. Neighbor NetworkImages are precached with an error callback.

## Tried and ruled out
Do not build all thumbnails or store a focus node for every data entry eagerly. Let each lazy thumbnail own/dispose its focus node. InkWell requires a resolved BorderRadius, so resolve BorderRadiusDirectional using the ambient direction rather than using physical radius APIs. Keep missing visible images and prefetch errors on graceful placeholder paths.

## Watch out
A project-page screens section can be an unbuilt sliver: fixed-frame tests must seek the vertical viewport until its context exists before ensureVisible. Dispose tester.ensureSemantics handles inside try/finally before the test body finishes; asynchronous teardown is too late for Flutter's verification. Mouse drag tests need a slop-establishing move and another movement to scroll. Seventeen screenshot tests cover opening image 3, swiping/arrows/keys/RTL, ends, Back/Escape/X, focus, lazy mouse drag, palette outlines, failed images, fade and project integration at all three widths in both languages. Real project screens remain [] pending owner assets; do not add fake media just to show the section.
