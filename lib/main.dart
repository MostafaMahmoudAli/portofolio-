import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/data/content_repository.dart';
import 'core/localization/locale_controller.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // Content is static: load it once, fail loudly if a JSON entry is broken.
  final content = await const ContentRepository().load();
  runApp(
    PortfolioApp(
      content: content,
      themeController: ThemeController(prefs),
      localeController: LocaleController(prefs),
    ),
  );
}
