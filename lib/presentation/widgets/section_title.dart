import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.eyebrow});

  final String text;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final label = eyebrow;
    final theme = Theme.of(context).textTheme;
    final ink = AppPalette.of(context).accentInk;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          ExcludeSemantics(
            child: Row(
              children: [
                SizedBox(width: 32, child: Divider(color: ink, thickness: 1)),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    style: theme.labelSmall?.copyWith(color: ink),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Semantics(header: true, child: Text(text, style: theme.headlineLarge)),
      ],
    );
  }
}
