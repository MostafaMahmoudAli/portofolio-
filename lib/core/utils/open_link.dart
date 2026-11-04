import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in a new tab. Relative paths (e.g. `resume.pdf`) resolve against
/// the site's base URL, so they work under the GitHub Pages sub-path.
Future<void> openLink(String url) =>
    launchUrl(Uri.base.resolve(url), webOnlyWindowName: '_blank');
