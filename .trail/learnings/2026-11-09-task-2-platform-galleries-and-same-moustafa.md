---
title: Task 2 platform galleries and same-platform static Hero
author: Moustafa-Mahmoud9
date: 2026-11-09
branch: media
cost: { minutes: 30, tokens: 648726 }
touches:
  - README.md
  - assets/data/projects.json
  - lib/core/models/project.dart
  - lib/core/models/project_screen.dart
  - lib/core/models/project_video.dart
  - lib/core/models/project_videos.dart
  - lib/presentation/sections/featured_projects.dart
  - lib/presentation/widgets/project_video_gallery.dart
  - test/core/content_repository_test.dart
  - test/core/project_media_test.dart
---

## Decided
Task 2 replaces ProjectVideoGallery with ProjectPlatformGallery. Phones keep a selected platform across breakpoints; tablet/desktop render both available slots side by side. Shared VideoPlatformPicker uses localized labels and palette fills/ink. PhoneFrame defaults Android, uses platform-specific symmetric cameras/corners, and both static and playback layers receive the same platform. Featured cards start at primary and carry the selected platform in the details URL; gallery Hero identity stays tied to that incoming platform, so the other frame never shares the tag. No-video pages omit the gallery.

## Tried and ruled out
Do not put a controller inside a Hero or its shuttle. The retained static-only Hero and settled-route playback overlay remain separate. The gallery uses platform records, not index paging or duplicate demo fallbacks. The shared 2-controller manager is unchanged; simultaneous visible iOS/Android frames use its two slots. Featured desktop frames use width 210 so the new 48px picker keeps the complete card within the existing 520px height budget.

## Watch out
ProjectPage accepts platform from the router query. Invalid or unavailable platform choices fall back to primary; a phone switch does not change which platform may own the return Hero. Keep fixed-frame helpers and FakeVideoPlatform. Both-language layout/choice/Hero tests, camera symmetry, cap tests and all existing project-page tests pass; analysis is clean.
