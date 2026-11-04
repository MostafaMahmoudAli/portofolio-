import 'require.dart';

/// Where a project link points.
enum ProjectLinkType { github, playStore, appStore, live }

/// One external link of a project. The URL is a plain string.
class ProjectLink {
  const ProjectLink({required this.type, required this.url});

  factory ProjectLink.fromJson(
    Map<String, dynamic> json, {
    required String where,
  }) {
    final typeName = requiredString(json, 'type', where);
    final type = ProjectLinkType.values.where((t) => t.name == typeName).isEmpty
        ? throw FormatException(
            '$where: link type "$typeName" is not one of '
            '${ProjectLinkType.values.map((t) => t.name).join(', ')}',
          )
        : ProjectLinkType.values.byName(typeName);
    return ProjectLink(type: type, url: requiredString(json, 'url', where));
  }

  final ProjectLinkType type;
  final String url;
}
