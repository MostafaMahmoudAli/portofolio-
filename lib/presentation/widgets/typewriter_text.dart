import 'package:flutter/material.dart';

/// Cycles through [roles] with a typewriter effect: type, hold, erase, next.
///
/// Under reduced motion it simply shows the first role, fully typed.
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.roles,
    this.style,
    this.textAlign,
    this.cursor = '|',
  });

  final List<String> roles;
  final TextStyle? style;
  final TextAlign? textAlign;
  final String cursor;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  /// Per role: typing, holding, erasing, then a short pause before the next.
  static const _perRole = Duration(seconds: 4);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _perRole * widget.roles.length,
  );

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      if (_controller.isAnimating) _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The slice of the current role that is visible at [progress] (0..1).
  String _textAt(double progress) {
    final roles = widget.roles;
    if (roles.isEmpty) return '';
    final perRole = 1 / roles.length;
    final index = (progress / perRole).floor().clamp(0, roles.length - 1);
    final local = (progress - index * perRole) / perRole;
    final role = roles[index].characters;
    final length = role.length;

    const typingEnd = 0.40;
    const holdEnd = 0.65;
    const erasingEnd = 0.85;

    final visible = switch (local) {
      < typingEnd => (length * local / typingEnd).floor(),
      < holdEnd => length,
      < erasingEnd =>
        (length * (1 - (local - holdEnd) / (erasingEnd - holdEnd))).floor(),
      _ => 0,
    };
    // Grapheme clusters, so Arabic letters with marks are never split.
    return role.take(visible.clamp(0, length)).toString();
  }

  @override
  Widget build(BuildContext context) {
    final roles = widget.roles;
    if (roles.isEmpty) return const SizedBox.shrink();

    if (_reduceMotion) {
      return Text(
        roles.first,
        style: widget.style,
        textAlign: widget.textAlign,
      );
    }

    // The longest role is laid out invisibly underneath, so the height is
    // already reserved for the tallest line count: typing never pushes the
    // rest of the page around.
    final longest = roles.reduce(
      (a, b) => a.characters.length >= b.characters.length ? a : b,
    );

    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: [
        ExcludeSemantics(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0,
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  '$longest${widget.cursor}',
                  style: widget.style,
                  textAlign: widget.textAlign,
                ),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => SizedBox(
            width: double.infinity,
            child: Text(
              '${_textAt(_controller.value)}${widget.cursor}',
              style: widget.style,
              textAlign: widget.textAlign,
            ),
          ),
        ),
      ],
    );
  }
}
