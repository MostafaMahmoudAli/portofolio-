import 'localized_text.dart';
import 'project_link.dart';
import 'project_screen.dart';
import 'project_videos.dart';
import 'require.dart';

/// One project card, featured ("big card, phone-framed video") or one of the
/// smaller "More projects" cards. Tech chip names stay plain strings.
class Project {
  const Project({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.featured,
    required this.order,
    required this.accent,
    required this.summary,
    required this.bullets,
    required this.tech,
    required this.status,
    required this.cover,
    required this.videos,
    required this.links,
    this.impact,
    this.screens = const [],
  });

  factory Project.fromJson(
    Map<String, dynamic> json, {
    required String where,
  }) => Project(
    slug: requiredString(json, 'slug', where),
    title: LocalizedText.fromJson(json['title'], where: where, field: 'title'),
    subtitle: LocalizedText.fromJson(
      json['subtitle'],
      where: where,
      field: 'subtitle',
    ),
    featured: requiredBool(json, 'featured', where),
    order: requiredInt(json, 'order', where),
    accent: requiredString(json, 'accent', where),
    summary: LocalizedText.fromJson(
      json['summary'],
      where: where,
      field: 'summary',
    ),
    bullets: [
      for (final (i, bullet) in requiredMaps(json, 'bullets', where).indexed)
        LocalizedText.fromJson(bullet, where: where, field: 'bullets[$i]'),
    ],
    tech: requiredStringList(json, 'tech', where),
    status: json['status'] == null
        ? null
        : LocalizedText.fromJson(json['status'], where: where, field: 'status'),
    cover: optionalString(json, 'cover', where),
    impact: json['impact'] == null
        ? null
        : LocalizedText.fromJson(json['impact'], where: where, field: 'impact'),
    videos: ProjectVideos.fromJson(json['videos'], where: where),
    screens: [
      for (final (i, screen) in optionalMaps(json, 'screens', where).indexed)
        ProjectScreen.fromJson(screen, where: '$where: screens[$i]'),
    ],
    links: [
      for (final (i, link) in optionalMaps(json, 'links', where).indexed)
        ProjectLink.fromJson(link, where: '$where: links[$i]'),
    ],
  );

  final String slug;
  final LocalizedText title;
  final LocalizedText subtitle;

  /// Featured cards get the large alternating layout; the rest join
  /// "More projects" in the grid.
  final bool featured;

  /// Sort order across all projects, featured first.
  final int order;

  /// Legacy content metadata; presentation uses the shared app palette.
  final String accent;
  final LocalizedText summary;
  final List<LocalizedText> bullets;
  final List<String> tech;
  final LocalizedText? status;
  final LocalizedText? impact;
  final String? cover;
  final ProjectVideos videos;
  final List<ProjectScreen> screens;
  final List<ProjectLink> links;
}
