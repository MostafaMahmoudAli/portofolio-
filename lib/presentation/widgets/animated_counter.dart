import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Counts from zero to [value] the first time it scrolls into view, after
/// [delay] so it can wait for a section's entrance animation.
///
/// The digits stay Western in both languages, so they match the resume. Under
/// reduced motion the final number shows straight away, ignoring [delay].
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.suffix = '',
    this.style,
    this.textAlign,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 1200),
  });

  final int value;
  final String suffix;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration delay;
  final Duration duration;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  final _visibilityKey = UniqueKey();
  late final Duration _total = widget.delay + widget.duration;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _total,
  );

  int _display = 0;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _controller.stop();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateDisplay);
  }

  /// The delay is part of the controller's timeline so no Timer is left
  /// behind; the number stays at zero until the delay has passed.
  void _updateDisplay() {
    final countMicros = widget.duration.inMicroseconds;
    final elapsedMicros = (_controller.value * _total.inMicroseconds).round();
    final progress = countMicros <= 0
        ? 1.0
        : ((elapsedMicros - widget.delay.inMicroseconds) / countMicros).clamp(
            0.0,
            1.0,
          );
    final next = (widget.value * Curves.easeOutCubic.transform(progress))
        .round();
    if (next == _display) return;
    setState(() => _display = next);
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
