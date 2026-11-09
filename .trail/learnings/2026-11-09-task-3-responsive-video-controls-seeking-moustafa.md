---
title: Task 3 responsive video controls seeking and idle lifecycle
author: Moustafa-Mahmoud9
date: 2026-11-09
branch: media
touches:
  - README.md
  - lib/l10n/app_ar.arb
  - lib/l10n/app_en.arb
  - lib/l10n/app_localizations.dart
  - lib/l10n/app_localizations_ar.dart
  - lib/l10n/app_localizations_en.dart
  - lib/presentation/widgets/project_video_player.dart
  - test/presentation/project_video_player_test.dart
  - lib/presentation/widgets/project_video_controls.dart
  - test/presentation/video_controls_test.dart
---

## Decided
Task 3 separates ProjectVideoControls from ProjectVideoPlayer: the controls listen to the existing controller but never acquire one. Position ticks rebuild only the overlay. Autoplay remains visible-only and muted; hidden videos pause and are remuted. Controls are always visible when paused; playback changes and interactions restart a cancellable three-second idle timer. Reduced motion removes the opacity transition. The entire bar is Directionality.ltr, with Western clocks and bilingual labels; Space and arrows control the focused player.

## Tried and ruled out
A single row cannot fit four 48px targets plus a usable slider at 200px. Below 440px, keep the four buttons on one row and the timeline on another; omit clock text below 220px. Scrubbing keeps local drag state and cancels idle hiding, updates only the label/thumb during drag, and seeks exactly once on release; controller position ticks must not override drag state. Keep the existing manager's two-controller cap.

## Watch out
FakeVideoPlatform now records seek targets and reports duration/position. Tests cover seeks and clamps, real slider gestures, position updates during drag, clocks including hours, hide/hover/paused behavior, keyboard, reduced motion and 200px layouts in both languages. All 212 Flutter tests pass, analysis is clean and the full lib/test/tool format check passes. Timers, focus nodes and controller listeners are disposed on eviction/unmount.
