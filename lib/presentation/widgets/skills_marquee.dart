import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'tech_chip.dart';

class SkillsMarquee extends StatefulWidget {
  const SkillsMarquee({super.key, required this.chips});
  final List<String> chips;
  @override
  State<SkillsMarquee> createState() => _SkillsMarqueeState();
}

class _SkillsMarqueeState extends State<SkillsMarquee>
    with SingleTickerProviderStateMixin {
  final _visibilityKey = UniqueKey();
  final _rowKey = GlobalKey();
  late final Ticker _ticker = createTicker(_tick);
  Duration? _last;
  double _distance = 0;
  bool _visible = false;
  bool _reduced = false;

  void _tick(Duration elapsed) {
    final previous = _last;
    _last = elapsed;
    final box = _rowKey.currentContext?.findRenderObject();
    if (previous == null ||
        box is! RenderBox ||
        !box.hasSize ||
        box.size.width == 0) {
      return;
    }
    setState(
      () => _distance =
          (_distance + (elapsed - previous).inMicroseconds / 1000000 * 24) %
          box.size.width,
    );
  }

  void _syncTicker() {
    if (_visible && !_reduced) {
      if (!_ticker.isActive) {
        _last = null;
        _ticker.start();
      }
    } else {
      _ticker.stop();
      _last = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    _syncTicker();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduced) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final chip in widget.chips) TechChip(label: chip)],
      );
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    Widget row({Key? key}) => Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final chip in widget.chips)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: TechChip(label: chip),
          ),
      ],
    );
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: (info) {
        _visible = info.visibleFraction > 0;
        _syncTicker();
      },
      child: ClipRect(
        child: OverflowBox(
          alignment: AlignmentDirectional.centerStart,
          maxWidth: double.infinity,
          child: Transform.translate(
            key: const ValueKey('marquee-translation'),
            offset: Offset(rtl ? _distance : -_distance, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                row(key: _rowKey),
                ExcludeSemantics(child: row()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
