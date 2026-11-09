import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/models/project_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'project_placeholder.dart';
import 'screens_viewer.dart';
import 'section_title.dart';

class _ScreensScrollBehavior extends MaterialScrollBehavior {
  const _ScreensScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}

class ScreensGallery extends StatefulWidget {
  const ScreensGallery({super.key, required this.screens});
  final List<ProjectScreen> screens;
  @override
  State<ScreensGallery> createState() => _ScreensGalleryState();
}

class _ScreensGalleryState extends State<ScreensGallery> {
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.screens.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(AppLocalizations.of(context).screens),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ScrollConfiguration(
            behavior: const _ScreensScrollBehavior(),
            child: ListView.builder(
              key: const ValueKey('screen-thumbnails'),
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              itemCount: widget.screens.length,
              itemExtent: 128,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsetsDirectional.only(
                  end: 16,
                  top: 8,
                  bottom: 8,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AspectRatio(
                    aspectRatio: 9 / 19.5,
                    child: _ScreenThumbnail(
                      key: ValueKey('screen-thumbnail-$index'),
                      screens: widget.screens,
                      index: index,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScreenThumbnail extends StatefulWidget {
  const _ScreenThumbnail({
    super.key,
    required this.screens,
    required this.index,
  });
  final List<ProjectScreen> screens;
  final int index;
  @override
  State<_ScreenThumbnail> createState() => _ScreenThumbnailState();
}

class _ScreenThumbnailState extends State<_ScreenThumbnail> {
  final _focus = FocusNode(debugLabel: 'Screenshot thumbnail');
  bool _hovered = false;
  bool _focused = false;
  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    await showScreensViewer(
      context,
      screens: widget.screens,
      initialIndex: widget.index,
    );
    if (mounted) _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final label = AppLocalizations.of(
      context,
    ).screenshotOf(widget.index + 1, widget.screens.length);
    final radius = BorderRadiusDirectional.circular(18);
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: Material(
            color: palette.surface,
            borderRadius: radius,
            child: InkWell(
              focusNode: _focus,
              onTap: _open,
              borderRadius: radius.resolve(Directionality.of(context)),
              onFocusChange: (focused) => setState(() => _focused = focused),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: _hovered || _focused
                        ? palette.accentInk
                        : palette.surfaceBorder,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadiusDirectional.circular(16),
                    child: AspectRatio(
                      aspectRatio: 9 / 19.5,
                      child: Image.network(
                        Uri.base
                            .resolve(widget.screens[widget.index].src)
                            .toString(),
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                        errorBuilder: (context, error, stackTrace) =>
                            const ProjectPlaceholder(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
