---
title: Round 2 projects and responsive layout contracts
author: Moustafa-Mahmoud9
date: 2026-11-14
branch: new-look
touches:
  - docs/plans/new-look-round-2.md
  - lib/presentation/sections/more_projects.dart
  - test/core/content_repository_test.dart
  - test/presentation/projects_sections_test.dart
  - test/presentation/round_two_projects_test.dart
  - test/presentation/screens_gallery_test.dart
  - docs/plans/resume-update.md
  - test-output.txt
---

## Decided
Round 2 continues new-look with one local commit per task, no push/merge/PR and all listed local/tooling files uncommitted. Egypt Abroad is first, Responsive Dashboard is the sixth featured tile, and RehlatiUAE moves to the seven-card More section without video/store links. A trailing single bento tile spans the full row. Featured projects without videos use the shared 16:10 LandscapeProjectFrame on Home and detail pages. Education/certification site fields were small to remove, while the supplied PDF stays byte-for-byte unchanged and gets its own commit.
## Tried and ruled out
Browser innerText alone misses Flutter ARIA labels, and offscreen semantics bounds do not prove viewport coverage. Combine normalized text with aria-label names and inspect actual scroll captures. Phone semantics counts include only a subset of offscreen GitHub actions; do not confuse that with the data/widget count. Keep visibility batching in the screenshot stability budget. The old 200 px TechChip test ceiling breaks on Clean Architecture under Ahem; compare label width plus padding and border instead.
## Watch out
More card cover requests are visibility-gated and retain project-tinted loading/error fallbacks; its thumbnail/title semantic action is separate from the external GitHub action and has a resolved directional focus ring. Non-featured two-screen fixtures must keep a featured project in retained Home's data and target the main scrollable, not the horizontal gallery. The email uses FittedBox(scaleDown), maxLines 1, softWrap false and LTR. All four consulate city rows appear on phones, each with a label and two compact 48 px-high badges. Desktop small tiles still cap at one city. Language/theme controls have an explicit 8 px gap in nav and menu; removing trailing timeline padding restores the usual section gap.
