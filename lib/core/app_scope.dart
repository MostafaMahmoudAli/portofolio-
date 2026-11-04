import 'package:flutter/widgets.dart';

import 'localization/locale_controller.dart';
import 'theme/theme_controller.dart';

/// Hands the app-wide controllers to the widgets that change them (the toggles).
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.theme,
    required this.locale,
    required super.child,
  });

  final ThemeController theme;
  final LocaleController locale;

  static AppScope of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      theme != oldWidget.theme || locale != oldWidget.locale;
}
