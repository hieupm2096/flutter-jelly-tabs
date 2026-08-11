import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:jelly_tabs/src/config/defaults.dart';
import 'package:jelly_tabs/src/config/spring_config.dart';

/// The layout geometry of the tab bar, mirroring RN's `TabBarLayout`.
@immutable
class JellyTabsLayout {
  /// Creates a [JellyTabsLayout].
  const JellyTabsLayout({
    required this.iconSize,
    required this.itemHeight,
    required this.maskOverscanX,
    required this.maskOverscanY,
    required this.trackHeight,
    required this.trackInset,
  });

  /// Icon size in logical pixels.
  final double iconSize;

  /// Per-tab height in logical pixels.
  final double itemHeight;

  /// Pill-mask horizontal overscan.
  final double maskOverscanX;

  /// Pill-mask vertical overscan.
  final double maskOverscanY;

  /// Track height in logical pixels.
  final double trackHeight;

  /// Track inset from the bar's edges.
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

/// Deep-partial override for [JellyTabsLayout]; every field is optional.
@immutable
class JellyTabsLayoutOverride {
  /// Creates a [JellyTabsLayoutOverride].
  const JellyTabsLayoutOverride({
    this.iconSize,
    this.itemHeight,
    this.maskOverscanX,
    this.maskOverscanY,
    this.trackHeight,
    this.trackInset,
  });

  /// See [JellyTabsLayout.iconSize].
  final double? iconSize;

  /// See [JellyTabsLayout.itemHeight].
  final double? itemHeight;

  /// See [JellyTabsLayout.maskOverscanX].
  final double? maskOverscanX;

  /// See [JellyTabsLayout.maskOverscanY].
  final double? maskOverscanY;

  /// See [JellyTabsLayout.trackHeight].
  final double? trackHeight;

  /// See [JellyTabsLayout.trackInset].
  final double? trackInset;
}

/// The resolved tab bar colors, mirroring RN's `TabBarColors`.
@immutable
class JellyTabsColors {
  /// Creates a [JellyTabsColors].
  const JellyTabsColors({
    required this.activeContent,
    required this.inactiveContent,
    required this.selectedSurface,
    required this.surface,
  });

  /// Color of the active icon and label.
  final Color activeContent;

  /// Color of the inactive icon and label.
  final Color inactiveContent;

  /// Color of the selected pill surface.
  final Color selectedSurface;

  /// Color of the track surface.
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

/// Shallow partial override for [JellyTabsColors]; every field is optional.
@immutable
class JellyTabsColorsOverride {
  /// Creates a [JellyTabsColorsOverride].
  const JellyTabsColorsOverride({
    this.activeContent,
    this.inactiveContent,
    this.selectedSurface,
    this.surface,
  });

  /// See [JellyTabsColors.activeContent].
  final Color? activeContent;

  /// See [JellyTabsColors.inactiveContent].
  final Color? inactiveContent;

  /// See [JellyTabsColors.selectedSurface].
  final Color? selectedSurface;

  /// See [JellyTabsColors.surface].
  final Color? surface;
}

/// The resolved layer opacities, mirroring RN's `TabBarOpacity`.
@immutable
class JellyTabsOpacity {
  /// Creates a [JellyTabsOpacity].
  const JellyTabsOpacity({
    required this.activeContent,
    required this.inactiveContent,
    required this.selectedSurface,
    required this.surface,
  });

  /// Opacity of the active icon and label.
  final double activeContent;

  /// Opacity of the inactive icon and label.
  final double inactiveContent;

  /// Opacity of the selected pill surface.
  final double selectedSurface;

  /// Opacity of the track surface.
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

/// Shallow partial override for [JellyTabsOpacity]; every field is optional.
@immutable
class JellyTabsOpacityOverride {
  /// Creates a [JellyTabsOpacityOverride].
  const JellyTabsOpacityOverride({
    this.activeContent,
    this.inactiveContent,
    this.selectedSurface,
    this.surface,
  });

  /// See [JellyTabsOpacity.activeContent].
  final double? activeContent;

  /// See [JellyTabsOpacity.inactiveContent].
  final double? inactiveContent;

  /// See [JellyTabsOpacity.selectedSurface].
  final double? selectedSurface;

  /// See [JellyTabsOpacity.surface].
  final double? surface;
}

/// The six springs used by the pill jelly frame stepping.
@immutable
class PillJellySpringsConfig {
  /// Creates a [PillJellySpringsConfig].
  const PillJellySpringsConfig({
    required this.panel,
    required this.press,
    required this.scaleX,
    required this.scaleY,
    required this.value,
    required this.velocity,
  });

  /// Panel micro-shift spring.
  final SpringConfig panel;

  /// Press inflation spring.
  final SpringConfig press;

  /// Pill horizontal scale spring.
  final SpringConfig scaleX;

  /// Pill vertical scale spring.
  final SpringConfig scaleY;

  /// Pill position spring.
  final SpringConfig value;

  /// Filtered velocity spring.
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

/// Deep-partial override for [PillJellySpringsConfig]; every field is optional.
@immutable
class PillJellySpringsConfigOverride {
  /// Creates a [PillJellySpringsConfigOverride].
  const PillJellySpringsConfigOverride({
    this.panel,
    this.press,
    this.scaleX,
    this.scaleY,
    this.value,
    this.velocity,
  });

  /// See [PillJellySpringsConfig.panel].
  final SpringConfig? panel;

  /// See [PillJellySpringsConfig.press].
  final SpringConfig? press;

  /// See [PillJellySpringsConfig.scaleX].
  final SpringConfig? scaleX;

  /// See [PillJellySpringsConfig.scaleY].
  final SpringConfig? scaleY;

  /// See [PillJellySpringsConfig.value].
  final SpringConfig? value;

  /// See [PillJellySpringsConfig.velocity].
  final SpringConfig? velocity;
}

/// Frame-stepping config for the pill jelly animation.
@immutable
class PillJellyFrameConfig {
  /// Creates a [PillJellyFrameConfig].
  const PillJellyFrameConfig({
    required this.releaseDistanceFraction,
    required this.springs,
  });

  /// Fraction of a tab the pill must settle within before deflating.
  final double releaseDistanceFraction;

  /// The six springs driving the frame state.
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

/// Deep-partial override for [PillJellyFrameConfig]; every field is optional.
@immutable
class PillJellyFrameConfigOverride {
  /// Creates a [PillJellyFrameConfigOverride].
  const PillJellyFrameConfigOverride({
    this.releaseDistanceFraction,
    this.springs,
  });

  /// See [PillJellyFrameConfig.releaseDistanceFraction].
  final double? releaseDistanceFraction;

  /// See [PillJellyFrameConfig.springs].
  final PillJellySpringsConfigOverride? springs;
}

/// The pill jelly physics config, mirroring RN's `PillJellyConfig`.
@immutable
class PillJellyConfig {
  /// Creates a [PillJellyConfig].
  const PillJellyConfig({
    required this.pressedScale,
    required this.snapOnPointerDown,
    required this.frameConfig,
  });

  /// Pill inflation scale while pressed.
  final double pressedScale;

  /// Whether pressing snaps the target toward the touched tab.
  final bool snapOnPointerDown;

  /// The frame-stepping config.
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

/// Deep-partial override for [PillJellyConfig]; every field is optional.
@immutable
class PillJellyConfigOverride {
  /// Creates a [PillJellyConfigOverride].
  const PillJellyConfigOverride({
    this.pressedScale,
    this.snapOnPointerDown,
    this.frameConfig,
  });

  /// See [PillJellyConfig.pressedScale].
  final double? pressedScale;

  /// See [PillJellyConfig.snapOnPointerDown].
  final bool? snapOnPointerDown;

  /// See [PillJellyConfig.frameConfig].
  final PillJellyFrameConfigOverride? frameConfig;
}

/// Config for the radial touch-feedback glow.
@immutable
class TouchFeedbackConfig {
  /// Creates a [TouchFeedbackConfig].
  const TouchFeedbackConfig({
    required this.middleOpacityRatio,
    required this.opacity,
    required this.radius,
    required this.scale,
  });

  /// Opacity of the gradient's middle stop relative to the center.
  final double middleOpacityRatio;

  /// Center opacity of the glow.
  final double opacity;

  /// Base radius in logical pixels.
  final double radius;

  /// Scale multiplier for the glow diameter.
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

/// Deep-partial override for [TouchFeedbackConfig]; every field is optional.
@immutable
class TouchFeedbackConfigOverride {
  /// Creates a [TouchFeedbackConfigOverride].
  const TouchFeedbackConfigOverride({
    this.middleOpacityRatio,
    this.opacity,
    this.radius,
    this.scale,
  });

  /// See [TouchFeedbackConfig.middleOpacityRatio].
  final double? middleOpacityRatio;

  /// See [TouchFeedbackConfig.opacity].
  final double? opacity;

  /// See [TouchFeedbackConfig.radius].
  final double? radius;

  /// See [TouchFeedbackConfig.scale].
  final double? scale;
}

/// Config for track distortion during a vertical drag.
@immutable
class VerticalDragConfig {
  /// Creates a [VerticalDragConfig].
  const VerticalDragConfig({
    required this.distortion,
    required this.distanceForMaxDistortion,
    required this.follow,
    required this.rubberBand,
  });

  /// Max horizontal scale reduction (1 - distortion).
  final double distortion;

  /// Vertical drag distance at which distortion saturates.
  final double distanceForMaxDistortion;

  /// Fraction of the rubber-banded translation applied to `translateY`.
  final double follow;

  /// Rubber-band factor for the vertical translation.
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

/// Deep-partial override for [VerticalDragConfig]; every field is optional.
@immutable
class VerticalDragConfigOverride {
  /// Creates a [VerticalDragConfigOverride].
  const VerticalDragConfigOverride({
    this.distortion,
    this.distanceForMaxDistortion,
    this.follow,
    this.rubberBand,
  });

  /// See [VerticalDragConfig.distortion].
  final double? distortion;

  /// See [VerticalDragConfig.distanceForMaxDistortion].
  final double? distanceForMaxDistortion;

  /// See [VerticalDragConfig.follow].
  final double? follow;

  /// See [VerticalDragConfig.rubberBand].
  final double? rubberBand;
}

/// The resolved distortion config, mirroring RN's `DistortionConfig`.
@immutable
class DistortionConfig {
  /// Creates a [DistortionConfig].
  const DistortionConfig({
    required this.pressedScale,
    required this.touchFeedback,
    required this.spring,
    required this.verticalDrag,
  });

  /// Whole-track press inflation scale.
  final double pressedScale;

  /// Radial touch-feedback glow config.
  final TouchFeedbackConfig touchFeedback;

  /// Physical spring for the settle animations.
  final DistortionSpringConfig spring;

  /// Vertical-drag distortion config.
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

/// Deep-partial override for [DistortionConfig]; every field is optional.
@immutable
class DistortionConfigOverride {
  /// Creates a [DistortionConfigOverride].
  const DistortionConfigOverride({
    this.pressedScale,
    this.touchFeedback,
    this.spring,
    this.verticalDrag,
  });

  /// See [DistortionConfig.pressedScale].
  final double? pressedScale;

  /// See [DistortionConfig.touchFeedback].
  final TouchFeedbackConfigOverride? touchFeedback;

  /// See [DistortionConfig.spring].
  final DistortionSpringConfig? spring;

  /// See [DistortionConfig.verticalDrag].
  final VerticalDragConfigOverride? verticalDrag;
}

/// The fully-resolved tab bar config (layout + pill jelly + distortion).
@immutable
class JellyTabsConfig {
  /// Creates a [JellyTabsConfig].
  const JellyTabsConfig({
    required this.layout,
    required this.pillJelly,
    required this.distortion,
  });

  /// The layout geometry.
  final JellyTabsLayout layout;

  /// The pill jelly physics.
  final PillJellyConfig pillJelly;

  /// The track distortion.
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

/// Deep-partial override for [JellyTabsConfig]; every field is optional.
@immutable
class JellyTabsConfigOverride {
  /// Creates a [JellyTabsConfigOverride].
  const JellyTabsConfigOverride({
    this.layout,
    this.pillJelly,
    this.distortion,
  });

  /// See [JellyTabsConfig.layout].
  final JellyTabsLayoutOverride? layout;

  /// See [JellyTabsConfig.pillJelly].
  final PillJellyConfigOverride? pillJelly;

  /// See [JellyTabsConfig.distortion].
  final DistortionConfigOverride? distortion;
}

/// Resolves a deep-partial [JellyTabsConfigOverride] against the defaults,
/// merging nested-object-per-key exactly like RN's `resolveTabBarConfig`.
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
