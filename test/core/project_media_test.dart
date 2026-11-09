import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:portfolio/core/models/project.dart';
import 'package:portfolio/core/models/project_videos.dart';

Map<String, dynamic> entry() => {
  'slug': 'test',
  'title': {'en': 'Test', 'ar': 'اختبار'},
  'subtitle': {'en': 'App', 'ar': 'تطبيق'},
  'featured': false,
  'order': 1,
  'accent': '#34D399',
  'summary': {'en': 'Summary', 'ar': 'ملخص'},
  'bullets': [],
  'tech': [],
};
Map<String, dynamic> video(String platform) => {
  'src': 'media/test/$platform.mp4',
  'poster': 'media/test/$platform.jpg',
  'caption': {'en': platform, 'ar': 'عرض'},
};
Project parse(Map<String, dynamic> data) =>
    Project.fromJson(data, where: 'projects.json: entry "test"');

void main() {
  for (final platforms in <List<String>>[
    [],
    ['ios'],
    ['android'],
    ['android', 'ios'],
  ]) {
    test('parse platforms $platforms, ordered iOS first', () {
      final project = parse(
        entry()
          ..['videos'] = {
            for (final platform in platforms) platform: video(platform),
          },
      );
      expect(project.videos.available.map((e) => e.$1), [
        if (platforms.contains('ios')) VideoPlatform.ios,
        if (platforms.contains('android')) VideoPlatform.android,
      ]);
      expect(
        project.videos.primary?.$1,
        platforms.contains('ios')
            ? VideoPlatform.ios
            : platforms.isEmpty
            ? null
            : VideoPlatform.android,
      );
    });
  }
  test('missing videos and screens are empty', () {
    final project = parse(entry());
    expect(project.videos.primary, isNull);
    expect(project.screens, isEmpty);
  });
  test('screens have optional bilingual captions', () {
    final project = parse(
      entry()
        ..['screens'] = [
          {
            'src': 'media/test/screens/01.jpg',
            'caption': {'en': 'Home', 'ar': 'الرئيسية'},
          },
          {'src': 'media/test/screens/02.webp'},
        ],
    );
    expect(project.screens.first.caption!.of(const Locale('ar')), 'الرئيسية');
    expect(project.screens.last.caption, isNull);
  });
  for (final (field, value) in <(String, Object)>[
    ('videos', {'web': video('web')}),
    ('videos', []),
    ('videos', {'ios': 'bad'}),
    (
      'videos',
      {
        'android': {'poster': 'p.jpg'},
      },
    ),
    ('screens', 'bad'),
    ('screens', [42]),
    (
      'screens',
      [
        {
          'caption': {'en': 'x'},
        },
      ],
    ),
  ]) {
    test('malformed $field $value names file entry and field', () {
      expect(
        () => parse(entry()..[field] = value),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            allOf([
              contains('projects.json'),
              contains('entry "test"'),
              contains(field),
              if (value is Map && value.containsKey('web'))
                contains('videos.web'),
            ]),
          ),
        ),
      );
    });
  }
}
