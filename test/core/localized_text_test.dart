import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/models/localized_text.dart';

void main() {
  const en = Locale('en');
  const ar = Locale('ar');

  test('returns the text for each language', () {
    const text = LocalizedText(en: 'Hello', ar: 'مرحبا');
    expect(text.of(en), 'Hello');
    expect(text.of(ar), 'مرحبا');
  });

  test('a missing "ar" falls back to English and warns in debug', () {
    final logs = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
    addTearDown(() => debugPrint = originalDebugPrint);

    final text = LocalizedText.fromJson(
      const {'en': 'Hello'},
      where: 'profile.json: profile',
      field: 'summary',
    );

    expect(text.of(en), 'Hello');
    expect(text.of(ar), 'Hello');
    expect(logs, everyElement(allOf(contains('"summary"'), contains('"ar"'))));
  });

  test('a present "ar" does not warn', () {
    final logs = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
    addTearDown(() => debugPrint = originalDebugPrint);

    final text = LocalizedText.fromJson(
      const {'en': 'Hello', 'ar': 'مرحبا'},
      where: 'profile.json: profile',
      field: 'summary',
    );
    expect(text.of(ar), 'مرحبا');
    expect(logs, isEmpty);
  });

  test('a plain string is rejected, naming the field', () {
    expect(
      () => LocalizedText.fromJson(
        'Only English',
        where: 'profile.json: profile',
        field: 'title',
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          allOf(contains('profile.json'), contains('"title"')),
        ),
      ),
    );
  });

  test('a missing "en" throws, naming the field', () {
    expect(
      () => LocalizedText.fromJson(
        const {'ar': 'مرحبا'},
        where: 'profile.json: profile',
        field: 'summary',
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          allOf(contains('profile.json'), contains('"summary.en"')),
        ),
      ),
    );
  });
}
