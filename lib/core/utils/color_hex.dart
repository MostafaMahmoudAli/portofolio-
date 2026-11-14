import 'package:flutter/material.dart';

/// Parses a `#RRGGBB` or `#AARRGGBB` string into a [Color].
///
/// The project accents come from the data file as hex strings, so the site
/// can give every project its own tint without touching the colour palette.
Color colorFromHex(String hex) {
  final cleaned = hex.trim().replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return const Color(0xFF000000);
  return Color(cleaned.length <= 6 ? 0xFF000000 | value : value);
}
