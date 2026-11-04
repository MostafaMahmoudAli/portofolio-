import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A phone-shaped frame around a video.
///
/// The frame keeps the same shape in both LTR and RTL: it is never mirrored,
/// because a physical phone does not flip when the reading direction changes.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child, this.width, this.accent});

  final Widget child;
  final double? width;

  /// Tints the frame's edge with the project's accent (spec section 3).
  final Color? accent;

  static const _radius = 30.0;
  static const _bezelTop = 22.0;
  static const _bezelBottom = 16.0;
  static const _speakerRadius = 9.0;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final frameWidth = width ?? 300;
    final frameHeight = frameWidth * 1.9;

    return SizedBox(
      width: frameWidth,
      height: frameHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border.all(
            color: accent?.withValues(alpha: 0.6) ?? palette.surfaceBorder,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: _bezelTop,
                child: Center(
                  child: Container(
                    width: _speakerRadius * 2,
                    height: _speakerRadius * 2,
                    decoration: BoxDecoration(
                      color: palette.mutedText.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Expanded(child: SizedBox.expand(child: child)),
              const SizedBox(height: _bezelBottom),
            ],
          ),
        ),
      ),
    );
  }
}
