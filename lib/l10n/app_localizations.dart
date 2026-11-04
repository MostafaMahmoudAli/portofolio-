import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mostafa Mahmoud — Flutter Developer'**
  String get appTitle;

  /// No description provided for @navAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get navAbout;

  /// No description provided for @navProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get navProjects;

  /// No description provided for @navExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get navExperience;

  /// No description provided for @navSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get navSkills;

  /// No description provided for @navContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get navContact;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @closeMenu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get closeMenu;

  /// No description provided for @themeToDark.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get themeToDark;

  /// No description provided for @themeToLight.
  ///
  /// In en, this message translates to:
  /// **'Switch to light theme'**
  String get themeToLight;

  /// No description provided for @languageToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'ع'**
  String get languageToggleLabel;

  /// No description provided for @languageToggleTooltip.
  ///
  /// In en, this message translates to:
  /// **'التبديل إلى العربية'**
  String get languageToggleTooltip;

  /// No description provided for @educationCertifications.
  ///
  /// In en, this message translates to:
  /// **'Education & certifications'**
  String get educationCertifications;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @contactCta.
  ///
  /// In en, this message translates to:
  /// **'Let\'s build something great together.'**
  String get contactCta;

  /// No description provided for @copyEmail.
  ///
  /// In en, this message translates to:
  /// **'Copy email'**
  String get copyEmail;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email copied'**
  String get emailCopied;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get sendEmail;

  /// No description provided for @backToTop.
  ///
  /// In en, this message translates to:
  /// **'Back to top'**
  String get backToTop;

  /// No description provided for @footerCredit.
  ///
  /// In en, this message translates to:
  /// **'Built with Flutter · © {year}'**
  String footerCredit(int year);

  /// No description provided for @projectComingSoon.
  ///
  /// In en, this message translates to:
  /// **'The page for {slug} is coming soon.'**
  String projectComingSoon(String slug);

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This page doesn\'t exist.'**
  String get notFoundBody;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backHome;

  /// No description provided for @heroRoleMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile App Developer'**
  String get heroRoleMobile;

  /// No description provided for @heroRoleCrossPlatform.
  ///
  /// In en, this message translates to:
  /// **'Cross-platform Specialist'**
  String get heroRoleCrossPlatform;

  /// No description provided for @heroRoleCleanCode.
  ///
  /// In en, this message translates to:
  /// **'Clean Code Advocate'**
  String get heroRoleCleanCode;

  /// No description provided for @viewProjects.
  ///
  /// In en, this message translates to:
  /// **'View projects'**
  String get viewProjects;

  /// No description provided for @downloadResume.
  ///
  /// In en, this message translates to:
  /// **'Download resume'**
  String get downloadResume;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @linkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get linkedin;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @highlightArchitectureTitle.
  ///
  /// In en, this message translates to:
  /// **'Clean Architecture'**
  String get highlightArchitectureTitle;

  /// No description provided for @highlightArchitectureBody.
  ///
  /// In en, this message translates to:
  /// **'Feature-first modules with clear layers, testable use cases and dependency injection.'**
  String get highlightArchitectureBody;

  /// No description provided for @highlightReleasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Store releases'**
  String get highlightReleasesTitle;

  /// No description provided for @highlightReleasesBody.
  ///
  /// In en, this message translates to:
  /// **'End-to-end Play Console and App Store Connect releases, gated by CI.'**
  String get highlightReleasesBody;

  /// No description provided for @highlightMediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Media & FFmpeg'**
  String get highlightMediaTitle;

  /// No description provided for @highlightMediaBody.
  ///
  /// In en, this message translates to:
  /// **'On-device video and audio editing with FFmpeg, CameraX and custom pipelines.'**
  String get highlightMediaBody;

  /// No description provided for @featuredProjects.
  ///
  /// In en, this message translates to:
  /// **'Featured Projects'**
  String get featuredProjects;

  /// No description provided for @moreProjects.
  ///
  /// In en, this message translates to:
  /// **'More Projects'**
  String get moreProjects;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @moreOnGithub.
  ///
  /// In en, this message translates to:
  /// **'More on GitHub'**
  String get moreOnGithub;

  /// No description provided for @viewOnGitHub.
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get viewOnGitHub;

  /// No description provided for @viewLive.
  ///
  /// In en, this message translates to:
  /// **'View live site'**
  String get viewLive;

  /// No description provided for @previousProject.
  ///
  /// In en, this message translates to:
  /// **'Previous project'**
  String get previousProject;

  /// No description provided for @nextProject.
  ///
  /// In en, this message translates to:
  /// **'Next project'**
  String get nextProject;

  /// No description provided for @selectVideo.
  ///
  /// In en, this message translates to:
  /// **'Play video {number}'**
  String selectVideo(int number);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
