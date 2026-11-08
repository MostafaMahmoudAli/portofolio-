import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Circular profile photo inside a slowly rotating mint ring.
///
/// The photo is resolved against [Uri.base] like other site media. Until it
/// loads, or when it is missing, the name's initials stand in.
class ProfilePhoto extends StatefulWidget {
  const ProfilePhoto({
    super.key,
    required this.name,
    required this.photo,
    this.size = 240,
  });

  final String name;
  final String photo;
  final double size;

  @override
  State<ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(seconds: 12);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      if (_controller.isAnimating) _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _initials {
    final words = widget.name.trim().split(RegExp(r'\s+'));
    return words
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word.substring(0, 1).toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final ringWidth = widget.size * 0.025;

    Widget ring(double turns) => SizedBox.square(
      dimension: widget.size,
      child: CustomPaint(
        painter: _RingPainter(palette: palette, turns: turns),
      ),
    );

    return Semantics(
      label: widget.name,
      image: true,
      child: SizedBox.square(
        dimension: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (reduceMotion)
              ring(0)
            else
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => ring(_controller.value),
              ),
            Padding(
              padding: EdgeInsetsDirectional.all(ringWidth * 3),
              child: ClipOval(
                child: SizedBox.expand(
                  child: Image.network(
                    Uri.base.resolve(widget.photo).toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _Initials(initials: _initials),
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : _Initials(initials: _initials),
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

class _Initials extends StatelessWidget {
  const _Initials({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: palette.surface),
      child: Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: palette.text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.palette, required this.turns});

  final AppPalette palette;

  /// 0..1 around the circle.
  final double turns;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.025;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - stroke / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = palette.accent.withValues(alpha: 0.25);
    canvas.drawCircle(center, radius, paint);
    paint.color = palette.accent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      turns * 2 * math.pi,
      1.65 * math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.turns != turns || oldDelegate.palette != palette;
}
