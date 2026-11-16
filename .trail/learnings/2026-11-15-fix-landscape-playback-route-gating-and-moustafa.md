---
title: Fix landscape playback route gating and exclusive video ownership
author: Moustafa-Mahmoud9
date: 2026-11-15
branch: new-look
touches:
  - lib/presentation/widgets/landscape_project_frame.dart
  - lib/presentation/widgets/project_video_player.dart
  - test/presentation/project_video_player_test.dart
  - test/presentation/round_two_projects_test.dart
  - docs/plans/resume-update.md
---

## Decided
Fixed review finding 2: LandscapeProjectFrame now follows the same current/settled-route gate as phone media and shows its poster during transitions. Acquiring an already managed URL evicts its old owner and creates a fresh controller; initialized controllers are never handed to another player. VisibilityDetector keys use State identity, not URL. Ignore stale initialization errors after eviction/unmount.
## Tried and ruled out
URL equality alone cannot establish controller ownership. Sharing the URL-based detector key also suppresses callbacks between distinct mounted players. Regression tests now exercise same-URL ownership transfer, old-owner removal, leak-free teardown, and Home/detail/Back route transitions.
## Watch out
Keep retained Home state for navigation. Keep the two-controller limit and identity check in release so old owners cannot dispose a replacement. Validation: flutter analyze clean; 69 tests across player, controls, project pages and round-two projects passed.
