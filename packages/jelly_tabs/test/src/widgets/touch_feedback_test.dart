import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/src/widgets/touch_feedback.dart';

import '../../helpers/pump_app.dart';

RadialGradient _gradientOf(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byType(TouchFeedback),
      matching: find.byType(Container),
    ),
  );
  return (container.decoration! as BoxDecoration).gradient! as RadialGradient;
}

void main() {
  group(TouchFeedback, () {
    group('renders', () {
      testWidgets('a gradient container sized by diameter', (tester) async {
        await tester.pumpAppWidget(
          const TouchFeedback(
            translate: Offset.zero,
            diameter: 600,
            centerOpacity: 0.15,
            middleOpacity: 0.0645,
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(TouchFeedback),
            matching: find.byType(Container),
          ),
        );

        expect(
          container.constraints,
          const BoxConstraints.tightFor(width: 600, height: 600),
        );
      });

      testWidgets(
        'a radial gradient with stops for center, middle, and transparent',
        (tester) async {
          await tester.pumpAppWidget(
            const TouchFeedback(
              translate: Offset.zero,
              diameter: 600,
              centerOpacity: 0.15,
              middleOpacity: 0.0645,
            ),
          );

          final gradient = _gradientOf(tester);

          expect(gradient.radius, 0.5);
          expect(gradient.stops, [0, 0.45, 1]);
          expect(gradient.colors, [
            const Color(0xFFFFFFFF).withValues(alpha: 0.15),
            const Color(0xFFFFFFFF).withValues(alpha: 0.0645),
            const Color(0xFFFFFFFF).withValues(alpha: 0),
          ]);
        },
      );

      testWidgets('using the provided color in every stop', (tester) async {
        await tester.pumpAppWidget(
          const TouchFeedback(
            translate: Offset.zero,
            diameter: 600,
            centerOpacity: 1,
            middleOpacity: 0.4,
            color: Color(0xFF123456),
          ),
        );

        final gradient = _gradientOf(tester);

        expect(gradient.colors, [
          const Color(0xFF123456).withValues(alpha: 1),
          const Color(0xFF123456).withValues(alpha: 0.4),
          const Color(0xFF123456).withValues(alpha: 0),
        ]);
      });
    });

    group('positioning', () {
      testWidgets('applies the animated translate offset', (tester) async {
        await tester.pumpAppWidget(
          const TouchFeedback(
            translate: Offset(250, 100),
            diameter: 600,
            centerOpacity: 0.15,
            middleOpacity: 0.0645,
          ),
        );

        final transform = tester.widget<Transform>(
          find.descendant(
            of: find.byType(TouchFeedback),
            matching: find.byType(Transform),
          ),
        );

        expect(transform.transform, Matrix4.translationValues(250, 100, 0));
      });

      testWidgets('applies the fade opacity', (tester) async {
        await tester.pumpAppWidget(
          const TouchFeedback(
            translate: Offset.zero,
            diameter: 600,
            centerOpacity: 0.15,
            middleOpacity: 0.0645,
            opacity: 0.4,
          ),
        );

        final opacity = tester.widget<Opacity>(
          find.descendant(
            of: find.byType(TouchFeedback),
            matching: find.byType(Opacity),
          ),
        );

        expect(opacity.opacity, 0.4);
      });
    });
  });
}
