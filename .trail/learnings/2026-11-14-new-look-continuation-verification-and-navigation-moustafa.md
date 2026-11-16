---
title: New-look continuation verification and navigation
author: Moustafa-Mahmoud9
date: 2026-11-14
branch: new-look
cost: { minutes: 27, tokens: 247783 }
touches:
  - docs/plans/new-look.md
  - lib/core/router/app_router.dart
  - lib/presentation/pages/home_page.dart
  - lib/presentation/pages/project_page.dart
  - test/presentation/project_page_test.dart
  - lib/presentation/widgets/project_platform_gallery.dart
  - test/presentation/contact_band_test.dart
  - test/presentation/platform_gallery_test.dart
  - lib/presentation/sections/contact_section.dart
  - lib/presentation/widgets/contact_band.dart
---

## Decided
Continue new-look locally with one commit per phase, no push/merge/PR, and leave .trail, .claude, .ignore, resume-update plan and test-output uncommitted. Consulate apps are developed at AppRock and receive release updates, not personally published; education year is 2021. Project desktop uses a single-platform sticky side column, while tablet retains the two-frame gallery.
## Tried and ruled out
PowerShell blocks trail.ps1; trail.cmd works without an execution-policy change. Embedded browser pointer actions failed with UnknownVizError and cannot resize; headed Chrome using temp-only Playwright provides real viewport checks without app dependencies. Immediate equal screenshots can precede visibility-detector callbacks, so require sustained pixel stability. Running browser captures, full tests and web build concurrently can exceed 120 seconds; run final verification separately.
## Watch out
Project logo must request consumed ?top=1 after route/viewport readiness; Back intentionally preserves Home scroll. Pinning uses RenderAbstractViewport.getOffsetToReveal, not stale pre-layout global coordinates. Use a GlobalKey to preserve gallery selection across column reparenting. ContactBand must explicitly stretch to content width and keep email/phone LTR within RTL. Preserve the empty tablet skill-grid cell for equal card widths.
