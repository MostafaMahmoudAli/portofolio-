import 'package:flutter/material.dart';

import 'gradient_text.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return GradientText(text, style: Theme.of(context).textTheme.headlineLarge);
  }
}
