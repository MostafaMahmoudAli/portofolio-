import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/presentation/widgets/animated_counter.dart';
import 'package:visibility_detector/visibility_detector.dart';

Future<void> pumpFrames(WidgetTester tester, Duration total) async {
  const step = Duration(milliseconds: 50);
  for (var elapsed = Duration.zero; elapsed < total; elapsed += step) {
    await tester.pump(step);
  }
}

Future<void> pumpCounter(WidgetTester tester) async {
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
              AnimatedCounter(value: 310, suffix: 'K+'),
              SizedBox(height: 900),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

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

  testWidgets('counts up once and does not restart when scrolled back', (
    tester,
  ) async {
    await pumpCounter(tester);
    expect(
      find.text('0K+'),
      findsOneWidget,
      reason: 'below the fold, not started',
    );

    await scrollBy(tester, -700);
    await pumpFrames(tester, const Duration(milliseconds: 1400));
    expect(find.text('310K+'), findsOneWidget);
    expect(find.text('0K+'), findsNothing);

    // Away and back: the final value stays, with no new count-up.
    await scrollBy(tester, 700);
    await scrollBy(tester, -700);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('310K+'), findsOneWidget);
    expect(find.text('0K+'), findsNothing, reason: 'never restarts from zero');
  });

  testWidgets('reduced motion shows the final value without animating', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pumpCounter(tester);
    expect(find.text('310K+'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
