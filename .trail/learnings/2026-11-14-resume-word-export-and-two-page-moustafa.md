---
title: Resume Word export and two-page verification
author: Moustafa-Mahmoud9
date: 2026-11-14
branch: new-look
cost: { minutes: 2, tokens: 18795 }
touches:
  - lib/l10n/app_ar.arb
  - lib/l10n/app_en.arb
  - lib/l10n/app_localizations.dart
  - lib/l10n/app_localizations_ar.dart
  - lib/l10n/app_localizations_en.dart
  - lib/presentation/sections/hero_section.dart
  - lib/presentation/sections/more_projects.dart
  - lib/presentation/widgets/social_button.dart
  - test/presentation/more_projects_test.dart
  - lib/core/models/project.dart
---

## Decided
Update the external resume through python-docx run text, then export with Word 2010 COM ExportAsFixedFormat(17). Preserve original run and paragraph formatting. The execution plan in docs/plans/resume-update.md forbids commits, pushes and PRs.

## Tried and ruled out
The exact expanded text produced three pages. The plan permits shortening Summary first, then Remix bullets. A page break before Freelance retained its original page-two start without an orphan heading. Final export is two pages.

## Watch out
LinkedIn is a complex HYPERLINK field, not a document relationship; its target was already correct. Normalize whitespace in PDF text checks because Firebase phone authentication crosses a line. Remix saves videos in app documents and shares with share_plus, not directly to the gallery. Recheck the app before changing that claim. Verification compared original run properties, fonts, sizes, styles, margins, hyperlinks and unrelated paragraphs. The final portfolio PDF must match the external PDF byte for byte.
