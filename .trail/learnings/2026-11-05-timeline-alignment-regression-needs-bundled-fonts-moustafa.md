---
title: Timeline alignment regression needs bundled fonts
author: Moustafa-Mahmoud9
date: 2026-11-05
branch: phase-7
cost: { minutes: 27, tokens: 582726 }
touches:
  - README.md
  - assets/fonts/SpaceGrotesk-Medium.ttf
  - lib/app.dart
  - lib/core/localization/document_locale.dart
  - lib/core/localization/document_locale_stub.dart
  - lib/core/localization/document_locale_web.dart
  - lib/core/localization/locale_controller.dart
  - lib/core/theme/app_theme.dart
  - lib/l10n/app_ar.arb
  - lib/l10n/app_en.arb
---

## Decided
Stretch the inner experience timeline Column so every entry shares full width, timeline dots stay centered on the line, and GlassCard start edges align in LTR and RTL. Regression tests measure all dots and cards at 1440 px with reduced motion.

## Tried and ruled out
The regression initially passed without the fix under Flutter's default Ahem test font: its wide glyphs force every card to wrap to full width and hide the staircase. Load bundled Inter, SpaceGrotesk and IBM Plex Sans Arabic fonts with FontLoader inside tester.runAsync. With real fonts, the unfixed English and Arabic tests fail by about 30 px and 14 px respectively.

## Watch out
Use fixed-frame page helpers and the fake video platform, not pumpAndSettle on the animated home page. Keep formatting in its own whitespace-only commit. User-owned .gitignore, .ignore and .claude/ changes remain excluded. Trail check can report lexical false positives for fixed-frame helpers and unrelated README tooling; inspect the actual code before changing behavior.
