import '../../l10n/app_localizations.dart';

/// The sections of the home page, in page order. The nav bar links to each one.
enum HomeSection {
  about,
  projects,
  experience,
  skills,
  contact;

  String label(AppLocalizations l10n) => switch (this) {
        about => l10n.navAbout,
        projects => l10n.navProjects,
        experience => l10n.navExperience,
        skills => l10n.navSkills,
        contact => l10n.navContact,
      };
}
