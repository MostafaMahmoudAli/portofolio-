import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../l10n/app_localizations.dart';

/// Western digits in both languages, independent of the surrounding locale.
String formatVideoTime(Duration duration) {
  final seconds = duration.inSeconds.clamp(0, 1 << 53);
  final tail = (seconds % 60).toString().padLeft(2, '0');
  return seconds >= 3600
      ? '${seconds ~/ 3600}:${((seconds ~/ 60) % 60).toString().padLeft(2, '0')}:$tail'
      : '${seconds ~/ 60}:$tail';
}

/// Position ticks rebuild only this overlay, never the visibility detector.
/// The owner, not this widget, acquires and releases the video controller.
class ProjectVideoControls extends StatefulWidget {
  const ProjectVideoControls({
    super.key,
    required this.controller,
    this.onSurfaceTap,
  });
  final VideoPlayerController controller;
  final VoidCallback? onSurfaceTap;
  @override
  State<ProjectVideoControls> createState() => _ProjectVideoControlsState();
}

class _ProjectVideoControlsState extends State<ProjectVideoControls> {
  final _focus = FocusNode(debugLabel: 'Video playback');
  Timer? _idle;
  bool _shown = true;
  late bool _playing;
  double? _drag;
  // The mouse left mid-drag; hide once the drag ends, even while paused.
  bool _exitedDuringDrag = false;

  @override
  void initState() {
    super.initState();
    _playing = widget.controller.value.isPlaying;
    widget.controller.addListener(_onPlaybackChanged);
    _armIdle();
  }

  @override
  void didUpdateWidget(ProjectVideoControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_onPlaybackChanged);
    widget.controller.addListener(_onPlaybackChanged);
    _playing = widget.controller.value.isPlaying;
    _shown = true;
    _drag = null;
    _armIdle();
  }

  void _onPlaybackChanged() {
    final playing = widget.controller.value.isPlaying;
    if (_playing == playing) return;
    _playing = playing;
    if (mounted) setState(() => _shown = true);
    _armIdle();
  }

  void _armIdle() {
    _idle?.cancel();
    if (!_playing || _drag != null) return;
    _idle = Timer(const Duration(seconds: 1), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _shown = false);
      }
    });
  }

  void _reveal() {
    if (!_shown) setState(() => _shown = true);
    _armIdle();
  }

  Future<void> _playPause() async {
    _reveal();
    if (widget.controller.value.isPlaying) {
      await widget.controller.pause();
    } else {
      await widget.controller.play();
    }
  }

  Future<void> _seek(Duration target) async {
    _reveal();
    await widget.controller.seekTo(
      Duration(
        milliseconds: target.inMilliseconds.clamp(
          0,
          widget.controller.value.duration.inMilliseconds,
        ),
      ),
    );
  }

  void _skip(int seconds) =>
      _seek(widget.controller.value.position + Duration(seconds: seconds));
  void _mute() {
    _reveal();
    widget.controller.setVolume(widget.controller.value.volume == 0 ? 1 : 0);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (event is KeyDownEvent) _playPause();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _skip(-5);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _skip(5);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    _idle?.cancel();
    widget.controller.removeListener(_onPlaybackChanged);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const shadows = [Shadow(color: Color(0x80000000), blurRadius: 4)];
    final l10n = AppLocalizations.of(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Focus(
      key: const ValueKey('video-focus'),
      focusNode: _focus,
      onKeyEvent: _onKey,
      child: MouseRegion(
        onEnter: (_) {
          _exitedDuringDrag = false;
          _reveal();
        },
        onHover: (_) => _reveal(),
        onExit: (_) {
          _idle?.cancel();
          if (_drag == null) {
            setState(() => _shown = false);
          } else {
            _exitedDuringDrag = true;
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _focus.requestFocus();
            _reveal();
            widget.onSurfaceTap?.call();
          },
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: widget.controller,
            builder: (context, value, _) {
              final shown = _shown;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    child: ExcludeFocus(
                      excluding: !shown,
                      child: ExcludeSemantics(
                        excluding: !shown,
                        child: IgnorePointer(
                          ignoring: !shown,
                          child: AnimatedOpacity(
                            key: const ValueKey('video-controls-bar'),
                            opacity: shown ? 1 : 0,
                            duration: reduced
                                ? Duration.zero
                                : const Duration(milliseconds: 180),
                            child: Material(
                              color: Colors.transparent,
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final position = Duration(
                                      milliseconds:
                                          (_drag ??
                                                  value.position.inMilliseconds
                                                      .toDouble())
                                              .round(),
                                    );
                                    Widget button(
                                      String label,
                                      IconData icon,
                                      VoidCallback onTap,
                                    ) => IconButton(
                                      tooltip: label,
                                      onPressed: onTap,
                                      icon: Icon(
                                        icon,
                                        size: 20,
                                        color: Colors.white,
                                        shadows: shadows,
                                      ),
                                      style: IconButton.styleFrom(
                                        minimumSize: const Size(48, 48),
                                        maximumSize: const Size(48, 48),
                                        padding: EdgeInsetsDirectional.zero,
                                        foregroundColor: Colors.white,
                                      ),
                                    );
                                    final back = button(
                                      l10n.seekBack5,
                                      Icons.replay_5,
                                      () => _skip(-5),
                                    );
                                    final play = button(
                                      value.isPlaying
                                          ? l10n.pauseVideo
                                          : l10n.playVideo,
                                      value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      _playPause,
                                    );
                                    final forward = button(
                                      l10n.seekForward5,
                                      Icons.forward_5,
                                      () => _skip(5),
                                    );
                                    final mute = button(
                                      value.volume == 0
                                          ? l10n.unmuteVideo
                                          : l10n.muteVideo,
                                      value.volume == 0
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      _mute,
                                    );
                                    final end = value.duration.inMilliseconds
                                        .toDouble();
                                    final slider = SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: Colors.white,
                                        thumbColor: Colors.white,
                                        inactiveTrackColor: Colors.white
                                            .withValues(alpha: 0.4),
                                        overlayColor: Colors.white.withValues(
                                          alpha: 0.12,
                                        ),
                                      ),
                                      child: Slider(
                                        key: const ValueKey('video-position'),
                                        label: formatVideoTime(position),
                                        min: 0,
                                        max: end > 0 ? end : 1,
                                        value: position.inMilliseconds
                                            .toDouble()
                                            .clamp(0, end > 0 ? end : 1),
                                        semanticFormatterCallback: (value) =>
                                            '${l10n.videoPosition}: ${formatVideoTime(Duration(milliseconds: value.round()))}',
                                        onChangeStart: end <= 0
                                            ? null
                                            : (value) {
                                                _idle?.cancel();
                                                setState(() {
                                                  _shown = true;
                                                  _drag = value;
                                                });
                                              },
                                        onChanged: end <= 0
                                            ? null
                                            : (value) =>
                                                  setState(() => _drag = value),
                                        onChangeEnd: end <= 0
                                            ? null
                                            : (value) async {
                                                await _seek(
                                                  Duration(
                                                    milliseconds: value.round(),
                                                  ),
                                                );
                                                if (!mounted) return;
                                                setState(() {
                                                  _drag = null;
                                                  if (_exitedDuringDrag) {
                                                    _shown = false;
                                                  }
                                                  _exitedDuringDrag = false;
                                                });
                                                _armIdle();
                                              },
                                      ),
                                    );
                                    final style = Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          shadows: shadows,
                                        );
                                    final timeline = Row(
                                      children: [
                                        if (constraints.maxWidth >= 220)
                                          Text(
                                            formatVideoTime(position),
                                            key: const ValueKey(
                                              'video-current-time',
                                            ),
                                            style: style,
                                          ),
                                        Expanded(child: slider),
                                        if (constraints.maxWidth >= 220)
                                          Text(
                                            formatVideoTime(value.duration),
                                            key: const ValueKey(
                                              'video-duration',
                                            ),
                                            style: style,
                                          ),
                                      ],
                                    );
                                    // Four 48px targets already occupy 192px. Give
                                    // the slider its own row instead of squeezing it,
                                    // and on a narrow phone frame drop to three
                                    // targets per row so nothing is cut off.
                                    final narrowTimeline = Row(
                                      children: [
                                        Expanded(child: slider),
                                        mute,
                                      ],
                                    );
                                    return Padding(
                                      padding:
                                          const EdgeInsetsDirectional.symmetric(
                                            horizontal: 2,
                                          ),
                                      child: constraints.maxWidth >= 440
                                          ? Row(
                                              children: [
                                                back,
                                                play,
                                                forward,
                                                Expanded(child: timeline),
                                                mute,
                                              ],
                                            )
                                          : constraints.maxWidth >= 200
                                          ? Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    back,
                                                    play,
                                                    forward,
                                                    mute,
                                                  ],
                                                ),
                                                timeline,
                                              ],
                                            )
                                          : Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    back,
                                                    play,
                                                    forward,
                                                  ],
                                                ),
                                                narrowTimeline,
                                              ],
                                            ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
