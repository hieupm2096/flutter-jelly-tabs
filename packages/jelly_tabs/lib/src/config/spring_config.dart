import 'package:flutter/foundation.dart';

/// The two parameters of the analytical damped-spring solver used for the pill
/// jelly springs. Mirrors RN's `SpringConfig` (`stiffness` + `dampingRatio`).
@immutable
class SpringConfig {
  /// Creates a [SpringConfig].
  const SpringConfig({required this.stiffness, required this.dampingRatio});

  /// Spring stiffness; higher is stiffer.
  final double stiffness;

  /// Damping ratio; <1 underdamped (overshoot), 1 critically damped, >1
  /// overdamped.
  final double dampingRatio;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpringConfig &&
          stiffness == other.stiffness &&
          dampingRatio == other.dampingRatio;

  @override
  int get hashCode => Object.hash(stiffness, dampingRatio);
}

/// The physical spring parameters driving the track distortion, ported from
/// RN's `distortion.spring` (`damping`, `mass`, `stiffness`) and fed to
/// Flutter's `SpringDescription`/`SpringSimulation`.
@immutable
class DistortionSpringConfig {
  /// Creates a [DistortionSpringConfig].
  const DistortionSpringConfig({
    required this.damping,
    required this.mass,
    required this.stiffness,
  });

  /// Damping coefficient.
  final double damping;

  /// Oscillator mass.
  final double mass;

  /// Spring stiffness.
  final double stiffness;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistortionSpringConfig &&
          damping == other.damping &&
          mass == other.mass &&
          stiffness == other.stiffness;

  @override
  int get hashCode => Object.hash(damping, mass, stiffness);
}
