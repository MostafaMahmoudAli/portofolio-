import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Rounded translucent card with a hairline border and a blurred backdrop.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final radius = BorderRadiusDirectional.circular(20);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border.all(
                color: _hovered ? palette.accent : palette.surfaceBorder,
              ),
              borderRadius: radius,
            ),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
