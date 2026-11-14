import 'package:flutter/material.dart';

import '../../core/utils/bold_markers.dart';

/// A paragraph whose `**bold**` markers from the data become bold spans.
class MarkedText extends StatelessWidget {
  const MarkedText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base =
        style ??
        Theme.of(context).textTheme.bodyMedium ??
        const TextStyle();
    final bold = base.copyWith(fontWeight: FontWeight.w700);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (final (part, isBold) in parseBoldMarkers(text))
            TextSpan(text: part, style: isBold ? bold : base),
        ],
      ),
    );
  }
}
