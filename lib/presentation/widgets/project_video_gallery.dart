import 'package:flutter/material.dart';

import '../../core/models/project.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import '../../l10n/app_localizations.dart';
import 'project_media_frame.dart';
import 'project_poster.dart';

class ProjectVideoGallery extends StatefulWidget {
  const ProjectVideoGallery({super.key, required this.project});

  final Project project;

  @override
  State<ProjectVideoGallery> createState() => _ProjectVideoGalleryState();
}

class _ProjectVideoGalleryState extends State<ProjectVideoGallery> {
  PageController? _pages;
  bool? _phone;
  int _selected = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final phone = ScreenSize.of(context) == ScreenSize.phone;
    if (_phone == phone) return;
    _phone = phone;
    final previous = _pages;
    _pages = PageController(initialPage: _selected);
    // Keep selection across breakpoints; detach the old PageView first.
    if (previous != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
    }
  }

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    if (project.videos.isEmpty) return const SizedBox.shrink();
    final phone = ScreenSize.of(context) == ScreenSize.phone;
    final palette = AppPalette.of(context);
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context);
    final width = phone ? 240.0 : 300.0;
    Widget frame(int index) => Center(
      child: ProjectMediaFrame(
        project: project,
        video: project.videos[index],
        width: width,
        hero: index == 0,
      ),
    );
    return Column(
      children: [
        SizedBox(
          height: width * 1.9,
          child: phone
              ? PageView.builder(
                  controller: _pages,
                  itemCount: project.videos.length,
                  onPageChanged: (index) => setState(() => _selected = index),
                  itemBuilder: (context, index) => frame(index),
                )
              : frame(_selected),
        ),
        if (project.videos[_selected].caption case final caption?)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16),
            child: Text(caption.of(locale), textAlign: TextAlign.center),
          ),
        if (project.videos.length > 1)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16),
            child: Wrap(
              key: ValueKey(phone ? 'gallery-dots' : 'gallery-thumbnails'),
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < project.videos.length; i++)
                  Semantics(
                    selected: i == _selected,
                    child: Tooltip(
                      message: l10n.selectVideo(i + 1),
                      child: InkWell(
                        onTap: () {
                          if (phone) {
                            _pages!.animateToPage(
                              i,
                              duration: MediaQuery.disableAnimationsOf(context)
                                  ? Duration.zero
                                  : const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            setState(() => _selected = i);
                          }
                        },
                        child: Container(
                          width: phone ? 48 : 96,
                          height: phone ? 48 : 64,
                          padding: const EdgeInsetsDirectional.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: i == _selected
                                  ? palette.text
                                  : palette.surfaceBorder,
                            ),
                            borderRadius: const BorderRadiusDirectional.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: phone
                              ? Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: i == _selected
                                          ? palette.text
                                          : palette.mutedText,
                                    ),
                                  ),
                                )
                              : ProjectPoster(path: project.videos[i].poster),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
