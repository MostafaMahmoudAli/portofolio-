---
title: Design pass continuation branding verification and media blockers
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
The approved docs/plans/design-pass.md is the design-pass authority: accent is mint fill; accentInk is #0B6E4A in light and mint in dark for text, lines and focus. This intentionally supersedes older neutral-only light accent notes. Keep all work uncommitted on enhancments until Mostafa reviews it. Implement optional enhancements 1-5 and 7; do not invent proficiency ratings for item 6. Impact labels must reuse numbers already documented in project content. Tajawal Bold is bundled for Arabic headings with its OFL license; body text remains IBM Plex Sans Arabic.

## Tried and ruled out
A BoxShadow inside ClipRRect has its outer blur clipped off: put a shadow-only decoration outside the clipped backdrop and surface. BorderSide.none is black by default but not painted; assert BorderStyle.none, not transparent color. Layered static Hero and player fallbacks cannot both have translucent placeholder fills: composite the tint over the page background first so the static icon does not ghost through the titled player fallback. Do not fabricate project media or replace 404 paths with unrelated imagery.

## Watch out
There are 23 missing media files: profile plus 22 project files (5 times cover/poster/demo plus 7 covers), despite the original plan saying 21 project files. node tool/check_media.mjs checks referenced files and the under-10-MB video budget; it is a deployment blocker, not a replacement for dimension/codec or visual checks. Regenerate all six brand PNGs using flutter test tool/generate_og_image.dart; pixel tests cover dimensions, palette and maskable safe circles. Browser navigation uses hash URLs, e.g. /#/?section=projects. Flutter merges card prose into aria-label, so exact DOM getByText on impact copy fails even when it is visibly rendered; use an aria-label substring. Browser preferences require JSON.stringify values under flutter.themeMode and flutter.languageCode. Reuse fixed-frame widget helpers, fake video platform and bundled fonts for geometry tests. trail check can emit lexical false positives about these explicitly approved accentInk/font changes and the retained sliver/router code: see the verification review notes in the plan.
