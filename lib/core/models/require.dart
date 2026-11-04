// Shared JSON-check helpers. Every failed check throws a [FormatException]
// whose message names the file, the entry (slug or index) and the field, so a
// broken entry fails loudly in debug.
//
// `where` strings look like `profile.json: profile`, `profile.json:
// experience[2]` or `projects.json: entry "remix"`.

Never missingField(String where, String field) =>
    throw FormatException('$where is missing required field "$field"');

String requiredString(Map<String, dynamic> json, String field, String where) {
  final value = json[field];
  if (value is! String) missingField(where, field);
  return value;
}

String? optionalString(Map<String, dynamic> json, String field, String where) {
  final value = json[field];
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('$where: field "$field" must be a string');
  }
  return value;
}

int requiredInt(Map<String, dynamic> json, String field, String where) {
  final value = json[field];
  if (value is! int) missingField(where, field);
  return value;
}

bool requiredBool(Map<String, dynamic> json, String field, String where) {
  final value = json[field];
  if (value is! bool) missingField(where, field);
  return value;
}

List<Map<String, dynamic>> requiredMaps(
  Map<String, dynamic> json,
  String field,
  String where,
) {
  final list = json[field];
  if (list is! List) missingField(where, field);
  return [
    for (final (i, entry) in list.indexed)
      entry is Map<String, dynamic>
          ? entry
          : throw FormatException('$where: $field[$i] must be an object'),
  ];
}

List<String> requiredStringList(
  Map<String, dynamic> json,
  String field,
  String where,
) {
  final list = json[field];
  if (list is! List) missingField(where, field);
  return [
    for (final (i, entry) in list.indexed)
      entry is String
          ? entry
          : throw FormatException('$where: $field[$i] must be a string'),
  ];
}

/// An optional list of objects; an empty list when the field is absent.
List<Map<String, dynamic>> optionalMaps(
  Map<String, dynamic> json,
  String field,
  String where,
) {
  final list = json[field];
  if (list == null) return const [];
  if (list is! List) {
    throw FormatException('$where: field "$field" must be a list of objects');
  }
  return [
    for (final (i, entry) in list.indexed)
      entry is Map<String, dynamic>
          ? entry
          : throw FormatException(
              '$where: field "$field[$i]" must be an object',
            ),
  ];
}
