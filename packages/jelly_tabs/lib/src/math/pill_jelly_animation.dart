import 'dart:math' as math;

import 'package:jelly_tabs/src/config/config.dart';
import 'package:jelly_tabs/src/math/animation_math.dart';

/// Mutable state for the pill jelly frame loop, mirroring
/// Reanimated shared values in `pill-jelly-animation.ts`.
class PillJellyFrameState {
  var baseScaleX = 1.0;
  var baseScaleXRate = 0.0;
  var baseScaleY = 1.0;
  var baseScaleYRate = 0.0;
  var filteredVelocity = 0.0;
  var filteredVelocityRate = 0.0;
  var isDragging = 0.0;
  var pressProgress = 0.0;
  var pressProgressRate = 0.0;
  var pressTarget = 0.0;
  var rawPanelOffset = 0.0;
  var rawPanelOffsetVelocity = 0.0;
  var releasePending = 0.0;
  var shapeTarget = 1.0;
  var targetValue = 0.0;
  var value = 0.0;
  var valueVelocity = 0.0;
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
  state.value = valueStep.value;
  state.valueVelocity = valueStep.velocity;

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
  state.filteredVelocity = velocityStep.value;
  state.filteredVelocityRate = velocityStep.velocity;

  // rawPanelOffset only springs back when not dragging
  if (state.isDragging == 0) {
    final panelStep = advanceSpring(
      state.rawPanelOffset,
      state.rawPanelOffsetVelocity,
      0,
      spring: config.springs.panel,
      dt: dt,
    );
    state.rawPanelOffset = panelStep.value;
    state.rawPanelOffsetVelocity = panelStep.velocity;
  }

  // settle released indicator
  if (state.releasePending > 0) {
    final releaseThreshold =
        config.releaseDistanceFraction * math.max(1, maxIndex);
    if ((state.value - state.targetValue).abs() < releaseThreshold) {
      state.releasePending = 0;
      state.pressTarget = 0;
      state.shapeTarget = 1;
    }
  }

  final pressStep = advanceSpring(
    state.pressProgress,
    state.pressProgressRate,
    state.pressTarget,
    spring: config.springs.press,
    dt: dt,
  );
  state.pressProgress = pressStep.value;
  state.pressProgressRate = pressStep.velocity;

  final scaleXStep = advanceSpring(
    state.baseScaleX,
    state.baseScaleXRate,
    state.shapeTarget,
    spring: config.springs.scaleX,
    dt: dt,
  );
  state.baseScaleX = scaleXStep.value;
  state.baseScaleXRate = scaleXStep.velocity;

  final scaleYStep = advanceSpring(
    state.baseScaleY,
    state.baseScaleYRate,
    state.shapeTarget,
    spring: config.springs.scaleY,
    dt: dt,
  );
  state.baseScaleY = scaleYStep.value;
  state.baseScaleYRate = scaleYStep.velocity;
}
