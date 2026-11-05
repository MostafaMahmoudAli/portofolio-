import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A phone-shaped frame around a video.
///
/// The frame keeps the same shape in both LTR and RTL: it is never mirrored,
/// because a physical phone does not flip when the reading direction changes.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child, this.width});

  final Widget child;
  final double? width;

  static const _radius = 30.0;
  static const _bezelTop = 22.0;
  static const _bezelBottom = 16.0;
  static const _speakerRadius = 9.0;
  static const _borderWidth = 2.0;

  /// Both the poster and the separate live overlay use this exact viewport.
  /// Clip the phone's outer corners, not a second rounded video rectangle.
  static Widget mediaLayer({required Widget child}) => PositionedDirectional(
    top: 0,
    bottom: 0,
    start: 0,
    end: 0,
    child: Padding(
      padding: const EdgeInsetsDirectional.all(_borderWidth),
      child: ClipRRect(
        borderRadius: const BorderRadiusDirectional.all(
          Radius.circular(_radius - _borderWidth),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            top: _bezelTop,
            bottom: _bezelBottom,
          ),
          child: SizedBox.expand(child: child),
        ),
      ),
    ),
  );

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
          border: Border.all(color: palette.surfaceBorder, width: _borderWidth),
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Stack(
          children: [
            mediaLayer(child: child),
            PositionedDirectional(
              top: _borderWidth,
              start: 0,
              end: 0,
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
          ],
        ),
      ),
    );
  }
}
