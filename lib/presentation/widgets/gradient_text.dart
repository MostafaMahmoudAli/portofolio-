import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Text filled with the accent gradient.
class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          AppPalette.of(context).accentGradient.createShader(bounds),
      // White is only a placeholder: srcIn keeps the gradient's colors, not the text's.
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}
