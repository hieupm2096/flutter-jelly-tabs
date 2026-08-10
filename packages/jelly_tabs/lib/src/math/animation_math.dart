import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:jelly_tabs/src/config/spring_config.dart';

const _springRestEpsilon = 0.0001;
const _millisecondsPerSecond = 1000;
const _maxFrameDeltaSeconds = 0.064;
const _easeOutControlPointX = 0.58;
const _easeOutSearchIterations = 10;
const _panelOffsetDistance = 4;

bool _isSpringAtRest(double displacement, double velocity) {
  return displacement.abs() < _springRestEpsilon &&
      velocity.abs() < _springRestEpsilon;
}

@visibleForTesting
class SpringStep {
  const SpringStep({required this.value, required this.velocity});

  final double value;
  final double velocity;
}

SpringStep _advanceCriticalSpring(
  double displacement,
  double velocity,
  double target,
  double naturalFrequency,
  double deltaSeconds,
) {
  final decay = math.exp(-naturalFrequency * deltaSeconds);
  final coefficient = velocity + naturalFrequency * displacement;

  return SpringStep(
    value: target + (displacement + coefficient * deltaSeconds) * decay,
    velocity:
        (velocity - naturalFrequency * coefficient * deltaSeconds) * decay,
  );
}

SpringStep _advanceUnderdampedSpring(
  double displacement,
  double velocity,
  double target,
  SpringConfig config,
  double naturalFrequency,
  double deltaSeconds,
) {
  final dampingFrequency = config.dampingRatio * naturalFrequency;
  final dampedFrequency =
      naturalFrequency *
      math.sqrt(1 - config.dampingRatio * config.dampingRatio);
  final decay = math.exp(-dampingFrequency * deltaSeconds);
  final angle = dampedFrequency * deltaSeconds;
  final cosine = math.cos(angle);
  final sine = math.sin(angle);
  final positionCoefficient =
      (velocity + dampingFrequency * displacement) / dampedFrequency;
  final velocityCoefficient =
      (dampingFrequency * velocity + config.stiffness * displacement) /
      dampedFrequency;

  return SpringStep(
    value:
        target + decay * (displacement * cosine + positionCoefficient * sine),
    velocity: decay * (velocity * cosine - velocityCoefficient * sine),
  );
}

SpringStep _advanceOverdampedSpring(
  double displacement,
  double velocity,
  double target,
  SpringConfig config,
  double naturalFrequency,
  double deltaSeconds,
) {
  // Mirror of the underdamped solution with a real damped frequency and
  // hyperbolic functions, keeping ratios above 1 (overdamped) from
  // producing NaN via sqrt of a negative number.
  final dampingFrequency = config.dampingRatio * naturalFrequency;
  final dampedFrequency =
      naturalFrequency *
      math.sqrt(config.dampingRatio * config.dampingRatio - 1);
  final decay = math.exp(-dampingFrequency * deltaSeconds);
  final angle = dampedFrequency * deltaSeconds;
  final hyperbolicCosine = cosh(angle);
  final hyperbolicSine = sinh(angle);
  final positionCoefficient =
      (velocity + dampingFrequency * displacement) / dampedFrequency;
  final velocityCoefficient =
      (dampingFrequency * velocity + config.stiffness * displacement) /
      dampedFrequency;

  return SpringStep(
    value:
        target +
        decay *
            (displacement * hyperbolicCosine +
                positionCoefficient * hyperbolicSine),
    velocity:
        decay *
        (velocity * hyperbolicCosine - velocityCoefficient * hyperbolicSine),
  );
}

/// Advances the unit-mass damped spring used by Compose's SpringSpec.
/// The analytical solution stays stable at both 60 Hz and 120 Hz.
SpringStep advanceSpring(
  double value,
  double velocity,
  double target, {
  required SpringConfig spring,
  required double dt,
}) {
  final displacement = value - target;
  if (_isSpringAtRest(displacement, velocity)) {
    return SpringStep(value: target, velocity: 0);
  }

  final naturalFrequency = math.sqrt(spring.stiffness);
  if (spring.dampingRatio == 1) {
    return _advanceCriticalSpring(
      displacement,
      velocity,
      target,
      naturalFrequency,
      dt,
    );
  }

  if (spring.dampingRatio > 1) {
    return _advanceOverdampedSpring(
      displacement,
      velocity,
      target,
      spring,
      naturalFrequency,
      dt,
    );
  }

  return _advanceUnderdampedSpring(
    displacement,
    velocity,
    target,
    spring,
    naturalFrequency,
    dt,
  );
}

/// Converts frame time in milliseconds to seconds, clamped to a safe maximum.
double? getFrameDeltaSeconds(int? timeSincePreviousFrame) {
  if (timeSincePreviousFrame == null) {
    return null;
  }

  return math.min(
    timeSincePreviousFrame / _millisecondsPerSecond,
    _maxFrameDeltaSeconds,
  );
}

double _evaluateCubicBezierCoordinate(
  double parameter,
  double secondControlPoint,
) {
  final parameterSquared = parameter * parameter;
  final inverse = 1 - parameter;

  return parameterSquared * (3 * inverse * secondControlPoint + parameter);
}

/// Compose's EaseOut is CubicBezierEasing(0, 0, 0.58, 1).
double easeOut(double input) {
  final x = input.clamp(0.0, 1.0);
  var low = 0.0;
  var high = 1.0;
  var parameter = x;

  for (var iteration = 0; iteration < _easeOutSearchIterations; iteration++) {
    final bezierX = _evaluateCubicBezierCoordinate(
      parameter,
      _easeOutControlPointX,
    );

    if (bezierX < x) {
      low = parameter;
    } else {
      high = parameter;
    }
    parameter = (low + high) / 2;
  }

  return _evaluateCubicBezierCoordinate(parameter, 1);
}

/// Computes the horizontal micro-shift of the panel while dragging.
double getHorizontalPanelOffset(
  double rawOffset,
  double trackWidth,
  double geometryScale,
) {
  if (trackWidth <= 0) {
    return 0;
  }

  final fraction = (rawOffset / trackWidth).clamp(-1.0, 1.0);
  if (fraction == 0) {
    return 0;
  }

  return fraction.sign *
      _panelOffsetDistance *
      geometryScale *
      easeOut(fraction.abs());
}

/// Computes the width of each tab, minus inset padding.
double getTabWidth(double trackWidth, double trackInset, int tabCount) {
  if (tabCount <= 0) {
    return 0;
  }

  return math.max(0, (trackWidth - trackInset * 2) / tabCount);
}

/// Returns the maximum valid tab index for the given count.
int getMaxTabIndex(int tabCount) {
  return math.max(0, tabCount - 1);
}

/// Damped resistance for drag overscroll.
double rubberBand(double distance, double dimension, double coefficient) {
  if (distance == 0) {
    return 0;
  }

  final absoluteDistance = distance.abs();
  final dampedDistance =
      (1 - 1 / ((absoluteDistance * coefficient) / dimension + 1)) * dimension;

  return distance.sign * dampedDistance;
}

/// Computes the clamped pointer origin position for distortion tracking.
double getPointerOrigin(
  double currentAbsolutePosition,
  double dimension,
  double initialAbsolutePosition,
  double initialLocalPosition,
) {
  final pointerPosition =
      initialLocalPosition +
      (currentAbsolutePosition - initialAbsolutePosition);

  return pointerPosition.clamp(0.0, dimension);
}

double sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;

double cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;
