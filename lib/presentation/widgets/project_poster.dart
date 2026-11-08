import 'package:flutter/material.dart';

import 'project_placeholder.dart';

/// Static media only: safe to use in a Hero shuttle, never owns a controller.
class ProjectPoster extends StatelessWidget {
  const ProjectPoster({super.key, required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) => path == null
      ? const ProjectPlaceholder()
      : Image.network(
          Uri.base.resolve(path!).toString(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const ProjectPlaceholder(),
        );
}
