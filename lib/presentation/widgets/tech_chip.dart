import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// One pill-shaped chip naming a technology, tinted with the project accent.
class TechChip extends StatelessWidget {
  const TechChip({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final chipColor = color ?? palette.mutedText;

    // No Center/alignment here: inside a Wrap that would stretch the chip to full width.
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        border: Border.all(color: chipColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        // Text in the theme color: accent-colored 12 px text (e.g. yellow on
        // the light background) fails WCAG AA. The accent tints the pill.
        style: textTheme.labelSmall?.copyWith(
          color: palette.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
