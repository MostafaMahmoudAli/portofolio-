import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'project_placeholder.dart';
import 'project_poster.dart';

/// Request a card's cover only after the thumbnail enters the viewport.
class LazyProjectCover extends StatefulWidget {
  const LazyProjectCover({super.key, required this.path, required this.accent});

  final String? path;
  final Color accent;

  @override
  State<LazyProjectCover> createState() => _LazyProjectCoverState();
}

class _LazyProjectCoverState extends State<LazyProjectCover> {
  final _visibilityKey = UniqueKey();
  bool _visible = false;

  @override
  Widget build(BuildContext context) => VisibilityDetector(
    key: _visibilityKey,
    onVisibilityChanged: (info) {
      if (!_visible && info.visibleFraction > 0 && mounted) {
        setState(() => _visible = true);
      }
    },
    child: _visible
        ? ProjectPoster(path: widget.path, accent: widget.accent)
        : ProjectPlaceholder(accent: widget.accent),
  );
}
