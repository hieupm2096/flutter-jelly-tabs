import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/src/config/config.dart';
import 'package:jelly_tabs/src/config/defaults.dart';
import 'package:jelly_tabs/src/controllers/distortion_controller.dart';

const _layout = JellyTabsLayout(
  iconSize: 28,
  itemHeight: 56,
  maskOverscanX: 48,
  maskOverscanY: 16,
  trackHeight: 64,
  trackInset: 4,
);

void main() {
  group(DistortionController, () {
    late DistortionController subject;

    setUp(() {
      subject = DistortionController(
        config: DefaultDistortion.config,
        layout: _layout,
        vsync: const TestVSync(),
      );
    });

    tearDown(() {
      subject.dispose();
    });

    group('begin', () {
      testWidgets('starts spring animating pressedScale toward target', (
        tester,
      ) async {
        subject.begin(50, 30, 50);
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 16));

        expect(subject.pressedScale, greaterThan(1));
        expect(subject.pressedScale, lessThanOrEqualTo(1.025));

        await tester.pump(const Duration(seconds: 2));
        expect(subject.pressedScale, closeTo(1.025, 1e-3));
      });

      testWidgets('starts spring animating touchFeedbackOpacity to 1', (
        tester,
      ) async {
        subject.begin(50, 30, 50);
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 16));

        expect(subject.touchFeedbackOpacity, greaterThan(0));

        await tester.pump(const Duration(seconds: 2));
        expect(subject.touchFeedbackOpacity, closeTo(1, 1e-3));
      });

      testWidgets('captures in-flight translateY into dragOriginY mid-flight', (
        tester,
      ) async {
        subject
          ..setTrackWidth(400)
          ..begin(50, 30, 50)
          ..update(50, 50)
          // Simulate a release spring still settling.
          ..end();
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 100));
        final inFlightTranslateY = subject.translateY;

        subject.begin(50, 30, 50);

        expect(subject.dragOriginY, closeTo(inFlightTranslateY, 1e-3));
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(seconds: 2));
      });
    });

    group('update', () {
      testWidgets(
        'sets translateY and scaleX as direct assignments (same-tick)',
        (tester) async {
          subject
            ..setTrackWidth(400)
            ..begin(50, 30, 50)
            ..update(140, 50);

          const expectedTranslateY =
              0 + 0.25 * ((1 - 1 / ((140 * 0.14) / 64 + 1)) * 64);
          // progress = min(140 / 700, 1) = 0.2
          const expectedScaleX = 1 - 0.2 * 0.08;

          expect(subject.translateY, closeTo(expectedTranslateY, 1e-6));
          expect(subject.scaleX, closeTo(expectedScaleX, 1e-6));
          await tester.pump(const Duration(milliseconds: 16));
          await tester.pump(const Duration(seconds: 2));
        },
      );

      testWidgets('keeps scaleX at 1 for horizontal-only input', (
        tester,
      ) async {
        subject
          ..setTrackWidth(400)
          ..begin(50, 30, 50)
          ..update(0, 50);

        expect(subject.scaleX, 1);
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(seconds: 2));
      });
    });

    group('end', () {
      testWidgets('springs values back to rest', (tester) async {
        subject
          ..setTrackWidth(400)
          ..begin(50, 30, 50)
          ..update(140, 50)
          ..end();
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(seconds: 2));

        expect(subject.translateY, closeTo(0, 1e-3));
        expect(subject.scaleX, closeTo(1, 1e-3));
        expect(subject.pressedScale, closeTo(1, 1e-3));
        expect(subject.touchFeedbackOpacity, closeTo(0, 1e-3));
      });

      testWidgets(
        'resets transformOriginX to trackWidth/2 when scaleX finishes',
        (tester) async {
          subject
            ..setTrackWidth(400)
            ..begin(50, 30, 50)
            ..update(140, 50)
            ..transformOriginX = 123
            ..end();
          await tester.pump(const Duration(milliseconds: 16));
          await tester.pump(const Duration(seconds: 2));

          expect(subject.transformOriginX, closeTo(200, 1e-3));
        },
      );
    });

    group('setTrackWidth', () {
      test('centers transformOriginX', () {
        subject.setTrackWidth(400);

        expect(subject.trackWidth, 400);
        expect(subject.transformOriginX, 200);
      });
    });
  });
}
