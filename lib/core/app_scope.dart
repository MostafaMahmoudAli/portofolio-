import 'package:flutter/widgets.dart';

import 'data/content.dart';
import 'localization/locale_controller.dart';
import 'theme/theme_controller.dart';

/// Hands the app-wide state to the widgets that read or change it (sections and
/// the toggles).
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.content,
    required this.theme,
    required this.locale,
    required super.child,
  });

  /// The parsed JSON, loaded once in `main()` before `runApp`.
  final Content content;
  final ThemeController theme;
  final LocaleController locale;

  static AppScope of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      theme != oldWidget.theme || locale != oldWidget.locale;
}
