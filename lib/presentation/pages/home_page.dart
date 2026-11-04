import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../sections/about_section.dart';
import '../sections/featured_projects.dart';
import '../sections/hero_section.dart';
import '../sections/more_projects.dart';
import '../widgets/nav_bar.dart';
import '../widgets/page_title.dart';
import '../widgets/section_placeholder.dart';
import 'home_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.section});

  final HomeSection? section;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scroll = ScrollController();
  final _keys = {for (final s in HomeSection.values) s: GlobalKey()};
  HomeSection? _pendingSection;
  bool _sectionScrollScheduled = false;
  int _scrollRequest = 0;

  @override
  void initState() {
    super.initState();
    _pendingSection = widget.section;
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section != widget.section) {
      _pendingSection = widget.section;
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Duration _scrollDuration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 600);

  Future<void> _scrollTo(HomeSection section) async {
    final request = ++_scrollRequest;
    // On a tall phone hero, even the About sliver has not been laid out yet.
    // Seek through the viewport until the target has geometry to reveal.
    while (mounted && request == _scrollRequest) {
      final target = _keys[section]!.currentContext?.findRenderObject();
      if (target is RenderBox && target.hasSize) break;
      final position = _scroll.position;
      final next = (position.pixels + position.viewportDimension).clamp(
        0.0,
        position.maxScrollExtent,
      );
      if (next == position.pixels) return;
      _scroll.jumpTo(next);
      await WidgetsBinding.instance.endOfFrame;
    }
    if (!mounted || request != _scrollRequest) return;
    await Scrollable.ensureVisible(
      _keys[section]!.currentContext!,
      duration: _scrollDuration(context),
      curve: Curves.easeInOutCubic,
    );
    // A far-away sliver initially uses estimated heights for the lazy cards.
    // Correct the target after those estimates have been laid out and adjusted.
    for (var pass = 0; pass < 3; pass++) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted ||
          request != _scrollRequest ||
          !(ModalRoute.isCurrentOf(context) ?? true)) {
        return;
      }
      await Scrollable.ensureVisible(_keys[section]!.currentContext!);
    }
  }

  void _scheduleSectionScroll() {
    if (_sectionScrollScheduled || _pendingSection == null) return;
    _sectionScrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sectionScrollScheduled = false;
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (!(route?.isCurrent ?? true)) return;
      if (!_scroll.hasClients ||
          !_scroll.position.hasViewportDimension ||
          !_scroll.position.hasContentDimensions ||
          (route != null &&
              (route.animation?.status != AnimationStatus.completed ||
                  route.secondaryAnimation?.status !=
                      AnimationStatus.dismissed))) {
        _scheduleSectionScroll();
        WidgetsBinding.instance.ensureVisualUpdate();
        return;
      }
      final section = _pendingSection;
      _pendingSection = null;
      if (section != null) _scrollTo(section);
    });
  }

  void _scrollToTop() {
    _scrollRequest++;
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(0);
    } else {
      _scroll.animateTo(
        0,
        duration: _scrollDuration(context),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ModalRoute.isCurrentOf(context) ?? true;
    if (current) _scheduleSectionScroll();
    return PageTitle(
      title: AppLocalizations.of(context).appTitle,
      child: Scaffold(
        body: Stack(
          children: [
            // Slivers, so long lists (featured cards and their videos) build lazily.
            // Nav keys sit on widgets that always exist, so ensureVisible works.
            CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverToBoxAdapter(
                  child: HeroSection(
                    onViewProjects: () => _scrollTo(HomeSection.projects),
                  ),
                ),
                SliverToBoxAdapter(
                  child: AboutSection(key: _keys[HomeSection.about]),
                ),
                FeaturedProjectsSection(headerKey: _keys[HomeSection.projects]),
                const SliverToBoxAdapter(child: MoreProjectsSection()),
                for (final s in [
                  HomeSection.experience,
                  HomeSection.skills,
                  HomeSection.contact,
                ])
                  SliverToBoxAdapter(
                    child: SectionPlaceholder(key: _keys[s], section: s),
                  ),
              ],
            ),
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: NavBar(onSectionTap: _scrollTo, onLogoTap: _scrollToTop),
            ),
          ],
        ),
      ),
    );
  }
}
