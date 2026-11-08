import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/home_section.dart';
import '../../presentation/pages/not_found_page.dart';
import '../../presentation/pages/project_page.dart';
import '../app_scope.dart';

/// Hash URLs (`/#/projects/remix`) are go_router's default on web.
GoRouter createRouter({String? initialLocation}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _page(
        context,
        state,
        HomePage(
          section: HomeSection.values
              .asNameMap()[state.uri.queryParameters['section']],
        ),
      ),
      routes: [
        GoRoute(
          path: 'projects/:slug',
          pageBuilder: (context, state) {
            final slug = state.pathParameters['slug']!;
            final known = AppScope.of(
              context,
            ).content.projects.any((project) => project.slug == slug);
            return _page(
              context,
              state,
              known
                  ? ProjectPage(key: ValueKey(slug), slug: slug)
                  : const NotFoundPage(),
            );
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);

CustomTransitionPage<void> _page(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  final duration = MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 300);
  return CustomTransitionPage<void>(
    key: state.pageKey,
    opaque: true,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
          opacity: animation,
          child: FadeTransition(
            opacity: ReverseAnimation(secondaryAnimation),
            child: child,
          ),
        ),
  );
}
