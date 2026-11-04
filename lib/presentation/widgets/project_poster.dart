import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Static media only: safe to use in a Hero shuttle, never owns a controller.
class ProjectPoster extends StatelessWidget {
  const ProjectPoster({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) => Image.network(
    Uri.base.resolve(path).toString(),
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppPalette.of(context).accentGradient,
      ),
      child: const SizedBox.expand(),
    ),
  );
}
