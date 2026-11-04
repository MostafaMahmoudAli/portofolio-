import 'package:flutter/material.dart';

class SectionContent extends StatelessWidget {
  const SectionContent({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(24, 96, 24, 48),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SizedBox(width: double.infinity, child: child),
      ),
    ),
  );
}
