import 'dart:math' as math;

import 'package:jelly_tabs/src/config/config.dart';
import 'package:jelly_tabs/src/math/animation_math.dart';

/// Mutable state for the pill jelly frame loop, mirroring
/// Reanimated shared values in `pill-jelly-animation.ts`.
class PillJellyFrameState {
  /// Horizontal pill scale, spring-driven toward [shapeTarget].
  double baseScaleX = 1;

  /// Velocity of [baseScaleX].
  double baseScaleXRate = 0;

  /// Vertical pill scale, spring-driven toward [shapeTarget].
  double baseScaleY = 1;

  /// Velocity of [baseScaleY].
  double baseScaleYRate = 0;

  /// Filtered pill velocity used for velocity-shear correction.
  double filteredVelocity = 0;

  /// Velocity of [filteredVelocity].
  double filteredVelocityRate = 0;

  /// 1 while a gesture is active, 0 otherwise.
  double isDragging = 0;

  /// Press inflation progress (0 → 1).
  double pressProgress = 0;

  /// Velocity of [pressProgress].
  double pressProgressRate = 0;

  /// The press-inflation target (1 while pressed, 0 on release).
  double pressTarget = 0;

  /// The raw, unclamped panel horizontal offset.
  double rawPanelOffset = 0;

  /// Velocity of [rawPanelOffset].
  double rawPanelOffsetVelocity = 0;

  /// 1 while a settle is pending after release, 0 otherwise.
  double releasePending = 0;

  /// The pill's scale target (1 at rest, `pressedScale` while pressed).
  double shapeTarget = 1;

  /// The target tab position (0..maxTabIndex).
  double targetValue = 0;

  /// The pill's current tab position.
  double value = 0;

  /// Velocity of [value].
  double valueVelocity = 0;
}

/// Advances the pill jelly frame state by one step, mirroring
/// `advancePillJellyFrame` in `pill-jelly-animation.ts`.
void advancePillJellyFrame(
  PillJellyFrameState state,
  PillJellyFrameConfig config, {
  required int tabCount,
  required int dtMs,
}) {
  final dt = getFrameDeltaSeconds(dtMs);
  if (dt == null) return;

  final maxIndex = getMaxTabIndex(tabCount);
  state.targetValue = state.targetValue.clamp(0.0, maxIndex.toDouble());

  final valueStep = advanceSpring(
    state.value,
    state.valueVelocity,
    state.targetValue,
    spring: config.springs.value,
    dt: dt,
  );
  state
    ..value = valueStep.value
    ..valueVelocity = valueStep.velocity;

  final velocityTarget = (state.isDragging > 0 && maxIndex > 0)
      ? state.valueVelocity / maxIndex
      : 0.0;
  final velocityStep = advanceSpring(
    state.filteredVelocity,
    state.filteredVelocityRate,
    velocityTarget,
    spring: config.springs.velocity,
    dt: dt,
  );
  state
    ..filteredVelocity = velocityStep.value
    ..filteredVelocityRate = velocityStep.velocity;

  // rawPanelOffset only springs back when not dragging
  if (state.isDragging == 0) {
    final panelStep = advanceSpring(
      state.rawPanelOffset,
      state.rawPanelOffsetVelocity,
      0,
      spring: config.springs.panel,
      dt: dt,
    );
    state
      ..rawPanelOffset = panelStep.value
      ..rawPanelOffsetVelocity = panelStep.velocity;
  }

  // settle released indicator
  if (state.releasePending > 0) {
    final releaseThreshold =
        config.releaseDistanceFraction * math.max(1, maxIndex);
    if ((state.value - state.targetValue).abs() < releaseThreshold) {
      state
        ..releasePending = 0
        ..pressTarget = 0
        ..shapeTarget = 1;
    }
  }

  final pressStep = advanceSpring(
    state.pressProgress,
    state.pressProgressRate,
    state.pressTarget,
    spring: config.springs.press,
    dt: dt,
  );
  state
    ..pressProgress = pressStep.value
    ..pressProgressRate = pressStep.velocity;

  final scaleXStep = advanceSpring(
    state.baseScaleX,
    state.baseScaleXRate,
    state.shapeTarget,
    spring: config.springs.scaleX,
    dt: dt,
  );
  state
    ..baseScaleX = scaleXStep.value
    ..baseScaleXRate = scaleXStep.velocity;

  final scaleYStep = advanceSpring(
    state.baseScaleY,
    state.baseScaleYRate,
    state.shapeTarget,
    spring: config.springs.scaleY,
    dt: dt,
  );
  state
    ..baseScaleY = scaleYStep.value
    ..baseScaleYRate = scaleYStep.velocity;
}
