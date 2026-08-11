import 'dart:ui';

import 'package:jelly_tabs/src/config/config.dart';
import 'package:jelly_tabs/src/config/spring_config.dart';

/// The default layout geometry, transcribed verbatim from RN's
/// `TABBAR_LAYOUT` in `constants.ts`.
abstract final class DefaultJellyTabsLayout {
  /// Default icon size in logical pixels.
  static const iconSize = 28.0;

  /// Default per-tab height in logical pixels.
  static const itemHeight = 56.0;

  /// Default pill-mask horizontal overscan.
  static const maskOverscanX = 48.0;

  /// Default pill-mask vertical overscan.
  static const maskOverscanY = 16.0;

  /// Default track height in logical pixels.
  static const trackHeight = 64.0;

  /// Default track inset from the bar's edges.
  static const trackInset = 4.0;
}

/// The default tab bar colors, transcribed verbatim from RN's `TABBAR_COLORS`.
abstract final class DefaultJellyTabsColors {
  /// Default active content color.
  static const activeContent = Color(0xFF11100F);

  /// Default inactive content color.
  static const inactiveContent = Color(0xFFB8B4AD);

  /// Default selected pill surface color.
  static const selectedSurface = Color(0xFFF2EEE7);

  /// Default track surface color.
  static const surface = Color(0xFF22211F);
}

/// The default layer opacities, transcribed verbatim from RN's
/// `TABBAR_OPACITY`.
abstract final class DefaultJellyTabsOpacity {
  /// Default active content opacity.
  static const activeContent = 1.0;

  /// Default inactive content opacity.
  static const inactiveContent = 1.0;

  /// Default selected pill surface opacity.
  static const selectedSurface = 1.0;

  /// Default track surface opacity.
  static const surface = 1.0;
}

/// The default pill jelly physics, transcribed verbatim from RN's
/// `PILL_JELLY` in `constants.ts`.
abstract final class DefaultPillJelly {
  /// Default pill inflation scale while pressed.
  static const pressedScale = 1.3;

  /// Whether pressing snaps the target toward the touched tab.
  static const snapOnPointerDown = true;

  /// Default pill jelly frame config.
  static const frameConfig = PillJellyFrameConfig(
    releaseDistanceFraction: 0.025,
    springs: PillJellySpringsConfig(
      panel: SpringConfig(stiffness: 300, dampingRatio: 1),
      press: SpringConfig(stiffness: 1000, dampingRatio: 1),
      scaleX: SpringConfig(stiffness: 250, dampingRatio: 0.6),
      scaleY: SpringConfig(stiffness: 250, dampingRatio: 0.7),
      value: SpringConfig(stiffness: 1000, dampingRatio: 1),
      velocity: SpringConfig(stiffness: 300, dampingRatio: 0.5),
    ),
  );

  /// The fully-resolved default [PillJellyConfig].
  static const config = PillJellyConfig(
    pressedScale: pressedScale,
    snapOnPointerDown: snapOnPointerDown,
    frameConfig: frameConfig,
  );
}

/// The default track distortion, transcribed verbatim from RN's
/// `DISTORTION` in `constants.ts`.
abstract final class DefaultDistortion {
  /// Default whole-track press inflation scale.
  static const pressedScale = 1.025;

  /// Default radial touch-feedback glow config.
  static const touchFeedback = TouchFeedbackConfig(
    middleOpacityRatio: 0.43,
    opacity: 0.15,
    radius: 150,
    scale: 2,
  );

  /// Default distortion spring.
  static const spring = DistortionSpringConfig(
    damping: 18,
    mass: 0.9,
    stiffness: 240,
  );

  /// Default vertical-drag distortion config.
  static const verticalDrag = VerticalDragConfig(
    distortion: 0.08,
    distanceForMaxDistortion: 700,
    follow: 0.25,
    rubberBand: 0.14,
  );

  /// The fully-resolved default [DistortionConfig].
  static const config = DistortionConfig(
    pressedScale: pressedScale,
    touchFeedback: touchFeedback,
    spring: spring,
    verticalDrag: verticalDrag,
  );
}
