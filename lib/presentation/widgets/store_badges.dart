import 'package:flutter/material.dart';

import '../../core/models/project_link.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/open_link.dart';

/// One custom-styled store badge button: an icon plus "Google Play" or
/// "App Store". These are not the official badge images.
class StoreBadge extends StatelessWidget {
  const StoreBadge({super.key, required this.link});

  final ProjectLink link;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final isPlay = link.type == ProjectLinkType.playStore;

    return OutlinedButton.icon(
      onPressed: () => openLink(link.url),
      icon: Icon(isPlay ? Icons.store : Icons.phone_iphone, size: 18),
      label: Text(isPlay ? 'Google Play' : 'App Store'),
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.text,
        side: BorderSide(color: palette.surfaceBorder),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Groups store links by their [ProjectLink.label] and renders each group
/// under its label heading. Links without a label are rendered as a group of
/// their own.
class StoreBadges extends StatelessWidget {
  const StoreBadges({super.key, required this.links});

  final List<ProjectLink> links;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<ProjectLink>>{};
    final unlabeled = <ProjectLink>[];
    // Badges are for store links only; GitHub and live links get their own buttons.
    for (final link in links.where(
      (l) =>
          l.type == ProjectLinkType.playStore ||
          l.type == ProjectLinkType.appStore,
    )) {
      final label = link.label;
      if (label == null || label.isEmpty) {
        unlabeled.add(link);
      } else {
        grouped.putIfAbsent(label, () => <ProjectLink>[]).add(link);
      }
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final entry in grouped.entries)
          _StoreGroup(label: entry.key, links: entry.value),
        if (unlabeled.isNotEmpty) _StoreGroup(links: unlabeled),
      ],
    );
  }
}

class _StoreGroup extends StatelessWidget {
  const _StoreGroup({this.label, required this.links});

  final String? label;
  final List<ProjectLink> links;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = AppPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: textTheme.labelSmall?.copyWith(
              color: palette.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final link in links) StoreBadge(link: link)],
        ),
      ],
    );
  }
}
