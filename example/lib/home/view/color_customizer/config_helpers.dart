import 'package:jelly_tabs/jelly_tabs.dart';

/// Builds a fully-populated [JellyTabsConfigOverride] from a resolved
/// [JellyTabsConfig] so the customizer can pass the resolved config it holds
/// in state back to `JellyTabBarHeadless`.
JellyTabsConfigOverride toConfigOverride(JellyTabsConfig config) {
  final layout = config.layout;
  final pillJelly = config.pillJelly;
  final frame = pillJelly.frameConfig;
  final springs = frame.springs;
  final distortion = config.distortion;

  return JellyTabsConfigOverride(
    layout: JellyTabsLayoutOverride(
      iconSize: layout.iconSize,
      itemHeight: layout.itemHeight,
      maskOverscanX: layout.maskOverscanX,
      maskOverscanY: layout.maskOverscanY,
      trackHeight: layout.trackHeight,
      trackInset: layout.trackInset,
    ),
    pillJelly: PillJellyConfigOverride(
      pressedScale: pillJelly.pressedScale,
      snapOnPointerDown: pillJelly.snapOnPointerDown,
      frameConfig: PillJellyFrameConfigOverride(
        releaseDistanceFraction: frame.releaseDistanceFraction,
        springs: PillJellySpringsConfigOverride(
          panel: springs.panel,
          press: springs.press,
          scaleX: springs.scaleX,
          scaleY: springs.scaleY,
          value: springs.value,
          velocity: springs.velocity,
        ),
      ),
    ),
    distortion: DistortionConfigOverride(
      pressedScale: distortion.pressedScale,
      touchFeedback: TouchFeedbackConfigOverride(
        middleOpacityRatio: distortion.touchFeedback.middleOpacityRatio,
        opacity: distortion.touchFeedback.opacity,
        radius: distortion.touchFeedback.radius,
        scale: distortion.touchFeedback.scale,
      ),
      spring: distortion.spring,
      verticalDrag: VerticalDragConfigOverride(
        distortion: distortion.verticalDrag.distortion,
        distanceForMaxDistortion:
            distortion.verticalDrag.distanceForMaxDistortion,
        follow: distortion.verticalDrag.follow,
        rubberBand: distortion.verticalDrag.rubberBand,
      ),
    ),
  );
}
