import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/project_videos.dart';

/// A phone-shaped frame around a video.
///
/// The frame keeps the same shape in both LTR and RTL: it is never mirrored,
/// because a physical phone does not flip when the reading direction changes.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({
    super.key,
    required this.child,
    this.width,
    this.platform = VideoPlatform.android,
  });

  final Widget child;
  final double? width;
  final VideoPlatform platform;

  static double _radius(VideoPlatform platform) =>
      platform == VideoPlatform.ios ? 36 : 26;
  static const _bezelTop = 22.0;
  static const _bezelBottom = 16.0;
  static const _borderWidth = 2.0;

  /// Both the poster and the separate live overlay use this exact viewport.
  /// Clip the phone's outer corners, not a second rounded video rectangle.
  static Widget mediaLayer({
    required Widget child,
    VideoPlatform platform = VideoPlatform.android,
  }) => PositionedDirectional(
    top: 0,
    bottom: 0,
    start: 0,
    end: 0,
    child: Padding(
      padding: const EdgeInsetsDirectional.all(_borderWidth),
      child: ClipRRect(
        borderRadius: BorderRadiusDirectional.all(
          Radius.circular(_radius(platform) - _borderWidth),
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
          border: Border.all(color: palette.accentInk, width: _borderWidth),
          borderRadius: BorderRadiusDirectional.circular(_radius(platform)),
        ),
        child: Stack(
          children: [
            mediaLayer(child: child, platform: platform),
            PositionedDirectional(
              top: _borderWidth,
              start: 0,
              end: 0,
              height: _bezelTop,
              child: Center(
                child: Container(
                  key: ValueKey('camera-${platform.name}'),
                  width: platform == VideoPlatform.ios ? 44 : 10,
                  height: platform == VideoPlatform.ios ? 12 : 10,
                  decoration: BoxDecoration(
                    color: palette.mutedText.withValues(alpha: 0.5),
                    borderRadius: BorderRadiusDirectional.circular(12),
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
