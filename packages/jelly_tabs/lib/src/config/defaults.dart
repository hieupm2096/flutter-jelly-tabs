import 'dart:ui';

import 'package:jelly_tabs/src/config/config.dart';
import 'package:jelly_tabs/src/config/spring_config.dart';

abstract final class DefaultJellyTabsLayout {
  static const iconSize = 28.0;
  static const itemHeight = 56.0;
  static const maskOverscanX = 48.0;
  static const maskOverscanY = 16.0;
  static const trackHeight = 64.0;
  static const trackInset = 4.0;
}

abstract final class DefaultJellyTabsColors {
  static const activeContent = Color(0xFF11100F);
  static const inactiveContent = Color(0xFFB8B4AD);
  static const selectedSurface = Color(0xFFF2EEE7);
  static const surface = Color(0xFF22211F);
}

abstract final class DefaultJellyTabsOpacity {
  static const activeContent = 1.0;
  static const inactiveContent = 1.0;
  static const selectedSurface = 1.0;
  static const surface = 1.0;
}

abstract final class DefaultPillJelly {
  static const pressedScale = 1.3;
  static const snapOnPointerDown = true;
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

  static const config = PillJellyConfig(
    pressedScale: pressedScale,
    snapOnPointerDown: snapOnPointerDown,
    frameConfig: frameConfig,
  );
}

abstract final class DefaultDistortion {
  static const pressedScale = 1.025;
  static const touchFeedback = TouchFeedbackConfig(
    middleOpacityRatio: 0.43,
    opacity: 0.15,
    radius: 150,
    scale: 2,
  );
  static const spring = DistortionSpringConfig(
    damping: 18,
    mass: 0.9,
    stiffness: 240,
  );
  static const verticalDrag = VerticalDragConfig(
    distortion: 0.08,
    distanceForMaxDistortion: 700,
    follow: 0.25,
    rubberBand: 0.14,
  );

  static const config = DistortionConfig(
    pressedScale: pressedScale,
    touchFeedback: touchFeedback,
    spring: spring,
    verticalDrag: verticalDrag,
  );
}
