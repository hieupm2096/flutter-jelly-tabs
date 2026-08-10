import 'package:flutter/material.dart';

/// A [CustomClipper] that produces the jelly pill's capsule shape, ported from
/// the RN `pill-masked-view` mask element.
///
/// The path is drawn in the overscan-sized content layer's coordinate space:
/// the pill is a capsule of [tabWidth] by [itemHeight] whose center sits at
/// `left + translationX + tabWidth / 2`, `top + itemHeight / 2`, scaled by
/// [scaleX]/[scaleY] about that center. [translationX] is the animated
/// `value * tabWidth` position and [scaleX]/[scaleY] are the velocity-shear
/// corrected scales, matching `getPillMaskStyle` in `use-pill-jelly.ts`.
class PillPathClipper extends CustomClipper<Path> {
  /// Creates a [PillPathClipper].
  const PillPathClipper({
    required this.translationX,
    required this.scaleX,
    required this.scaleY,
    required this.tabWidth,
    required this.itemHeight,
    required this.left,
    required this.top,
  });

  /// Animated pill position, `value * tabWidth`.
  final double translationX;

  /// Velocity-shear corrected horizontal scale (`baseScaleX / (1 - corr)`).
  final double scaleX;

  /// Velocity-shear corrected vertical scale (`baseScaleY * (1 - corr)`).
  final double scaleY;

  /// Width of one tab; the pill's base width.
  final double tabWidth;

  /// Height of one tab; the pill's base height and capsule diameter.
  final double itemHeight;

  /// Horizontal inset of the content layer (`maskOverscanX + trackInset`).
  final double left;

  /// Vertical inset of the content layer (`maskOverscanY + trackInset`).
  final double top;

  @override
  Path getClip(Size size) {
    final center = Offset(
      left + translationX + tabWidth / 2,
      top + itemHeight / 2,
    );
    final rect = Rect.fromCenter(
      center: center,
      width: tabWidth * scaleX,
      height: itemHeight * scaleY,
    );
    // Scaling the capsule about its center turns its circular corners into
    // ellipses, exactly like the RN transform applied to the mask element.
    final radiusX = itemHeight / 2 * scaleX;
    final radiusY = itemHeight / 2 * scaleY;
    final corner = Radius.elliptical(radiusX, radiusY);
    return Path()..addRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: corner,
        topRight: corner,
        bottomRight: corner,
        bottomLeft: corner,
      ),
    );
  }

  @override
  bool shouldReclip(PillPathClipper oldClipper) =>
      oldClipper.translationX != translationX ||
      oldClipper.scaleX != scaleX ||
      oldClipper.scaleY != scaleY ||
      oldClipper.tabWidth != tabWidth ||
      oldClipper.itemHeight != itemHeight ||
      oldClipper.left != left ||
      oldClipper.top != top;
}
