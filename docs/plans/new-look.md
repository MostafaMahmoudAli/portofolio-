# New look — layout, data display, Arabic and mobile fixes

Source: the browser review of the release build on 2026-11-14 (desktop, dark mode, Arabic,
375 px mobile) plus the resume comparison. This plan supersedes nothing in
`docs/PORTFOLIO_PLAN.md` or `docs/plans/design-pass.md`, except the one decision noted in
"Decisions taken".

**Branch:** `new-look` (Mostafa asked for "new look"; git branch names cannot contain spaces).
**Done when:** every phase below is finished, `flutter analyze` is clean, `flutter test` passes,
and the home page and one project page have been checked in a browser in light, dark, Arabic and
375 px mobile.

## Execution mode — run the whole plan without stopping

- Execute Step 0 and Phases 1 to 9 in order, in one run. **Do not stop to ask Mostafa for a
  review, an approval or a choice between phases or tasks.** He reviews once, at the end, when
  the whole plan is finished.
- Every decision this plan needed from Mostafa is already recorded under "Decisions taken".
  Do not re-ask them.
- When something is unclear, pick the simplest option that fits this plan and the existing
  code, write one line about it under "Agent notes" at the end of this file, and continue.
- When a task cannot be finished (a test that cannot pass, a layout that cannot work), write
  what blocked it under "Agent notes", leave the code in a working state, and continue with
  the next task. Do not stop the run.
- Items under "Deferred" are out of scope. Do not start them and do not ask about them.
- Do not change the colour palette in `lib/core/theme/app_colors.dart`. The only colour change
  in this plan is the per-project accent on project tiles.
- Finish with one report: what was done per phase, what was verified in the browser, what was
  not verified, and everything in "Agent notes".

## Step 0 — do this first

1. Run `git status`. The working tree on `media` has uncommitted changes (`.gitignore`, `.ignore`,
   `.claude/`, `.trail/README.md`). Do not revert, stash-drop or delete them.
2. Create the branch from the current `media` HEAD and switch to it:
   `git switch -c new-look`
3. Make every change in this plan on `new-look` only. **Never push `new-look`, never merge it
   into `main` or any other branch, and never open a PR.** The work stays local on `new-look`.
   Mostafa does the push, merge and everything after that himself.
4. Commit once per phase on `new-look`, with the phase name in the message. Stage only the files
   that phase changed. Leave the pre-existing uncommitted files from item 1 unstaged.

## Rules for the whole plan

- **No media exists yet.** There is no `media/` folder, so every cover, poster, video and the
  profile photo render as placeholders. Every layout must look finished with placeholders.
  Do not add demo or substitute media.
- **No new dependencies.** Use what `pubspec.yaml` already has.
- Keep the existing structure: content in `assets/data/*.json`, models in `lib/core/models/`,
  UI strings in `lib/l10n/app_en.arb` and `app_ar.arb` (regenerate with `flutter gen-l10n`),
  sections in `lib/presentation/sections/`, shared widgets in `lib/presentation/widgets/`.
- Every new or changed string needs both `en` and `ar`.
- Keep directional widgets (`EdgeInsetsDirectional`, `AlignmentDirectional`) so RTL keeps working.
- Keep reduced-motion support (`MediaQuery.disableAnimationsOf`). Add no new animation.
- Keep the lazy sliver list for featured projects, or an equivalent that does not build
  off-screen video players.
- Update the tests in `test/` that a change breaks, and add a test for each new model field.
- Breakpoints stay as in `lib/core/utils/breakpoints.dart`: phone < 600, tablet 600–1024,
  desktop > 1024. Check every new grid at all three.

## Decisions taken

- **Per-project accent colours.** `design-pass.md` (2026-11-08) said "one brand hue, no second
  accent in this pass". This plan reverses that for project tiles only: each tile uses the
  `accent` already stored in `assets/data/projects.json` for its border glow and frame tint.
  Text, links and focus rings stay on `accentInk`, so legibility does not depend on the
  per-project colour.
- **Experience order stays as it is.** The earlier review said the order was wrong. It is not:
  current roles first, then by end date. Do not reorder `experience` in `profile.json`.

- **2026-11-14 — LinkedIn URL.** Mostafa confirmed the portfolio URL is the correct one
  (`https://www.linkedin.com/in/mostafa-mahmoud-ali-4a4932279`). Do not change `profile.json`.
  The resume PDF carries the wrong URL; Mostafa fixes the resume himself.
- **2026-11-14 — WhatsApp button.** Yes. Phase 6 adds a WhatsApp button built from
  `profile.phone` (`https://wa.me/201015078567`).
- **2026-11-14 — no "lead" title.** Mostafa is not a lead mobile engineer. Do not write "lead"
  anywhere in the portfolio content.

---

## Phase 1 — Content and data (`assets/data/`, models)

1. **Impact lines.** Only 2 of 5 featured projects have `impact`. Add one to each of the other
   three, built from facts already in the data:
   - `new-courier-app`: "Offline-first sync · cold-start deep links"
   - `alkharj-business-guide`: "Live on both stores · app + web admin panel"
   - `rehlati-uae`: "Stripe, PayPal & cards · multi-currency checkout"
2. **Arabic name.** The hero shows "Mostafa Mahmoud Ali" in Latin when the locale is Arabic.
   Make `name` in `profile.json` localized (`{ "en": ..., "ar": "مصطفى محمود علي" }`), update
   `lib/core/models/profile.dart` and every reader of `profile.name` (hero, `ProfilePhoto`,
   page title).
3. **Translated city labels.** Store links for the consulate apps carry `label` as plain text
   ("Kuwait", "Riyadh", "Jeddah", "Milan"). Make `label` localized in
   `lib/core/models/project_link.dart` and in the data (الكويت، الرياض، جدة، ميلانو).
4. **Mixed Arabic/Latin text.** Arabic strings that attach "و" directly to a Latin word render
   in the wrong order ("وFFmpeg", "وApp Store", "وCameraX"). In `app_ar.arb`, `profile.json`
   and `projects.json`, put a space between "و" and any Latin word, and reword the About
   summary so the list "BLoC/Cubit, Dio, go_router, get_it" sits together and does not end the
   sentence out of order. Check the result in the browser, not only in the file.
5. **AppRock entry is weaker than the resume.** Add to `experience[0].bullets` (en + ar), from
   the resume: three build flavors (dev/staging/prod) with separate application IDs and Firebase
   projects; the Play App Signing / Firebase SHA-1 mismatch fix; QR-based device linking; FCM
   with actionable notifications and the image/PDF upload pipeline. Keep each bullet to one line
   on desktop.
6. **Skill chips missing from the site but on the resume.** Add `easy_localization`,
   `Firestore`, `Stripe & PayPal` to the fitting groups in `skillGroups`.
7. **Shorter summaries for "More projects".** Summaries are cut at two lines with "…". Rewrite
   the seven non-featured `summary` values (en + ar) so each fits two lines at the card width.

## Phase 2 — Hero (`sections/hero_section.dart`)

1. **Role is shown three times** (availability pill, typewriter line, static title). Remove the
   static `profile.title` line under the typewriter. Under reduced motion the typewriter must
   still show a role.
2. **Stats strip.** Replace the loose `_Stats` row with one band: four cells, large number,
   small label, thin dividers between cells. Desktop and tablet: one row of four. Phone: 2 × 2.
3. **Mobile first screen.** At 375 × 812 the stats are below the fold because the photo circle
   takes a third of the screen. Reduce the phone photo size (currently 176) and the gaps so
   name, role, both buttons and the stats strip fit in the first screen. Remove the empty gap
   under the typewriter line.
4. **Real brand icons.** The social buttons use `Icons.code_rounded` and
   `Icons.work_outline_rounded`. Replace with GitHub and LinkedIn marks drawn in a small
   `CustomPainter` widget (no new package). Reuse the widget in the contact section and the
   "View on GitHub" buttons.
5. Keep `ProfilePhoto` in the hero for now. The phone-frame hero is in "Deferred".

## Phase 3 — Featured projects (`sections/featured_projects.dart`)

1. **Bento grid.** Desktop: the first project (lowest `order`) is one full-width tile; the other
   four sit in a 2 × 2 grid. Tablet: full-width first tile, then two columns if the tiles stay
   readable, else one column. Phone: one column.
2. **Tile content**, in this order: phone frame, impact line, title, subtitle, at most four tech
   chips (a "+N" chip for the rest), one "Details" button. Remove the `summary` paragraph from
   the tile: it repeats the subtitle. Remove the status line from small tiles; keep it on the
   full-width tile.
3. **Per-project accent.** Tint the tile border, hover glow and the phone-frame placeholder with
   `project.accent`. Check contrast of every tile in light and dark.
4. **Store badges.** The consulate tile shows eight badges. Group them by city: one row per
   city with its label and two compact badges, or a city picker with one badge pair. Small
   tiles show at most one badge pair; the rest live on the project page. Apply the same grouping
   in `widgets/store_badges.dart` so the project page gets it too.
5. **Phone height.** Each card is about two screens tall at 375 px. Use a smaller frame on phone
   (about 140 wide), so a tile is at most about one screen tall.
6. Keep the desktop hover tilt only if it still looks right on the smaller tiles; else remove it.

## Phase 4 — More projects (`sections/more_projects.dart`)

1. Replace the `Wrap` with a grid of equal-height cards: 4 columns desktop, 2 tablet, 1 phone.
   No hole in the last row: with seven items, show the first four and put the rest behind a
   "Show all" button that expands in place.
2. Allow three lines for the summary so no card ends in "…" after Phase 1 item 7.
3. Add a small cover thumbnail area at the top of each card that renders the existing
   placeholder, tinted with `project.accent`.
4. Pin the "View on GitHub" button to the bottom of each card.

## Phase 5 — Experience, education, skills

1. **Experience bullets** (`sections/experience_section.dart`). Bullets are plain "• text".
   Bold the key number or technology in each bullet. Do this with a light inline marker in the
   data (for example `**57 test suites**`) parsed into `TextSpan`s; keep the parser to a few
   lines and test it.
2. **Company badge.** Put the company's initial in a small circle on each timeline dot. No logo
   files.
3. **Shorter teaching role.** Merge the two MDQ Academy bullets into one.
4. **Education and certifications.** Cards have random widths and one wraps alone. Split into
   two labeled rows: "Education" (one card) and "Certifications" (equal-width cards).
5. **Languages.** Two chips sit alone above Contact with a large gap. Move them into the
   education block as a third labeled row and remove them from `skills_section.dart`.
6. **Skills grid** (`sections/skills_section.dart`). Replace the single long column with group
   cards: 3 columns desktop, 2 tablet, 1 phone. Each card shows the group title and its first
   five chips; a "Show all" control reveals the rest of that group. Order chips in
   `profile.json` so the five most important come first.

## Phase 6 — Contact and footer (`sections/contact_section.dart`)

1. Make the contact block a full-width band: large headline, email with copy button, then
   buttons for email, WhatsApp (`https://wa.me/201015078567`, digits taken from
   `profile.phone`), LinkedIn and GitHub with the brand icons from Phase 2. Draw the WhatsApp
   mark the same way as the other brand icons.
2. Extract the band into a widget and show it at the bottom of every project page too.
3. Add the phone number as visible text next to the email.

## Phase 7 — Project page (`pages/project_page.dart`)

1. **Two columns on desktop.** Phone frame and platform picker on one side and sticky while the
   text column scrolls; text on the other side. Tablet and phone stay single column.
2. **Quick-facts row** under the title: platforms (from `videos` keys and store links), status,
   and tech chips.
3. **Remove the repeated summary.** The summary paragraph restates the subtitle; show subtitle
   in the header and go straight to the bullets.
4. **Empty gap.** When a project has no store links, the card leaves a blank gap under the tech
   chips. Render the spacing only when there are links.
5. Shrink the 180 px cover banner on desktop or drop it when the cover is a placeholder; it
   pushes the content down and shows nothing.
6. Add the contact band from Phase 6 under the previous/next buttons, then the footer.

## Phase 8 — Checks seen once in review (verify, fix only if real)

1. From the top of the home page, click "Experience" in the nav. In review the first click
   landed mid-section with blank cards for about three seconds; the second click was correct.
   Reproduce in a normal browser window. If real, fix in `_scrollTo` in
   `pages/home_page.dart` or in `widgets/reveal_on_scroll.dart`.
2. Switch language to Arabic. In review the screen stayed blank for about three seconds
   (`widgets/language_flip.dart` should take about 0.6 s). Reproduce; fix if real.
3. Clicking the logo on a project page returned to the home page mid-scroll, not at the top.
   The logo must always land at the top of the home page. Fix it if it does not.

## Phase 9 — Verification

1. `flutter analyze` — no issues.
2. `flutter test` — all pass.
3. `flutter build web --release`, then serve `build/web` (the `web-release` entry in
   `.claude/launch.json`).
4. Check in the browser: home page and one project page, each in light, dark, Arabic and
   375 px mobile, plus 800 px tablet for the new grids.
5. Report what was verified and what was not. Do not claim a phase is done without this check.

## Deferred — needs media or content from Mostafa

- **Hero phone frame.** Replace the profile circle with a tilted phone frame playing the best
  app's video, and move the photo to About. Needs the videos.
- **Screens gallery.** `screens` is empty for all twelve projects, so the gallery never shows.
- **Case-study sections** (Problem, What I built, Result) on the project page. Needs new text
  per project.
- **Outcome numbers** in experience bullets (crash-free rate, startup time, team size). Needs
  real figures.
- **Trimming "More projects"** to the best three or four. Mostafa picks which to keep.

## Agent notes

- Continuation: Phases 1–4 remain committed and will not be redone; existing Phase 5/6 work is preserved and audited before committing separately.
- Tooling: PowerShell blocks the trail.ps1 shim; use trail.cmd without changing execution policy. Keep all .trail changes uncommitted as requested.
- Build-first verification: added WhatsApp translations and removed the unused import. Updated the old “no phone text” regression to require the now-requested visible phone; it was the only failing assertion in the initial suite.
- Phase 5 audit: all six items are implemented: tested bold-marker spans on every bilingual bullet; company initials; one teaching bullet; separate education/certification rows; languages moved to education; responsive 3/2/1 skill cards with independent expansion. Prioritized the first five UI/routing/release chips and added graduation year 2021 in both languages.
- Content correction: consulate apps are developed at AppRock with release updates, not personally published. Changed both project descriptions and the profile summary/stat wording to avoid suggesting personal publication; live listings/download facts remain.
- Test decision: contact text is lazy-built; assert the visible phone after scrolling to it, not at every intermediate scroll offset.
- Build-first gate passed: analyzer clean; all 259 tests pass. Phase 5 build-repair localization travels with Phase 5; the phone regression travels with Phase 6.
- trail check reports broad lexical conflicts against old branch-wide README/design-pass text and ordinary build/release terminology, not semantic regressions. Proceed with the explicit new-look plan (which supersedes the old tile-accent decision); no palette, thumbnail-laziness or scrubbing changes.
- Phase 6: reuse ContactBand after previous/next on every project; preserve the shared copy-email action, visible phone, international-digit WhatsApp URL and existing vector brand icons. Add coverage across all twelve project routes.
- Phase 7: desktop uses a 380 px media side column with one selected platform and picker. Scroll-derived translation pins it within the text column, allowing tall media to scroll into view on short windows; tablet/phone stay single-column. No nested scroll view or new animation.
- Phase 7: remove the empty cover banner entirely (all current media are placeholders), move platform/status/tech facts below the title, omit repeated summary and link spacing for linkless projects, reuse GitHub marks, then previous/next → contact → footer. Existing desktop two-player assertions now check the requested platform picker instead.
- Browser tooling: embedded browser renders but pointer clicks fail with UnknownVizError and has no viewport-resize tool. Use a separate headed Chrome via Playwright installed only under the approved temp directory (no application dependency or repo config change), serving the exact web-release command on port 8081.
- Phase 8 browser reproduction: first Experience click lands at the section heading with visible cards; Arabic switch completes with readable RTL content (about 1.2–1.3 s including automation/screenshot overhead), no multi-second blank reproduced. Leave scroll/reveal/flip behavior unchanged.
- Phase 8 confirmed logo bug: returning from a project preserves Home at Experience. Add a consumed `?top=1` navigation request; wait for the route/viewport to be ready, jump to zero and remove the query. Normal Back still preserves Home scroll.
- Phase 8 verified in headed Chrome after rebuilding: logo now returns to hero/stats; no page errors. Regression tests pass, including consumed top requests and preserved Back behavior.
