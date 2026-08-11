import 'package:flutter/material.dart';

import 'package:jelly_tabs/src/models/jelly_tabs_icon_builder.dart';

/// A single tab in a `JellyTabBarHeadless`, ported from
/// `react-native-jelly-tabs`'s `TabsItem`.
@immutable
class JellyTabsItem {
  /// Creates a [JellyTabsItem].
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

  /// A stable identifier for the tab.
  final String key;

  /// The label shown under the icon.
  final String label;

  /// Builds the icon for the selected tab.
  final JellyTabsIconBuilder activeIcon;

  /// Builds the icon for unselected tabs.
  final JellyTabsIconBuilder inactiveIcon;

  /// Overrides the semantics label (defaults to [label]).
  final String? accessibilityLabel;

  /// Merged over the base label style.
  final TextStyle? labelStyle;

  /// A number or string shown in a pill anchored to the icon's top-right.
  final Object? badge;

  /// Style overrides for the badge text.
  final TextStyle? badgeStyle;

  /// A key for tests.
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
