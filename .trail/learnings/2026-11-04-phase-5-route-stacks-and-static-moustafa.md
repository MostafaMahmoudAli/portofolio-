---
title: Phase 5 route stacks and static video Hero
author: Moustafa-Mahmoud9
date: 2026-11-04
branch: phase-5
cost: { minutes: 16, tokens: 42913 }
touches:
  - lib/core/router/app_router.dart
  - lib/presentation/pages/project_page.dart
  - lib/presentation/widgets/project_media_frame.dart
  - lib/presentation/widgets/project_video_gallery.dart
  - test/presentation/project_page_test.dart
---

## Decided
Nest projects/:slug beneath / so go() preserves Home state and pasted links have Home underneath. Configured routes use opaque CustomTransitionPage fades and zero duration under reduced motion. Hero children and shuttles contain static ProjectPoster/PhoneFrame only; ProjectVideoPlayer is a sibling overlay mounted after the route settles. Keep gallery selection across responsive breakpoint changes.

## Tried and ruled out
Do not pass both errorBuilder and errorPageBuilder: go_router 17.5 asserts that at most one is supplied. Retained the requested errorBuilder for unknown paths, which therefore use its default opaque MaterialPage rather than the custom fade. Unknown slugs are checked inside the project child route and do use the custom page.

## Watch out
Use fixed frame pumps for app tests: aurora/typewriter do not settle. FakeVideoPlatform.live needs a short tester.runAsync real-time tick before asserting disposal. Test Hero flights by finding a static poster outside both page subtrees and comparing platform.created before and during flight. The player fallback repeats the project title, so do not assert exactly one Text(title).
