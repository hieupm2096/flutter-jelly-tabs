import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/src/config/defaults.dart';
import 'package:jelly_tabs/src/config/spring_config.dart';
import 'package:jelly_tabs/src/math/animation_math.dart';
import 'package:jelly_tabs/src/math/pill_jelly_animation.dart';

void main() {
  group('advanceSpring', () {
    test('snaps to target when at rest', () {
      final step = advanceSpring(
        5,
        0,
        5,
        spring: const SpringConfig(stiffness: 300, dampingRatio: 1),
        dt: 0.016,
      );
      expect(step.value, 5);
      expect(step.velocity, 0);
    });

    test('critical damping reaches target without overshoot', () {
      var v = 100.0;
      var x = 0.0;
      const config = SpringConfig(stiffness: 300, dampingRatio: 1);
      for (var i = 0; i < 300; i++) {
        final step = advanceSpring(x, v, 1, spring: config, dt: 0.016);
        x = step.value;
        v = step.velocity;
      }
      expect(x, closeTo(1, 1e-3));
      expect(v, closeTo(0, 1e-3));
    });

    test('underdamped overshoots then settles', () {
      var v = 100.0;
      var x = 0.0;
      var maxX = 0.0;
      const config = SpringConfig(stiffness: 300, dampingRatio: 0.5);
      for (var i = 0; i < 500; i++) {
        final step = advanceSpring(x, v, 1, spring: config, dt: 0.016);
        x = step.value;
        v = step.velocity;
        if (x > maxX) maxX = x;
      }
      expect(maxX, greaterThan(1));
      expect(x, closeTo(1, 1e-3));
      expect(v, closeTo(0, 1e-3));
    });

    test('overdamped converges to target', () {
      var v = 100.0;
      var x = 0.0;
      const config = SpringConfig(stiffness: 300, dampingRatio: 2);
      for (var i = 0; i < 500; i++) {
        final step = advanceSpring(x, v, 1, spring: config, dt: 0.016);
        x = step.value;
        v = step.velocity;
      }
      expect(x, closeTo(1, 1e-3));
      expect(v, closeTo(0, 1e-3));
    });
  });

  group('getFrameDeltaSeconds', () {
    test('returns null when null input', () {
      expect(getFrameDeltaSeconds(null), isNull);
    });

    test('clamps to MAX_FRAME_DELTA_SECONDS', () {
      final dt = getFrameDeltaSeconds(100);
      expect(dt, isNotNull);
      expect(dt! <= 0.064, isTrue);
    });

    test('converts milliseconds to seconds', () {
      final dt = getFrameDeltaSeconds(16);
      expect(dt, closeTo(0.016, 1e-6));
    });
  });

  group('easeOut', () {
    test('easeOut(0) == 0', () {
      expect(easeOut(0), 0);
    });

    test('easeOut(1) ≈ 1', () {
      expect(easeOut(1), closeTo(1, 1e-3));
    });

    test('is monotonic', () {
      var last = 0.0;
      for (var t = 0.0; t <= 1.0; t += 0.05) {
        final y = easeOut(t);
        expect(y, greaterThanOrEqualTo(last));
        last = y;
      }
    });

    test('easeOut(0.5) is within [0.5, 1]', () {
      final y = easeOut(0.5);
      expect(y, greaterThanOrEqualTo(0.5));
      expect(y, lessThanOrEqualTo(1));
    });
  });

  group('rubberBand', () {
    test('rubberBand(0, dim, coeff) == 0', () {
      expect(rubberBand(0, 100, 0.14), 0);
    });

    test('sign is preserved', () {
      final pos = rubberBand(50, 100, 0.14);
      final neg = rubberBand(-50, 100, 0.14);
      expect(pos, greaterThan(0));
      expect(neg, lessThan(0));
    });

    test('bounded by dimension', () {
      final result = rubberBand(10000, 100, 0.14);
      expect(result.abs(), lessThanOrEqualTo(100));
    });
  });

  group('getTabWidth', () {
    test('getTabWidth(400, 4, 4) == 98', () {
      expect(getTabWidth(400, 4, 4), 98);
    });

    test('getTabWidth(0, 4, 4) == 0', () {
      expect(getTabWidth(0, 4, 4), 0);
    });

    test('returns 0 when tabCount <= 0', () {
      expect(getTabWidth(400, 4, 0), 0);
    });
  });

  group('getMaxTabIndex', () {
    test('getMaxTabIndex(4) == 3', () {
      expect(getMaxTabIndex(4), 3);
    });

    test('getMaxTabIndex(0) == 0', () {
      expect(getMaxTabIndex(0), 0);
    });
  });

  group('getHorizontalPanelOffset', () {
    test('returns 0 at rest', () {
      expect(getHorizontalPanelOffset(0, 400, 1), 0);
    });

    test('returns 0 when trackWidth <= 0', () {
      expect(getHorizontalPanelOffset(100, 0, 1), 0);
    });

    test('returns value within ±4 * scale pixels', () {
      final offset = getHorizontalPanelOffset(200, 400, 1);
      expect(offset.abs(), lessThanOrEqualTo(4));
    });
  });

  group('getPointerOrigin', () {
    test('clamps to [0, dimension]', () {
      expect(getPointerOrigin(500, 400, 0, 100), 400);
      expect(getPointerOrigin(-100, 400, 0, 100), 0);
    });

    test('tracks local position with absolute delta', () {
      final result = getPointerOrigin(150, 400, 100, 100);
      expect(result, 150);
    });
  });

  group('advancePillJellyFrame', () {
    test('press then release keeps pill inflated initially', () {
      final state = PillJellyFrameState();
      const config = DefaultPillJelly.frameConfig;

      // Simulate press
      state
        ..pressTarget = 1
        ..shapeTarget = 1.3
        ..pressProgress = 1
        ..baseScaleX = 1.3
        ..baseScaleY = 1.3
        ..releasePending = 0;

      // Advance many frames
      for (var i = 0; i < 60; i++) {
        advancePillJellyFrame(state, config, tabCount: 4, dtMs: 16);
      }

      // Pill should be inflating toward pressedScale
      expect(state.baseScaleX, greaterThan(1));
    });

    test('settles to rest after release', () {
      final state = PillJellyFrameState();
      const config = DefaultPillJelly.frameConfig;

      state
        ..pressTarget = 1
        ..shapeTarget = 1.3
        ..pressProgress = 1
        ..baseScaleX = 1.3
        ..baseScaleY = 1.3
        // Simulate release
        ..pressTarget = 0
        ..shapeTarget = 1
        ..releasePending = 1;

      // Settle
      for (var i = 0; i < 300; i++) {
        advancePillJellyFrame(state, config, tabCount: 4, dtMs: 16);
      }

      expect(state.baseScaleX, closeTo(1, 1e-3));
      expect(state.baseScaleY, closeTo(1, 1e-3));
      expect(state.pressProgress, closeTo(0, 1e-3));
    });

    test('clampTargetValue bounds to [0, maxTabIndex]', () {
      final state = PillJellyFrameState();
      const config = DefaultPillJelly.frameConfig;

      state.targetValue = 10;
      advancePillJellyFrame(state, config, tabCount: 4, dtMs: 16);
      expect(state.targetValue, lessThanOrEqualTo(3));
      expect(state.targetValue, greaterThanOrEqualTo(0));

      state.targetValue = -1;
      advancePillJellyFrame(state, config, tabCount: 4, dtMs: 16);
      expect(state.targetValue, greaterThanOrEqualTo(0));
    });
  });
}
