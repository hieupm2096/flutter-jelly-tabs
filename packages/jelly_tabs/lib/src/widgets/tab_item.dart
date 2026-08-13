import 'package:flutter/material.dart';
import 'package:jelly_tabs/src/config/config.dart';
import 'package:jelly_tabs/src/config/defaults.dart';
import 'package:jelly_tabs/src/models/jelly_tabs_icon_builder.dart';
import 'package:jelly_tabs/src/models/jelly_tabs_icon_props.dart';

/// A single tab: icon + label + optional badge.
///
/// When [isActive] is true it renders [activeIcon] with [activeColor] and a
/// bold label; otherwise [inactiveIcon] with [inactiveColor] and a regular
/// label. The optional [badge] is a small pill anchored to the icon's top-right
/// corner. [displayScale] scales the geometry exactly like the reference's
/// `displayScale`.
class TabItem extends StatelessWidget {
  /// Creates a [TabItem].
  const TabItem({
    required this.text,
    required this.colors,
    required this.activeIcon,
    required this.inactiveIcon,
    super.key,
    this.isActive = false,
    this.activeColor = const Color(0xFF000000),
    this.inactiveColor = const Color(0xFFAFAFAF),
    this.activeOpacity = 1,
    this.inactiveOpacity = 1,
    this.displayScale = 1,
    this.iconSize,
    this.itemHeight,
    this.labelStyle,
    this.badge,
    this.badgeStyle,
    this.activeBadgeStyle,
  });

  /// The label shown under the icon.
  final String text;

  /// The resolved tab bar colors, forwarded to the icon builders.
  final JellyTabsColors colors;

  /// Builds the icon when [isActive] is true.
  final JellyTabsIconBuilder activeIcon;

  /// Builds the icon when [isActive] is false.
  final JellyTabsIconBuilder inactiveIcon;

  /// Whether this tab is the selected one.
  final bool isActive;

  /// Color of the active icon and label.
  final Color activeColor;

  /// Color of the inactive icon and label.
  final Color inactiveColor;

  /// Opacity applied to the active tab content.
  final double activeOpacity;

  /// Opacity applied to the inactive tab content.
  final double inactiveOpacity;

  /// Geometry scale; multiplies the item height, icon size, offsets, and fonts.
  final double displayScale;

  /// Icon size in pixels (already scaled). Defaults to `28 * displayScale`.
  final double? iconSize;

  /// Item height in pixels (already scaled). Defaults to `56 * displayScale`.
  final double? itemHeight;

  /// Style overrides for the label, merged over the base label style.
  final TextStyle? labelStyle;

  /// A number or string shown in a pill anchored to the icon's top-right.
  final Object? badge;

  /// Style overrides for the badge text.
  final TextStyle? badgeStyle;

  /// Additional style overrides for the badge text when [isActive] is true.
  final TextStyle? activeBadgeStyle;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;
    final opacity = isActive ? activeOpacity : inactiveOpacity;
    final icon = isActive ? activeIcon : inactiveIcon;
    final resolvedItemHeight =
        itemHeight ?? DefaultJellyTabsLayout.itemHeight * displayScale;
    final resolvedIconSize =
        iconSize ?? DefaultJellyTabsLayout.iconSize * displayScale;

    return SizedBox(
      height: resolvedItemHeight,
      child: Opacity(
        opacity: opacity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: Offset(0, 2 * displayScale),
              child: Stack(
                children: [
                  icon(
                    JellyTabsIconProps(
                      color: color,
                      colors: colors,
                      opacity: opacity,
                      size: resolvedIconSize,
                    ),
                  ),
                  if (badge != null) _buildBadge(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4 * displayScale),
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: _labelStyle(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    final textStyle = _mergeBadgeTextStyle();
    final color = textStyle.backgroundColor ?? const Color(0xFFFF3B30);

    return Positioned(
      right: -10 * displayScale,
      top: -5 * displayScale,
      child: Container(
        height: 16 * displayScale,
        constraints: BoxConstraints(minWidth: 16 * displayScale),
        padding: EdgeInsets.symmetric(horizontal: 4 * displayScale),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8 * displayScale),
        ),
        child: Text(
          '$badge',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      ),
    );
  }

  TextStyle _labelStyle(Color color) {
    final base = TextStyle(
      inherit: false,
      color: color,
      fontSize: 13 * displayScale,
      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
    );
    return labelStyle == null ? base : base.merge(labelStyle);
  }

  TextStyle _mergeBadgeTextStyle() {
    var style = TextStyle(
      inherit: false,
      color: const Color(0xFFFFFFFF),
      fontSize: 10 * displayScale,
      fontWeight: FontWeight.w700,
      height: 16 * displayScale / (10 * displayScale),
    );
    if (badgeStyle != null) {
      style = style.merge(badgeStyle);
    }
    if (isActive && activeBadgeStyle != null) {
      style = style.merge(activeBadgeStyle);
    }
    return style;
  }
}
