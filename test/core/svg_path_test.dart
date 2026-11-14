import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/utils/svg_path.dart';

void main() {
  Rect boundsOf(String d) => parseSvgPath(d).getBounds();

  test('a move and a line', () {
    expect(boundsOf('M10 10 L20 20'), const Rect.fromLTRB(10, 10, 20, 20));
  });

  test('relative commands and the shorthand for omitted separators', () {
    expect(boundsOf('M10 10h10v10'), const Rect.fromLTRB(10, 10, 20, 20));
  });

  test('a repeated move continues as a line', () {
    expect(
      boundsOf('M0 0 10 0 10 10'),
      const Rect.fromLTRB(0, 0, 10, 10),
    );
  });

  test('horizontal and vertical shorthand', () {
    expect(boundsOf('M5 5H15V25'), const Rect.fromLTRB(5, 5, 15, 25));
  });

  test('cubic curves reach their end point', () {
    expect(
      boundsOf('M0 0C0 0 10 0 10 10'),
      const Rect.fromLTRB(0, 0, 10, 10),
    );
  });

  test('an arc bulges out to its radius', () {
    // SVG angles grow with the y axis pointing down, so a sweep of 1 from
    // (0,0) to (10,0) travels over the top of the circle.
    final bounds = boundsOf('M0 0A5 5 0 0 1 10 0');
    expect(bounds.left, closeTo(0, 0.01));
    expect(bounds.right, closeTo(10, 0.01));
    expect(bounds.top, closeTo(-5, 0.01));
    expect(bounds.bottom, closeTo(0, 0.01));

    final mirrored = boundsOf('M0 0A5 5 0 0 0 10 0');
    expect(mirrored.top, closeTo(0, 0.01));
    expect(mirrored.bottom, closeTo(5, 0.01));
  });

  test('arc flags may be written without a separator', () {
    // "01" means large-arc off and sweep on; "00" the other way round.
    final swept = boundsOf('M0 0a5 5 0 012 0');
    final other = boundsOf('M0 0a5 5 0 002 0');
    expect(swept.right, closeTo(2, 0.01));
    expect(other.right, closeTo(2, 0.01));
    // The two arcs bend to opposite sides.
    expect(swept.top, lessThan(0));
    expect(other.bottom, greaterThan(0));
    expect(swept.top, closeTo(-other.bottom, 0.01));
  });

  test('a close returns to the start of the subpath', () {
    expect(
      boundsOf('M0 0L10 0L10 10Z'),
      const Rect.fromLTRB(0, 0, 10, 10),
    );
  });

  test('a malformed path stops instead of throwing', () {
    expect(() => parseSvgPath('M0 0 L'), returnsNormally);
    expect(() => parseSvgPath(''), returnsNormally);
    expect(() => parseSvgPath('M0 0X5 5'), returnsNormally);
  });
}
