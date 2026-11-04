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
  String get educationCertifications => 'التعليم والشهادات';

  @override
  String get languages => 'اللغات';

  @override
  String get contactCta => 'لنبنِ شيئًا رائعًا معًا.';

  @override
  String get copyEmail => 'نسخ البريد الإلكتروني';

  @override
  String get emailCopied => 'تم نسخ البريد الإلكتروني';

  @override
  String get sendEmail => 'إرسال بريد إلكتروني';

  @override
  String get backToTop => 'العودة إلى الأعلى';

  @override
  String footerCredit(int year) {
    return 'بُني باستخدام Flutter · © $year';
  }

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

  @override
  String get heroRoleMobile => 'مطوّر تطبيقات الجوال';

  @override
  String get heroRoleCrossPlatform => 'متخصص في التطبيقات متعددة المنصات';

  @override
  String get heroRoleCleanCode => 'مهتم بالكود النظيف';

  @override
  String get viewProjects => 'استعرض المشاريع';

  @override
  String get downloadResume => 'حمّل السيرة الذاتية';

  @override
  String get github => 'GitHub';

  @override
  String get linkedin => 'LinkedIn';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get highlightArchitectureTitle => 'المعمارية النظيفة';

  @override
  String get highlightArchitectureBody =>
      'وحدات مبنية على الميزات بطبقات واضحة وحالات استخدام قابلة للاختبار وحقن للتبعيات.';

  @override
  String get highlightReleasesTitle => 'إصدارات المتاجر';

  @override
  String get highlightReleasesBody =>
      'إصدارات كاملة على Play Console وApp Store Connect مع بوابات CI.';

  @override
  String get highlightMediaTitle => 'الوسائط وFFmpeg';

  @override
  String get highlightMediaBody =>
      'تحرير الفيديو والصوت على الجهاز باستخدام FFmpeg وCameraX ومسارات مخصصة.';

  @override
  String get featuredProjects => 'المشاريع المميزة';

  @override
  String get moreProjects => 'مزيد من المشاريع';

  @override
  String get details => 'التفاصيل';

  @override
  String get moreOnGithub => 'المزيد على GitHub';

  @override
  String get viewOnGitHub => 'عرض على GitHub';

  @override
  String get viewLive => 'عرض الموقع';

  @override
  String get previousProject => 'المشروع السابق';

  @override
  String get nextProject => 'المشروع التالي';

  @override
  String selectVideo(int number) {
    return 'تشغيل الفيديو $number';
  }
}
