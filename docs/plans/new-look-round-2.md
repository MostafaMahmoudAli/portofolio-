# New look — round 2

**Branch:** `new-look` (continue on it). **State:** `docs/plans/new-look.md` Phases 1–9 are done and committed. Do not redo them.

**Done when:** `flutter analyze` is clean, `flutter test` passes, `flutter build web --release` succeeds, and the browser check in Task 8 passes.

## Execution mode

- Run Tasks 1–8 in one run. No review, approval or choice questions. Mostafa reviews once at the end.
- Unclear point: take the simplest option, write one line under "Agent notes" at the end of this file.
- Blocked task: write the blocker under "Agent notes", leave the code working, continue.
- Never push, never merge, never open a PR. One commit per task, staging only that task's files.
- Leave `.gitignore`, `.claude/`, `.ignore`, `.trail/`, `docs/plans/resume-update.md` and `test-output.txt` uncommitted.
- Same rules as the first plan: no new dependencies, no palette change in `lib/core/theme/app_colors.dart`, every string in English and Arabic, directional widgets, reduced motion respected, tests updated with the code.
- No media exists yet. Every layout must look finished with placeholders.

## Task 1 — Add the project "Egypt Abroad" (مصري بالخارج)

Add to `assets/data/projects.json` as the first featured project (`order` 1; shift the others down).

- `slug`: `egypt-abroad`
- `title`: en "Egypt Abroad", ar "مصري بالخارج"
- `subtitle`: en "Consular services super-app for Egyptians abroad", ar: translate
- `impact`: en "Built from scratch · live on both stores", ar: translate
- `status`: live on Google Play and the App Store (same wording style as the other live projects)
- `summary` (en): "Consular services super-app for Egyptians abroad, built from scratch with the team at AppRock, in Arabic and English."
- `bullets` (en), describe the product, not personal ownership:
  1. "Citizens book, reschedule and cancel consulate appointments for themselves and family members."
  2. "Track transactions and fees, file complaints with ticket chat, and follow consulate news, holidays and locations."
  3. "Real-time AI assistant, OCR national-ID verification at sign-up, biometric and Google/Apple sign-in, and QR device linking."
  4. "Push notifications that open the right appointment."
- `tech`: Flutter, Clean Architecture, Cubit, Dio, SSE, go_router, Firebase, Flavors
- `links`: Google Play `https://play.google.com/store/apps/details?id=com.approc.mfa.egyptconsulate`, App Store `https://apps.apple.com/app/id6806766895`
- `videos`: `ios` and `android` entries following the same pattern as `alkharj-business-guide` (files do not exist yet; placeholders must render)
- `cover`: `media/egypt-abroad/cover.jpg`
- `accent`: a colour not used by another featured project
- Write natural Arabic for every field. Keep a space between "و" and any Latin word.
- Do not state a team size anywhere. Do not say Mostafa built a named feature alone.

## Task 2 — Featured list changes

1. `rehlati-uae`: set `featured` to false. It moves to "More projects". It has no GitHub link and no store link (listing retired): its card shows the status text where other cards show the GitHub button. Remove its `videos` entry.
2. `responsive-dashboard`: set `featured` to true, last in featured order. It is a web/desktop project with no video: its featured tile and project page must show a landscape (wide) placeholder frame, not a phone frame. Use a wide frame whenever a featured project has no `videos`. Add an `impact` line (en: "Adaptive layouts for desktop, tablet and mobile", plus Arabic).
3. Featured order becomes: Egypt Abroad, Egypt Consulate Apps, New Courier App, Alkharj Business Guide, Remix, Responsive Dashboard (six tiles).
4. Bento grid with six tiles: first tile full width, the others in two columns; when the count leaves one tile alone in the last row, that tile spans the full width. Tablet and phone rules stay as they are. No empty cell at any width.
5. "More projects" still has seven cards; "Show all" behaviour stays.

## Task 3 — Images on "More projects" cards and their project pages

Today a card always draws the tinted placeholder, even when `cover` is set, and the card cannot open its project page.

1. Card thumbnail: show the project's `cover` image when the file loads; fall back to the tinted placeholder when it is missing or fails. Lazy-load it.
2. Make the card open the project page (`/projects/<slug>`): the title and thumbnail are the tap target, with a visible focus ring and a semantic label. The "View on GitHub" button stays and still opens GitHub.
3. The project page already shows `screens` (many images) through `ScreensGallery`. Confirm it works for a non-featured project and add a test with two screens.
4. Document in `README.md`, in two or three lines, how to add media for a project: one `cover` for the card, any number of `screens` for the project page.

## Task 4 — Remove education and certifications from the site

1. Remove the "Education & certifications" block from `lib/presentation/sections/experience_section.dart` (education row and certifications row).
2. Keep the languages chips: move them into the About section, under the summary.
3. Remove l10n keys that become unused and regenerate. Keep `education` and `certifications` in `profile.json` and the model only if removing them needs more than a small change; otherwise remove them too and fix the tests.
4. The resume PDF keeps its education section. Do not touch `web/resume.pdf` content.

## Task 5 — Content corrections to match the resume

In `assets/data/profile.json`, `experience[0]` (AppRock), en + ar:

1. Bullet 1: name the product. "…across a **23-module** consular super-app, **Egypt Abroad** — …"
2. OCR/security bullet: change "Shipped **OCR** national-ID verification and hardened the app with…" to "Contributed to **OCR** national-ID verification and helped harden the app with…".
3. Keep the stats as they are (6 live apps, 57 test suites, 23 modules). Mostafa decided this.
4. Check the About summary still reads correctly with Egypt Abroad added; do not add new claims.

## Task 6 — Small layout fixes seen in review

1. Phone width (375): the email in the contact band breaks into two lines ("moustafamahmoudali16 / 97@gmail.com"). Keep it on one line (scale the text down to fit; never break the address). Check English and Arabic, home page and project page.
2. Phone width: the consulate tile lists eight store badges in one long column. Show them as city rows (label + two badges on one row), as planned in Phase 3 item 4.
3. Nav bar: the language button and the theme button touch each other when selected, hovered or focused (their highlight shapes meet with no gap). Add a gap of about 8 px between them so the two highlights never touch. Check desktop and the phone nav, English and Arabic.
4. After Task 4 the gap between Experience and Skills must match the gap between other sections.

## Task 7 — Resume PDF

`web/resume.pdf` has uncommitted changes (newer resume). Commit it alone as "Update resume PDF".

## Task 8 — Verification

1. `flutter analyze` clean, `flutter test` all pass, `flutter build web --release` succeeds.
2. Browser check at 1440, 800 and 375 px, light and dark, English and Arabic:
   - home page: six featured tiles with no empty cell; More projects with RehlatiUAE and without Responsive Dashboard; no education block; languages in About; contact email on one line;
   - project pages: `egypt-abroad`, `responsive-dashboard` (wide frame), `rehlati-uae`, and one GitHub project opened from its card.
3. Final report: what changed per task, what was verified, what was not, all agent notes.

## Agent notes

- Task 1: add Egypt Abroad as a team-built product with natural Arabic, two platform placeholder paths and an orange accent unused by the other featured projects. Shift all existing order values by one; keep the fixed profile stats unchanged.
- Execution: continue on `new-look`, preserve all listed uncommitted files (including the newer PDF until Task 7), no push/merge/PR. Use `trail.cmd` because PowerShell blocks the `.ps1` shim.
- Task 2: use orders 1–6 for the six featured projects and 7 for RehlatiUAE. The last bento row shares its whole width, including tablet; preserve lazy slivers. A shared 16:10 browser-style frame handles featured projects without videos on Home and their detail pages; no placeholder phone or video controller is created.
- Task 2: RehlatiUAE keeps its retired-listing status in place of a nonexistent GitHub button, with no videos or store link. More projects still contains seven entries (three GitHub buttons before expansion, six after).
- Task 2 tests: update old “no poster for video-less featured projects” assertions to the new landscape frame; keep sticky-media regression on the longer consulate fixture rather than depending on whichever project happens to be first.
- Task 3: visibility-gate cover requests, retain the project-tinted fallback while loading/on error, and make thumbnail+title one labeled, keyboard-focusable project link with an explicit ink focus ring. GitHub remains a separate action. Verify the existing gallery with a two-screen non-featured fixture; document cover/screens paths in README.
- Trail check: most findings are lexical matches to unrelated historical prose. Applied the relevant InkWell guidance by resolving the directional radius; preserve typed media slots, controller limits, route guards and lazy galleries. No substitute media were added.
