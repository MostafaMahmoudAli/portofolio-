import 'localized_text.dart';
import 'require.dart';

/// One skills section: a translated group title and its chips. The chip names
/// (Flutter, FFmpegKit…) stay plain strings in both languages.
class SkillGroup {
  const SkillGroup({required this.title, required this.chips});

  factory SkillGroup.fromJson(
    Map<String, dynamic> json, {
    required String where,
  }) {
    final title = LocalizedText.fromJson(
      json['title'],
      where: where,
      field: 'title',
    );
    return SkillGroup(
      title: title,
      chips: requiredStringList(json, 'chips', where),
    );
  }

  final LocalizedText title;
  final List<String> chips;
}
