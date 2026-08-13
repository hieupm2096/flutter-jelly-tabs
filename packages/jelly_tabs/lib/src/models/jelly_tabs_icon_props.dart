import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:jelly_tabs/src/config/config.dart';

/// The resolved styling passed to a `JellyTabsIconBuilder`, mirroring the
/// reference `TabsIcon` component's props.
@immutable
class JellyTabsIconProps {
  /// Creates a [JellyTabsIconProps].
  const JellyTabsIconProps({
    required this.color,
    required this.colors,
    required this.opacity,
    required this.size,
  });

  /// The resolved active/inactive content color.
  final Color color;

  /// The resolved tab bar colors.
  final JellyTabsColors colors;

  /// The resolved layer opacity.
  final double opacity;

  /// The resolved icon size.
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
