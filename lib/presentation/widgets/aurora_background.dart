import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Three large blurred gradient blobs drifting slowly behind the page.
///
/// It sits in `MaterialApp.builder`, outside [LanguageFlip], so the page turns
/// over a background that stays still. Under reduced motion the blobs hold
/// their position instead of drifting.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  /// Slow enough to read as light moving, not as an animation to watch.
  static const _duration = Duration(seconds: 36);
  static const _stillProgress = 0.18;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
    value: _stillProgress,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      if (_controller.isAnimating) _controller.stop();
      _controller.value = _stillProgress;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final light = Theme.of(context).brightness == Brightness.light;

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: RepaintBoundary(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _AuroraPainter(
                    progress: _controller.value,
                    palette: palette,
                    opacity: light ? 0.22 : 0.45,
                  ),
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({
    required this.progress,
    required this.palette,
    required this.opacity,
  });

  final double progress;
  final AppPalette palette;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;
    final shortest = size.shortestSide;

    // (fraction of width, fraction of height, radius as a fraction of the
    // shortest side, color)
    final blobs = <(double, double, double, Color)>[
      (
        0.18 + 0.10 * math.sin(t),
        0.16 + 0.08 * math.cos(t * 0.8),
        0.62,
        palette.accentStart,
      ),
      (
        0.82 + 0.08 * math.cos(t * 0.9),
        0.30 + 0.10 * math.sin(t * 0.7),
        0.55,
        palette.accentEnd,
      ),
      (
        0.50 + 0.12 * math.sin(t * 0.6 + 1.5),
        0.88 + 0.06 * math.cos(t * 0.8),
        0.60,
        palette.highlight,
      ),
    ];

    for (final (fx, fy, radiusFactor, color) in blobs) {
      final center = Offset(size.width * fx, size.height * fy);
      final radius = shortest * radiusFactor;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.35);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.palette != palette ||
      oldDelegate.opacity != opacity;
}
