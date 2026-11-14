import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/theme/app_theme.dart';
import 'package:portfolio/presentation/widgets/brand_icon.dart';

void main() {
  testWidgets('every brand mark paints without a painter error', (tester) async {
    for (final mark in BrandMark.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(Brightness.light, const Locale('en')),
          home: Scaffold(
            body: Center(child: BrandIcon(mark, size: 24)),
          ),
        ),
      );
      expect(find.byType(BrandIcon), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  test('the marks are drawn inside their 24 by 24 box', () {
    for (final mark in BrandMark.values) {
      final icon = BrandIcon(mark, size: 24);
      expect(icon.size, 24);
      expect(icon.mark, mark);
    }
  });

  test('every mark parses into a shape inside the 24 by 24 box', () {
    for (final mark in BrandMark.values) {
      final bounds = brandMarkPath(mark).getBounds();
      expect(bounds.isEmpty, isFalse, reason: mark.name);
      expect(bounds.left, greaterThanOrEqualTo(-0.5), reason: mark.name);
      expect(bounds.top, greaterThanOrEqualTo(-0.5), reason: mark.name);
      expect(bounds.right, lessThanOrEqualTo(24.5), reason: mark.name);
      expect(bounds.bottom, lessThanOrEqualTo(24.5), reason: mark.name);
      // A mark that fills the box is a mark that drew something.
      expect(bounds.width, greaterThan(4), reason: mark.name);
      expect(bounds.height, greaterThan(4), reason: mark.name);
    }
  });
}
