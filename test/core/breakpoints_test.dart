import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/utils/breakpoints.dart';

void main() {
  test('ScreenSize.fromWidth maps widths to spec breakpoints', () {
    expect(ScreenSize.fromWidth(599), ScreenSize.phone);
    expect(ScreenSize.fromWidth(600), ScreenSize.tablet);
    expect(ScreenSize.fromWidth(1024), ScreenSize.tablet);
    expect(ScreenSize.fromWidth(1025), ScreenSize.desktop);
  });
}
