import 'package:go_router/go_router.dart';

import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/not_found_page.dart';
import '../../presentation/pages/project_page.dart';

/// Hash URLs (`/#/projects/remix`) are go_router's default on web.
GoRouter createRouter() => GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/projects/:slug',
          builder: (context, state) => ProjectPage(slug: state.pathParameters['slug']!),
        ),
      ],
      errorBuilder: (context, state) => const NotFoundPage(),
    );
