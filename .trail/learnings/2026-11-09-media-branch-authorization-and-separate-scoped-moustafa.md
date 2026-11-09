---
title: Media branch authorization and separate scoped task commits
author: Moustafa-Mahmoud9
date: 2026-11-09
branch: enhancments
cost: { minutes: 28, tokens: 644299 }
touches:
  - lib/app.dart
  - lib/core/models/project.dart
  - lib/core/theme/app_colors.dart
  - lib/core/theme/app_theme.dart
  - lib/core/utils/project_accent.dart
  - lib/l10n/app_ar.arb
  - lib/l10n/app_en.arb
  - lib/l10n/app_localizations.dart
  - lib/l10n/app_localizations_ar.dart
  - lib/l10n/app_localizations_en.dart
---

## Decided
The media-enhancements request authorizes a design-pass checkpoint commit on enhancments, then a media branch from it. This supersedes the earlier uncommitted-only rule. Never push or merge. Commit each numbered media task separately, stage only explicitly scoped touched files, and never git add -A. Preserve unrelated .claude, .ignore, .trail/README.md and graft-ignore work.

## Tried and ruled out
The design checkpoint is not a claim that owner media or mobile Lighthouse acceptance is finished. Keep the documented 23 missing media files and mobile Performance 63 versus target 80 visible. Do not fabricate media, ratings or a passing audit.

## Watch out
Use directional Flutter layout, AppPalette ink for light-theme text, bilingual ARB strings, fixed-frame tests and FakeVideoPlatform. Media schema changes must migrate all existing fixtures and callers in the same data-model commit so intermediate commits still analyze and test.
