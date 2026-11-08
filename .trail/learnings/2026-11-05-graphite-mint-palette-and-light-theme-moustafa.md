---
title: Graphite mint palette and light-theme contrast boundaries
author: Moustafa-Mahmoud9
date: 2026-11-05
branch: colors
cost: { minutes: 50, tokens: 614358 }
touches:
  - lib/core/utils/download_file.dart
  - lib/core/utils/download_file_stub.dart
  - lib/core/utils/download_file_web.dart
  - lib/presentation/sections/experience_section.dart
  - lib/presentation/sections/featured_projects.dart
  - lib/presentation/sections/hero_section.dart
  - lib/presentation/widgets/nav_bar.dart
  - lib/presentation/widgets/nav_menu_sheet.dart
  - test/presentation/enhancements_test.dart
  - test/presentation/phase_six_test.dart
---

## Decided
Graphite + mint replaces the old multi-accent presentation. AppPalette exposes background, text, accent, mutedText, surface, surfaceBorder and onAccent. Mint and onAccent are identical across themes. Material primary fills use mint with onAccent labels; secondary controls use neutral labels and transparent fills with hover/focus mint outlines. Nav/menu resume controls are outlined so the hero retains its single primary action.

Project accent metadata remains parseable but is intentionally ignored by presentation. Remove the project color extension and color arguments from media/placeholder widgets. Placeholder surfaces and titles are neutral with a thin mint border. All previous gradient text becomes normal theme text. Rename the about-section localization keys to capability names so the retired-token grep has zero matches without changing bilingual copy.

## Tried and ruled out
Multiple colored blobs, gradient rings, tinted project chips and accent-colored light-theme text are intentionally superseded by the requested calm palette. The hero alone owns one blurred mint circle at 0.10 light / 0.14 dark; its slow ticker stops under reduced motion. The photo keeps its rotation using a solid mint arc instead of a shader. Existing flip/reveal and layout behavior remain covered by tests.

## Watch out
Use fixed-frame helpers for widget tests. A MaterialApp reused across palette cases needs zero theme animation duration or fixed frames before reading its new colors. New tests compute WCAG sRGB luminance, inspect effective Text/RichText and Icon colors throughout home/remix scrolling in both languages, and check hover/focus outlines. All 162 tests pass, including layout sweeps. Regenerate web/og-image.png with the Flutter tool, not an approximate external renderer. Browser preference seeding requires JSON.stringify values for flutter.themeMode and flutter.languageCode. Release screenshots must wait for the entrance animations/counters to finish before capture.
