---
title: Phase 6 scroll geometry marquee and consumed navigation queries
author: Moustafa-Mahmoud9
date: 2026-11-04
branch: phase-6
cost: { minutes: 30, tokens: 77216 }
touches:
  - lib/core/router/app_router.dart
  - lib/core/utils/project_accent.dart
  - lib/presentation/pages/home_page.dart
  - lib/presentation/pages/not_found_page.dart
  - lib/presentation/pages/project_page.dart
  - lib/presentation/sections/featured_projects.dart
  - lib/presentation/widgets/nav_menu_sheet.dart
  - lib/presentation/widgets/page_title.dart
  - lib/presentation/widgets/phone_frame.dart
  - lib/presentation/widgets/project_media_frame.dart
---

## Decided
Phase 6 sections retain Home navigation GlobalKeys and use sliver adapters. Timeline progress derives from post-layout scroll geometry; individual dots retain a one-shot appearance flag. Skills uses one visibility-gated Ticker and two chip rows, with a static Wrap under reduced motion. Consume a section query with router.replace('/') only after scrolling and layout corrections complete.

## Tried and ruled out
Default widget finders omit offscreen slivers: the marquee pause regression must use skipOffstage: false to inspect the retained transform after scrolling away. Do not use timer-driven progress for the timeline or pumpAndSettle for the animated home page.

## Watch out
Keep fixed frame tests and fake video platform setup. The full suite including the 12 width/language/theme combinations passed in 55 seconds. Placeholder foreground contrast must derive from project accent brightness rather than the active theme. User-owned .gitignore, .ignore and .claude changes were present before Phase 6.
