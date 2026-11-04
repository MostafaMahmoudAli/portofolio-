import 'require.dart';

/// Where a project link points.
enum ProjectLinkType { github, playStore, appStore, live }

/// One external link of a project. The URL is language-independent, and so is
/// the optional short [label] naming the link (a plain string like a tech
/// chip, e.g. "Kuwait", "Riyadh").
class ProjectLink {
  const ProjectLink({required this.type, required this.url, this.label});

  factory ProjectLink.fromJson(
    Map<String, dynamic> json, {
    required String where,
  }) {
    final typeName = requiredString(json, 'type', where);
    final type =
        ProjectLinkType.values.asNameMap()[typeName] ??
        (throw FormatException(
          '$where: link type "$typeName" is not one of '
          '${ProjectLinkType.values.map((t) => t.name).join(' | ')}',
        ));
    return ProjectLink(
      type: type,
      url: requiredString(json, 'url', where),
      label: optionalString(json, 'label', where),
    );
  }

  final ProjectLinkType type;
  final String url;

  /// Short plain text naming the link, e.g. "Riyadh".
  final String? label;
}
