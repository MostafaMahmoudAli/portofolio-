import 'package:flutter/material.dart';

import 'project_placeholder.dart';

/// Static media only: safe to use in a Hero shuttle, never owns a controller.
class ProjectPoster extends StatelessWidget {
  const ProjectPoster({
    super.key,
    required this.path,
    required this.accentColor,
  });

  final String? path;
  final Color accentColor;

  @override
  Widget build(BuildContext context) => path == null
      ? ProjectPlaceholder(accentColor: accentColor)
      : Image.network(
          Uri.base.resolve(path!).toString(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              ProjectPlaceholder(accentColor: accentColor),
        );
}
