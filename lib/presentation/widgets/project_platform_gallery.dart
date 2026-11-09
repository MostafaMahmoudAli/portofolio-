import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/models/project.dart';
import '../../core/models/project_videos.dart';
import '../../core/utils/breakpoints.dart';
import '../../l10n/app_localizations.dart';
import 'project_media_frame.dart';
import 'video_platform_picker.dart';

class ProjectPlatformGallery extends StatefulWidget {
  const ProjectPlatformGallery({
    super.key,
    required this.project,
    this.heroPlatform,
  });
  final Project project;
  final VideoPlatform? heroPlatform;

  @override
  State<ProjectPlatformGallery> createState() => _ProjectPlatformGalleryState();
}

class _ProjectPlatformGalleryState extends State<ProjectPlatformGallery> {
  late VideoPlatform _selected =
      widget.heroPlatform ?? widget.project.videos.primary!.$1;

  @override
  Widget build(BuildContext context) {
    final available = widget.project.videos.available;
    if (available.isEmpty) return const SizedBox.shrink();
    final selected = available.any((entry) => entry.$1 == _selected)
        ? _selected
        : available.first.$1;
    final requestedHero = widget.heroPlatform;
    final heroPlatform = available.any((entry) => entry.$1 == requestedHero)
        ? requestedHero
        : available.first.$1;
    final phone = ScreenSize.of(context) == ScreenSize.phone;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = phone
            ? math.min(240.0, constraints.maxWidth)
            : math.min(
                300.0,
                (constraints.maxWidth - (available.length - 1) * 24) /
                    available.length,
              );
        Widget frame(VideoPlatform platform) {
          final video = available
              .singleWhere((entry) => entry.$1 == platform)
              .$2;
          return SizedBox(
            key: ValueKey('gallery-${platform.name}'),
            width: width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProjectMediaFrame(
                  project: widget.project,
                  video: video,
                  platform: platform,
                  width: width,
                  hero: platform == heroPlatform,
                ),
                const SizedBox(height: 12),
                Text(
                  videoPlatformLabel(l10n, platform),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (video.caption case final caption?) ...[
                  const SizedBox(height: 8),
                  Text(caption.of(locale), textAlign: TextAlign.center),
                ],
              ],
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (phone && available.length > 1) ...[
              VideoPlatformPicker(
                selected: selected,
                onChanged: (value) => setState(() => _selected = value),
              ),
              const SizedBox(height: 16),
            ],
            if (phone)
              frame(selected)
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (index, entry) in available.indexed) ...[
                    if (index > 0) const SizedBox(width: 24),
                    frame(entry.$1),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }
}
