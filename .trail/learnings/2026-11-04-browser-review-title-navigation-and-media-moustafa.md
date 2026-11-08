---
title: Browser review title navigation and media fixes
author: Moustafa-Mahmoud9
date: 2026-11-04
branch: phase-5
cost: { minutes: 114, tokens: 794523 }
touches:
  - lib/presentation/pages/home_page.dart
  - lib/presentation/widgets/page_title.dart
  - lib/presentation/pages/project_page.dart
  - lib/presentation/widgets/phone_frame.dart
  - lib/presentation/widgets/project_poster.dart
  - test/presentation/project_page_test.dart
---

## Decided
Browser review found that project titles survived Back and home navigation. Give every page a PageTitle that mounts a Title only while its route is current. Mounting a fresh Title resends the browser label without replacing the retained page subtree. Project nav links carry HomeSection.name in a section query parameter. Home waits for route transitions and viewport dimensions, then scrolls to the requested section and corrects lazy-sliver height estimates.

Use PhoneFrame.mediaLayer for both the static poster and the sibling video overlay; clip both against the same phone boundary. Share ProjectPlaceholder between poster and player, tinted with the project accent. Read covers from project.cover, treating null as a placeholder. ProjectAccent owns the hex-to-Color conversion. Unknown-path errorBuilder transitions remain unchanged, explicitly accepted in browser review.

## Tried and ruled out
An unchanged Title does not resend its label when a retained route returns. A single post-frame callback can run before Home has viewport dimensions after dismissing the mobile menu. A zero-duration ensureVisible can use an estimated lazy-list extent, so correct its target after layout. Independently rounded video overlays leave poster-colored corner slivers.

## Watch out
Keep fixed-frame pumps. Record SystemChrome.setApplicationSwitcherDescription calls to test actual title changes, not just widget properties. Test project-to-home links for all sections in both languages and at phone/desktop widths. The Arabic menu footer needs wrapping and the sheet needs enough height. Preserve plain Back scroll offsets: only an explicit section request triggers section scrolling.
