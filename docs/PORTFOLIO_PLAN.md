# Portfolio Website Plan

A personal portfolio site built with Flutter Web: resume content, project demo
videos and links. Content lives in JSON files in the repo (no admin panel). Adding
a project means editing JSON, dropping in a video and pushing.

## Decisions

| Topic | Decision |
|---|---|
| Framework | Flutter Web, same Flutter as Remix (3.41.6 / Dart 3.11.4) |
| Content | `assets/data/profile.json` + `assets/data/projects.json` |
| Videos | Compressed MP4 in the repo, under `web/media/`, each with a poster image |
| Hosting | GitHub Pages at `https://mostafamahmoudali.github.io/portofolio-/` |
| Repo | `MostafaMahmoudAli/portofolio-` (public). Renaming it to `MostafaMahmoudAli.github.io` moves the site to the root URL; the workflow uses the repo name as base href, so no code change |
| URLs | Hash links (`/#/projects/remix`), Flutter Web's default, so no 404 trick |
| Theme | Light / dark toggle, starts from the system setting, choice remembered |
| Look | Animated, modern, gradient accents (see Design) |
| Projects | Every resume project, plus selected repos from the personal GitHub |

## 1. Project setup

- `flutter create --platforms web portfolio` in `D:\الشغل\portfolio`.
- Folder layout follows Remix, one class per file:
  ```
  lib/
    main.dart
    app.dart                      # MaterialApp.router, theme, router
    core/
      models/                     # Profile, Project, ProjectVideo, ProjectLink, Experience, SkillGroup, Stat
      data/content_repository.dart  # loads and parses the JSON once
      theme/                      # app_colors.dart, app_theme.dart, app_text_styles.dart, theme_controller.dart
      router/app_router.dart      # go_router routes
      utils/                      # breakpoints.dart, open_link.dart
    presentation/
      pages/                      # home_page.dart, project_page.dart, not_found_page.dart
      sections/                   # hero, about, featured_projects, more_projects, experience, skills, contact, footer
      widgets/                    # nav_bar, theme_toggle, gradient_text, glass_card, phone_frame,
                                  # project_video_player, tech_chip, store_badges, reveal_on_scroll,
                                  # animated_counter, aurora_background, section_title
  assets/data/                    # profile.json, projects.json
  assets/fonts/                   # bundled fonts (no runtime Google Fonts fetch)
  web/
    index.html                    # meta tags, loading splash, plain HTML fallback links
    resume.pdf
    og-image.png                  # 1200x630 link preview
    media/<slug>/                 # demo.mp4, poster.jpg, cover.jpg
  ```
- **Packages (kept small):**
  - `go_router`: routes.
  - `video_player`: uses the HTML `<video>` element on web.
  - `flutter_animate`: declarative animations.
  - `visibility_detector`: scroll reveal, and playing videos only while visible.
  - `url_launcher`: store, GitHub and mail links.
  - `shared_preferences`: stores the theme choice in localStorage.
- **No BLoC.** The content is static: load it once in `main()`. The theme is a
  `ValueNotifier<ThemeMode>`, the same pattern as `AppPreferences.displayMode` in Remix.

## 2. Content (JSON)

Content is taken from the resume (Word file, Nov 2026 version).

**`profile.json`:**
- name, title, location, email, phone (optional), linkedin, github
- photo path, resume PDF path
- summary
- `stats`, shown as animated counters:
  - 3+ years
  - 6 published apps
  - 310K+ downloads
  - 57 test suites
- `experience[]`, each with:
  - role, company, dates, mode
  - 2–4 short bullets
  - Entries: AppRock, Freelance, MDQ Academy, Oday
- `skillGroups[]`: the 9 groups from the resume, with short chip labels
- `education`, `languages`, `certifications`

**`projects.json`**, one entry per project:
```json
{
  "slug": "remix",
  "title": "Remix",
  "subtitle": "Short-form video editor — duet, trim, sound reuse & import",
  "featured": true,
  "order": 4,
  "accent": "#FF5C8A",
  "summary": "One or two lines for the card.",
  "bullets": ["Longer points for the project page."],
  "tech": ["Flutter", "Cubit", "FFmpegKit", "CameraX"],
  "status": "Private repository — walkthrough on request",
  "cover": "media/remix/cover.jpg",
  "videos": [{ "src": "media/remix/demo.mp4", "poster": "media/remix/poster.jpg", "caption": "Duet + speed" }],
  "links": [{ "type": "github|playStore|appStore|live", "url": "..." }]
}
```

**Featured projects** (from the resume):
1. Egypt Consulate Apps: Kuwait, Riyadh, Jeddah and Milan, with 8 store links.
2. New Courier App.
3. Alkharj Business Guide: the app and the web admin panel.
4. Remix.
5. RehlatiUAE.

**More projects** (smaller cards). Proposed picks from `github.com/MostafaMahmoudAli`, to be confirmed:
- `responsive_dashboard`
- `rick_and_motry_app`
- `vocabs_app`
- `flutter_google_maps`
- `Bookly_App`
- `flutter_shop_app`
- `flutter_social_app`

Older practice repos (todo, news, tasks) stay off the site; a "More on GitHub" button covers them.

## 3. Design

**Feel:** dark-first, with soft animated gradient light ("aurora") behind glass
cards, bold type, and plenty of space. The same layout in light mode, on a clean
off-white background.

**Colors** (tokens in `app_colors.dart`):

| Token | Dark | Light |
|---|---|---|
| background | `#0A0A12` | `#F6F6FB` |
| surface (glass) | white at 6%, 1px white 10% border | white at 70%, 1px black 6% border |
| text | `#EDEDF5` | `#14141C` |
| muted text | `#9A9AB0` | `#5C5C70` |
| accent gradient | `#7C5CFF` → `#22D3EE` | `#6D4BFF` → `#0EA5C6` |
| highlight | `#FF5C8A` | `#E8457A` |

- **Per-project accent:** each project's `accent` color tints its card glow,
  chips and video frame.
- **Contrast:** checked for both themes, with WCAG AA as the minimum for body text.

**Type:**
- `Space Grotesk` for headings, `Inter` for body text.
- Both are bundled in `assets/fonts/`, so there is no extra network fetch.

**Animations** (all via `flutter_animate`, all short, 200–700 ms):
- **Aurora background:** 3 blurred gradient blobs drifting slowly in the hero.
- **Hero entrance:** staggered fade and slide for name, title, buttons and stats. The
  name uses gradient text. The title cycles through roles with a typewriter effect.
- **Photo:** a rotating gradient ring around the profile photo.
- **Stat counters:** count up from 0 the first time they scroll into view.
- **Scroll reveal:** each section and card fades up once when it enters the viewport
  (`RevealOnScroll` widget).
- **Cards (desktop):** lift, glow in the project accent, and tilt slightly toward the cursor.
- **Phone frame:** a phone-shaped frame around each video. The video autoplays
  muted while visible and pauses when off screen.
- **Experience timeline:** the line draws itself downward while scrolling, and the
  dots pop in.
- **Skills:** a slow infinite marquee of tech chips, plus the grouped chips below.
- **Theme toggle:** sun/moon morph, and the new theme spreads from the button as a
  circular reveal.
- **Card to project page:** a `Hero` transition on the cover image.
- **Reduced motion:** when the OS asks for less motion (`MediaQuery.disableAnimations`),
  reveals become plain fades and the aurora and marquee stop.

**Responsive breakpoints** (in `breakpoints.dart`):
- phone < 600
- tablet 600–1024
- desktop > 1024

On phones the nav becomes a menu sheet, and the featured cards stack the video
above the text.

## 4. Pages

**Home** (`/#/`), one scrolling page:
1. **Nav bar:** sticky, with a glass blur.
   - Logo initials and section links that scroll smoothly to their sections.
   - Theme toggle and a "Resume" button that opens `resume.pdf`.
2. **Hero:**
   - Photo, name, typewriter title and a one-line pitch.
   - Buttons: View projects, Download resume, GitHub, LinkedIn, Email.
   - The 4 animated stats.
3. **About:** short summary and 3 highlight tiles: Clean Architecture, store releases, media/FFmpeg.
4. **Featured projects:** large cards that alternate left and right.
   - Phone-framed video, title, summary, tech chips, status and store badges.
   - A "Details" link to the project page.
5. **More projects:** a grid of small cards with name, one line, tech, and a GitHub link.
6. **Experience:** animated timeline.
7. **Skills:** marquee plus grouped chips.
8. **Contact:** a large call to action.
   - The email can be copied to the clipboard with a toast.
   - LinkedIn and GitHub links.
9. **Footer:** "Built with Flutter" and the year.

**Project page** (`/#/projects/<slug>`):
- Back button and hero cover.
- Video gallery: several videos, swipe on phone, thumbnails on desktop.
- All bullets, tech chips, links and status.
- Next / previous project buttons.

An unknown slug shows `not_found_page.dart` with a link home.

## 5. Video handling

- `ProjectVideoPlayer` builds its controller with `VideoPlayerController.networkUrl(Uri.base.resolve(src))`.
  It shows the poster first and creates the controller only when the video
  scrolls into view.
- It disposes the controller when the video goes far off screen. At most 2
  controllers exist at a time.
- Autoplay is muted, because browsers block autoplay with sound. A tap unmutes
  and shows controls.
- **Compressing a recording before adding it** (FFmpeg on the PC):
  ```bash
  ffmpeg -i raw.mp4 -vf "scale=-2:1280,fps=30" -c:v libx264 -crf 28 -preset slow -c:a aac -b:a 96k -movflags +faststart demo.mp4
  ffmpeg -ss 1 -i demo.mp4 -frames:v 1 -q:v 3 poster.jpg
  ```
  The target is under 10 MB per video. `+faststart` lets the video start before it
  has fully downloaded.
- **GitHub Pages limits:** 100 MB per file and about 1 GB for the whole site. That
  is roughly 60+ demo videos.

## 6. Speed and link previews

- **Build:** `flutter build web --wasm --release`.
  - Browsers without WasmGC fall back to JS automatically.
  - GitHub Pages can't set the COOP/COEP headers, so the Wasm build runs
    single-threaded. That is fine for this site.
- **`index.html` splash:** a CSS-only loading splash in the brand gradient that
  shows instantly and is removed on Flutter's first frame.
- **`index.html` head:**
  - `<title>` and a meta description.
  - Open Graph and Twitter tags with `og-image.png`, so LinkedIn and WhatsApp
    show a rich preview.
  - A `<noscript>` block with name, email and a resume link.
- **Images:** posters and covers as JPG/WebP, at most about 1280 px on the long side.
- **Check:** run Lighthouse in Chrome. The target is Performance ≥ 80 on desktop.

## 7. Deploy

- **Repo:** `MostafaMahmoudAli.github.io`, created on GitHub by Mostafa. It must have
  exactly this name to serve at the root URL.
- **Workflow:** `.github/workflows/deploy.yml` runs on every push to `main`.
  1. Check out the code.
  2. `subosito/flutter-action`, pinned to 3.41.6.
  3. `flutter pub get`.
  4. `flutter build web --wasm --release`.
  5. `actions/upload-pages-artifact` with `build/web`.
  6. `actions/deploy-pages`.
- **Settings:** Settings → Pages → Source: **GitHub Actions**.
- **After launch:** put the site link on the resume, LinkedIn and the GitHub profile README.

## 8. Adding a project later

The README spells out these steps:
1. Compress the recording with the two commands in section 5.
2. Put `demo.mp4`, `poster.jpg` and `cover.jpg` in `web/media/<slug>/`.
3. Add an entry to `assets/data/projects.json`.
4. `git push`. The site updates in about 3 minutes.

## 9. Phases

| Phase | Work | Done when |
|---|---|---|
| 0 | Create the project and repo, then deploy a placeholder page through the workflow | The live URL shows the placeholder |
| 1 | Colors, fonts, theme toggle, breakpoints, nav bar, router | Toggle works and is remembered; nav works on phone and desktop |
| 2 | Models, JSON files filled from the resume, content repository | All content loads; a bad JSON entry fails loudly in debug |
| 3 | Hero, aurora, stats, about, scroll reveal | Hero animates in; counters run once |
| 4 | Featured and more projects, phone frame, video player | Videos autoplay muted only while visible |
| 5 | Project pages with Hero transition, gallery, next/previous | `/#/projects/remix` opens directly from a pasted link |
| 6 | Experience timeline, skills marquee, contact, footer | All sections are done in both themes |
| 7 | Splash, meta/OG tags, reduced motion, responsive pass, Lighthouse | Score targets met; checked at 375, 768 and 1440 px |
| 8 | README, final content check, link on the resume | Adding a test project by JSON alone works |

## 10. Mostafa provides

- A demo recording (20–40 s, phone screen) for each featured project.
- A profile photo, square, at least 800 px.
- Confirmation of the "More projects" list, plus any repos from the `Moustafa-Mahmoud9` account.
- Creating the `MostafaMahmoudAli.github.io` repo.

## Out of scope (later)

- Admin panel
- Arabic / RTL version
- Analytics
- Blog
- Contact form backend
