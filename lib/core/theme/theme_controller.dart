import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Starts from the saved choice, or the system setting when there is none.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController(this._prefs) : super(_read(_prefs));

  static const _key = 'themeMode';
  final SharedPreferences _prefs;

  static ThemeMode _read(SharedPreferences prefs) => switch (prefs.getString(_key)) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };

  /// Switches away from what is on screen ([current]) and remembers the choice.
  void toggle(Brightness current) {
    value = current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    _prefs.setString(_key, value.name);
  }
}
