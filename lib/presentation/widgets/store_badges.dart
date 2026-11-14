import 'package:flutter/material.dart';

import '../../core/models/project_link.dart';
import '../../core/models/localized_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/open_link.dart';

/// One custom-styled store badge button: an icon plus "Google Play" or
/// "App Store". These are not the official badge images.
class StoreBadge extends StatelessWidget {
  const StoreBadge({super.key, required this.link, this.compact = false});

  final ProjectLink link;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final isPlay = link.type == ProjectLinkType.playStore;

    return OutlinedButton.icon(
      onPressed: () => openLink(link.url),
      icon: Icon(
        isPlay ? Icons.store : Icons.phone_iphone,
        size: compact ? 14 : 18,
      ),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          isPlay ? 'Google Play' : 'App Store',
          maxLines: 1,
          softWrap: false,
          style: compact ? const TextStyle(fontSize: 12) : null,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.text,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: compact ? 6 : 10,
          vertical: 8,
        ),
        minimumSize: const Size(48, 48),
      ),
    );
  }
}

/// Groups store links by their [ProjectLink.label] and renders each group
/// under its label heading: one row per city, with its badge pair. Links
/// without a label are rendered as a group of their own.
///
/// [maxGroups] caps how many labelled groups are shown, so a small card can
/// show one city and leave the rest to the project page.
class StoreBadges extends StatelessWidget {
  const StoreBadges({super.key, required this.links, this.maxGroups});

  final List<ProjectLink> links;
  final int? maxGroups;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<ProjectLink>>{};
    final labels = <String, LocalizedText>{};
    final unlabeled = <ProjectLink>[];
    // Badges are for store links only; GitHub and live links get their own buttons.
    for (final link in links.where(
      (l) =>
          l.type == ProjectLinkType.playStore ||
          l.type == ProjectLinkType.appStore,
    )) {
      final label = link.label;
      if (label == null || label.en.isEmpty) {
        unlabeled.add(link);
      } else {
        // The English text is the stable identity of a group; the visible
        // label follows the page language.
        grouped.putIfAbsent(label.en, () => <ProjectLink>[]).add(link);
        labels.putIfAbsent(label.en, () => label);
      }
    }

    final entries = grouped.entries.toList();
    final shown = maxGroups == null
        ? entries
        : entries.take(maxGroups!.clamp(0, entries.length)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in shown)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8),
            child: _StoreGroup(label: labels[entry.key], links: entry.value),
          ),
        if (unlabeled.isNotEmpty) _StoreGroup(links: unlabeled),
      ],
    );
  }
}

class _StoreGroup extends StatelessWidget {
  const _StoreGroup({this.label, required this.links});

  final LocalizedText? label;
  final List<ProjectLink> links;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final textTheme = Theme.of(context).textTheme;
    final palette = AppPalette.of(context);

    if (label == null) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final link in links) StoreBadge(link: link)],
      );
    }
    return Row(
      key: ValueKey('store-city-${label!.en}'),
      children: [
        SizedBox(
          width: 64,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              label!.of(locale),
              style: textTheme.labelSmall?.copyWith(
                color: palette.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        for (final link in links) ...[
          const SizedBox(width: 8),
          Expanded(child: StoreBadge(link: link, compact: true)),
        ],
      ],
    );
  }
}
