import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Rounded translucent card with a hairline border and a blurred backdrop.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(24),
    this.borderColor,
    this.hoverBorderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// The resting border colour; the theme's hairline by default.
  final Color? borderColor;

  /// The border colour while hovered; the theme's accent ink by default.
  final Color? hoverBorderColor;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final radius = BorderRadiusDirectional.circular(20);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      // Shadow must sit outside the clip or its entire outer blur is cut off.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: dark ? const Color(0x59000000) : const Color(0x0F23272A),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.surface,
                border: Border.all(
                  color: _hovered
                      ? (widget.hoverBorderColor ?? palette.accentInk)
                      : (widget.borderColor ?? palette.surfaceBorder),
                ),
                borderRadius: radius,
              ),
              child: Padding(padding: widget.padding, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
