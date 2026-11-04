import 'package:flutter/material.dart';

import '../../core/models/project.dart';
import '../../core/models/project_video.dart';
import 'phone_frame.dart';
import 'project_poster.dart';
import 'project_video_player.dart';

/// The Hero owns only the static frame. Playback is a separate overlay and is
/// mounted only after the route settles, so a flight cannot acquire a player.
class ProjectMediaFrame extends StatelessWidget {
  const ProjectMediaFrame({
    super.key,
    required this.project,
    required this.video,
    required this.accent,
    required this.width,
    this.hero = true,
  });

  final Project project;
  final ProjectVideo video;
  final Color accent;
  final double width;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final poster = PhoneFrame(
      width: width,
      accent: accent,
      child: ProjectPoster(path: video.poster, accentColor: accent),
    );
    final route = ModalRoute.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([
        route?.animation,
        route?.secondaryAnimation,
      ]),
      builder: (context, _) {
        final settled =
            route == null ||
            (route.isCurrent &&
                route.animation?.status == AnimationStatus.completed &&
                route.secondaryAnimation?.status == AnimationStatus.dismissed);
        return SizedBox(
          width: width,
          height: width * 1.9,
          child: Stack(
            children: [
              if (hero && !MediaQuery.disableAnimationsOf(context))
                Hero(
                  tag: 'project-${project.slug}',
                  flightShuttleBuilder:
                      (context, animation, direction, from, to) => poster,
                  child: poster,
                )
              else
                poster,
              if (settled)
                PhoneFrame.mediaLayer(
                  child: ProjectVideoPlayer(
                    key: ValueKey(video.src),
                    video: video,
                    title: project.title.of(Localizations.localeOf(context)),
                    accentColor: accent,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
