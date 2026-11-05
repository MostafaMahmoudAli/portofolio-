import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'theme_reveal_painter.dart';

/// Keeps the old frame above the new theme until a circular hole uncovers it.
class ThemeReveal extends StatefulWidget {
  const ThemeReveal({super.key, required this.child});

  final Widget child;

  static ThemeRevealState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<ThemeRevealState>();

  @override
  State<ThemeReveal> createState() => ThemeRevealState();
}

class ThemeRevealState extends State<ThemeReveal>
    with SingleTickerProviderStateMixin {
  final _boundary = GlobalKey();
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  ui.Image? _snapshot;
  Offset _center = Offset.zero;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) _clear();
    });
  }

  void _clear() {
    final image = _snapshot;
    setState(() {
      _snapshot = null;
      _busy = false;
    });
    image?.dispose();
  }

  Future<void> toggle(BuildContext button, VoidCallback switchTheme) async {
    if (_busy) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      switchTheme();
      return;
    }
    _busy = true;
    final boundary =
        _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final box = button.findRenderObject()! as RenderBox;
    _center = boundary.globalToLocal(
      box.localToGlobal(box.size.center(Offset.zero)),
    );
    try {
      final image = await boundary.toImage(
        pixelRatio: MediaQuery.devicePixelRatioOf(context).clamp(1, 2),
      );
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() => _snapshot = image);
      switchTheme();
      _animation.forward(from: 0);
    } catch (_) {
      // A platform view or unavailable raster frame must not block the toggle.
      if (mounted && _snapshot == null) switchTheme();
      if (mounted) _clear();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    _snapshot?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      RepaintBoundary(key: _boundary, child: widget.child),
      if (_snapshot case final image?)
        PositionedDirectional(
          top: 0,
          bottom: 0,
          start: 0,
          end: 0,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) => CustomPaint(
                key: const ValueKey('theme-reveal-overlay'),
                painter: ThemeRevealPainter(image, _center, _animation.value),
              ),
            ),
          ),
        ),
    ],
  );
}
