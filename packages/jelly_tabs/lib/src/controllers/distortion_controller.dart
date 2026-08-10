import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:jelly_tabs/src/config/config.dart';
import 'package:jelly_tabs/src/math/animation_math.dart';

class DistortionController extends ChangeNotifier {
  DistortionController({
    required DistortionConfig config,
    required JellyTabsLayout layout,
    double displayScale = 1,
  })  : _config = config,
        _layout = layout,
        _geometryScale = displayScale > 0 ? displayScale : 1;

  final DistortionConfig _config;
  final JellyTabsLayout _layout;
  final double _geometryScale;

  // Track geometry
  double trackWidth = 0;

  // Animated state (read by widgets)
  double translateY = 0;
  double scaleX = 1;
  double pressedScale = 1;
  double touchFeedbackOpacity = 0;

  // Drag origin (for compounding drags)
  double dragOriginY = 0;

  // Pointer tracking
  double pointerLocalY = 0;
  double transformOriginX = 0;
  double pointerInitialLocalX = 0;
  double pointerInitialAbsoluteX = 0;

  double get trackHeight => _layout.trackHeight * _geometryScale;
  double get touchFeedbackRadius => _config.touchFeedback.radius;

  double get distanceForMaxDistortion =>
      _config.verticalDrag.distanceForMaxDistortion * _geometryScale;

  /// Returns the [SpringDescription] for distortion spring animations.
  SpringDescription get springDescription => SpringDescription(
        mass: _config.spring.mass,
        stiffness: _config.spring.stiffness,
        damping: _config.spring.damping,
      );

  /// Called on pointer down. Sets targets for spring-driven values.
  /// The caller is responsible for wiring these targets to
  /// [AnimationController.animateWith].
  double get beginPressedScaleTarget => _config.pressedScale;
  double get beginTouchFeedbackOpacityTarget => 1;

  void begin(double localX, double localY, double absoluteX) {
    dragOriginY = translateY;

    pressedScale = _config.pressedScale;
    touchFeedbackOpacity = 1;

    pointerInitialLocalX = localX;
    pointerInitialAbsoluteX = absoluteX;
    pointerLocalY = localY.clamp(0.0, trackHeight);
    transformOriginX = localX.clamp(0.0, trackWidth);

    notifyListeners();
  }

  /// Called each frame during a drag. Direct assignments (no spring).
  void update(double verticalTranslation, double absoluteX, [double? localX]) {
    final appliedTranslation = rubberBand(
              verticalTranslation,
              trackHeight,
              _config.verticalDrag.rubberBand,
            ) *
        _config.verticalDrag.follow;
    final progress = (verticalTranslation.abs() /
                distanceForMaxDistortion.clamp(0.0001, double.infinity))
            .clamp(0.0, 1.0);

    translateY = dragOriginY + appliedTranslation;
    scaleX = 1 - progress * _config.verticalDrag.distortion;
    transformOriginX = localX == null
        ? getPointerOrigin(
            absoluteX,
            trackWidth,
            pointerInitialAbsoluteX,
            pointerInitialLocalX,
          )
        : localX.clamp(0.0, trackWidth);

    notifyListeners();
  }

  /// Called on pointer up. Resets all values to rest.
  /// The caller is responsible for animating these via spring.
  double get endTranslateYTarget => 0;
  double get endScaleXTarget => 1;
  double get endPressedScaleTarget => 1;
  double get endTouchFeedbackOpacityTarget => 0;

  void end({bool onScaleXDone = false}) {
    translateY = 0;
    scaleX = 1;
    pressedScale = 1;
    touchFeedbackOpacity = 0;

    if (onScaleXDone) {
      transformOriginX = trackWidth / 2;
    }

    notifyListeners();
  }

  /// Sets the track width and centers the transform origin.
  void setTrackWidth(double width) {
    trackWidth = width;
    transformOriginX = width / 2;
    notifyListeners();
  }
}
