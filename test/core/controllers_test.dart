import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/localization/locale_controller.dart';
import 'package:portfolio/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  group('ThemeController', () {
    test('starts from the system setting when nothing is saved', () async {
      expect(ThemeController(await prefsWith({})).value, ThemeMode.system);
    });

    test(
      'toggle switches away from what is on screen and is remembered',
      () async {
        final prefs = await prefsWith({});
        ThemeController(prefs).toggle(Brightness.dark);
        expect(ThemeController(prefs).value, ThemeMode.light);
        ThemeController(prefs).toggle(Brightness.light);
        expect(ThemeController(prefs).value, ThemeMode.dark);
      },
    );
  });

  group('LocaleController', () {
    test('first visit follows the browser language', () async {
      final prefs = await prefsWith({});
      expect(
        LocaleController(prefs, platformLocale: const Locale('ar', 'EG')).value,
        LocaleController.arabic,
      );
      expect(
        LocaleController(prefs, platformLocale: const Locale('fr')).value,
        LocaleController.english,
      );
    });

    test('a saved choice beats the browser language', () async {
      final prefs = await prefsWith({'languageCode': 'en'});
      expect(
        LocaleController(prefs, platformLocale: const Locale('ar')).value,
        LocaleController.english,
      );
    });

    test('set is remembered', () async {
      final prefs = await prefsWith({});
      final controller = LocaleController(
        prefs,
        platformLocale: const Locale('en'),
      );
      expect(controller.other, LocaleController.arabic);
      controller.set(controller.other);
      expect(
        LocaleController(prefs, platformLocale: const Locale('en')).isArabic,
        isTrue,
      );
    });
  });
}
