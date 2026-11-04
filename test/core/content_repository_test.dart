import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content_repository.dart';
import 'package:portfolio/core/models/project.dart';
import 'package:portfolio/core/models/project_link.dart';
import 'package:portfolio/core/models/project_video.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final arabicLetter = RegExp(r'[\u0600-\u06FF]');
  final isArabicText = predicate(
    (text) => text is String && text.isNotEmpty && arabicLetter.hasMatch(text),
    'non-empty Arabic text',
  );

  group('real assets/data', () {
    late Content content;
    setUpAll(() async {
      content = await const ContentRepository().load();
    });

    test('profile parses with all four stats', () {
      expect(content.profile.name, 'Mostafa Mahmoud Ali');
      expect(content.profile.title.of(const Locale('en')), 'Flutter Developer');
      expect(content.profile.stats.map((stat) => stat.value), [3, 6, 310, 57]);
      expect(
        content.profile.experience.map((entry) => entry.company),
        contains('AppRock Software Development'),
      );
    });

    test('profile text is translated in Arabic', () {
      final profile = content.profile;
      expect(profile.location.of(const Locale('ar')), isArabicText);
      expect(profile.summary.of(const Locale('ar')), isArabicText);
      expect(profile.experience.first.role.of(const Locale('ar')), isArabicText);
      expect(profile.skillGroups.first.title.of(const Locale('ar')), isArabicText);
      final chips = content.profile.skillGroups.expand((group) => group.chips);
      expect(chips, contains('FFmpegKit'));
    });

    test('all twelve projects parse in both languages', () {
      expect(content.projects, hasLength(12));
      expect(
        content.projects.where((project) => project.featured),
        hasLength(5),
      );

      final remix =
          content.projects.singleWhere((project) => project.slug == 'remix');
      expect(remix.accent, '#FF5C8A');
      expect(remix.subtitle.of(const Locale('en')), contains('duet'));
      expect(remix.subtitle.of(const Locale('ar')), isArabicText);
      expect(remix.videos.single.src, 'media/remix/demo.mp4');
      expect(remix.status?.of(const Locale('ar')), isArabicText);

      // Every entry carries Arabic subtitles, summaries, bullets or status.
      for (final project in content.projects) {
        expect(project.subtitle.of(const Locale('ar')), isArabicText,
            reason: 'subtitle of ${project.slug}');
        expect(project.summary.of(const Locale('ar')), isArabicText,
            reason: 'summary of ${project.slug}');
        expect(project.title.of(const Locale('ar')), isNotEmpty,
            reason: 'title of ${project.slug}');
      }
    });

    test('more projects link to their GitHub repos', () {
      final bookly = content.projects
          .singleWhere((project) => project.slug == 'Bookly_App');
      expect(bookly.featured, isFalse);
      final link = bookly.links.single;
      expect(link.type, ProjectLinkType.github);
      expect(
        link.url,
        'https://github.com/MostafaMahmoudAli/Bookly_App',
      );
    });

    test('featured counts line up with the resume stats', () {
      final consulates = content.projects
          .singleWhere((project) => project.slug == 'egypt-consulate-apps');
      expect(consulates.summary.of(const Locale('en')), contains('310K+'));
      expect(consulates.tech, contains('Flavors'));
    });
  });

  group('a broken entry fails loudly', () {
    test('a missing title names file, entry and field', () {
      const entry = <String, dynamic>{'slug': 'broken', 'accent': '#000000'};
      expect(
        () => Project.fromJson(entry, where: 'projects.json: entry "broken"'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('projects.json'),
              contains('entry "broken"'),
              contains('"title"'),
            ),
          ),
        ),
      );
    });

    test('a nested video error names the video index', () {
      const entry = <String, dynamic>{'poster': 'media/remix/poster.jpg'};
      expect(
        () => ProjectVideo.fromJson(
          entry,
          where: 'projects.json: entry "remix": videos[1]',
        ),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('entry "remix": videos[1]'),
              contains('"src"'),
            ),
          ),
        ),
      );
    });

    test('an unknown link type names the type', () {
      final entry = <String, dynamic>{
        'type': 'nonsense',
        'url': 'https://example.com',
      };
      expect(
        () => ProjectLink.fromJson(
          entry,
          where: 'projects.json: entry "x": links[0]',
        ),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('links[0]'),
              contains('"nonsense"'),
            ),
          ),
        ),
      );
    });
  });
}
