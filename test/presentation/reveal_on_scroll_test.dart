import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/presentation/widgets/reveal_on_scroll.dart';
import 'package:visibility_detector/visibility_detector.dart';

Future<void> pumpReveal(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 900),
              RevealOnScroll(child: Text('revealed child')),
              SizedBox(height: 900),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

double opacityOf(WidgetTester tester) => tester
    .widget<FadeTransition>(
      find.descendant(
        of: find.byType(RevealOnScroll),
        matching: find.byType(FadeTransition),
      ),
    )
    .opacity
    .value;

Future<void> scrollBy(WidgetTester tester, double dy) async {
  await tester.drag(find.byType(SingleChildScrollView), Offset(0, dy));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });
  tearDownAll(() {
    VisibilityDetectorController.instance.updateInterval = const Duration(
      milliseconds: 500,
    );
  });

  testWidgets('reveals its child once, on first entry', (tester) async {
    await pumpReveal(tester);
    expect(find.text('revealed child'), findsOneWidget);
    expect(opacityOf(tester), 0, reason: 'still below the fold');

    await scrollBy(tester, -700);
    await tester.pump(const Duration(milliseconds: 700));
    expect(opacityOf(tester), 1);

    // Away and back: it stays revealed instead of replaying the fade.
    await scrollBy(tester, 700);
    expect(opacityOf(tester), 1);
    await scrollBy(tester, -700);
    await tester.pump(const Duration(milliseconds: 50));
    expect(opacityOf(tester), 1);
  });

  testWidgets('reduced motion is a plain fade without the slide', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pumpReveal(tester);
    expect(
      find.descendant(
        of: find.byType(RevealOnScroll),
        matching: find.byType(SlideTransition),
      ),
      findsNothing,
    );
    expect(opacityOf(tester), 0);

    await scrollBy(tester, -700);
    await tester.pump(const Duration(milliseconds: 400));
    expect(opacityOf(tester), 1);
  });
}
