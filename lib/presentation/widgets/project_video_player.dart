import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../core/models/project_video.dart';
import '../../core/theme/app_colors.dart';
import 'project_placeholder.dart';

/// Keeps at most two video controllers alive at a time. When a third
/// controller is needed, the oldest (least recently used) one is disposed.
class VideoControllerManager {
  VideoControllerManager._();
  static final VideoControllerManager instance = VideoControllerManager._();

  static const int _maxControllers = 2;
  final Map<String, VideoPlayerController> _byUrl = {};
  final Map<String, VoidCallback> _onEvicted = {};
  final List<String> _order = []; // most-recently-used first

  int get controllerCount => _byUrl.length;

  /// Returns the controller currently managed for [url], if any.
  VideoPlayerController? controllerFor(String url) => _byUrl[url];

  /// [onEvicted] runs before the controller is disposed to make room for
  /// another, so its owner stops using it and falls back to the poster.
  VideoPlayerController acquire(
    String url,
    Uri resolved, {
    required VoidCallback onEvicted,
  }) {
    _onEvicted[url] = onEvicted;
    if (_byUrl.containsKey(url)) {
      _order.remove(url);
      _order.insert(0, url);
      return _byUrl[url]!;
    }
    if (_order.length >= _maxControllers) {
      final oldest = _order.removeLast();
      _onEvicted.remove(oldest)?.call();
      _byUrl.remove(oldest)?.dispose();
    }
    final controller = VideoPlayerController.networkUrl(resolved);
    _byUrl[url] = controller;
    _order.insert(0, url);
    return controller;
  }

  /// Releases [controller] for [url], disposing it only if it is still the
  /// controller managed for that url.
  void release(String url, VideoPlayerController controller) {
    if (_byUrl[url] != controller) return;
    _order.remove(url);
    _onEvicted.remove(url);
    _byUrl.remove(url)?.dispose();
  }

  void disposeAll() {
    for (final controller in _byUrl.values) {
      controller.dispose();
    }
    _byUrl.clear();
    _onEvicted.clear();
    _order.clear();
  }
}

/// A phone-framed demo video.
///
/// The poster is shown first. The controller is created with
/// `VideoPlayerController.networkUrl` only when the video scrolls into view,
/// then it plays muted and looped while visible and pauses when it leaves.
/// At most two controllers are alive at a time, managed by
/// [VideoControllerManager]. A tap unmutes the video and shows simple
/// controls. A missing poster shows an accent-gradient placeholder in its
/// place; a failed video replaces the whole player with it. Under reduced motion the video does not
/// autoplay; the poster is shown with a play button instead.
///
/// Rebuilds are deliberately scarce: visibility only acquires/pauses the
/// controller, and the playing video repaints through the controller's own
/// listener rather than rebuilding this widget. That keeps VisibilityDetector
/// from re-firing during rebuilds and looping endlessly.
class ProjectVideoPlayer extends StatefulWidget {
  const ProjectVideoPlayer({
    super.key,
    required this.video,
    required this.title,
    required this.accentColor,
  });

  final ProjectVideo video;
  final String title;
  final Color accentColor;

  @override
  State<ProjectVideoPlayer> createState() => _ProjectVideoPlayerState();
}

class _ProjectVideoPlayerState extends State<ProjectVideoPlayer> {
  VideoPlayerController? _controller;
  bool _visible = false;
  bool _muted = true;
  bool _showControls = false;
  bool _videoError = false;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);
  bool get _showVideo =>
      _visible &&
      _controller != null &&
      _controller!.value.isInitialized &&
      !_videoError;

  String get _posterUrl => Uri.base.resolve(widget.video.poster).toString();

  /// Creates (or re-acquires after eviction) the controller and starts muted,
  /// looped playback. Only called when the video becomes visible. Rebuilds at
  /// most once, when the controller transitions from null to created.
  Future<void> _ensureController() async {
    if (_videoError) return;
    final manager = VideoControllerManager.instance;
    final managed = manager.controllerFor(widget.video.src);
    if (_controller != null && managed == _controller) {
      // Re-visit: resume playback without rebuilding.
      if (_visible && !_reduceMotion) {
        await _controller!.play();
      }
      return;
    }

    _controller = manager.acquire(
      widget.video.src,
      Uri.base.resolve(widget.video.src),
      onEvicted: _onEvicted,
    );
    final controller = _controller!..addListener(_onControllerChanged);
    try {
      await controller.initialize();
      // Unmounted, or evicted while initializing.
      if (!mounted || _controller != controller) return;
      await controller.setLooping(true);
      await controller.setVolume(0.0);
      _muted = true;
      if (_visible && !_reduceMotion) {
        await controller.play();
      }
      // One rebuild so the VideoPlayer widget appears in place of the poster.
      if (mounted) setState(() {});
    } catch (_) {
      _videoError = true;
      if (mounted) setState(() {});
    }
  }

  Future<void> _pause() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.pause();
    } catch (_) {}
    _muted = true;
    _showControls = false;
  }

  void _onControllerChanged() {
    final controller = _controller;
    if (controller == null || !mounted) return;
    if (controller.value.hasError && !_videoError) {
      _videoError = true;
      setState(() {});
    }
  }

  /// Another video took this controller's slot: drop it and show the poster.
  void _onEvicted() {
    _controller?.removeListener(_onControllerChanged);
    _controller = null;
    _showControls = false;
    if (mounted) setState(() {});
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final nowVisible = info.visibleFraction > 0;
    if (nowVisible == _visible) return;
    _visible = nowVisible;
    if (nowVisible) {
      _ensureController();
    } else {
      _pause();
    }
    // No rebuild here: play/pause repaint through the controller's listener.
  }

  Future<void> _unmute() async {
    _muted = false;
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.setVolume(1.0);
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _play() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.play();
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _togglePlayPause() async {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleMute() async {
    _muted = !_muted;
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.setVolume(_muted ? 0.0 : 1.0);
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _onPlayTap() async {
    // Nothing to play until the video has scrolled into view.
    if (!_visible && _controller == null) return;
    if (_reduceMotion) {
      await _unmute();
      await _play();
    } else {
      setState(() => _showControls = true);
      await _unmute();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    if (_controller != null) {
      VideoControllerManager.instance.release(widget.video.src, _controller!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoError) {
      return ProjectPlaceholder(
        accentColor: widget.accentColor,
        title: widget.title,
      );
    }

    return VisibilityDetector(
      key: ValueKey(widget.video.src),
      onVisibilityChanged: _onVisibilityChanged,
      child: GestureDetector(
        onTap: _reduceMotion ? null : _onPlayTap,
        child: Stack(
          children: [
            Positioned.fill(
              // A missing poster shows the placeholder in its place; the video
              // still loads and plays over it when visible.
              child: Image.network(
                _posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    ProjectPlaceholder(
                      accentColor: widget.accentColor,
                      title: widget.title,
                    ),
              ),
            ),
            if (_showVideo) Positioned.fill(child: VideoPlayer(_controller!)),
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reduced motion never autoplays: offer play until it plays.
                  if (_reduceMotion &&
                      _visible &&
                      !(_controller?.value.isPlaying ?? false))
                    _ControlButton(
                      label: AppLocalizations.of(context).playVideo,
                      icon: Icons.play_circle_rounded,
                      onTap: _onPlayTap,
                    ),
                  if (_showControls)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ControlButton(
                          label: _controller!.value.isPlaying
                              ? AppLocalizations.of(context).pauseVideo
                              : AppLocalizations.of(context).playVideo,
                          icon: _controller!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          onTap: _togglePlayPause,
                        ),
                        const SizedBox(width: 8),
                        _ControlButton(
                          label: _muted
                              ? AppLocalizations.of(context).unmuteVideo
                              : AppLocalizations.of(context).muteVideo,
                          icon: _muted ? Icons.volume_off : Icons.volume_up,
                          onTap: _toggleMute,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Material(
      color: Colors.transparent,
      child: IconButton(
        tooltip: label,
        onPressed: onTap,
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: palette.surface,
          side: BorderSide(color: palette.surfaceBorder),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.all(Radius.circular(10)),
          ),
        ),
        icon: Icon(icon, size: 20, color: palette.text),
      ),
    );
  }
}
