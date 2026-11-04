import 'localized_text.dart';
import 'require.dart';

/// One counter in the hero, e.g. 310 with the suffix "K+" and the label
/// "Downloads". The digits stay Western in both languages.
class Stat {
  const Stat({
    required this.value,
    required this.suffix,
    required this.label,
  });

  factory Stat.fromJson(Map<String, dynamic> json, {required String where}) =>
      Stat(
        value: requiredInt(json, 'value', where),
        suffix: optionalString(json, 'suffix', where) ?? '',
        label: LocalizedText.fromJson(
          json['label'],
          where: where,
          field: 'label',
        ),
      );

  final int value;
  final String suffix;
  final LocalizedText label;
}
