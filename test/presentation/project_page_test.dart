import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_scope.dart';
import 'package:portfolio/core/data/content.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/localization/locale_controller.dart';
import 'package:portfolio/core/models/localized_text.dart';
import 'package:portfolio/core/models/project.dart';
import 'package:portfolio/core/models/project_video.dart';
import 'package:portfolio/core/router/app_router.dart';
import 'package:portfolio/core/theme/app_theme.dart';
import 'package:portfolio/core/theme/theme_controller.dart';
import 'package:portfolio/core/theme/app_colors.dart';
import 'package:portfolio/l10n/app_localizations.dart';
import 'package:portfolio/presentation/pages/home_page.dart';
import 'package:portfolio/presentation/pages/home_section.dart';
import 'package:portfolio/presentation/pages/not_found_page.dart';
import 'package:portfolio/presentation/pages/project_page.dart';
import 'package:portfolio/presentation/widgets/glass_card.dart';
import 'package:portfolio/presentation/widgets/nav_bar.dart';
import 'package:portfolio/presentation/widgets/nav_menu_sheet.dart';
import 'package:portfolio/presentation/widgets/page_title.dart';
import 'package:portfolio/presentation/widgets/project_media_frame.dart';
import 'package:portfolio/presentation/widgets/project_placeholder.dart';
import 'package:portfolio/presentation/widgets/project_poster.dart';
import 'package:portfolio/presentation/widgets/project_video_gallery.dart';
import 'package:portfolio/presentation/widgets/project_video_player.dart';
import 'package:portfolio/presentation/sections/experience_section.dart';
import 'package:portfolio/presentation/sections/skills_section.dart';
import 'package:portfolio/presentation/sections/contact_section.dart';
import 'package:portfolio/presentation/sections/about_section.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'project_video_player_test.dart' show FakeVideoPlatform;

late Content content;
late FakeVideoPlatform platform;

Future<void> frames(WidgetTester tester, [int count = 8]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<GoRouter> pumpPage(
  WidgetTester tester, {
  String location = '/projects/remix',
  double width = 1440,
  String language = 'en',
  bool reducedMotion = false,
  Brightness brightness = Brightness.light,
  Content? data,
  GoRouter? routing,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reducedMotion);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final theme = ThemeController(prefs);
  final locale = LocaleController(prefs, platformLocale: Locale(language));
  final router = routing ?? createRouter(initialLocation: location);
  addTearDown(() {
    router.dispose();
    theme.dispose();
    locale.dispose();
  });
  await tester.pumpWidget(
    AppScope(
      content: data ?? content,
      theme: theme,
      locale: locale,
      child: MaterialApp.router(
        routerConfig: router,
        locale: Locale(language),
        theme: AppTheme.build(brightness, Locale(language)),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await frames(tester);
  return router;
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await frames(tester, 2);
  VideoControllerManager.instance.disposeAll();
}

ScrollPosition scrollOf(WidgetTester tester, Type page) => tester
    .state<ScrollableState>(
      find
          .descendant(of: find.byType(page), matching: find.byType(Scrollable))
          .first,
    )
    .position;

Finder heroFor(String slug) => find.byWidgetPredicate(
  (widget) => widget is Hero && widget.tag == 'project-$slug',
);

Future<void> bottom(WidgetTester tester) async {
  final scroll = scrollOf(tester, ProjectPage);
  for (var i = 0; i < 8; i++) {
    scroll.jumpTo(scroll.maxScrollExtent);
    await frames(tester, 2);
  }
}

Project testProject(int videos, {String? cover}) => Project(
  slug: 'gallery-test',
  title: const LocalizedText(en: 'Gallery test', ar: 'اختبار المعرض'),
  subtitle: const LocalizedText(en: 'Subtitle', ar: 'عنوان فرعي'),
  featured: true,
  order: 0,
  accent: '#7C5CFF',
  summary: const LocalizedText(en: 'Summary', ar: 'ملخص'),
  bullets: const [],
  tech: const [],
  status: null,
  cover: cover,
  videos: [
    for (var i = 0; i < videos; i++)
      ProjectVideo(
        src: 'media/test/demo$i.mp4',
        poster: 'media/test/poster$i.jpg',
        caption: LocalizedText(en: 'Caption $i', ar: 'شرح $i'),
      ),
  ],
  links: const [],
);

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  content = await const ContentRepository().load();
  setUpAll(
    () => VisibilityDetectorController.instance.updateInterval = Duration.zero,
  );
  setUp(() {
    platform = FakeVideoPlatform();
    VideoPlayerPlatform.instance = platform;
  });

  testWidgets('pasted project link has Home underneath; Back returns home', (
    tester,
  ) async {
    final router = await pumpPage(tester);
    expect(find.byType(ProjectPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(HomePage, skipOffstage: false), findsOneWidget);
    expect(router.canPop(), isTrue);
    final title = tester.widget<PageTitle>(
      find
          .ancestor(
            of: find.byType(ProjectVideoGallery),
            matching: find.byType(PageTitle),
          )
          .first,
    );
    expect(
      title.title,
      'Remix — ${AppLocalizations.of(tester.element(find.byType(ProjectPage))).appTitle}',
    );
    await tester.tap(find.byType(BackButton));
    await frames(tester);
    expect(find.byType(HomePage), findsOneWidget);
    await unmount(tester);
  });

  testWidgets(
    'go keeps home state and scroll; opaque page hides Home after fade',
    (tester) async {
      final router = await pumpPage(tester, location: '/');
      final home = tester.state(find.byType(HomePage));
      final scroll = scrollOf(tester, HomePage);
      scroll.jumpTo(600);
      await frames(tester);
      router.go('/projects/remix');
      await frames(tester);
      expect(find.byType(HomePage), findsNothing);
      expect(find.byType(HomePage, skipOffstage: false), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await frames(tester);
      expect(tester.state(find.byType(HomePage)), same(home));
      expect(scrollOf(tester, HomePage).pixels, 600);
      await unmount(tester);
    },
  );

  testWidgets('unknown slug and unknown path show NotFoundPage', (
    tester,
  ) async {
    final router = await pumpPage(tester, location: '/projects/not-a-project');
    expect(find.byType(NotFoundPage), findsOneWidget);
    expect(router.canPop(), isTrue);
    router.go('/missing/path');
    await frames(tester, 16);
    expect(find.byType(NotFoundPage), findsOneWidget);
    await unmount(tester);
  });

  for (final language in ['en', 'ar']) {
    testWidgets('browser title restored after Back, nav and 404 in $language', (
      tester,
    ) async {
      final labels = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'SystemChrome.setApplicationSwitcherDescription') {
            labels.add((call.arguments as Map)['label'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final router = await pumpPage(tester, location: '/', language: language);
      final l10n = AppLocalizations.of(tester.element(find.byType(HomePage)));
      expect(labels.last, l10n.appTitle);
      router.go('/projects/remix');
      await frames(tester);
      expect(
        labels.last,
        '${content.projects.firstWhere((p) => p.slug == 'remix').title.of(Locale(language))} — ${l10n.appTitle}',
      );
      await tester.tap(find.byType(BackButton));
      await frames(tester);
      expect(labels.last, l10n.appTitle);
      router.go('/projects/remix');
      await frames(tester);
      await tester.tap(
        find.descendant(of: find.byType(NavBar), matching: find.text('MM')),
      );
      await frames(tester);
      expect(labels.last, l10n.appTitle);
      for (final path in ['/projects/unknown', '/unknown']) {
        router.go('/projects/remix');
        await frames(tester);
        router.go(path);
        await frames(tester, 16);
        expect(labels.last, '${l10n.notFoundTitle} — ${l10n.appTitle}');
      }
      await tester.tap(find.text(l10n.backHome));
      await frames(tester, 16);
      expect(labels.last, l10n.appTitle);
      await unmount(tester);
    });

    for (final width in [375.0, 1440.0]) {
      testWidgets(
        'project nav reaches each home section at $width in $language',
        (tester) async {
          final router = await pumpPage(
            tester,
            language: language,
            width: width,
          );
          final l10n = AppLocalizations.of(
            tester.element(find.byType(ProjectPage)),
          );
          for (final section in HomeSection.values) {
            router.go('/projects/remix');
            await frames(tester);
            if (width < 600) {
              await tester.tap(find.byIcon(Icons.menu_rounded));
              await frames(tester);
            }
            await tester.tap(
              find.descendant(
                of: find.byType(width < 600 ? NavMenuSheet : NavBar),
                matching: find.text(section.label(l10n)),
              ),
            );
            await frames(tester, 24);
            expect(find.byType(HomePage), findsOneWidget);
            expect(router.routeInformationProvider.value.uri.toString(), '/');
            expect(scrollOf(tester, HomePage).pixels, greaterThan(0));
            final target = switch (section) {
              HomeSection.about => find.byType(AboutSection),
              HomeSection.projects => find.text(l10n.featuredProjects),
              HomeSection.experience => find.byType(ExperienceSection),
              HomeSection.skills => find.byType(SkillsSection),
              HomeSection.contact => find.byType(ContactSection),
            };
            final rect = tester.getRect(target);
            expect(rect.bottom, greaterThan(72));
            expect(rect.top, lessThan(900));
            expect(tester.takeException(), isNull);
          }
          await unmount(tester);
        },
      );
    }
  }

  testWidgets('pasted section link scrolls after first layout', (tester) async {
    await pumpPage(tester, location: '/?section=skills', reducedMotion: true);
    final target = find.byType(SkillsSection);
    expect(tester.getRect(target).top, inInclusiveRange(-0.001, 900));
    expect(scrollOf(tester, HomePage).pixels, greaterThan(0));
    await unmount(tester);
  });

  for (final cover in [null, 'media/custom/alternate.jpg']) {
    testWidgets('cover uses JSON field $cover with null placeholder', (
      tester,
    ) async {
      final project = testProject(0, cover: cover);
      await pumpPage(
        tester,
        location: '/projects/${project.slug}',
        data: Content(profile: content.profile, projects: [project]),
      );
      final poster = tester.widget<ProjectPoster>(find.byType(ProjectPoster));
      expect(poster.path, cover);
      if (cover == null) {
        expect(find.byType(ProjectPlaceholder), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(ProjectPoster),
            matching: find.byType(Image),
          ),
          findsNothing,
        );
      } else {
        final image = tester.widget<Image>(
          find.descendant(
            of: find.byType(ProjectPoster),
            matching: find.byType(Image),
          ),
        );
        expect(
          (image.image as NetworkImage).url,
          Uri.base.resolve(cover).toString(),
        );
      }
      await unmount(tester);
    });
  }

  testWidgets(
    'poster and player share viewport bounds and neutral placeholder',
    (tester) async {
      platform.failCreate = true;
      final project = testProject(1);
      await pumpPage(
        tester,
        location: '/projects/${project.slug}',
        data: Content(profile: content.profile, projects: [project]),
      );
      await tester.ensureVisible(find.byType(ProjectVideoGallery));
      await frames(tester);
      final media = find.byType(ProjectMediaFrame);
      final poster = find.descendant(
        of: media,
        matching: find.byType(ProjectPoster),
      );
      final player = find.descendant(
        of: media,
        matching: find.byType(ProjectVideoPlayer),
      );
      expect(tester.getRect(poster), tester.getRect(player));
      final placeholders = tester.widgetList<ProjectPlaceholder>(
        find.descendant(of: media, matching: find.byType(ProjectPlaceholder)),
      );
      expect(placeholders.length, 2);
      for (final element
          in find
              .descendant(of: media, matching: find.byType(ProjectPlaceholder))
              .evaluate()) {
        final decoration =
            tester
                    .widget<Container>(
                      find
                          .descendant(
                            of: find.byWidget(element.widget),
                            matching: find.byType(Container),
                          )
                          .first,
                    )
                    .decoration!
                as BoxDecoration;
        expect(decoration.color, AppPalette.light.surface);
        expect(
          (decoration.border! as Border).top.color,
          AppPalette.light.accent,
        );
      }
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets('Back falls back to home when no page is underneath', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/standalone',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/standalone',
          builder: (context, state) => const ProjectPage(slug: 'remix'),
        ),
      ],
    );
    await pumpPage(tester, routing: router);
    expect(router.canPop(), isFalse);
    await tester.tap(find.byType(BackButton));
    await frames(tester, 16);
    expect(find.byType(HomePage), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('gallery keeps selection when crossing the phone breakpoint', (
    tester,
  ) async {
    final project = testProject(3);
    await pumpPage(
      tester,
      location: '/projects/${project.slug}',
      data: Content(profile: content.profile, projects: [project]),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('gallery-thumbnails')),
    );
    await frames(tester);
    await tester.tap(find.byTooltip('Play video 3'));
    await frames(tester);
    tester.view.physicalSize = const Size(375, 900);
    await frames(tester);
    expect(find.text('Caption 2'), findsOneWidget);
    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller!.page, 2);
    await unmount(tester);
  });

  testWidgets('previous and next follow order and wrap at both ends', (
    tester,
  ) async {
    final sorted = [...content.projects]
      ..sort((a, b) => a.order.compareTo(b.order));
    await pumpPage(tester, location: '/projects/${sorted.first.slug}');
    await bottom(tester);
    await tester.tap(find.byKey(const ValueKey('previous-project')));
    await frames(tester);
    expect(
      tester.widget<ProjectPage>(find.byType(ProjectPage)).slug,
      sorted.last.slug,
    );
    await bottom(tester);
    await tester.tap(find.byKey(const ValueKey('next-project')));
    await frames(tester);
    expect(
      tester.widget<ProjectPage>(find.byType(ProjectPage)).slug,
      sorted.first.slug,
    );
    for (final project in sorted.skip(1)) {
      await bottom(tester);
      await tester.tap(find.byKey(const ValueKey('next-project')));
      await frames(tester);
      expect(
        tester.widget<ProjectPage>(find.byType(ProjectPage)).slug,
        project.slug,
      );
    }
    await bottom(tester);
    await tester.tap(find.byKey(const ValueKey('previous-project')));
    await frames(tester);
    expect(
      tester.widget<ProjectPage>(find.byType(ProjectPage)).slug,
      sorted[sorted.length - 2].slug,
    );
    await unmount(tester);
  });

  testWidgets(
    'card and gallery share a static Hero; flight creates no controller',
    (tester) async {
      final router = await pumpPage(tester, location: '/');
      final scroll = scrollOf(tester, HomePage);
      for (var i = 0; i < 25 && heroFor('remix').evaluate().isEmpty; i++) {
        scroll.jumpTo((scroll.pixels + 400).clamp(0, scroll.maxScrollExtent));
        await frames(tester, 2);
      }
      expect(heroFor('remix'), findsOneWidget);
      await tester.ensureVisible(heroFor('remix'));
      await frames(tester, 14);
      // video_player completes disposal on a real-time tick.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      expect(
        find.ancestor(of: heroFor('remix'), matching: find.byType(GlassCard)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: heroFor('remix'),
          matching: find.byType(ProjectVideoPlayer),
        ),
        findsNothing,
      );
      final created = platform.created;
      router.go('/projects/remix');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(platform.created, created);
      // A static poster is in the overlay while both routes are transitioning.
      expect(
        find.byElementPredicate(
          (element) =>
              element.widget is ProjectPoster &&
              element.findAncestorWidgetOfExactType<HomePage>() == null &&
              element.findAncestorWidgetOfExactType<ProjectPage>() == null,
        ),
        findsOneWidget,
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      expect(platform.live.length, lessThanOrEqualTo(2));
      await frames(tester);
      expect(heroFor('remix'), findsOneWidget);
      expect(
        find.ancestor(
          of: heroFor('remix'),
          matching: find.byType(ProjectVideoGallery),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: heroFor('remix'),
          matching: find.byType(ProjectVideoPlayer),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets('reduced motion has zero-duration routes and no Hero', (
    tester,
  ) async {
    final router = await pumpPage(tester, location: '/', reducedMotion: true);
    router.go('/projects/remix');
    await tester.pump();
    await tester.pump();
    final route = ModalRoute.of(tester.element(find.byType(ProjectPage)))!;
    expect(route.transitionDuration, Duration.zero);
    expect(route.reverseTransitionDuration, Duration.zero);
    expect(find.byType(HomePage), findsNothing);
    expect(heroFor('remix'), findsNothing);
    await unmount(tester);
  });

  for (final width in [375.0, 768.0, 1440.0]) {
    for (final count in [1, 3]) {
      testWidgets('gallery with $count videos at $width px', (tester) async {
        final project = testProject(count);
        await pumpPage(
          tester,
          location: '/projects/${project.slug}',
          width: width,
          data: Content(profile: content.profile, projects: [project]),
        );
        await tester.ensureVisible(find.byType(ProjectVideoGallery));
        await frames(tester);
        final phone = width < 600;
        final controls = find.byKey(
          ValueKey(phone ? 'gallery-dots' : 'gallery-thumbnails'),
        );
        expect(controls, count == 1 ? findsNothing : findsOneWidget);
        expect(
          find.byKey(ValueKey(phone ? 'gallery-thumbnails' : 'gallery-dots')),
          findsNothing,
        );
        expect(find.text('Caption 0'), findsOneWidget);
        if (count == 3) {
          await tester.ensureVisible(controls);
          await frames(tester);
          if (phone) {
            await tester.drag(find.byType(PageView), const Offset(-260, 0));
          } else {
            await tester.tap(find.byTooltip('Play video 2'));
          }
          await frames(tester);
          expect(find.text('Caption 1'), findsOneWidget);
          expect(platform.live.length, lessThanOrEqualTo(2));
        }
        expect(tester.takeException(), isNull);
        await unmount(tester);
      });
    }
    for (final language in ['en', 'ar']) {
      for (final slug in [
        'remix',
        'egypt-consulate-apps',
        'responsive-dashboard',
      ]) {
        testWidgets('$slug fits $width px in $language throughout scroll', (
          tester,
        ) async {
          await pumpPage(
            tester,
            location: '/projects/$slug',
            width: width,
            language: language,
          );
          expect(find.byType(ProjectPage), findsOneWidget);
          expect(
            Directionality.of(tester.element(find.byType(ProjectPage))),
            language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          );
          final scroll = scrollOf(tester, ProjectPage);
          for (var y = 0.0; y < scroll.maxScrollExtent + 500; y += 400) {
            scroll.jumpTo(y.clamp(0, scroll.maxScrollExtent));
            await frames(tester, 3);
            expect(tester.takeException(), isNull, reason: 'offset $y');
          }
          await unmount(tester);
        });
      }
    }
  }
}
