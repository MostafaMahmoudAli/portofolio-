---
title: Full-width timeline cards and verified resume downloads
author: Moustafa-Mahmoud9
date: 2026-11-05
branch: enhancements
cost: { minutes: 153, tokens: 1396082 }
touches:
  - lib/core/theme/app_colors.dart
  - lib/core/theme/app_text_styles.dart
  - lib/core/theme/theme_controller.dart
  - lib/presentation/pages/home_section.dart
  - lib/presentation/widgets/language_flip.dart
  - lib/presentation/widgets/language_toggle.dart
  - lib/presentation/widgets/nav_bar.dart
  - test/core/app_colors_test.dart
  - test/core/controllers_test.dart
  - test/presentation/phase_six_test.dart
---

## Decided
Timeline rows need two levels of constraints: the inner Column stretches entries, and each entry Stack uses StackFit.passthrough so GlassCards fill those entries. Test both directional edges, not only dots and card start edges.

All three resume buttons use profile.resumePdf and the conditional download_file adapter. The web adapter creates, appends, clicks and removes an anchor with a resolved same-origin URL and the fixed resume filename; the VM adapter records calls. The committed PDF starts with %PDF and is 606826 bytes, below 2 MB.

## Tried and ruled out
Checking only card start edges missed shrink-to-content card end edges. Keep the bundled-font setup for timeline and featured-card height tests: Ahem makes the smaller featured card artificially taller than 520 px. Default ensureVisible places the hero download button behind the sticky nav; use Scrollable.ensureVisible with alignment 0.5 for that tap test.

## Watch out
Featured media widths are 220 desktop and 200 tablet/phone; padding is 24 desktop/tablet and 16 phone, horizontal media/text gap 32, and vertical card margins 12. Preserve alternating layout and Hero tags. Release download verification used flutter build web --wasm --release and node tool/serve.mjs: hero, desktop nav and phone menu each downloaded Mostafa-Mahmoud-Resume.pdf with bytes identical to web/resume.pdf. Reuse existing bilingual ARB labels; no new user-visible copy was needed.
