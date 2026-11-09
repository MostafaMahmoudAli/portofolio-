import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/project_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'project_placeholder.dart';

Future<void> showScreensViewer(
  BuildContext context, {
  required List<ProjectScreen> screens,
  required int initialIndex,
}) async {
  if (screens.isEmpty) return;
  final reduced = MediaQuery.disableAnimationsOf(context);
  final locale = Localizations.localeOf(context);
  await showGeneralDialog<void>(
    context: context,
    routeSettings: const RouteSettings(name: '/screens'),
    barrierDismissible: true,
    barrierLabel: AppLocalizations.of(context).closeScreens,
    barrierColor: AppPalette.dark.background.withValues(alpha: 0.96),
    transitionDuration: reduced
        ? Duration.zero
        : const Duration(milliseconds: 200),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        reduced ? child : FadeTransition(opacity: animation, child: child),
    pageBuilder: (context, animation, secondaryAnimation) => Theme(
      data: AppTheme.build(Brightness.dark, locale),
      child: ScreensViewer(
        screens: List.unmodifiable(screens),
        initialIndex: initialIndex.clamp(0, screens.length - 1),
      ),
    ),
  );
}

class ScreensViewer extends StatefulWidget {
  const ScreensViewer({
    super.key,
    required this.screens,
    required this.initialIndex,
  });
  final List<ProjectScreen> screens;
  final int initialIndex;
  @override
  State<ScreensViewer> createState() => _ScreensViewerState();
}

class _ScreensViewerState extends State<ScreensViewer> {
  final _focus = FocusNode(debugLabel: 'Screenshot viewer');
  final _prefetched = <String>{};
  late final _pages = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  bool _scheduledPrecache = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduledPrecache) return;
    _scheduledPrecache = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _precacheNeighbors(_index);
    });
  }

  void _precacheNeighbors(int index) {
    for (final neighbor in [index - 1, index + 1]) {
      if (neighbor < 0 || neighbor >= widget.screens.length) continue;
      final url = Uri.base.resolve(widget.screens[neighbor].src).toString();
      if (!_prefetched.add(url)) continue;
      // Missing media should use the same graceful fallback as the visible image.
      precacheImage(NetworkImage(url), context, onError: (_, _) {});
    }
  }

  void _go(int delta) {
    final target = (_index + delta).clamp(0, widget.screens.length - 1);
    if (target == _index || !_pages.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(target);
    } else {
      _pages.animateToPage(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      final rtl = Directionality.of(context) == TextDirection.rtl;
      final right = event.logicalKey == LogicalKeyboardKey.arrowRight;
      _go(right != rtl ? 1 : -1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    _focus.dispose();
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final style = Theme.of(context).textTheme;
    Widget button(String label, IconData icon, VoidCallback action, Key key) =>
        IconButton(
          key: key,
          tooltip: label,
          icon: Icon(icon),
          onPressed: action,
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            foregroundColor: palette.text,
          ),
        );
    return Focus(
      autofocus: true,
      focusNode: _focus,
      onKeyEvent: _onKey,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Semantics(
                      liveRegion: true,
                      excludeSemantics: true,
                      label: l10n.screenshotOf(
                        _index + 1,
                        widget.screens.length,
                      ),
                      child: Text(
                        '${_index + 1} / ${widget.screens.length}',
                        key: const ValueKey('screen-counter'),
                        style: style.titleMedium,
                      ),
                    ),
                    const Spacer(),
                    button(
                      l10n.closeScreens,
                      Icons.close_rounded,
                      () => Navigator.of(context).pop(),
                      const ValueKey('close-screens'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      key: const ValueKey('screens-pages'),
                      controller: _pages,
                      itemCount: widget.screens.length,
                      onPageChanged: (index) {
                        setState(() => _index = index);
                        _precacheNeighbors(index);
                      },
                      itemBuilder: (context, index) {
                        final screen = widget.screens[index];
                        return Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 64,
                                  vertical: 8,
                                ),
                                child: SizedBox.expand(
                                  child: Image.network(
                                    Uri.base.resolve(screen.src).toString(),
                                    fit: BoxFit.contain,
                                    excludeFromSemantics: true,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const ProjectPlaceholder(),
                                  ),
                                ),
                              ),
                            ),
                            if (screen.caption case final caption?)
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  64,
                                  8,
                                  64,
                                  24,
                                ),
                                child: Text(
                                  caption.of(locale),
                                  style: style.bodyMedium,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    if (_index > 0)
                      PositionedDirectional(
                        start: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: button(
                            l10n.previousScreen,
                            Icons.arrow_back_rounded,
                            () => _go(-1),
                            const ValueKey('previous-screen'),
                          ),
                        ),
                      ),
                    if (_index < widget.screens.length - 1)
                      PositionedDirectional(
                        end: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: button(
                            l10n.nextScreen,
                            Icons.arrow_forward_rounded,
                            () => _go(1),
                            const ValueKey('next-screen'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
