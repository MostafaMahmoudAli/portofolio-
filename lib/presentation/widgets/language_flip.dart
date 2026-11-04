import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/theme/app_colors.dart';

/// Switches the language with a page flip: the page turns edge-on, the locale
/// changes while nothing is visible (so the LTR ⇄ RTL mirror is never seen),
/// then the page turns back showing the mirrored side.
///
/// The widget tree stays the same during the flip, so scroll position and
/// page state survive. With reduced motion it is a 200 ms crossfade instead.
class LanguageFlip extends StatefulWidget {
  const LanguageFlip({super.key, required this.child});

  final Widget child;

  static LanguageFlipState of(BuildContext context) =>
      context.findAncestorStateOfType<LanguageFlipState>()!;

  @override
  State<LanguageFlip> createState() => LanguageFlipState();
}

class LanguageFlipState extends State<LanguageFlip> with SingleTickerProviderStateMixin {
  // 0 → 0.5 turning away, 0.5 edge-on (locale switches), 0.5 → 1 turning back.
  late final AnimationController _controller = AnimationController(vsync: this);
  double _direction = 1;
  bool _reducedMotion = false;

  bool get isFlipping => _controller.isAnimating;

  Future<void> flip() async {
    if (_controller.isAnimating) return;
    final locale = AppScope.of(context).locale;
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    // Turn in the direction of the old reading order.
    _direction = Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    final half = Duration(milliseconds: _reducedMotion ? 100 : 300);

    await _controller.animateTo(0.5, duration: half, curve: Curves.easeIn);
    if (!mounted) return;
    locale.set(locale.other);
    await _controller.animateTo(1, duration: half, curve: Curves.easeOut);
    if (!mounted) return;
    _controller.value = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      // Same widget types at rest and mid-flip, so the page subtree is never rebuilt from scratch.
      builder: (context, child) {
        final t = _controller.value;
        final peak = 1 - (2 * t - 1).abs(); // 0 at rest, 1 edge-on
        final rotate = !_reducedMotion && t > 0 && t < 1;
        final angle = (t <= 0.5 ? t * 2 : (t - 1) * 2) * (math.pi / 2) * _direction;
        final scale = 1 - 0.06 * peak;
        final glow = rotate ? peak : 0.0;

        return AbsorbPointer(
          absorbing: _controller.isAnimating,
          child: Opacity(
            opacity: _reducedMotion ? 1 - peak : 1,
            child: Transform(
              alignment: Alignment.center,
              transform: rotate
                  ? (Matrix4.identity()
                    // Perspective relative to width keeps the near edge from ballooning.
                    ..setEntry(3, 2, 1 / (2 * width))
                    ..rotateY(angle)
                    ..scaleByDouble(scale, scale, 1, 1))
                  : Matrix4.identity(),
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  gradient: glow == 0
                      ? null
                      : LinearGradient(
                          colors: [
                            palette.accentStart.withValues(alpha: 0.4 * glow),
                            palette.accentStart.withValues(alpha: 0),
                            palette.accentEnd.withValues(alpha: 0),
                            palette.accentEnd.withValues(alpha: 0.4 * glow),
                          ],
                          stops: const [0, 0.1, 0.9, 1],
                        ),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
