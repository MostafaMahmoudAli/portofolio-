import 'package:flutter/material.dart';

import '../../core/models/project_videos.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

String videoPlatformLabel(AppLocalizations l10n, VideoPlatform platform) =>
    platform == VideoPlatform.ios ? l10n.platformIos : l10n.platformAndroid;

class VideoPlatformPicker extends StatelessWidget {
  const VideoPlatformPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.compact = false,
  });
  final VideoPlatform selected;
  final ValueChanged<VideoPlatform> onChanged;

  /// Uses a smaller label, so the picker fits under a narrow phone frame.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<VideoPlatform>(
      showSelectedIcon: false,
      segments: [
        for (final platform in VideoPlatform.values)
          ButtonSegment(
            value: platform,
            label: Text(
              videoPlatformLabel(l10n, platform),
              style: compact
                  ? Theme.of(context).textTheme.labelSmall
                  : null,
            ),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (value) => onChanged(value.single),
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsetsDirectional.symmetric(horizontal: 8),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.accent
              : palette.surface,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.onAccent
              : palette.text,
        ),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color:
                states.contains(WidgetState.focused) ||
                    states.contains(WidgetState.selected)
                ? palette.accentInk
                : palette.surfaceBorder,
          ),
        ),
      ),
    );
  }
}
