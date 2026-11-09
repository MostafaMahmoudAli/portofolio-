---
title: Design pass acceptance and mobile Lighthouse performance gap
author: Moustafa-Mahmoud9
date: 2026-11-09
branch: enhancments
touches:
  - assets/data/profile.json
  - assets/data/projects.json
  - lib/core/models/project.dart
  - lib/core/theme/app_colors.dart
  - lib/core/theme/app_text_styles.dart
  - lib/core/theme/app_theme.dart
  - lib/l10n/app_ar.arb
  - lib/l10n/app_en.arb
  - lib/l10n/app_localizations.dart
  - lib/l10n/app_localizations_ar.dart
---

## Decided
Do not mark docs/plans/design-pass.md finished just because the design code and tests pass. The continuation reached roughly 80% overall from inherited roughly 45%; media, mobile performance, monogram approval and release verification are still open. No commit, push or deployment is authorized before review.

## Tried and ruled out
Lighthouse 13.6 on the final flutter build web --wasm --release with the unchanged tool/serve.mjs server measured desktop Performance 92 and mobile Performance 63, Accessibility 100 and SEO 100 on both, Best Practices 77 on both. Do not relax mobile throttling or add cross-origin-isolation headers merely to meet 80: the Pages-like deployment deliberately lacks COOP/COEP. No pre-change performance baseline was captured, so do not assert non-regression. Lighthouse accessibility 100 does not by itself validate canvas text contrast.

## Watch out
The mobile report has about 2.31s simulated blocking time, 8.4s speed index, and 5.5 MiB payload, with most script CPU attributed to main.dart.mjs and skwasm.js. Best Practices reports the known missing-media 404s plus engine SharedArrayBuffer and Intl.v8BreakIterator deprecations. Reports are in ignored build/lighthouse-{desktop,mobile}.report.{html,json}. Final analysis is clean, all 181 Flutter tests pass, and the 12-case Chrome width/theme/language sweep has zero JS exceptions and only the known media 404s. Browser screenshot checks need merged card aria-label selectors and settled reveal animations; use hash navigation /#/?section=projects.
