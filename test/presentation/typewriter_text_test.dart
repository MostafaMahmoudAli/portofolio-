import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/presentation/widgets/typewriter_text.dart';

const _arabicRoles = [
  'مطوّر تطبيقات الجوال',
  'متخصص في التطبيقات متعددة المنصات',
  'مهتم بالكود النظيف',
];

Future<void> pumpTypewriter(WidgetTester tester) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 327,
              child: TypewriterText(
                roles: _arabicRoles,
                style: const TextStyle(fontSize: 24, height: 1.4),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets(
    'height is reserved for the longest role while typing in Arabic',
    (tester) async {
      await pumpTypewriter(tester);

      // One full 12 s cycle in 100 ms steps, covering typing, holding and
      // erasing for every role.
      final heights = <double>{};
      for (var step = 0; step < 120; step++) {
        await tester.pump(const Duration(milliseconds: 100));
        heights.add(tester.getSize(find.byType(TypewriterText)).height);
      }

      expect(
        heights,
        hasLength(1),
        reason: 'the reserved height never changes',
      );
    },
  );
}
