import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'document_locale.dart';

/// Starts from the saved choice; on a first visit, Arabic when the browser
/// language is Arabic, otherwise English.
class LocaleController extends ValueNotifier<Locale> {
  LocaleController(this._prefs, {Locale? platformLocale})
    : super(
        _initial(_prefs, platformLocale ?? PlatformDispatcher.instance.locale),
      ) {
    addListener(_syncDocument);
    _syncDocument();
  }

  void _syncDocument() =>
      setDocumentLocale(value.languageCode, isArabic ? 'rtl' : 'ltr');

  static const _key = 'languageCode';
  static const english = Locale('en');
  static const arabic = Locale('ar');

  final SharedPreferences _prefs;

  static Locale _initial(SharedPreferences prefs, Locale platform) =>
      (prefs.getString(_key) ?? platform.languageCode) == 'ar'
      ? arabic
      : english;

  bool get isArabic => value == arabic;

  Locale get other => isArabic ? english : arabic;

  void set(Locale locale) {
    value = locale;
    _prefs.setString(_key, locale.languageCode);
  }
}
