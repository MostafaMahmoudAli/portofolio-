import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/data/content.dart';
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
      expect(
        content.profile.name.of(const Locale('en')),
        'Mostafa Mahmoud Ali',
      );
      expect(content.profile.title.of(const Locale('en')), 'Flutter Developer');
      expect(content.profile.stats.map((stat) => stat.value), [3, 6, 310, 57]);
      expect(
        content.profile.experience.map((entry) => entry.company),
        contains('AppRock Software Development'),
      );
    });

    test('education year and experience emphasis exist in both languages', () {
      for (final locale in [const Locale('en'), const Locale('ar')]) {
        expect(content.profile.education.of(locale), contains('2021'));
        for (final entry in content.profile.experience) {
          for (final bullet in entry.bullets) {
            expect(bullet.of(locale), contains(RegExp(r'\*\*.+?\*\*')));
          }
        }
      }
      expect(
        content.profile.experience
            .singleWhere((entry) => entry.company.startsWith('MDQ'))
            .bullets,
        hasLength(1),
      );
    });

    test('consulate work credits development at AppRock, not publication', () {
      final project = content.projects.singleWhere(
        (project) => project.slug == 'egypt-consulate-apps',
      );
      for (final locale in [const Locale('en'), const Locale('ar')]) {
        expect(project.summary.of(locale), contains('AppRock'));
        expect(project.bullets.first.of(locale), contains('AppRock'));
        final description = [
          project.summary.of(locale),
          ...project.bullets.map((bullet) => bullet.of(locale)),
        ].join(' ');
        expect(description, isNot(contains(RegExp('publish|نشرت|منشورة'))));
      }
    });

    test('the name is localized in both languages', () {
      final name = content.profile.name;
      expect(name.of(const Locale('en')), 'Mostafa Mahmoud Ali');
      expect(name.of(const Locale('ar')), isArabicText);
      expect(name.of(const Locale('ar')), 'مصطفى محمود علي');
    });

    test('the page title joins the localized name and role', () {
      final profile = content.profile;
      expect(
        profile.pageTitleOf(const Locale('en')),
        'Mostafa Mahmoud Ali — Flutter Developer',
      );
      expect(
        profile.pageTitleOf(const Locale('ar')),
        contains('مصطفى محمود علي'),
      );
    });

    test('profile text is translated in Arabic', () {
      final profile = content.profile;
      expect(profile.location.of(const Locale('ar')), isArabicText);
      expect(profile.summary.of(const Locale('ar')), isArabicText);
      expect(
        profile.experience.first.role.of(const Locale('ar')),
        isArabicText,
      );
      expect(
        profile.skillGroups.first.title.of(const Locale('ar')),
        isArabicText,
      );
      final chips = content.profile.skillGroups.expand((group) => group.chips);
      expect(chips, contains('FFmpegKit'));
    });

    test('profile has 9 skill groups after the Testing & Release merge', () {
      final titles = content.profile.skillGroups
          .map((group) => group.title.en)
          .toList();
      expect(titles, hasLength(9));
      expect(titles, contains('Testing & Release'));
      expect(titles, isNot(contains('Testing & Quality')));
    });

    test('all thirteen projects parse in both languages', () {
      expect(content.projects, hasLength(13));
      expect(
        content.projects.where((project) => project.featured),
        hasLength(6),
      );

      final remix = content.projects.singleWhere(
        (project) => project.slug == 'remix',
      );
      expect(remix.accent, '#FF5C8A');
      expect(remix.subtitle.of(const Locale('en')), contains('duet'));
      expect(remix.subtitle.of(const Locale('ar')), isArabicText);
      expect(remix.videos.android!.src, 'media/remix/android.mp4');
      expect(remix.status?.of(const Locale('ar')), isArabicText);

      // Every entry carries Arabic subtitles, summaries, bullets or status.
      for (final project in content.projects) {
        expect(
          project.subtitle.of(const Locale('ar')),
          isArabicText,
          reason: 'subtitle of ${project.slug}',
        );
        expect(
          project.summary.of(const Locale('ar')),
          isArabicText,
          reason: 'summary of ${project.slug}',
        );
        expect(
          project.title.of(const Locale('ar')),
          isNotEmpty,
          reason: 'title of ${project.slug}',
        );
      }
    });

    test('more projects link to their GitHub repos', () {
      final bookly = content.projects.singleWhere(
        (project) => project.slug == 'bookly-app',
      );
      expect(bookly.featured, isFalse);
      final link = bookly.links.single;
      expect(link.type, ProjectLinkType.github);
      expect(link.url, 'https://github.com/MostafaMahmoudAli/Bookly_App');
    });

    test('the consulate project carries its 8 labelled store links', () {
      final consulates = content.projects.singleWhere(
        (project) => project.slug == 'egypt-consulate-apps',
      );
      expect(consulates.links, hasLength(8));
      expect(
        consulates.links.where(
          (link) => link.type == ProjectLinkType.playStore,
        ),
        hasLength(4),
      );
      expect(
        consulates.links.map((link) => link.label!.en),
        containsAll(['Kuwait', 'Riyadh', 'Jeddah', 'Milan']),
      );
    });

    test('store link labels are translated', () {
      final consulates = content.projects.singleWhere(
        (project) => project.slug == 'egypt-consulate-apps',
      );
      final arabic = <String>{
        for (final link in consulates.links) link.label!.of(const Locale('ar')),
      };
      expect(arabic, {'الكويت', 'الرياض', 'جدة', 'ميلانو'});
      for (final link in consulates.links) {
        expect(link.label!.of(const Locale('ar')), isArabicText);
      }
      // A GitHub link carries no label at all.
      final bookly = content.projects.singleWhere(
        (project) => project.slug == 'bookly-app',
      );
      expect(bookly.links.single.label, isNull);
    });

    test('every featured project carries an impact line in both languages', () {
      final featured = content.projects.where((project) => project.featured);
      expect(featured, hasLength(6));
      for (final project in featured) {
        expect(project.impact, isNotNull, reason: project.slug);
        expect(
          project.impact!.of(const Locale('en')),
          isNotEmpty,
          reason: project.slug,
        );
        expect(
          project.impact!.of(const Locale('ar')),
          isArabicText,
          reason: project.slug,
        );
      }
    });

    test('the resume skills are on the site', () {
      final chips = content.profile.skillGroups
          .expand((group) => group.chips)
          .toSet();
      expect(chips, contains('easy_localization'));
      expect(chips, contains('Firestore'));
      expect(chips, contains('Stripe & PayPal'));
    });

    test('Egypt Abroad is first, bilingual and linked to both stores', () {
      final projects = [...content.projects]
        ..sort((a, b) => a.order.compareTo(b.order));
      final project = projects.first;
      expect(project.slug, 'egypt-abroad');
      expect(project.order, 1);
      expect(project.featured, isTrue);
      expect(project.title.en, 'Egypt Abroad');
      expect(project.title.of(const Locale('ar')), 'مصري بالخارج');
      expect(project.bullets, hasLength(4));
      expect(project.summary.en, contains('with the team at AppRock'));
      expect(project.summary.of(const Locale('ar')), contains('فريق AppRock'));
      expect(project.videos.available, hasLength(2));
      expect(project.videos.ios!.src, 'media/egypt-abroad/ios.mp4');
      expect(project.videos.android!.poster, 'media/egypt-abroad/android.jpg');
      expect(project.cover, 'media/egypt-abroad/cover.jpg');
      expect(
        project.links.map((link) => link.url),
        containsAll([
          'https://play.google.com/store/apps/details?id=com.approc.mfa.egyptconsulate',
          'https://apps.apple.com/app/id6806766895',
        ]),
      );
      expect(
        projects.skip(1).where((p) => p.featured).map((p) => p.accent),
        isNot(contains(project.accent)),
      );
      expect(projects.map((p) => p.order).toSet(), hasLength(13));
    });

    test('a featured project links to both stores', () {
      final alkharj = content.projects.singleWhere(
        (project) => project.slug == 'alkharj-business-guide',
      );
      expect(
        alkharj.links.map((link) => link.type),
        containsAll([ProjectLinkType.playStore, ProjectLinkType.appStore]),
      );
    });

    test('slugs are kebab-case across all projects', () {
      final kebab = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
      for (final project in content.projects) {
        expect(kebab.hasMatch(project.slug), isTrue, reason: project.slug);
      }
    });

    test('featured counts line up with the resume stats', () {
      final consulates = content.projects.singleWhere(
        (project) => project.slug == 'egypt-consulate-apps',
      );
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
            allOf(contains('entry "remix": videos[1]'), contains('"src"')),
          ),
        ),
      );
    });

    test('a non-object videos field names the field, not a TypeError', () {
      final entry = <String, dynamic>{
        'slug': 'x',
        'title': {'en': 'X'},
        'subtitle': {'en': 'S'},
        'featured': false,
        'order': 1,
        'accent': '#000000',
        'summary': {'en': 'Sum'},
        'bullets': [],
        'tech': ['Flutter'],
        'videos': 'nope',
        'links': <String, dynamic>{'type': 'github', 'url': 'u'},
      };
      expect(
        () => Project.fromJson(entry, where: 'projects.json: entry "x"'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            allOf(contains('entry "x"'), contains('"videos"')),
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
            allOf(contains('links[0]'), contains('"nonsense"')),
          ),
        ),
      );
    });
  });
}
