import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/theme/app_colors.dart';

/// The dot on the timeline. It carries the company's initial in a small
/// circle, so the reader can tell the entries apart at a glance.
class TimelineDot extends StatefulWidget {
  const TimelineDot({super.key, this.initial});

  /// The company's first letter; the dot stays a plain circle without it.
  final String? initial;

  @override
  State<TimelineDot> createState() => _TimelineDotState();
}

class _TimelineDotState extends State<TimelineDot> {
  final _visibilityKey = UniqueKey();
  bool _appeared = false;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final palette = AppPalette.of(context);
    final initial = widget.initial?.trim();
    final letter = initial == null || initial.isEmpty
        ? null
        : initial.substring(0, 1).toUpperCase();

    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: (info) {
        if (!_appeared && info.visibleFraction > 0) {
          setState(() => _appeared = true);
        }
      },
      child: AnimatedScale(
        scale: reduced || _appeared ? 1 : 0,
        duration: reduced ? Duration.zero : const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        child: Container(
          width: 32,
          height: 32,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: palette.surface,
            border: Border.all(color: palette.accentInk, width: 2),
          ),
          child: letter == null
              ? null
              : Text(
                  letter,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: palette.accentInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
