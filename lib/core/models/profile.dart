import 'experience.dart';
import 'localized_text.dart';
import 'skill_group.dart';
import 'stat.dart';
import 'require.dart';

/// Everything the hero and the info sections show: identity, links, summary,
/// stats, the experience timeline and the skills groups. Plain strings are
/// language-independent (email, phone, paths); everything readable is
/// localized.
class Profile {
  const Profile({
    required this.name,
    required this.title,
    required this.location,
    required this.email,
    required this.phone,
    required this.linkedin,
    required this.github,
    required this.photo,
    required this.resumePdf,
    required this.summary,
    required this.stats,
    required this.experience,
    required this.skillGroups,
    required this.education,
    required this.languages,
    required this.certifications,
  });

  factory Profile.fromJson(Map<String, dynamic> json, {required String where}) {
    final phone = optionalString(json, 'phone', where);
    return Profile(
      name: requiredString(json, 'name', where),
      title: LocalizedText.fromJson(
        json['title'],
        where: where,
        field: 'title',
      ),
      location: LocalizedText.fromJson(
        json['location'],
        where: where,
        field: 'location',
      ),
      email: requiredString(json, 'email', where),
      phone: phone,
      linkedin: requiredString(json, 'linkedin', where),
      github: requiredString(json, 'github', where),
      photo: requiredString(json, 'photo', where),
      resumePdf: requiredString(json, 'resumePdf', where),
      summary: LocalizedText.fromJson(
        json['summary'],
        where: where,
        field: 'summary',
      ),
      stats: [
        for (final (i, entry) in requiredMaps(json, 'stats', where).indexed)
          Stat.fromJson(entry, where: '$where: stats[$i]'),
      ],
      experience: [
        for (final (i, entry) in requiredMaps(json, 'experience', where).indexed)
          Experience.fromJson(entry, where: '$where: experience[$i]'),
      ],
      skillGroups: [
        for (final (i, entry) in requiredMaps(json, 'skillGroups', where).indexed)
          SkillGroup.fromJson(entry, where: '$where: skillGroups[$i]'),
      ],
      education: LocalizedText.fromJson(
        json['education'],
        where: where,
        field: 'education',
      ),
      languages: [
        for (final (i, entry)
            in requiredMaps(json, 'languages', where).indexed)
          LocalizedText.fromJson(
            entry,
            where: where,
            field: 'languages[$i]',
          ),
      ],
      certifications: [
        for (final (i, entry)
            in requiredMaps(json, 'certifications', where).indexed)
          LocalizedText.fromJson(
            entry,
            where: where,
            field: 'certifications[$i]',
          ),
      ],
    );
  }

  final String name;
  final LocalizedText title;
  final LocalizedText location;
  final String email;

  /// Optional; some templates leave it out.
  final String? phone;
  final String linkedin;
  final String github;
  final String photo;
  final String resumePdf;
  final LocalizedText summary;
  final List<Stat> stats;
  final List<Experience> experience;
  final List<SkillGroup> skillGroups;
  final LocalizedText education;
  final List<LocalizedText> languages;
  final List<LocalizedText> certifications;
}
