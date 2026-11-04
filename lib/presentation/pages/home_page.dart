import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/gradient_text.dart';
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

  Duration _scrollDuration(BuildContext context) => MediaQuery.disableAnimationsOf(context)
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
      _scroll.animateTo(0, duration: _scrollDuration(context), curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scroll,
            child: Column(
              children: [
                SizedBox(
                  height: math.max(MediaQuery.sizeOf(context).height, 500),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
                      child: GradientText(
                        l10n.appTitle,
                        style: textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                for (final s in HomeSection.values)
                  SectionPlaceholder(key: _keys[s], section: s),
              ],
            ),
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
