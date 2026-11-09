import 'project_video.dart';

enum VideoPlatform { ios, android }

class ProjectVideos {
  const ProjectVideos({this.ios, this.android});

  factory ProjectVideos.fromJson(Object? value, {required String where}) {
    if (value == null) return const ProjectVideos();
    if (value is! Map<String, dynamic>) {
      throw FormatException('$where: field "videos" must be an object');
    }
    for (final key in value.keys) {
      if (!VideoPlatform.values.any((platform) => platform.name == key)) {
        throw FormatException('$where: field "videos.$key" is unknown');
      }
    }
    ProjectVideo? read(VideoPlatform platform) {
      if (!value.containsKey(platform.name)) return null;
      final video = value[platform.name];
      if (video is! Map<String, dynamic>) {
        throw FormatException(
          '$where: field "videos.${platform.name}" must be an object',
        );
      }
      return ProjectVideo.fromJson(
        video,
        where: '$where: videos.${platform.name}',
      );
    }

    return ProjectVideos(
      ios: read(VideoPlatform.ios),
      android: read(VideoPlatform.android),
    );
  }

  final ProjectVideo? ios;
  final ProjectVideo? android;

  List<(VideoPlatform, ProjectVideo)> get available => [
    if (ios case final video?) (VideoPlatform.ios, video),
    if (android case final video?) (VideoPlatform.android, video),
  ];

  (VideoPlatform, ProjectVideo)? get primary => available.firstOrNull;
}
