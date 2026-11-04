# Phase 1 implementation plan

Source: `docs/PORTFOLIO_PLAN.md` (the spec). Phase 1 row: colors, fonts (incl. Arabic),
theme toggle, gen-l10n + locale controller, language toggle with the flip,
breakpoints, nav bar, router.

**Done when:** both toggles work and are remembered; the flip mirrors the page to RTL
without losing scroll; nav works on phone and desktop.

Branch: `phase-1`. Who does what: Task 1 and Task 3 → Haiku, Task 2 → Opus (controller).
Opus reviews every Haiku diff.

## Global constraints

- Flutter 3.41.6 / Dart 3.11.4. One class per file. Folder layout as in spec section 1.
- `flutter analyze` must report no issues; `flutter test` must pass.
- Layout code uses directional APIs only: `EdgeInsetsDirectional`, `AlignmentDirectional`,
  `PositionedDirectional`, `BorderRadiusDirectional`, `start`/`end`. Never `left`/`right`.
- UI text comes from `AppLocalizations` (no hard-coded user-facing strings), except the
  logo initials `MM`.
- Colors come from `AppPalette` (no hex literals in widgets).
- Commit only the files your task names (`git add <paths>`), never `git add -A`.
- Commit messages end with `Co-Authored-By: Claude Haiku 5.5 <noreply@anthropic.com>`
  (Haiku tasks).

## Task 1: Foundation — packages, fonts, l10n, colors, breakpoints, links

**Files:** `pubspec.yaml`, `l10n.yaml`, `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`,
`assets/fonts/*.ttf`, `lib/core/theme/app_colors.dart`, `lib/core/utils/breakpoints.dart`,
`lib/core/utils/open_link.dart`, `test/core/breakpoints_test.dart`,
`test/core/app_colors_test.dart`.

### 1a. Packages

```bash
flutter pub add go_router url_launcher shared_preferences intl
flutter pub add flutter_localizations --sdk=flutter
```
If `intl` conflicts with the version pinned by `flutter_localizations`, run
`flutter pub add intl:any`. Remove `cupertino_icons` (unused): `flutter pub remove cupertino_icons`.

In `pubspec.yaml` under `flutter:` add `generate: true`.

### 1b. Fonts

Download into `assets/fonts/` (create the folder) with these exact names:

| File | URL |
|---|---|
| `SpaceGrotesk-Medium.ttf` | https://fonts.gstatic.com/s/spacegrotesk/v22/V8mQoQDjQSkFtoMM3T6r8E7mF71Q-gOoraIAEj7aUUsj.ttf |
| `SpaceGrotesk-Bold.ttf` | https://fonts.gstatic.com/s/spacegrotesk/v22/V8mQoQDjQSkFtoMM3T6r8E7mF71Q-gOoraIAEj4PVksj.ttf |
| `Inter-Regular.ttf` | https://fonts.gstatic.com/s/inter/v20/UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfMZg.ttf |
| `Inter-Medium.ttf` | https://fonts.gstatic.com/s/inter/v20/UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuI6fMZg.ttf |
| `Inter-SemiBold.ttf` | https://fonts.gstatic.com/s/inter/v20/UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuGKYMZg.ttf |
| `IBMPlexSansArabic-Regular.ttf` | https://fonts.gstatic.com/s/ibmplexsansarabic/v15/Qw3CZRtWPQCuHme67tEYUIx3Kh0PHR9N6bs6.ttf |
| `IBMPlexSansArabic-Medium.ttf` | https://fonts.gstatic.com/s/ibmplexsansarabic/v15/Qw3NZRtWPQCuHme67tEYUIx3Kh0PHR9N6YPO_9CT.ttf |
| `IBMPlexSansArabic-Bold.ttf` | https://fonts.gstatic.com/s/ibmplexsansarabic/v15/Qw3NZRtWPQCuHme67tEYUIx3Kh0PHR9N6YOG-dCT.ttf |

Use `curl -fsSL -o <file> <url>`. Check each file is > 20 KB and starts with the TTF
magic bytes `00 01 00 00`.

Declare them in `pubspec.yaml` (`flutter: fonts:`), families `SpaceGrotesk`
(500, 700), `Inter` (400, 500, 600), `IBMPlexSansArabic` (400, 500, 700), each asset with
its `weight:`. All three families are under the OFL license; add
`assets/fonts/OFL.txt` containing one line:
`SpaceGrotesk, Inter and IBM Plex Sans Arabic are licensed under the SIL Open Font License 1.1 (https://openfontlicense.org).`

### 1c. Localization files

`l10n.yaml`:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
nullable-getter: false
```

`lib/l10n/app_en.arb`:
```json
{
  "@@locale": "en",
  "appTitle": "Mostafa Mahmoud — Flutter Developer",
  "navAbout": "About",
  "navProjects": "Projects",
  "navExperience": "Experience",
  "navSkills": "Skills",
  "navContact": "Contact",
  "resume": "Resume",
  "menu": "Menu",
  "closeMenu": "Close menu",
  "themeToDark": "Switch to dark theme",
  "themeToLight": "Switch to light theme",
  "languageToggleLabel": "ع",
  "languageToggleTooltip": "التبديل إلى العربية",
  "sectionComingSoon": "Coming soon",
  "projectComingSoon": "The page for {slug} is coming soon.",
  "@projectComingSoon": { "placeholders": { "slug": { "type": "String" } } },
  "notFoundTitle": "Page not found",
  "notFoundBody": "This page doesn't exist.",
  "backHome": "Back to home"
}
```

`lib/l10n/app_ar.arb`:
```json
{
  "@@locale": "ar",
  "appTitle": "مصطفى محمود — مطوّر Flutter",
  "navAbout": "نبذة",
  "navProjects": "المشاريع",
  "navExperience": "الخبرات",
  "navSkills": "المهارات",
  "navContact": "تواصل",
  "resume": "السيرة الذاتية",
  "menu": "القائمة",
  "closeMenu": "إغلاق القائمة",
  "themeToDark": "التبديل إلى الوضع الداكن",
  "themeToLight": "التبديل إلى الوضع الفاتح",
  "languageToggleLabel": "EN",
  "languageToggleTooltip": "Switch to English",
  "sectionComingSoon": "قريبًا",
  "projectComingSoon": "صفحة {slug} قريبًا.",
  "notFoundTitle": "الصفحة غير موجودة",
  "notFoundBody": "هذه الصفحة غير موجودة.",
  "backHome": "العودة إلى الرئيسية"
}
```
The toggle label and tooltip name the *other* language on purpose.

Run `flutter gen-l10n`; it must generate `lib/l10n/app_localizations.dart`,
`app_localizations_en.dart`, `app_localizations_ar.dart`. Commit the generated files.

### 1d. `lib/core/theme/app_colors.dart`

```dart
import 'package:flutter/material.dart';

/// Color tokens from the spec (section 3). Read with `AppPalette.of(context)`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceBorder,
    required this.text,
    required this.mutedText,
    required this.accentStart,
    required this.accentEnd,
    required this.highlight,
  });

  final Color background;
  final Color surface;
  final Color surfaceBorder;
  final Color text;
  final Color mutedText;
  final Color accentStart;
  final Color accentEnd;
  final Color highlight;

  static const dark = AppPalette(
    background: Color(0xFF0A0A12),
    surface: Color(0x0FFFFFFF), // white 6%
    surfaceBorder: Color(0x1AFFFFFF), // white 10%
    text: Color(0xFFEDEDF5),
    mutedText: Color(0xFF9A9AB0),
    accentStart: Color(0xFF7C5CFF),
    accentEnd: Color(0xFF22D3EE),
    highlight: Color(0xFFFF5C8A),
  );

  static const light = AppPalette(
    background: Color(0xFFF6F6FB),
    surface: Color(0xB3FFFFFF), // white 70%
    surfaceBorder: Color(0x0F000000), // black 6%
    text: Color(0xFF14141C),
    mutedText: Color(0xFF5C5C70),
    accentStart: Color(0xFF6D4BFF),
    accentEnd: Color(0xFF0EA5C6),
    highlight: Color(0xFFE8457A),
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>()!;

  LinearGradient get accentGradient =>
      LinearGradient(colors: [accentStart, accentEnd]);

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceBorder,
    Color? text,
    Color? mutedText,
    Color? accentStart,
    Color? accentEnd,
    Color? highlight,
  }) =>
      AppPalette(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceBorder: surfaceBorder ?? this.surfaceBorder,
        text: text ?? this.text,
        mutedText: mutedText ?? this.mutedText,
        accentStart: accentStart ?? this.accentStart,
        accentEnd: accentEnd ?? this.accentEnd,
        highlight: highlight ?? this.highlight,
      );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      text: Color.lerp(text, other.text, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      accentStart: Color.lerp(accentStart, other.accentStart, t)!,
      accentEnd: Color.lerp(accentEnd, other.accentEnd, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
    );
  }
}
```

Test `test/core/app_colors_test.dart`: `AppPalette.dark.lerp(AppPalette.light, 0)` has
dark's background, at `1` light's background; `copyWith(text: X).text == X`.

### 1e. `lib/core/utils/breakpoints.dart`

```dart
import 'package:flutter/widgets.dart';

/// Spec breakpoints: phone < 600, tablet 600–1024, desktop > 1024.
enum ScreenSize {
  phone,
  tablet,
  desktop;

  static ScreenSize fromWidth(double width) {
    if (width < 600) return phone;
    if (width <= 1024) return tablet;
    return desktop;
  }

  static ScreenSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);
}
```

Test `test/core/breakpoints_test.dart`: 599 → phone, 600 → tablet, 1024 → tablet,
1025 → desktop.

### 1f. `lib/core/utils/open_link.dart`

```dart
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in a new tab. Relative paths (e.g. `resume.pdf`) resolve against
/// the site's base URL, so they work under the GitHub Pages sub-path.
Future<void> openLink(String url) =>
    launchUrl(Uri.base.resolve(url), webOnlyWindowName: '_blank');
```

### Verify and commit
`flutter analyze` clean, `flutter test test/core` passes. One commit:
`Add packages, fonts, l10n strings, color tokens and breakpoints`.

## Task 2: Theme, controllers, app shell, router, language flip (Opus)

**Files:** `lib/core/theme/app_text_styles.dart`, `lib/core/theme/app_theme.dart`,
`lib/core/theme/theme_controller.dart`, `lib/core/localization/locale_controller.dart`,
`lib/core/router/app_router.dart`, `lib/app.dart`, `lib/main.dart`,
`lib/presentation/widgets/language_flip.dart`, `lib/presentation/widgets/language_toggle.dart`,
`lib/presentation/widgets/theme_toggle.dart`, placeholder pages
`lib/presentation/pages/{home_page,project_page,not_found_page}.dart` (Task 3 replaces the
home page body), tests under `test/`.

Interfaces Task 3 relies on:
- `AppPalette.of(context)`, `ScreenSize.of(context)`, `openLink(url)` (Task 1).
- `AppLocalizations.of(context)` (Task 1).
- `const LanguageToggle()` and `const ThemeToggle()` — self-contained buttons, ~40×40.
- `HomePage` is a `StatefulWidget` at `/`; Task 3 owns its body.
- Routes: `/` → `HomePage`, `/projects/:slug` → `ProjectPage(slug:)`, anything else →
  `NotFoundPage`.

## Task 3: Nav bar, menu sheet, home page skeleton, not-found page (Haiku)

**Files:** `lib/presentation/widgets/gradient_text.dart`,
`lib/presentation/widgets/nav_bar.dart`, `lib/presentation/widgets/nav_menu_sheet.dart`,
`lib/presentation/widgets/section_title.dart`, `lib/presentation/pages/home_page.dart`,
`lib/presentation/pages/home_section.dart`, `lib/presentation/pages/not_found_page.dart`,
`test/presentation/nav_bar_test.dart`.

Spec details are in the dispatch brief written by the controller after Task 2
(`task-3-brief.md` in the SDD workspace), because they depend on Task 2's code.
