import 'dart:math' as math;
import 'dart:ui';

/// A tiny SVG path reader: it turns the `d` attribute of an SVG icon into a
/// [Path], so brand marks can be drawn without adding a package.
///
/// It supports the commands the site's marks need: `M/m`, `L/l`, `H/h`, `V/v`,
/// `C/c`, `S/s`, `Q/q`, `T/t`, `A/a` and `Z/z`, including the implicit
/// "repeat the previous command" shorthand.
Path parseSvgPath(String d) {
  final scanner = _PathScanner(d);
  final path = Path();

  var current = Offset.zero;
  var subpathStart = Offset.zero;
  var cubicControl = Offset.zero;
  var quadControl = Offset.zero;
  var hasCubicControl = false;
  var hasQuadControl = false;
  String? command;

  while (true) {
    late final String letter;
    if (scanner.atCommand) {
      command = scanner.readCommand();
      letter = command;
      if (letter.toUpperCase() == 'Z') {
        path.close();
        current = subpathStart;
        hasCubicControl = false;
        hasQuadControl = false;
        command = null;
        continue;
      }
    } else {
      final previous = command;
      if (previous == null) break;
      // Implicit repeat: `M` continues as `L`, every other command repeats.
      letter = previous.toUpperCase() == 'M'
          ? (previous == previous.toLowerCase() ? 'l' : 'L')
          : previous;
    }

    final relative = letter == letter.toLowerCase();
    final upper = letter.toUpperCase();

    Offset absolute(double x, double y) =>
        relative ? current.translate(x, y) : Offset(x, y);

    if (upper == 'M') {
      final x = scanner.readNumber();
      final y = scanner.readNumber();
      if (x == null || y == null) return path;
      current = absolute(x, y);
      subpathStart = current;
      path.moveTo(current.dx, current.dy);
      hasCubicControl = false;
      hasQuadControl = false;
    } else if (upper == 'L') {
      final x = scanner.readNumber();
      final y = scanner.readNumber();
      if (x == null || y == null) return path;
      current = absolute(x, y);
      path.lineTo(current.dx, current.dy);
      hasCubicControl = false;
      hasQuadControl = false;
    } else if (upper == 'H') {
      final x = scanner.readNumber();
      if (x == null) return path;
      current = Offset(relative ? current.dx + x : x, current.dy);
      path.lineTo(current.dx, current.dy);
      hasCubicControl = false;
      hasQuadControl = false;
    } else if (upper == 'V') {
      final y = scanner.readNumber();
      if (y == null) return path;
      current = Offset(current.dx, relative ? current.dy + y : y);
      path.lineTo(current.dx, current.dy);
      hasCubicControl = false;
      hasQuadControl = false;
    } else if (upper == 'C' || upper == 'S') {
      double? firstX;
      double? firstY;
      if (upper == 'C') {
        firstX = scanner.readNumber();
        firstY = scanner.readNumber();
        if (firstX == null || firstY == null) return path;
      }
      final x2 = scanner.readNumber();
      final y2 = scanner.readNumber();
      final x = scanner.readNumber();
      final y = scanner.readNumber();
      if (x2 == null || y2 == null || x == null || y == null) return path;
      final control1 = upper == 'C'
          ? absolute(firstX!, firstY!)
          : hasCubicControl
          ? current * 2 - cubicControl
          : current;
      final control2 = absolute(x2, y2);
      current = absolute(x, y);
      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        current.dx,
        current.dy,
      );
      cubicControl = control2;
      hasCubicControl = true;
      hasQuadControl = false;
    } else if (upper == 'Q' || upper == 'T') {
      double? firstX;
      double? firstY;
      if (upper == 'Q') {
        firstX = scanner.readNumber();
        firstY = scanner.readNumber();
        if (firstX == null || firstY == null) return path;
      }
      final x = scanner.readNumber();
      final y = scanner.readNumber();
      if (x == null || y == null) return path;
      final control = upper == 'Q'
          ? absolute(firstX!, firstY!)
          : hasQuadControl
          ? current * 2 - quadControl
          : current;
      current = absolute(x, y);
      path.quadraticBezierTo(
        control.dx,
        control.dy,
        current.dx,
        current.dy,
      );
      quadControl = control;
      hasQuadControl = true;
      hasCubicControl = false;
    } else if (upper == 'A') {
      final rx = scanner.readNumber();
      final ry = scanner.readNumber();
      final rotation = scanner.readNumber();
      final largeArc = scanner.readFlag();
      final sweep = scanner.readFlag();
      final x = scanner.readNumber();
      final y = scanner.readNumber();
      if (rx == null ||
          ry == null ||
          rotation == null ||
          largeArc == null ||
          sweep == null ||
          x == null ||
          y == null) {
        return path;
      }
      final end = absolute(x, y);
      _appendArc(
        path,
        current,
        end,
        rx: rx,
        ry: ry,
        rotationDegrees: rotation,
        largeArc: largeArc,
        sweep: sweep,
      );
      current = end;
      hasCubicControl = false;
      hasQuadControl = false;
    } else {
      // Unknown command: stop rather than guess.
      return path;
    }
  }
  return path;
}

/// Appends an SVG elliptical arc as a series of cubic curves, using the
/// endpoint-to-centre conversion from the SVG specification.
void _appendArc(
  Path path,
  Offset start,
  Offset end, {
  required double rx,
  required double ry,
  required double rotationDegrees,
  required bool largeArc,
  required bool sweep,
}) {
  if (start == end) return;
  rx = rx.abs();
  ry = ry.abs();
  if (rx == 0 || ry == 0) {
    path.lineTo(end.dx, end.dy);
    return;
  }

  final phi = rotationDegrees * math.pi / 180;
  final cosPhi = math.cos(phi);
  final sinPhi = math.sin(phi);

  final dx = (start.dx - end.dx) / 2;
  final dy = (start.dy - end.dy) / 2;
  final x1 = cosPhi * dx + sinPhi * dy;
  final y1 = -sinPhi * dx + cosPhi * dy;

  // Scale the radii up when they are too small to span the two points.
  final lambda = (x1 * x1) / (rx * rx) + (y1 * y1) / (ry * ry);
  if (lambda > 1) {
    final scale = math.sqrt(lambda);
    rx *= scale;
    ry *= scale;
  }

  final rx2 = rx * rx;
  final ry2 = ry * ry;
  final x1p2 = x1 * x1;
  final y1p2 = y1 * y1;
  final numerator = rx2 * ry2 - rx2 * y1p2 - ry2 * x1p2;
  final denominator = rx2 * y1p2 + ry2 * x1p2;
  final coefficient = (largeArc != sweep ? 1 : -1) *
      math.sqrt(math.max(0, numerator / denominator));
  final cxp = coefficient * (rx * y1 / ry);
  final cyp = coefficient * (-ry * x1 / rx);

  final center = Offset(
    cosPhi * cxp - sinPhi * cyp + (start.dx + end.dx) / 2,
    sinPhi * cxp + cosPhi * cyp + (start.dy + end.dy) / 2,
  );

  final startVector = Offset((x1 - cxp) / rx, (y1 - cyp) / ry);
  var theta = math.atan2(startVector.dy, startVector.dx);
  var delta = math.atan2((-y1 - cyp) / ry, (-x1 - cxp) / rx) - theta;
  if (!sweep && delta > 0) {
    delta -= 2 * math.pi;
  } else if (sweep && delta < 0) {
    delta += 2 * math.pi;
  }

  // Split the arc into segments of at most 90 degrees.
  final segments = (delta.abs() / (math.pi / 2)).ceil().clamp(1, 8);
  final step = delta / segments;
  final alpha = 4 / 3 * math.tan(step / 4);

  for (var i = 0; i < segments; i++) {
    final theta1 = theta + step * i;
    final theta2 = theta + step * (i + 1);
    final p1 = _ellipsePoint(center, rx, ry, cosPhi, sinPhi, theta1);
    final p2 = _ellipsePoint(center, rx, ry, cosPhi, sinPhi, theta2);
    final d1 = _ellipseTangent(center, rx, ry, cosPhi, sinPhi, theta1);
    final d2 = _ellipseTangent(center, rx, ry, cosPhi, sinPhi, theta2);
    path.cubicTo(
      p1.dx + alpha * d1.dx,
      p1.dy + alpha * d1.dy,
      p2.dx - alpha * d2.dx,
      p2.dy - alpha * d2.dy,
      p2.dx,
      p2.dy,
    );
  }
}

Offset _ellipsePoint(
  Offset center,
  double rx,
  double ry,
  double cosPhi,
  double sinPhi,
  double theta,
) => Offset(
  center.dx + rx * cosPhi * math.cos(theta) - ry * sinPhi * math.sin(theta),
  center.dy + rx * sinPhi * math.cos(theta) + ry * cosPhi * math.sin(theta),
);

Offset _ellipseTangent(
  Offset center,
  double rx,
  double ry,
  double cosPhi,
  double sinPhi,
  double theta,
) => Offset(
  -rx * cosPhi * math.sin(theta) - ry * sinPhi * math.cos(theta),
  -rx * sinPhi * math.sin(theta) + ry * cosPhi * math.cos(theta),
);

/// Reads the tokens of an SVG path string.
class _PathScanner {
  _PathScanner(this.source);

  final String source;
  int _index = 0;

  bool get atCommand {
    var i = _index;
    while (i < source.length && _isWhitespace(source[i])) {
      i++;
    }
    if (i >= source.length) return false;
    const commands = 'MmLlHhVvCcSsQqTtAaZz';
    return commands.contains(source[i]);
  }

  String readCommand() {
    while (_index < source.length &&
        (_isWhitespace(source[_index]) || source[_index] == ',')) {
      _index++;
    }
    final command = source[_index];
    _index++;
    return command;
  }

  /// Reads the next number, or null when the path ends.
  double? readNumber() {    var i = _index;
    while (i < source.length &&
        (_isWhitespace(source[i]) || source[i] == ',')) {
      i++;
    }
    final start = i;
    if (i < source.length && (source[i] == '+' || source[i] == '-')) i++;
    while (i < source.length && _isDigit(source[i])) {
      i++;
    }
    if (i < source.length && source[i] == '.') {
      i++;
      while (i < source.length && _isDigit(source[i])) {
        i++;
      }
    }
    if (i < source.length && (source[i] == 'e' || source[i] == 'E')) {
      final mark = i;
      i++;
      if (i < source.length && (source[i] == '+' || source[i] == '-')) i++;
      if (i < source.length && _isDigit(source[i])) {
        while (i < source.length && _isDigit(source[i])) {
          i++;
        }
      } else {
        i = mark;
      }
    }
    if (i == start) return null;
    _index = i;
    return double.parse(source.substring(start, i));
  }

  /// Reads an arc flag: a single `0` or `1` character, which may sit right
  /// next to the next flag ("01" means large-arc off, sweep on).
  bool? readFlag() {
    var i = _index;
    while (i < source.length &&
        (_isWhitespace(source[i]) || source[i] == ',')) {
      i++;
    }
    if (i >= source.length) return null;
    final char = source[i];
    if (char != '0' && char != '1') return null;
    _index = i + 1;
    return char == '1';
  }

  static bool _isWhitespace(String char) =>
      char == ' ' || char == '\n' || char == '\r' || char == '\t';

  static bool _isDigit(String char) =>
      char.codeUnitAt(0) >= 0x30 && char.codeUnitAt(0) <= 0x39;
}
