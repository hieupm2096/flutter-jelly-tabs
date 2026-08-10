import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:jelly_tabs/src/config/defaults.dart';
import 'package:jelly_tabs/src/config/spring_config.dart';

@immutable
class JellyTabsLayout {
  const JellyTabsLayout({
    required this.iconSize,
    required this.itemHeight,
    required this.maskOverscanX,
    required this.maskOverscanY,
    required this.trackHeight,
    required this.trackInset,
  });

  final double iconSize;
  final double itemHeight;
  final double maskOverscanX;
  final double maskOverscanY;
  final double trackHeight;
  final double trackInset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JellyTabsLayout &&
          iconSize == other.iconSize &&
          itemHeight == other.itemHeight &&
          maskOverscanX == other.maskOverscanX &&
          maskOverscanY == other.maskOverscanY &&
          trackHeight == other.trackHeight &&
          trackInset == other.trackInset;

  @override
  int get hashCode => Object.hash(
    iconSize,
    itemHeight,
    maskOverscanX,
    maskOverscanY,
    trackHeight,
    trackInset,
  );
}

@immutable
class JellyTabsLayoutOverride {
  const JellyTabsLayoutOverride({
    this.iconSize,
    this.itemHeight,
    this.maskOverscanX,
    this.maskOverscanY,
    this.trackHeight,
    this.trackInset,
  });

  final double? iconSize;
  final double? itemHeight;
  final double? maskOverscanX;
  final double? maskOverscanY;
  final double? trackHeight;
  final double? trackInset;
}

@immutable
class JellyTabsColors {
  const JellyTabsColors({
    required this.activeContent,
    required this.inactiveContent,
    required this.selectedSurface,
    required this.surface,
  });

  final Color activeContent;
  final Color inactiveContent;
  final Color selectedSurface;
  final Color surface;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JellyTabsColors &&
          activeContent == other.activeContent &&
          inactiveContent == other.inactiveContent &&
          selectedSurface == other.selectedSurface &&
          surface == other.surface;

  @override
  int get hashCode =>
      Object.hash(activeContent, inactiveContent, selectedSurface, surface);
}

@immutable
class JellyTabsColorsOverride {
  const JellyTabsColorsOverride({
    this.activeContent,
    this.inactiveContent,
    this.selectedSurface,
    this.surface,
  });

  final Color? activeContent;
  final Color? inactiveContent;
  final Color? selectedSurface;
  final Color? surface;
}

@immutable
class JellyTabsOpacity {
  const JellyTabsOpacity({
    required this.activeContent,
    required this.inactiveContent,
    required this.selectedSurface,
    required this.surface,
  });

  final double activeContent;
  final double inactiveContent;
  final double selectedSurface;
  final double surface;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JellyTabsOpacity &&
          activeContent == other.activeContent &&
          inactiveContent == other.inactiveContent &&
          selectedSurface == other.selectedSurface &&
          surface == other.surface;

  @override
  int get hashCode =>
      Object.hash(activeContent, inactiveContent, selectedSurface, surface);
}

@immutable
class JellyTabsOpacityOverride {
  const JellyTabsOpacityOverride({
    this.activeContent,
    this.inactiveContent,
    this.selectedSurface,
    this.surface,
  });

  final double? activeContent;
  final double? inactiveContent;
  final double? selectedSurface;
  final double? surface;
}

@immutable
class PillJellySpringsConfig {
  const PillJellySpringsConfig({
    required this.panel,
    required this.press,
    required this.scaleX,
    required this.scaleY,
    required this.value,
    required this.velocity,
  });

  final SpringConfig panel;
  final SpringConfig press;
  final SpringConfig scaleX;
  final SpringConfig scaleY;
  final SpringConfig value;
  final SpringConfig velocity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PillJellySpringsConfig &&
          panel == other.panel &&
          press == other.press &&
          scaleX == other.scaleX &&
          scaleY == other.scaleY &&
          value == other.value &&
          velocity == other.velocity;

  @override
  int get hashCode =>
      Object.hash(panel, press, scaleX, scaleY, value, velocity);
}

@immutable
class PillJellySpringsConfigOverride {
  const PillJellySpringsConfigOverride({
    this.panel,
    this.press,
    this.scaleX,
    this.scaleY,
    this.value,
    this.velocity,
  });

  final SpringConfig? panel;
  final SpringConfig? press;
  final SpringConfig? scaleX;
  final SpringConfig? scaleY;
  final SpringConfig? value;
  final SpringConfig? velocity;
}

@immutable
class PillJellyFrameConfig {
  const PillJellyFrameConfig({
    required this.releaseDistanceFraction,
    required this.springs,
  });

  final double releaseDistanceFraction;
  final PillJellySpringsConfig springs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PillJellyFrameConfig &&
          releaseDistanceFraction == other.releaseDistanceFraction &&
          springs == other.springs;

  @override
  int get hashCode => Object.hash(releaseDistanceFraction, springs);
}

@immutable
class PillJellyFrameConfigOverride {
  const PillJellyFrameConfigOverride({
    this.releaseDistanceFraction,
    this.springs,
  });

  final double? releaseDistanceFraction;
  final PillJellySpringsConfigOverride? springs;
}

@immutable
class PillJellyConfig {
  const PillJellyConfig({
    required this.pressedScale,
    required this.snapOnPointerDown,
    required this.frameConfig,
  });

  final double pressedScale;
  final bool snapOnPointerDown;
  final PillJellyFrameConfig frameConfig;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PillJellyConfig &&
          pressedScale == other.pressedScale &&
          snapOnPointerDown == other.snapOnPointerDown &&
          frameConfig == other.frameConfig;

  @override
  int get hashCode => Object.hash(pressedScale, snapOnPointerDown, frameConfig);
}

@immutable
class PillJellyConfigOverride {
  const PillJellyConfigOverride({
    this.pressedScale,
    this.snapOnPointerDown,
    this.frameConfig,
  });

  final double? pressedScale;
  final bool? snapOnPointerDown;
  final PillJellyFrameConfigOverride? frameConfig;
}

@immutable
class TouchFeedbackConfig {
  const TouchFeedbackConfig({
    required this.middleOpacityRatio,
    required this.opacity,
    required this.radius,
    required this.scale,
  });

  final double middleOpacityRatio;
  final double opacity;
  final double radius;
  final double scale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TouchFeedbackConfig &&
          middleOpacityRatio == other.middleOpacityRatio &&
          opacity == other.opacity &&
          radius == other.radius &&
          scale == other.scale;

  @override
  int get hashCode => Object.hash(middleOpacityRatio, opacity, radius, scale);
}

@immutable
class TouchFeedbackConfigOverride {
  const TouchFeedbackConfigOverride({
    this.middleOpacityRatio,
    this.opacity,
    this.radius,
    this.scale,
  });

  final double? middleOpacityRatio;
  final double? opacity;
  final double? radius;
  final double? scale;
}

@immutable
class VerticalDragConfig {
  const VerticalDragConfig({
    required this.distortion,
    required this.distanceForMaxDistortion,
    required this.follow,
    required this.rubberBand,
  });

  final double distortion;
  final double distanceForMaxDistortion;
  final double follow;
  final double rubberBand;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerticalDragConfig &&
          distortion == other.distortion &&
          distanceForMaxDistortion == other.distanceForMaxDistortion &&
          follow == other.follow &&
          rubberBand == other.rubberBand;

  @override
  int get hashCode =>
      Object.hash(distortion, distanceForMaxDistortion, follow, rubberBand);
}

@immutable
class VerticalDragConfigOverride {
  const VerticalDragConfigOverride({
    this.distortion,
    this.distanceForMaxDistortion,
    this.follow,
    this.rubberBand,
  });

  final double? distortion;
  final double? distanceForMaxDistortion;
  final double? follow;
  final double? rubberBand;
}

@immutable
class DistortionConfig {
  const DistortionConfig({
    required this.pressedScale,
    required this.touchFeedback,
    required this.spring,
    required this.verticalDrag,
  });

  final double pressedScale;
  final TouchFeedbackConfig touchFeedback;
  final DistortionSpringConfig spring;
  final VerticalDragConfig verticalDrag;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistortionConfig &&
          pressedScale == other.pressedScale &&
          touchFeedback == other.touchFeedback &&
          spring == other.spring &&
          verticalDrag == other.verticalDrag;

  @override
  int get hashCode =>
      Object.hash(pressedScale, touchFeedback, spring, verticalDrag);
}

@immutable
class DistortionConfigOverride {
  const DistortionConfigOverride({
    this.pressedScale,
    this.touchFeedback,
    this.spring,
    this.verticalDrag,
  });

  final double? pressedScale;
  final TouchFeedbackConfigOverride? touchFeedback;
  final DistortionSpringConfig? spring;
  final VerticalDragConfigOverride? verticalDrag;
}

@immutable
class JellyTabsConfig {
  const JellyTabsConfig({
    required this.layout,
    required this.pillJelly,
    required this.distortion,
  });

  final JellyTabsLayout layout;
  final PillJellyConfig pillJelly;
  final DistortionConfig distortion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JellyTabsConfig &&
          layout == other.layout &&
          pillJelly == other.pillJelly &&
          distortion == other.distortion;

  @override
  int get hashCode => Object.hash(layout, pillJelly, distortion);
}

@immutable
class JellyTabsConfigOverride {
  const JellyTabsConfigOverride({
    this.layout,
    this.pillJelly,
    this.distortion,
  });

  final JellyTabsLayoutOverride? layout;
  final PillJellyConfigOverride? pillJelly;
  final DistortionConfigOverride? distortion;
}

JellyTabsConfig resolveJellyTabsConfig([JellyTabsConfigOverride? override]) {
  final layoutOverride = override?.layout;
  final distortionOverride = override?.distortion;
  final pillJellyOverride = override?.pillJelly;
  final frameConfigOverride = pillJellyOverride?.frameConfig;
  final springsOverride = frameConfigOverride?.springs;
  final touchFeedbackOverride = distortionOverride?.touchFeedback;
  final verticalDragOverride = distortionOverride?.verticalDrag;

  return JellyTabsConfig(
    layout: JellyTabsLayout(
      iconSize: layoutOverride?.iconSize ?? DefaultJellyTabsLayout.iconSize,
      itemHeight:
          layoutOverride?.itemHeight ?? DefaultJellyTabsLayout.itemHeight,
      maskOverscanX:
          layoutOverride?.maskOverscanX ?? DefaultJellyTabsLayout.maskOverscanX,
      maskOverscanY:
          layoutOverride?.maskOverscanY ?? DefaultJellyTabsLayout.maskOverscanY,
      trackHeight:
          layoutOverride?.trackHeight ?? DefaultJellyTabsLayout.trackHeight,
      trackInset:
          layoutOverride?.trackInset ?? DefaultJellyTabsLayout.trackInset,
    ),
    pillJelly: PillJellyConfig(
      pressedScale:
          pillJellyOverride?.pressedScale ?? DefaultPillJelly.pressedScale,
      snapOnPointerDown:
          pillJellyOverride?.snapOnPointerDown ??
          DefaultPillJelly.snapOnPointerDown,
      frameConfig: PillJellyFrameConfig(
        releaseDistanceFraction:
            frameConfigOverride?.releaseDistanceFraction ??
            DefaultPillJelly.frameConfig.releaseDistanceFraction,
        springs: PillJellySpringsConfig(
          panel:
              springsOverride?.panel ??
              DefaultPillJelly.frameConfig.springs.panel,
          press:
              springsOverride?.press ??
              DefaultPillJelly.frameConfig.springs.press,
          scaleX:
              springsOverride?.scaleX ??
              DefaultPillJelly.frameConfig.springs.scaleX,
          scaleY:
              springsOverride?.scaleY ??
              DefaultPillJelly.frameConfig.springs.scaleY,
          value:
              springsOverride?.value ??
              DefaultPillJelly.frameConfig.springs.value,
          velocity:
              springsOverride?.velocity ??
              DefaultPillJelly.frameConfig.springs.velocity,
        ),
      ),
    ),
    distortion: DistortionConfig(
      pressedScale:
          distortionOverride?.pressedScale ?? DefaultDistortion.pressedScale,
      touchFeedback: TouchFeedbackConfig(
        middleOpacityRatio:
            touchFeedbackOverride?.middleOpacityRatio ??
            DefaultDistortion.touchFeedback.middleOpacityRatio,
        opacity:
            touchFeedbackOverride?.opacity ??
            DefaultDistortion.touchFeedback.opacity,
        radius:
            touchFeedbackOverride?.radius ??
            DefaultDistortion.touchFeedback.radius,
        scale:
            touchFeedbackOverride?.scale ??
            DefaultDistortion.touchFeedback.scale,
      ),
      spring: distortionOverride?.spring ?? DefaultDistortion.spring,
      verticalDrag: VerticalDragConfig(
        distortion:
            verticalDragOverride?.distortion ??
            DefaultDistortion.verticalDrag.distortion,
        distanceForMaxDistortion:
            verticalDragOverride?.distanceForMaxDistortion ??
            DefaultDistortion.verticalDrag.distanceForMaxDistortion,
        follow:
            verticalDragOverride?.follow ??
            DefaultDistortion.verticalDrag.follow,
        rubberBand:
            verticalDragOverride?.rubberBand ??
            DefaultDistortion.verticalDrag.rubberBand,
      ),
    ),
  );
}
