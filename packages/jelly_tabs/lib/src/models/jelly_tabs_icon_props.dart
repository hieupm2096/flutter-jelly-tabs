import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:jelly_tabs/src/config/config.dart';

@immutable
class JellyTabsIconProps {
  const JellyTabsIconProps({
    required this.color,
    required this.colors,
    required this.opacity,
    required this.size,
  });

  final Color color;
  final JellyTabsColors colors;
  final double opacity;
  final double size;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JellyTabsIconProps &&
          color == other.color &&
          colors == other.colors &&
          opacity == other.opacity &&
          size == other.size;

  @override
  int get hashCode => Object.hash(color, colors, opacity, size);
}
