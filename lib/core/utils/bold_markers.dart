/// Splits a bullet into its plain and bold parts.
///
/// The data marks the key number or technology of a bullet with `**bold**`,
/// for example "Grew coverage to **57 test suites**". The markers are removed
/// from the text; each part is returned with the flag that says whether it is
/// bold.
List<(String, bool)> parseBoldMarkers(String text) {
  final pattern = RegExp(r'\*\*(.+?)\*\*', dotAll: true);
  final parts = <(String, bool)>[];
  var index = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > index) {
      parts.add((text.substring(index, match.start), false));
    }
    parts.add((match.group(1)!, true));
    index = match.end;
  }
  if (index < text.length) parts.add((text.substring(index), false));
  return parts;
}
