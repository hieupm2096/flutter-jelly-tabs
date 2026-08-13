import 'dart:ui';

import 'package:flutter/widgets.dart';

/// A blurred backdrop for the tab bar, mirroring the reference example's use
/// of `expo-blur`'s `BlurView`.
///
/// `intensity` mirrors `expo-blur`'s 1-100 intensity scale; it is mapped to a
/// Gaussian sigma via `intensity / 5` so the default pill (20) and track (35)
/// look like the reference demo.
class BlurView extends StatelessWidget {
  const BlurView({
    required this.intensity,
    super.key,
    this.tint = const Color(0x00000000),
  });

  /// Blur intensity on `expo-blur`'s 1-100 scale.
  final double intensity;

  /// Overlay color drawn over the blurred content.
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: intensity / 5,
          sigmaY: intensity / 5,
        ),
        child: ColoredBox(color: tint),
      ),
    );
  }
}
