import 'localized_text.dart';
import 'require.dart';

/// Where a project link points.
enum ProjectLinkType { github, playStore, appStore, live }

/// One external link of a project. The URL is language-independent, and so is
/// the optional short [label] naming the link (a city such as "Kuwait" or
/// "Riyadh", translated per language).
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
      label: json['label'] == null
          ? null
          : LocalizedText.fromJson(
              json['label'],
              where: where,
              field: 'label',
            ),
    );
  }

  final ProjectLinkType type;
  final String url;

  /// Short text naming the link, e.g. "Riyadh" / "الرياض".
  final LocalizedText? label;
}
