import 'package:flutter/material.dart';

import 'project_placeholder.dart';

/// Static media only: safe to use in a Hero shuttle, never owns a controller.
class ProjectPoster extends StatelessWidget {
  const ProjectPoster({super.key, required this.path, this.accent});

  final String? path;

  /// The project's own tint, used by the fallback placeholder.
  final Color? accent;

  @override
  Widget build(BuildContext context) => path == null
      ? ProjectPlaceholder(accent: accent)
      : Image.network(
          Uri.base.resolve(path!).toString(),
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, synchronous) =>
              frame != null ? child : ProjectPlaceholder(accent: accent),
          errorBuilder: (context, error, stackTrace) =>
              ProjectPlaceholder(accent: accent),
        );
}
