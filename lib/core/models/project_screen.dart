import 'localized_text.dart';
import 'require.dart';

class ProjectScreen {
  const ProjectScreen({required this.src, this.caption});

  factory ProjectScreen.fromJson(
    Map<String, dynamic> json, {
    required String where,
  }) => ProjectScreen(
    src: requiredString(json, 'src', where),
    caption: json['caption'] == null
        ? null
        : LocalizedText.fromJson(
            json['caption'],
            where: where,
            field: 'caption',
          ),
  );

  final String src;
  final LocalizedText? caption;
}
