# Design pass — colors, surfaces, layout polish

Source: the live-site review of `https://mostafamahmoudali.github.io/portofolio-/` against the
code in `lib/` at `ddd2eee` (Graphite and mint color system). This document is the plan for the
next design pass; it supersedes nothing in `docs/PORTFOLIO_PLAN.md`.

**Branch:** `enhancments` (created from `main`; the spelling is Mostafa's).
**Done when:** the live site has no 404 media, no Flutter-blue icons, every accent use is legible
in both themes, and the hero and cards read as one system.

Mostafa provides the media files listed in "Inputs from Mostafa" — nothing in Phase 2 or later
can be verified as finished without them.

### Decisions taken

- **2026-11-08 — accent token split.** Mostafa chose the token name `accentInk`: `accent` stays
  the mint fill (`#34D399` in both themes), `accentInk` is the text/line/border/focus color
  (`#0B6E4A` light, `#34D399` dark). One brand hue, no second accent in this pass.
- **2026-11-08 — execution mode.** Work lands on `enhancments` **uncommitted**: no commit, no
   push, no merge until Mostafa reviews the result.
- **2026-11-09 — continuation audit.** The inherited working tree contained the code for
  Phases 1 and 4 (roughly 45% of the numbered work, counting optional enhancements), but
  branding, enhancements and verification were unfinished. Two inherited palette assertions
  failed because `BorderSide.none` was tested by color rather than `BorderStyle.none`.

### Execution status — 2026-11-09

**Follow-up authorization:** the media-enhancements request now explicitly authorizes committing
this design-pass checkpoint before creating `media` from `enhancments`. This supersedes the
earlier uncommitted-only execution decision, not the acceptance gates below. Missing owner-supplied
media, mobile performance, optional proficiency ratings and live approval remain documented open
items; this checkpoint must not be described as fully accepted or deployed.

**Estimated progress:** inherited work ~45%; after this continuation ~80% overall. This is a
checklist-based estimate including optional enhancements and verification, **not** a claim that
the live site's acceptance criteria pass. Media, mobile performance, visual approval and release
verification remain open.

| Phase | Status |
|---|---|
| 1 — Palette split | Implemented. Also corrected the card shadow: the inherited implementation clipped off the outer shadow. |
| 2 — Media | **Blocked:** all 23 media files are missing (profile + 22 project files, not 21). Resume is present. No substitute photos, screenshots or demos were fabricated. |
| 3 — Brand assets | Generated all six PNGs using bundled Space Grotesk/Inter; monogram artwork fits the maskable safe circle. **Visual approval and installed-PWA/live-preview checks still needed.** |
| 4 — Component polish | Implemented, retaining the previous agent's work. Browser inspection also caught ghosted fallback icons where the static Hero poster and video placeholder overlapped; the placeholder tint is now composited to an opaque fill. |
| 5 — Enhancements | Items 1–5 and 7 implemented: active desktop/mobile navigation, 2px directional progress, bilingual availability, evidence-backed impact labels, eyebrows, and bundled Tajawal Bold headings. **Item 6 deferred:** proficiency levels need Mostafa's ratings; existing skill groups stay intact rather than making up expertise claims. |
| 6 — Verification | Analysis/tests/release build pass. Desktop performance passes; **mobile performance fails the target**. See results below. Deployment/live re-check deliberately not performed before review. |

Regenerate the favicon, PWA icons and OG image with:

```bash
flutter test tool/generate_og_image.dart
```

Validate media before deployment with:

```bash
node tool/check_media.mjs
```

The media check fails until every path referenced by the JSON exists and each video is under
10 MB; it does not replace visual/dimension/codec checks. Tajawal Bold is from Google Fonts
(`ofl/tajawal/Tajawal-Bold.ttf`); its license is bundled as `assets/fonts/Tajawal-OFL.txt`.
Impact copy uses numbers already present in the project descriptions, with no invented metrics.

#### Verification results

- `flutter analyze`: clean.
- `flutter test`: **181 tests passed**, including the 12 width/theme/language layout sweeps,
  light-theme ink checks, scroll spy/progress, font selection, PNG dimensions, and maskable
  safe-circle pixel checks. The brand generator also passes independently.
- `flutter build web --wasm --release`: succeeded. Flutter prints an existing
  `CupertinoIcons` font lookup warning; no Cupertino icon package is used by this pass.
- Browser sweep: 375/768/1440px × light/dark × English/Arabic, hero and first featured card.
  Correct document `lang`/`dir`, no JavaScript exceptions, and only the known missing-media
  HTTP failures. Screenshots and request summaries are in `build/design-pass/`.
- Lighthouse 13.6, Chrome headless, the unmodified Pages-like local server, separate desktop
  and mobile runs against the final Wasm release build:

  | Audit | Desktop | Mobile | Gate |
  |---|---:|---:|---|
  | Performance | 92 | **63** | Mobile **does not pass** the ≥80 target. |
  | Accessibility | 100 | 100 | Does not replace widget contrast checks or manual canvas/RTL review. |
  | Best practices | 77 | 77 | Missing-media 404s plus engine API deprecations. |
  | SEO | 100 | 100 | Local audit only. |

  Reports: `build/lighthouse-desktop.report.html` / `.json` and
  `build/lighthouse-mobile.report.html` / `.json`. Mobile's simulated total blocking time is
  ~2.31s, speed index ~8.4s, and total payload ~5.5 MiB. The report attributes most CPU work
  to `main.dart.mjs` and `skwasm.js`; this needs a startup/performance pass, not a false
  completion tick or relaxed throttling. The existing server deliberately omits COOP/COEP to
  match Pages; headers were not changed to improve the score artificially. No pre-change
  Lighthouse baseline was captured, so enhancement non-regression is not asserted.

  Media, the mobile performance target, installed-PWA/live link-preview approval and deployment
  remain acceptance blockers. No commit, push or deployment was performed.
- `trail check`: exits 1 with 17 lexical warnings. The design's explicitly approved
  `accentInk` split, placeholder tint, stronger aurora and separate Arabic display face
  intentionally supersede the older neutral-only presentation notes. Other matches misread
  existing bundled-font practices as prohibitions, or match unrelated words in the retained
  sliver/router structure. Navigation's existing multi-frame seeking/correction is preserved;
  the new post-frame callback only samples already-laid-out geometry for the scroll spy.
  These warnings were reviewed, not reported as a clean check.

---

## Why this pass exists

The graphite/mint system replaced the old purple/cyan gradients, but three things were left
half-migrated:

1. **Every image is missing.** `web/media/` is not in the repository. `assets/data/profile.json`
   points at `media/profile.jpg`, and `assets/data/projects.json` references 22 files under
   `media/<slug>/`. All of them return 404 on the live site, so the hero renders the "MM"
   initials fallback and every featured card renders an empty mint-outlined box.
2. **Brand assets are still the Flutter defaults.** `web/favicon.png` and all four
   `web/icons/Icon-*.png` are the blue Flutter logo. `web/og-image.png` was regenerated for the
   new palette but is mostly empty space.
3. **The accent token is over-loaded.** `#34D399` is used as a fill *and* as a text/line/border
   color. It scores 9.21:1 on the dark background and **1.74:1** on the light one, so in light
   mode the experience timeline, chip hover borders, card hover borders and focus rings are
   effectively invisible.

---

## Color system

### Palette

One brand hue (mint). The only change is splitting the accent into a fill color and an ink
color, because a single mint cannot pass contrast on both backgrounds.

| Token | Light | Dark | Used for |
|---|---|---|---|
| `background` | `#F3F4F1` | `#15191A` | page |
| `surface` | white 88% | white 5% | glass cards, chips, sheets |
| `surfaceBorder` | `#23272A` at 14% | white at 11% | card and chip hairlines |
| `text` | `#23272A` | `#DCE1DD` | headings and body |
| `mutedText` | `#5F6763` | `#8E9691` | secondary text |
| `accent` (existing) | `#34D399` | `#34D399` | fills only: buttons, rings, dots |
| `accentInk` (new) | `#0B6E4A` | `#34D399` | text, lines, borders, focus |
| `onAccent` | `#15191A` | `#15191A` | text on an accent fill |

### Measured contrast (WCAG 2.1)

| Pair | Ratio | Verdict |
|---|---|---|
| `text` on `background` (light) | 13.63 | AAA |
| `text` on `background` (dark) | 13.37 | AAA |
| `mutedText` on `background` (light) | 5.27 | AA |
| `mutedText` on `background` (dark) | 5.84 | AA |
| `onAccent` on `accent` | 9.21 | AAA |
| `accentInk` on `background` (light) | 5.69 | AA |
| `accentInk` on white card (light) | 6.28 | AA |
| `accentInk` on `background` (dark) | 9.21 | AAA |
| `accent` on `background` (light) | 1.74 | **fails — fills only** |

The last row is the reason `accent` is restricted to fills. `accentInk` is the only accent value
allowed to carry text, a 1px line, or a hairline border.

### Surfaces

| | Light | Dark |
|---|---|---|
| card vs page separation | 1.10 → **1.13** (surface 88%) | 1.12 → **1.16** (surface 5%) |
| border vs page | 1.24 → **1.34** | 1.33 → **1.33** |
| card shadow | none → `rgba(35,39,42,.06)`, blur 24, y 6 | `rgba(0,0,0,.35)`, blur 24, y 6 |

Separation above ~1.1 is not a WCAG requirement — cards are not text. The numbers are here so
the change is measurable rather than a matter of taste.

### Aurora

Light mode currently paints mint at 10% over `#F3F4F1`, which is invisible. Switch the aurora
to `accentInk` and raise the opacity to 14% in both themes. The dark aurora keeps mint.

### Optional second hue

A second hue may be introduced later for **decoration only** — never text, never a button fill:

- teal `#0F766E` — 3.24:1 on graphite, graphic use only
- violet `#6D28D9` — 6.44:1 on light, usable as text if a text-grade accent is ever needed

Not part of this pass. Single-hue coherence is worth more than the depth.

---

## Phases

### Phase 1 — Palette split

**Files:** `lib/core/theme/app_colors.dart`, `lib/core/theme/app_theme.dart`,
`test/core/app_colors_test.dart`, `test/core/palette_contrast_test.dart`,
`test/presentation/palette_test.dart`.

1. Add `accentInk` to `AppPalette`: constructor field, `copyWith`, `lerp`.
   - `AppPalette.light.accentInk = Color(0xFF0B6E4A)`
   - `AppPalette.dark.accentInk = Color(0xFF34D399)`
2. In `app_theme.dart`, route every **ink** use to `accentInk`:
   - the hover/focus `outline` border side
   - `focusColor`
   - the `TextButton` / `OutlinedButton` focus border
3. Leave `accent` on the filled button background and `onAccent` on its foreground.
4. Raise surface opacity and border opacity per the table above, and add the card shadow in
   `lib/presentation/widgets/glass_card.dart` (light: `rgba(35,39,42,.06)`; dark:
   `rgba(0,0,0,.35)`).
5. Move the aurora to `accentInk` at 14% in `lib/presentation/widgets/aurora_background.dart`.
6. Move the experience timeline line and the timeline dot fill to `accentInk` in
   `lib/presentation/sections/experience_section.dart` and
   `lib/presentation/widgets/timeline_dot.dart`.

**Tests to update:**

- `test/core/app_colors_test.dart` — the "mint and its foreground stay identical across theme
  interpolation" test asserted that `accent` is theme-independent. `accentInk` **is**
  theme-dependent now, so that expectation moves to `accent` only, and a new expectation pins
  `accentInk` to `#0B6E4A` in light and `#34D399` in dark.
- `test/core/palette_contrast_test.dart` — the existing test asserts that light `accent` has
  contrast **below** 4.5. Keep that assertion (it documents the fill-only rule) and add
  `accentInk` contrast ≥ 4.5 against both the background and the composited surface.
- `test/presentation/palette_test.dart` — hover-border expectations currently resolve to
  `palette.accent`; they resolve to `palette.accentInk` now.

**Done when:** `flutter analyze` is clean, `flutter test` passes, and in light mode the timeline
line, chip hover border and focus ring are all clearly visible on the page background.

### Phase 2 — Media assets (blocked on Mostafa)

**Files:** `web/media/**` (new), `assets/data/profile.json`, `assets/data/projects.json`.

The repository has no `web/media/` directory and no commit history for it. Required files,
taken from the paths already referenced in the JSON:

```
web/media/profile.jpg                        (square, >= 800px)

web/media/egypt-consulate-apps/    cover.jpg  poster.jpg  demo.mp4
web/media/new-courier-app/         cover.jpg  poster.jpg  demo.mp4
web/media/alkharj-business-guide/  cover.jpg  poster.jpg  demo.mp4
web/media/remix/                   cover.jpg  poster.jpg  demo.mp4
web/media/rehlati-uae/             cover.jpg  poster.jpg  demo.mp4
web/media/responsive-dashboard/    cover.jpg
web/media/rick-and-morty-app/      cover.jpg
web/media/vocabs-app/              cover.jpg
web/media/flutter-google-maps/     cover.jpg
web/media/bookly-app/              cover.jpg
web/media/flutter-shop-app/        cover.jpg
web/media/flutter-social-app/      cover.jpg
```

Encoding, from `docs/PORTFOLIO_PLAN.md` section 5:

```bash
ffmpeg -i raw.mp4 -vf "scale=-2:1280,fps=30" -c:v libx264 -crf 28 -preset slow -c:a aac -b:a 96k -movflags +faststart demo.mp4
ffmpeg -ss 1 -i demo.mp4 -frames:v 1 -q:v 3 poster.jpg
```

Under 10 MB per video. JPG and WebP posters, at most ~1280px on the long side.

Also required by `web/index.html` and `web/manifest.json` but already present:
`web/resume.pdf` ✅.

**Done when:** no 404 in the browser network tab on any page of the site, and the hero shows the
photo rather than the initials fallback.

### Phase 3 — Brand assets

**Files:** `web/favicon.png`, `web/icons/Icon-192.png`, `web/icons/Icon-512.png`,
`web/icons/Icon-maskable-192.png`, `web/icons/Icon-maskable-512.png`, `web/og-image.png`,
`tool/generate_og_image.dart`.

1. Replace the Flutter logo in the favicon and the four app icons with an "MM" monogram:
   graphite `#15191A` background, mint `#34D399` letters. The maskable variants need the
   monogram inside the 80% safe zone.
2. Redesign the OG image. The current one is 80% empty. Target layout, 1200×630:
   - graphite background
   - mint rule, 180×10, top left
   - "Mostafa Mahmoud Ali" at 64px, Space Grotesk Bold, `#DCE1DD`
   - "Flutter Developer" at 36px, Inter, `#8E9691`
   - the "MM" monogram, large, right side
   - no void: the block is vertically centered in the frame
3. Update `tool/generate_og_image.dart` to produce the new layout, so the image stays
   regenerable instead of being hand-edited.

**Done when:** the browser tab shows the monogram, the installed PWA icon shows the monogram,
and a link preview shows a filled card rather than empty space.

### Phase 4 — Component polish

**Files:** `lib/core/theme/app_theme.dart`, `lib/presentation/widgets/nav_bar.dart`,
`lib/presentation/sections/hero_section.dart`, `lib/presentation/sections/skills_section.dart`,
`lib/presentation/widgets/project_placeholder.dart`, `assets/data/profile.json`.

1. **Button hierarchy.** `textButtonTheme` and `outlinedButtonTheme` currently share one style
   with a border, so every text button renders as an outlined pill. Give the text button theme
   no border; keep the border on the outlined button only. The nav then shows five plain links
   instead of five pills.
2. **Hero CTA count.** Five equal-weight buttons in the hero. Keep "View projects" as the
   filled button and "Download resume" as the outlined one; render GitHub, LinkedIn and Email as
   icon-only round buttons with tooltips.
3. **Hero vertical balance.** `minHeight: MediaQuery.sizeOf(context).height` in
   `hero_section.dart` leaves roughly 200px of void below the stats on a desktop viewport.
   Reduce it to about 0.85 of the viewport height, or anchor the stats to the bottom of the
   hero block.
4. **Stats baseline.** The "Automated test suites" label wraps to two lines and breaks the
   baseline against the other three. Shorten the label to "Test suites" in
   `assets/data/profile.json`, or widen the 150px column.
5. **Skills duplication.** `skills_section.dart` renders a marquee of every chip and then the
   same chips again in groups. Keep the grouped chips; drop the marquee, or keep the marquee and
   show only the group titles below it. Not both.
6. **Project placeholder.** `project_placeholder.dart` is a flat box with a mint border and the
   title text. Restyle it: graphite-on-mint-tinted fill with an icon, so a missing poster still
   looks designed rather than broken.

**Done when:** the nav reads as links, the hero has one primary action, the stats sit on one
baseline, and the skills section is not a duplicate list.

### Phase 5 — Enhancements

**Files:** `lib/presentation/widgets/nav_bar.dart`,
`lib/presentation/pages/home_page.dart`, `lib/presentation/sections/hero_section.dart`,
`lib/presentation/widgets/section_title.dart`, `lib/presentation/sections/skills_section.dart`,
`lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`.

Ordered by value, all optional:

1. **Active section indicator** in the nav — nothing currently shows which section is in view.
2. **Scroll progress bar**, 2px mint, under the nav bar.
3. **Availability pill** in the hero: "Open to Flutter roles · Alexandria, Remote".
4. **Impact numbers on project cards** — "310K+ downloads", "4 apps from one codebase" — so the
   cards lead with proof instead of description.
5. **Section eyebrows**: a small uppercase `accentInk` label and a hairline rule above each
   `SectionTitle`.
6. **Skills proficiency tiers** — three levels instead of a flat chip list.
7. **Arabic display face** (Cairo or Tajawal) for Arabic headings. IBM Plex Sans Arabic is
   currently used for both headings and body, which makes the RTL side read flatter than LTR.
   Space Grotesk and Inter have no Arabic glyphs, so this needs a new bundled font.

**Done when:** each item is visible on the live site and does not regress the Lighthouse score
from section 6.

### Phase 6 — Verification

1. `flutter analyze` — no issues.
2. `flutter test` — all pass, including the updated palette tests.
3. Lighthouse desktop and mobile against the local build:
   ```bash
   flutter build web --wasm --release
   node tool/serve.mjs
   npx lighthouse http://127.0.0.1:8080 --preset=desktop --output=html --output-path=build/lighthouse-desktop.html
   npx lighthouse http://127.0.0.1:8080 --output=html --output-path=build/lighthouse-mobile.html
   ```
   Target: Performance ≥ 80, no new contrast or accessibility regressions.
4. Manual pass at 375px, 768px and 1440px, in light and dark, in English and Arabic (RTL):
   - every accent use legible
   - no text wraps to a broken baseline
   - no 404 in the network tab
5. Deploy through the workflow and re-check the live URL. Note that the CDN holds assets for
   10 minutes, so a stale bundle can look like a failed deploy — hard-reload before concluding.

---

## Inputs from Mostafa

| Input | Blocks |
|---|---|
| `media/profile.jpg`, square, >= 800px | Phase 2 |
| 22 project media files (5 × cover/poster/demo, 7 × cover) | Phase 2 |
| Approval of the monogram design for the favicon and app icons | Phase 3 |

Phase 1, and the code-side parts of Phases 3–6, can start immediately.

---

## Out of scope

- Renaming the repository to `MostafaMahmoudAli.github.io` (moves the site to the root URL, no
  code change — worth doing, but a separate decision)
- Analytics, blog, contact form backend
- Arabic link previews (Open Graph stays English)
- Per-project accent colors from `projects.json` — currently unused metadata; reintroducing them
  would work only as decorative graphics, and would weaken the single-hue system
