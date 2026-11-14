import 'project_video.dart';

enum VideoPlatform { ios, android }

class ProjectVideos {
  const ProjectVideos({this.ios, this.android, this.web});

  factory ProjectVideos.fromJson(Object? value, {required String where}) {
    if (value == null) return const ProjectVideos();
    if (value is! Map<String, dynamic>) {
      throw FormatException('$where: field "videos" must be an object');
    }
    for (final key in value.keys) {
      if (key != 'web' &&
          !VideoPlatform.values.any((platform) => platform.name == key)) {
        throw FormatException('$where: field "videos.$key" is unknown');
      }
    }
    ProjectVideo? read(String name) {
      if (!value.containsKey(name)) return null;
      final video = value[name];
      if (video is! Map<String, dynamic>) {
        throw FormatException('$where: field "videos.$name" must be an object');
      }
      return ProjectVideo.fromJson(video, where: '$where: videos.$name');
    }

    return ProjectVideos(
      ios: read('ios'),
      android: read('android'),
      web: read('web'),
    );
  }

  final ProjectVideo? ios;
  final ProjectVideo? android;

  /// One landscape demo for a web or desktop project. It is not a phone
  /// platform, so it is not part of [available].
  final ProjectVideo? web;

  List<(VideoPlatform, ProjectVideo)> get available => [
    if (ios case final video?) (VideoPlatform.ios, video),
    if (android case final video?) (VideoPlatform.android, video),
  ];

  (VideoPlatform, ProjectVideo)? get primary => available.firstOrNull;
}
