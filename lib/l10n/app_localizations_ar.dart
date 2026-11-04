// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مصطفى محمود — مطوّر Flutter';

  @override
  String get navAbout => 'نبذة';

  @override
  String get navProjects => 'المشاريع';

  @override
  String get navExperience => 'الخبرات';

  @override
  String get navSkills => 'المهارات';

  @override
  String get navContact => 'تواصل';

  @override
  String get resume => 'السيرة الذاتية';

  @override
  String get menu => 'القائمة';

  @override
  String get closeMenu => 'إغلاق القائمة';

  @override
  String get themeToDark => 'التبديل إلى الوضع الداكن';

  @override
  String get themeToLight => 'التبديل إلى الوضع الفاتح';

  @override
  String get languageToggleLabel => 'EN';

  @override
  String get languageToggleTooltip => 'Switch to English';

  @override
  String get sectionComingSoon => 'قريبًا';

  @override
  String projectComingSoon(String slug) {
    return 'صفحة $slug قريبًا.';
  }

  @override
  String get notFoundTitle => 'الصفحة غير موجودة';

  @override
  String get notFoundBody => 'هذه الصفحة غير موجودة.';

  @override
  String get backHome => 'العودة إلى الرئيسية';
}
