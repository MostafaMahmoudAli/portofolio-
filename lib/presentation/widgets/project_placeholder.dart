import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ProjectPlaceholder extends StatelessWidget {
  const ProjectPlaceholder({super.key, required this.accentColor, this.title});

  final Color accentColor;
  final String? title;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [accentColor, accentColor.withValues(alpha: 0.7)],
      ),
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
