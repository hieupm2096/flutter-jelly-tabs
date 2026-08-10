import 'package:flutter/material.dart';

/// A radial "glow" rendered behind the pill and over the surface, ported from
/// `react-native-jelly-tabs`'s `TouchFeedback` (SVG radial gradient).
///
/// Draws a `diameter x diameter` square filled with a radial gradient whose
/// stops fade from [color] at [centerOpacity] through [middleOpacity] at 45% to
/// fully transparent at the edge. The glow is positioned by [translate], which
/// the parent animates each frame, and faded by [opacity] as it springs in on
/// press and out on release.
class TouchFeedback extends StatelessWidget {
  /// Creates a [TouchFeedback] glow.
  const TouchFeedback({
    required this.translate,
    required this.diameter,
    required this.centerOpacity,
    required this.middleOpacity,
    super.key,
    this.color = const Color(0xFFFFFFFF),
    this.opacity = 1,
  });

  /// Translation applied to the glow, animating it under the pointer.
  final Offset translate;

  /// Diameter of the glow square; the gradient radius is `diameter / 2`.
  final double diameter;

  /// Opacity of [color] at the center of the gradient.
  final double centerOpacity;

  /// Opacity of [color] at 45% of the gradient radius.
  final double middleOpacity;

  /// Color of the glow. Defaults to white, matching `touch-feedback.tsx`.
  final Color color;

  /// Overall fade of the glow, e.g. `touchFeedbackOpacity` on press/release.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: translate,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              stops: const [0, 0.45, 1],
              colors: [
                color.withValues(alpha: centerOpacity),
                color.withValues(alpha: middleOpacity),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
