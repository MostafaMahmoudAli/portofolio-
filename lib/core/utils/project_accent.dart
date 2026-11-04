import 'package:flutter/material.dart';

import '../models/project.dart';

extension ProjectAccent on Project {
  Color get accentColor =>
      Color(0xFF000000 | int.parse(accent.substring(1), radix: 16));
}
