// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mostafa Mahmoud — Flutter Developer';

  @override
  String get navAbout => 'About';

  @override
  String get navProjects => 'Projects';

  @override
  String get navExperience => 'Experience';

  @override
  String get navSkills => 'Skills';

  @override
  String get navContact => 'Contact';

  @override
  String get resume => 'Resume';

  @override
  String get menu => 'Menu';

  @override
  String get closeMenu => 'Close menu';

  @override
  String get themeToDark => 'Switch to dark theme';

  @override
  String get themeToLight => 'Switch to light theme';

  @override
  String get languageToggleLabel => 'ع';

  @override
  String get languageToggleTooltip => 'التبديل إلى العربية';

  @override
  String get sectionComingSoon => 'Coming soon';

  @override
  String projectComingSoon(String slug) {
    return 'The page for $slug is coming soon.';
  }

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundBody => 'This page doesn\'t exist.';

  @override
  String get backHome => 'Back to home';
}
