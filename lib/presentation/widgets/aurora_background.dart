import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// One soft mint glow, clipped to the hero. Reduced motion holds it still.
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
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    painter: _AuroraPainter(
                      progress: _controller.value,
                      palette: palette,
                      opacity: light ? 0.10 : 0.14,
                    ),
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
    final radius = size.shortestSide * 0.28;
    final center = Offset(
      size.width * (0.72 + 0.08 * math.sin(t)),
      size.height * (0.40 + 0.06 * math.cos(t)),
    );
    // A single blurred circle, not a multicolor shader or a page-wide wash.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = palette.accent.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.65),
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.palette != palette ||
      oldDelegate.opacity != opacity;
}
