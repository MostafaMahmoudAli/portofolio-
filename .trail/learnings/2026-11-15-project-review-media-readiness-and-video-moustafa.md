---
title: Project review media readiness and video ownership
author: Moustafa-Mahmoud9
date: 2026-11-15
branch: new-look
touches:
  - docs/plans/resume-update.md
---

## Decided
Project-wide review on Nov 15: flutter analyze passes, all 292 existing tests pass, and release Wasm build succeeds. Media validation fails with only 1 of 33 referenced media files ready. Deployment workflow builds without analyze, test, or media validation.
## Tried and ruled out
A temporary focused widget test mounted two ProjectVideoPlayer owners for the same URL and explicitly delivered visibility to the second owner. FakeVideoPlatform recorded two creations because acquire returns the existing controller and _ensureController initializes it again. The temporary test was removed after the review. Normal visibility callbacks can collide because detector keys use the same URL.
## Watch out
LandscapeProjectFrame mounts players without ProjectMediaFrame's current/settled-route guard. Home remains mounted under project routes, so web-demo navigation needs ownership isolation or route-gated playback. This is a code-level reproduction, not a browser reproduction. Missing media currently masks real playback behavior.
