import 'package:flutter/widgets.dart' show Locale, debugPrint;

/// A human-readable text that carries both site languages, parsed from
/// `{"en": "...", "ar": "..."}`. A missing `ar` falls back to the English text
/// with a debug-mode warning, so a half-translated entry still shows.
class LocalizedText {
  const LocalizedText({required this.en, String? ar}) : _ar = ar ?? en;

  /// Accepts a localized object; a plain string stands for the English text.
  /// `where` names the file and entry, `field` the JSON key being read, so a
  /// missing required `en` fails loudly.
  factory LocalizedText.fromJson(
    Object? json, {
    required String where,
    required String field,
  }) {
    if (json is String) return LocalizedText(en: json);
    if (json is! Map<String, dynamic>) {
      throw FormatException(
        '$where: field "$field" must be a localized object (or a string)',
      );
    }
    final en = json['en'];
    if (en is! String) {
      throw FormatException('$where: field "$field.en" is missing');
    }
    final ar = json['ar'];
    if (ar == null) {
      assert(() {
        debugPrint(
          '$where: field "$field" has no "ar" text, falling back to English',
        );
        return true;
      }());
    } else if (ar is! String) {
      throw FormatException('$where: field "$field.ar" must be a string');
    }
    return LocalizedText(en: en, ar: ar);
  }

  final String en;
  final String _ar;

  /// The text for [locale]; Arabic falls back to the English text.
  String of(Locale locale) => locale.languageCode == 'ar' ? _ar : en;
}
