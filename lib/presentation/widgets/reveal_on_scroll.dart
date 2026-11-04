import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Fades its child up the first time it scrolls into the viewport, then leaves
/// it alone: scrolling away and back never replays the reveal.
///
/// Under reduced motion it is a plain fade with no slide.
class RevealOnScroll extends StatefulWidget {
  const RevealOnScroll({super.key, required this.child});

  final Widget child;

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll>
    with SingleTickerProviderStateMixin {
  static const _revealDuration = Duration(milliseconds: 600);
  static const _fadeDuration = Duration(milliseconds: 350);

  final _visibilityKey = UniqueKey();
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _revealDuration,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  bool _revealed = false;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
  }

  void _handleVisibility(VisibilityInfo info) {
    if (_revealed || info.visibleFraction == 0) return;
    _revealed = true;
    _controller.duration = _reduceMotion ? _fadeDuration : _revealDuration;
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = FadeTransition(opacity: _opacity, child: widget.child);

    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _handleVisibility,
      child: _reduceMotion
          ? fade
          : SlideTransition(position: _offset, child: fade),
    );
  }
}
