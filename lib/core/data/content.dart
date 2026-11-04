import '../models/profile.dart';
import '../models/project.dart';

/// Everything the site shows, parsed once in `main()` and handed to
/// `PortfolioApp` like the theme and locale controllers.
class Content {
  const Content({required this.profile, required this.projects});

  final Profile profile;
  final List<Project> projects;
}
