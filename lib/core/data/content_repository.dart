import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/profile.dart';
import '../models/project.dart';
import '../models/require.dart';
import 'content.dart';

/// Loads `assets/data/profile.json` and `assets/data/projects.json` and
/// parses them into models. A missing required field throws a
/// [FormatException] naming the file, the entry (slug or index) and the field.
class ContentRepository {
  const ContentRepository({
    this.profilePath = 'assets/data/profile.json',
    this.projectsPath = 'assets/data/projects.json',
  });

  final String profilePath;
  final String projectsPath;

  static const _profileWhere = 'profile.json: profile';

  Future<Content> load() async {
    final profile = Profile.fromJson(
      await _readJson(profilePath),
      where: _profileWhere,
    );

    final projectsJson = await _readJson(projectsPath);
    final entries = requiredMaps(projectsJson, 'projects', projectsPath);
    final projects = [
      for (final (i, entry) in entries.indexed)
        Project.fromJson(entry, where: projectsPath + _entryTag(entry, i)),
    ];
    return Content(profile: profile, projects: projects);
  }

  /// ` entry "remix"` when the slug exists, ` entry #3` when it does not.
  static String _entryTag(Map<String, dynamic> entry, int index) {
    final slug = entry['slug'];
    return slug is String ? ': entry "$slug"' : ': entry #$index';
  }

  Future<Map<String, dynamic>> _readJson(String path) async {
    final raw = await rootBundle.loadString(path);
    final Object? parsed;
    try {
      parsed = jsonDecode(raw);
    } on FormatException catch (error) {
      throw FormatException('$path: invalid JSON (${error.message})');
    }
    if (parsed is! Map<String, dynamic>) {
      throw FormatException('$path: the top level must be an object');
    }
    return parsed;
  }
}
