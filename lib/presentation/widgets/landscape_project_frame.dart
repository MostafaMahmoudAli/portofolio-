import 'package:flutter/material.dart';

import '../../core/models/project.dart';
import '../../core/theme/app_colors.dart';
import 'project_poster.dart';

/// A browser-style, landscape frame for projects without phone videos.
class LandscapeProjectFrame extends StatelessWidget {
  const LandscapeProjectFrame({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Semantics(
      image: true,
      label: project.title.of(Localizations.localeOf(context)),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.background,
            border: Border.all(
              color: project.accentColor.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadiusDirectional.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(8),
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Icon(
                    Icons.desktop_windows_outlined,
                    size: 20,
                    color: palette.mutedText,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadiusDirectional.circular(8),
                    child: SizedBox.expand(
                      child: ProjectPoster(
                        path: project.cover,
                        accent: project.accentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
