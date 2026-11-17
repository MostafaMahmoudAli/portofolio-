---
title: Add real project media while preserving existing images
author: Moustafa-Mahmoud9
date: 2026-11-17
branch: new-look
touches:
  - README.md
  - assets/data/projects.json
  - lib/core/models/project.dart
  - lib/presentation/pages/project_page.dart
  - test/core/content_repository_test.dart
  - test/core/project_media_test.dart
  - test/presentation/platform_gallery_test.dart
  - test/presentation/project_page_test.dart
  - test/presentation/screens_gallery_test.dart
  - tool/check_media.mjs
---

## Decided
Preserve every existing portfolio image and gallery entry when importing media; append only genuinely new screenshots. The November project folder contains the same eight Egypt Abroad and three Milan screenshots already committed, plus four Daily Tasks and six Remix screenshots. Videos have a user-requested maximum of 50,000,000 bytes each. Keep already-small H.264/AAC recordings lossless via remux/faststart; compress larger recordings at native resolution using H.264 CRF 20, slow preset and AAC 128k, then verify size and full decode.

## Tried and ruled out
Do not label Kuwait and Milan as different OS platforms: both supplied recordings are Android. Keep Kuwait as the consulate project's primary Android video and Milan in additionalVideos, rendered with a non-Hero ProjectMediaFrame. Remove only nonexistent iOS demo metadata for the two imported consular projects so the real Android video becomes primary; preserve store links and all images.

## Watch out
The repository already references missing profile/cover/demo assets for unrelated projects, so the global media check reports existing missing files. Validate all imported-project references separately. UI tests for two-platform behavior and empty galleries should use testProject fixtures rather than mutable real portfolio content. GitHub Actions deploys main using the /portofolio-/ base href; new-look and main shared a tip before this import.
