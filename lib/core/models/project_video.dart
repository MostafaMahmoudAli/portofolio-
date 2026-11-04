import 'localized_text.dart';
import 'require.dart';

/// One demo video of a project. Paths are relative to the site root
/// (`media/<slug>/demo.mp4`) and are resolved against the page URL at play time.
class ProjectVideo {
  const ProjectVideo({
    required this.src,
    required this.poster,
    required this.caption,
  });

  factory ProjectVideo.fromJson(
    Map<String, dynamic> json, {
    required String where,
  }) => ProjectVideo(
    src: requiredString(json, 'src', where),
    poster: requiredString(json, 'poster', where),
    caption: json['caption'] == null
        ? null
        : LocalizedText.fromJson(
            json['caption'],
            where: where,
            field: 'caption',
          ),
  );

  final String src;
  final String poster;
  final LocalizedText? caption;
}
