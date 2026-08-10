import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'jelly_tabs_icon_builder.dart';
import 'jelly_tabs_icon_props.dart';

@immutable
class JellyTabsItem {
  const JellyTabsItem({
    required this.key,
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    this.accessibilityLabel,
    this.labelStyle,
    this.badge,
    this.badgeStyle,
    this.testID,
  });

  final String key;
  final String label;
  final JellyTabsIconBuilder activeIcon;
  final JellyTabsIconBuilder inactiveIcon;
  final String? accessibilityLabel;
  final TextStyle? labelStyle;
  final Object? badge;
  final TextStyle? badgeStyle;
  final Key? testID;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JellyTabsItem &&
          key == other.key &&
          label == other.label &&
          activeIcon == other.activeIcon &&
          inactiveIcon == other.inactiveIcon &&
          accessibilityLabel == other.accessibilityLabel &&
          labelStyle == other.labelStyle &&
          badge == other.badge &&
          badgeStyle == other.badgeStyle &&
          testID == other.testID;

  @override
  int get hashCode => Object.hash(
        key,
        label,
        activeIcon,
        inactiveIcon,
        accessibilityLabel,
        labelStyle,
        badge,
        badgeStyle,
        testID,
      );
}
