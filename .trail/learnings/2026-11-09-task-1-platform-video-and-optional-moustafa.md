---
title: Task 1 platform video and optional screens schema migration
author: Moustafa-Mahmoud9
date: 2026-11-09
branch: media
cost: { minutes: 30, tokens: 648726 }
touches:
  - assets/data/profile.json
  - assets/data/projects.json
  - assets/fonts/Tajawal-Bold.ttf
  - assets/fonts/Tajawal-OFL.txt
  - docs/plans/design-pass.md
  - lib/core/models/project.dart
  - lib/core/theme/app_colors.dart
  - lib/core/theme/app_text_styles.dart
  - lib/core/theme/app_theme.dart
  - lib/l10n/app_ar.arb
---

## Decided
Task 1 migrates Project.videos to ProjectVideos with optional ios/android slots, available as ordered (VideoPlatform, ProjectVideo) records and primary as the first record or null. ProjectScreen supports an optional caption; screens defaults empty. Unknown platform keys and malformed slot/screen objects fail with projects.json, entry and field context. JSON now has Android demos for the five former demo-list projects and iOS only for the two projects carrying App Store links; all projects include screens: []. Existing UI and fixture callers were adapted in the schema commit without adding the task-2 layout yet.

## Tried and ruled out
Do not retain list compatibility APIs on ProjectVideos. Tests should construct typed String-key maps, just as jsonDecode does; a dynamically inferred map is not Map<String,dynamic>. Existing three-demo fixtures must become the two valid platform slots. No real media was present to rename on disk.

## Watch out
check_media.mjs now reports file/field paths per project. With the new platform layout there are 27 missing referenced media files, plus the present resume. Screen arrays remain empty until the owner supplies images. README documents the new schema and ffmpeg commands. Later task commits must preserve the static-only Hero and 2-controller cap.
