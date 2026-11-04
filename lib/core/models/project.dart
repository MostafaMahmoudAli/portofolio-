import 'localized_text.dart';
import 'project_link.dart';
import 'project_video.dart';
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
    videos: [
      for (final (i, video) in optionalMaps(json, 'videos', where).indexed)
        ProjectVideo.fromJson(video, where: '$where: videos[$i]'),
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

  /// Hex accent color like `#FF5C8A`, tinting the card glow and chips.
  final String accent;
  final LocalizedText summary;
  final List<LocalizedText> bullets;
  final List<String> tech;
  final LocalizedText? status;
  final String? cover;
  final List<ProjectVideo> videos;
  final List<ProjectLink> links;
}
