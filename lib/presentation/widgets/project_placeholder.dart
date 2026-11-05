import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ProjectPlaceholder extends StatelessWidget {
  const ProjectPlaceholder({super.key, this.title});
  final String? title;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppPalette.of(context).surface,
      border: Border.all(color: AppPalette.of(context).accent),
    ),
    alignment: AlignmentDirectional.center,
    child: title == null
        ? null
        : Text(
            title!,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppPalette.of(context).text,
            ),
            textAlign: TextAlign.center,
          ),
  );
}
