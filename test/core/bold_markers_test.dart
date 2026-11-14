import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/utils/bold_markers.dart';

void main() {
  test('plain text has one plain part', () {
    expect(parseBoldMarkers('Nothing special'), [('Nothing special', false)]);
  });

  test('a marker becomes a bold part', () {
    expect(parseBoldMarkers('Grew to **57 suites**'), [
      ('Grew to ', false),
      ('57 suites', true),
    ]);
  });

  test('a marker at the start and at the end', () {
    expect(parseBoldMarkers('**FCM** notifications'), [
      ('FCM', true),
      (' notifications', false),
    ]);
    expect(parseBoldMarkers('notifications **FCM**'), [
      ('notifications ', false),
      ('FCM', true),
    ]);
  });

  test('two markers in one line', () {
    expect(parseBoldMarkers('**BLoC** and **MVVM**'), [
      ('BLoC', true),
      (' and ', false),
      ('MVVM', true),
    ]);
  });

  test('an empty marker is left alone', () {
    expect(parseBoldMarkers('a ** b'), [('a ** b', false)]);
  });

  test('an unclosed marker is left alone', () {
    expect(parseBoldMarkers('a **b'), [('a **b', false)]);
  });

  test('an empty text has no parts', () {
    expect(parseBoldMarkers(''), isEmpty);
  });
}
