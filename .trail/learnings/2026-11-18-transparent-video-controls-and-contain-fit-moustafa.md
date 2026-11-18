---
title: Transparent video controls and contain fit
author: Moustafa-Mahmoud9
date: 2026-11-18
branch: new-look
cost: { minutes: 8, tokens: 52273 }
touches:
  - README.md
  - lib/presentation/widgets/project_video_controls.dart
  - lib/presentation/widgets/project_video_player.dart
  - test/presentation/video_controls_test.dart
---

## Decided
Video controls now hide after one second of playing idle time and on mouse exit even when paused. Mouse exit cancels idle timing but must not hide during an active slider drag. Paused touch users retain controls. White shadowed controls sit on a transparent Material in both themes. Poster and initialized video use contain on black; video layout uses the controller's natural size.
## Tried and ruled out
Do not force shown with !isPlaying: it prevents paused mouse-exit hiding. Do not stretch VideoPlayer with Positioned.fill alone or crop its poster with cover. Preserve the 440/200/220 layout breakpoints and 48px buttons.
## Watch out
Keep visibility callbacks free of setState and leave position rebuilds inside the controls. Tests cover one-second timing, enter/exit while playing and paused, drag exit suppression, theme-independent white styling and contain layout.
Seeking (slider, ±5s) snaps back to 0 on `flutter run -d web-server` and the python launch.json server: neither answers Range requests with 206, so the video's seekable range is [0,0]. GitHub Pages returns 206 and seeking works there. Not an app bug; test seeking on Pages or a Range-capable server. A mouse exit during a slider drag hides the controls when the drag ends, even while paused (`_exitedDuringDrag`).
