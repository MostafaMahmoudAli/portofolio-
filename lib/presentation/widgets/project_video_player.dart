import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../core/models/project_video.dart';
import 'project_placeholder.dart';
import 'project_video_controls.dart';

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
    // A URL identifies media, not its owner. Transfer ownership by evicting
    // the previous player rather than returning its initialized controller.
    if (_byUrl.containsKey(url)) {
      _onEvicted.remove(url)?.call();
      _byUrl.remove(url)?.dispose();
      _order.remove(url);
    }
    if (_order.length >= _maxControllers) {
      final oldest = _order.removeLast();
      _onEvicted.remove(oldest)?.call();
      _byUrl.remove(oldest)?.dispose();
    }
    final controller = VideoPlayerController.networkUrl(resolved);
    _byUrl[url] = controller;
    _onEvicted[url] = onEvicted;
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
/// controls. A missing poster shows a neutral placeholder in its
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
  });

  final ProjectVideo video;
  final String title;

  @override
  State<ProjectVideoPlayer> createState() => _ProjectVideoPlayerState();
}

class _ProjectVideoPlayerState extends State<ProjectVideoPlayer> {
  VideoPlayerController? _controller;
  bool _visible = false;
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
      if (_visible && !_reduceMotion) {
        await controller.play();
      }
      // One rebuild so the VideoPlayer widget appears in place of the poster.
      if (mounted) setState(() {});
    } catch (_) {
      if (!mounted || _controller != controller) return;
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
    try {
      await controller.setVolume(0);
    } catch (_) {}
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

  Future<void> _onPlayTap() async {
    // Nothing to play until the video has scrolled into view.
    if (!_visible || _controller == null || _reduceMotion) return;
    await _controller!.setVolume(1);
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
      return ProjectPlaceholder(title: widget.title);
    }

    return VisibilityDetector(
      key: ObjectKey(this),
      onVisibilityChanged: _onVisibilityChanged,
      child: GestureDetector(
        onTap: _reduceMotion ? null : _onPlayTap,
        child: Stack(
          children: [
            Positioned.fill(
              // A missing poster shows the placeholder in its place; the video
              // still loads and plays over it when visible.
              child: ColoredBox(
                color: Colors.black,
                child: Image.network(
                  _posterUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      ProjectPlaceholder(title: widget.title),
                ),
              ),
            ),
            if (_showVideo)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),
              ),
            // Reduced motion never autoplays: the paused bar offers play.
            if (_controller?.value.isInitialized ?? false)
              Positioned.fill(
                child: ProjectVideoControls(
                  key: ObjectKey(_controller),
                  controller: _controller!,
                  onSurfaceTap: _onPlayTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
