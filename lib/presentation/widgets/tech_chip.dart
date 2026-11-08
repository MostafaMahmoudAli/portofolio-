import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A neutral technology pill with a mint hover outline.
class TechChip extends StatefulWidget {
  const TechChip({super.key, required this.label});

  final String label;
  @override
  State<TechChip> createState() => _TechChipState();
}

class _TechChipState extends State<TechChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    // No Center/alignment here: inside a Wrap that would stretch the chip to full width.
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border.all(
            color: _hovered ? palette.accent : palette.surfaceBorder,
          ),
          borderRadius: BorderRadiusDirectional.circular(20),
        ),
        child: Text(
          widget.label,
          style: textTheme.labelSmall?.copyWith(
            color: palette.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
