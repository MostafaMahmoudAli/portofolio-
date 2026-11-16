# Resume update plan

**Goal:** apply the agreed corrections to Mostafa's resume, in place, in both the Word file and the PDF.

**Files to change (same files, same names, same folder):**

- `D:\الشغل\MOSTAFA_MAHMOUD_Flutter_Developer_Resume.docx` — the source. All text edits happen here.
- `D:\الشغل\MOSTAFA_MAHMOUD_Flutter_Developer_Resume.pdf` — re-exported from the edited Word file.

**Done when:** both files carry every change below, the PDF is still 2 pages with the same look, and the checks in Step 5 pass.

## Execution mode — run the whole plan without stopping

- Run Steps 1 to 6 in one run. Do not stop to ask for review, approval or a choice. Mostafa reviews once at the end.
- If a point is unclear, take the simplest option that keeps the resume truthful, and write one line about it under "Agent notes" at the end of this file.
- If a step is blocked, write the blocker under "Agent notes", leave both resume files valid and openable, and continue with the next step.
- Do not add any claim that is not written in this plan. Do not rewrite text this plan does not mention.
- No git work is needed for the resume files. Do not commit, push, merge or open a PR anywhere.
- Give one final report: what changed, what was verified, what was not, and all agent notes.

## Facts to respect (from Mostafa)

- He is **not** a lead engineer. The word "lead" must not appear as a claim about his current role. ("Programmer Club Leader" at MDQ Academy is a real job title and stays.)
- All four consulate apps were built at AppRock. He did **not** do the first publication of any of them. He uploads new releases (features, bug fixes) for most of them. So: no "published four apps", no "keystore setup", no "store listings and screenshots" claims.
- Graduation year: 2021.
- The portfolio website is not ready. Do not add a portfolio link.
- LinkedIn profile: `https://www.linkedin.com/in/mostafa-mahmoud-ali-4a4932279`.

## Step 1 — Back up

1. Copy both files next to the originals as `MOSTAFA_MAHMOUD_Flutter_Developer_Resume.backup.docx` and `MOSTAFA_MAHMOUD_Flutter_Developer_Resume.backup.pdf`.
2. If a backup file already exists, do not overwrite it.

## Step 2 — How to edit the Word file

- Python 3.12 with `python-docx` is installed. Use it.
- The folder name is Arabic. If a tool fails on the path, copy the file to an ASCII-only temp folder, work there, then copy the result back over the original.
- Text in one paragraph is split across several runs (bold and normal). Change text inside the existing runs. Keep fonts, sizes, bold, italics, bullets, spacing, margins and tab stops as they are. Do not rebuild paragraphs and do not change styles.
- Bold in the new text must follow the same pattern as the old text (key terms bold, the rest normal).
- A hyperlink has two parts: the visible text and the link target in the document relationships. Change both.

## Step 3 — Text changes

Replace the old text with the new text exactly. "Remove" means delete only the quoted words and fix the punctuation around them.

### 3.1 Header

- LinkedIn visible text: `linkedin.com/in/mostafa-mahmoud-ali` → `linkedin.com/in/mostafa-mahmoud-ali-4a4932279`
- LinkedIn link target → `https://www.linkedin.com/in/mostafa-mahmoud-ali-4a4932279`

### 3.2 Summary — replace the whole paragraph

> Flutter Developer with 3+ years building cross-platform apps across government, logistics and travel. Worked on six apps released on Google Play and the App Store, including four consulate apps built from a single codebase with 310K+ combined Google Play downloads. Owns feature modules end-to-end — Clean Architecture, BLoC/Cubit, Dio, go_router, get_it — from API contract through flavor setup to store release updates. Core mobile developer on a 23-module consular super-app with an AI assistant streamed over SSE, OCR national-ID verification and device-integrity enforcement, backed by 57 automated test suites. Bilingual Arabic/English with full RTL delivery experience.

### 3.3 Technical skills

- Data & Networking: remove `pretty_dio_logger, `
- Native & Device: remove `share_plus, permission_handler, `

### 3.4 AppRock experience

- Bullet 1, new text:
  > Own feature modules end-to-end (entities, use cases, repositories, Cubits and UI) across the 23-module Flutter codebase behind the Egypt Consulate apps, under a feature-first Clean Architecture with get_it dependency injection.
- Test bullet: remove ` — catching 3 defects before release`. The sentence ends after `widget behaviour.`
- Release bullet (starts with "Handle end-to-end release into"), new text:
  > Ship release updates to Google Play Console and App Store Connect for most of the consulate apps — version and build numbering, signed builds, internal and closed test tracks, TestFlight distribution, staged rollout and app review submissions, promoted via GitHub Actions release gates.

### 3.5 Freelance experience

- Bullet 2, new text:
  > Built multi-currency checkout (PayPal, Stripe, Visa, MasterCard) and multilingual content flows for travel and local-business products.

### 3.6 Project: Egypt Consulate Apps

- Tech line: add ` | Built at AppRock` at the end, after `8 live store listings`.
- Replace the single bullet with two bullets:
  > Develop four consulate apps from one Flutter codebase using flavor-based builds — three Gulf missions and one in Europe — each with region-specific feature sets, branding and store listings.

  > Ship feature and bug-fix releases to Google Play and the App Store for most of the four apps. Together they have 310K+ Google Play downloads; Riyadh is rated 4.5 stars from 2.2K+ reviews.

### 3.7 Project: Alkharj Business Guide

- `Firebase phone-number authentication` → `Firebase phone authentication` (the old wording broke across a line and was read as "phonenumber" by text extractors).

### 3.8 Project: Remix

- Tech line: `CameraX` → `camera (CameraX)`
- Bullet 1, new text:
  > Built a TikTok-style remix toolkit — duet, trim and sound reuse — as Cubit state machines with FFmpeg compositing, working on local files and HLS (.m3u8) streams; removed a duet audio echo and made scrubbing smooth (throttled seeks, 1 s keyframes).
- Bullet 2: first check the Remix code at `C:\Users\El3atty\remix_app`. Search `pubspec.yaml` and `lib/` for a save-to-phone-gallery feature (a package such as `gal`, `saver_gallery`, `image_gallery_saver`, `gallery_saver`, or `MediaStore` use).
  - **If the feature exists**, new text:
    > Added 0.5×–3× speed baked into exports (setpts/atempo), gallery import with a 4-minute limit, cancellable FFmpeg jobs, saved display modes and a filterable library; finished videos download to the device gallery or share out through share_plus. Refactored to sealed Cubit states.
  - **If the feature does not exist** (state on 2026-11-14: finished videos are saved inside the app's own documents folder and leave the app only through the share sheet), new text:
    > Added 0.5×–3× speed baked into exports (setpts/atempo), gallery import with a 4-minute limit, cancellable FFmpeg jobs, saved display modes and a filterable library; finished videos are saved in the app and exported to the device through the share_plus share sheet. Refactored to sealed Cubit states.
  - Write under "Agent notes" which of the two texts was used. Do not change the Remix code.

### 3.9 Education

- `Bachelor of Tourism & Hotels — High Institute EGOTH, Alexandria (Grade: Very Good)` → `Bachelor of Tourism & Hotels — High Institute EGOTH, Alexandria, 2021 (Grade: Very Good)`

## Step 4 — Export the PDF

- Microsoft Word 2010 is installed at `C:\Program Files (x86)\Microsoft Office\Office14\WINWORD.EXE`. Export through Word automation from PowerShell: open the edited `.docx`, call `ExportAsFixedFormat` with format 17 (PDF), close the document without saving, quit Word.
- Work on an ASCII-only temp copy if the Arabic path causes errors, then copy the PDF over `D:\الشغل\MOSTAFA_MAHMOUD_Flutter_Developer_Resume.pdf`.
- If Word export fails, write the blocker under "Agent notes". Leave the old PDF in place and say clearly in the final report that the PDF is not updated.

## Step 5 — Verify

1. The PDF has exactly 2 pages. If the text runs onto a third page, shorten the Summary first, then the Remix bullets. Never shrink fonts or margins.
2. Extract the PDF text and confirm:
   - present: `mostafa-mahmoud-ali-4a4932279`, `Core mobile developer`, `Built at AppRock`, `HLS (.m3u8)`, `Alexandria, 2021`, `Firebase phone authentication`
   - absent: `lead mobile engineer`, `catching 3 defects`, `published four`, `pretty_dio_logger`, `SSEstreamed`, `phonenumber`, `keystore`
3. Render both pages to images and look at them: same fonts and spacing as before, no orphan heading at a page bottom, no broken bullets, links still blue and underlined.
4. Open the `.docx` again with `python-docx` to confirm it is not corrupted.

## Step 6 — Copy to the portfolio

- Copy the new PDF over `C:\Users\El3atty\portfolio\web\resume.pdf`. Do not commit it.

## Not in this plan

- Portfolio link in the header: add when the site is live.
- A real "save to phone gallery" feature in the Remix app: separate code task.
- Any change to job titles, dates, or the "Earlier" and "Volunteering" lines.

## Agent notes

- Remix verification: no save-to-phone-gallery package or MediaStore use exists in `pubspec.yaml` or `lib/`. `VideoStorage` saves finished videos in the app documents folder, and `share_video.dart` exports through the `share_plus` share sheet. Used the non-gallery text from Step 3.8, then shortened it under Step 5.1.
- Pagination fallback: the exact requested text exported to three pages in Word 2010. Shortened the Summary first, then both Remix bullets, as Step 5.1 permits. Final Summary: "Flutter Developer with 3+ years in government, logistics and travel apps. Worked on six apps on Google Play and the App Store, including four consulate apps from one codebase (310K+ combined Google Play downloads). Owns modules end-to-end: Clean Architecture, BLoC/Cubit, Dio, go_router, get_it; API contracts, flavors and store release updates. Core mobile developer on a 23-module consular super-app: AI assistant streamed over SSE, OCR national-ID verification, device-integrity enforcement and 57 automated test suites. Arabic/English; full RTL delivery."
- Final shortened Remix bullets: "Built Cubit/FFmpeg duet, trim and sound reuse for local files/HLS (.m3u8); fixed echo and scrubbing." and "Added 0.5×–3× export speed (setpts/atempo), gallery import (4-minute limit), cancellable FFmpeg jobs, saved display modes and a filterable library. Videos save in-app and export through the share_plus share sheet. Refactored to sealed Cubit states."
- Pagination-only adjustment: added a page break before the existing Freelance heading to preserve its original page-two start and prevent an orphan job heading. No fonts, sizes, margins, spacing, tab stops, styles, or unrelated text changed.
- LinkedIn uses a Word HYPERLINK field rather than a document relationship. Its target already matched the requested URL; retained it, updated the visible text, and verified the exported PDF target.
- Verification passed: two PDF pages; all required phrases present after normalizing extraction line breaks; all forbidden phrases absent; DOCX reopened successfully; both rendered pages visually inspected; original PDF font/size set and all hyperlink targets preserved; portfolio PDF byte-identical to the updated source PDF. Text reflows, including the longer Remix tech line, but no orphan headings, broken bullets, or lost blue underlined links remain. No blockers or outstanding checks. No commits, pushes, merges, or PRs.
