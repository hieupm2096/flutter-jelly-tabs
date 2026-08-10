import 'package:flutter/foundation.dart';

@immutable
class SpringConfig {
  const SpringConfig({required this.stiffness, required this.dampingRatio});

  final double stiffness;
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

@immutable
class DistortionSpringConfig {
  const DistortionSpringConfig({
    required this.damping,
    required this.mass,
    required this.stiffness,
  });

  final double damping;
  final double mass;
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
