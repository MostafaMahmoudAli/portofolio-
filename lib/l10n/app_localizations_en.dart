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
  String get playVideo => 'Play video';

  @override
  String get pauseVideo => 'Pause video';

  @override
  String get muteVideo => 'Mute video';

  @override
  String get unmuteVideo => 'Unmute video';

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
  String get educationCertifications => 'Education & certifications';

  @override
  String get languages => 'Languages';

  @override
  String get contactCta => 'Let\'s build something great together.';

  @override
  String get copyEmail => 'Copy email';

  @override
  String get emailCopied => 'Email copied';

  @override
  String get sendEmail => 'Send email';

  @override
  String get backToTop => 'Back to top';

  @override
  String footerCredit(int year) {
    return 'Built with Flutter · © $year';
  }

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

  @override
  String get heroRoleMobile => 'Mobile App Developer';

  @override
  String get heroRoleCrossPlatform => 'Cross-platform Specialist';

  @override
  String get heroRoleCleanCode => 'Clean Code Advocate';

  @override
  String get viewProjects => 'View projects';

  @override
  String get downloadResume => 'Download resume';

  @override
  String get github => 'GitHub';

  @override
  String get linkedin => 'LinkedIn';

  @override
  String get email => 'Email';

  @override
  String get highlightArchitectureTitle => 'Clean Architecture';

  @override
  String get highlightArchitectureBody =>
      'Feature-first modules with clear layers, testable use cases and dependency injection.';

  @override
  String get highlightReleasesTitle => 'Store releases';

  @override
  String get highlightReleasesBody =>
      'End-to-end Play Console and App Store Connect releases, gated by CI.';

  @override
  String get highlightMediaTitle => 'Media & FFmpeg';

  @override
  String get highlightMediaBody =>
      'On-device video and audio editing with FFmpeg, CameraX and custom pipelines.';

  @override
  String get featuredProjects => 'Featured Projects';

  @override
  String get moreProjects => 'More Projects';

  @override
  String get details => 'Details';

  @override
  String get moreOnGithub => 'More on GitHub';

  @override
  String get viewOnGitHub => 'View on GitHub';

  @override
  String get viewLive => 'View live site';

  @override
  String get previousProject => 'Previous project';

  @override
  String get nextProject => 'Next project';

  @override
  String selectVideo(int number) {
    return 'Play video $number';
  }
}
