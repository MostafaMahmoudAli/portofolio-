import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Counts from zero to [value] the first time it scrolls into view.
///
/// The digits stay Western in both languages, so they match the resume. Under
/// reduced motion the final number shows straight away.
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.suffix = '',
    this.style,
    this.textAlign,
    this.duration = const Duration(milliseconds: 1200),
  });

  final int value;
  final String suffix;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration duration;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  final _visibilityKey = UniqueKey();
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  int _display = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _display =
            (widget.value * Curves.easeOutCubic.transform(_controller.value))
                .round();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleVisibility(VisibilityInfo info) {
    if (_started || info.visibleFraction == 0) return;
    _started = true;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final text = Text(
      '${reduceMotion ? widget.value : _display}${widget.suffix}',
      style: widget.style,
      textAlign: widget.textAlign,
      // Keeps "310K+" in that order inside an RTL paragraph.
      textDirection: TextDirection.ltr,
    );

    if (reduceMotion) return text;

    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _handleVisibility,
      child: text,
    );
  }
}
