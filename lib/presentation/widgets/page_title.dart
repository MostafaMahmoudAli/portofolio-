import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Remounts only the Title when a retained route becomes current again.
/// Updating an unchanged Title does not resend its label to the browser.
class PageTitle extends StatelessWidget {
  const PageTitle({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      if (ModalRoute.isCurrentOf(context) ?? true)
        Title(
          title: title,
          color: AppPalette.of(context).background,
          child: const SizedBox.shrink(),
        )
      else
        const SizedBox.shrink(),
      child,
    ],
  );
}
