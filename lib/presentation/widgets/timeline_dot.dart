import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/theme/app_colors.dart';

class TimelineDot extends StatefulWidget {
  const TimelineDot({super.key});
  @override
  State<TimelineDot> createState() => _TimelineDotState();
}

class _TimelineDotState extends State<TimelineDot> {
  final _visibilityKey = UniqueKey();
  bool _appeared = false;
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
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
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppPalette.of(context).accentEnd,
          ),
        ),
      ),
    );
  }
}
