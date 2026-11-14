import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Shown when a project has no poster. A tinted block with an icon reads as
/// designed, where an empty bordered box reads as broken.
class ProjectPlaceholder extends StatelessWidget {
  const ProjectPlaceholder({super.key, this.title, this.accent});

  final String? title;

  /// The project's own tint; the theme's accent ink by default.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final tint = accent ?? palette.accentInk;
    return Container(
      decoration: BoxDecoration(
        // The static Hero poster sits underneath the player. Composite the
        // tint first so its fallback icon cannot ghost through this fallback.
        color: Color.alphaBlend(
          tint.withValues(alpha: 0.08),
          palette.background,
        ),
        border: Border.all(color: tint.withValues(alpha: 0.30)),
        borderRadius: BorderRadiusDirectional.circular(16),
      ),
      alignment: AlignmentDirectional.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The icon keeps the theme's ink colour: a project accent is a fill,
          // not a legible ink colour on the light background.
          Icon(Icons.image_outlined, size: 32, color: palette.accentInk),
          if (title != null) ...[
            const SizedBox(height: 8),
            Text(
              title!,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: palette.text),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
