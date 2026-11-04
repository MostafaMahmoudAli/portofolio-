import 'package:flutter/material.dart';

import '../sections/about_section.dart';
import '../sections/featured_projects.dart';
import '../sections/hero_section.dart';
import '../sections/more_projects.dart';
import '../widgets/nav_bar.dart';
import '../widgets/section_placeholder.dart';
import 'home_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scroll = ScrollController();
  final _keys = {for (final s in HomeSection.values) s: GlobalKey()};

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Duration _scrollDuration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 600);

  void _scrollTo(HomeSection section) {
    Scrollable.ensureVisible(
      _keys[section]!.currentContext!,
      duration: _scrollDuration(context),
      curve: Curves.easeInOutCubic,
    );
  }

  void _scrollToTop() {
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
    return Scaffold(
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
    );
  }
}
