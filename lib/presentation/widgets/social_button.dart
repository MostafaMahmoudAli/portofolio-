import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A round, quiet action used for the social and GitHub links: one filled
/// action, one outlined action, then quiet circles.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: icon,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        backgroundColor: WidgetStatePropertyAll(palette.surface),
        foregroundColor: WidgetStatePropertyAll(palette.text),
        overlayColor: WidgetStatePropertyAll(
          palette.text.withValues(alpha: 0.04),
        ),
        shape: WidgetStateProperty.resolveWith<OutlinedBorder?>(
          (states) => CircleBorder(
            side: BorderSide(
              color:
                  states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.focused)
                  ? palette.accentInk
                  : palette.surfaceBorder,
            ),
          ),
        ),
      ),
    );
  }
}
