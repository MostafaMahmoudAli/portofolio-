import 'localized_text.dart';
import 'require.dart';

/// One timeline entry. The company name stays a plain string; role, dates and
/// working mode are translated.
class Experience {
  const Experience({
    required this.role,
    required this.company,
    required this.dates,
    required this.mode,
    required this.bullets,
  });

  factory Experience.fromJson(
    Map<String, dynamic> json, {
    required String where,
  }) =>
      Experience(
        role: LocalizedText.fromJson(
          json['role'],
          where: where,
          field: 'role',
        ),
        company: requiredString(json, 'company', where),
        dates: LocalizedText.fromJson(
          json['dates'],
          where: where,
          field: 'dates',
        ),
        mode: LocalizedText.fromJson(
          json['mode'],
          where: where,
          field: 'mode',
        ),
        bullets: [
          for (final (i, bullet)
              in requiredMaps(json, 'bullets', where).indexed)
            LocalizedText.fromJson(
              bullet,
              where: where,
              field: 'bullets[$i]',
            ),
        ],
      );

  final LocalizedText role;
  final String company;
  final LocalizedText dates;
  final LocalizedText mode;
  final List<LocalizedText> bullets;
}
