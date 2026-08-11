import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:jelly_tabs/src/config/config.dart';
import 'package:jelly_tabs/src/math/animation_math.dart';

/// Drives the track distortion on vertical drag, press inflation, and the
/// radial touch-feedback glow, ported from `use-distortion.ts`.
///
/// Horizontal drag is handled by `PillJellyController`; this controller only
/// owns the vertical/scale animations. During a gesture the vertical
/// translation and scaleX are applied as direct assignments (matching RN's
/// un-sprung `update`); on release everything springs back via
/// `distortion.spring` (`SpringSimulation`).
class DistortionController extends ChangeNotifier {
  /// Creates a [DistortionController].
  DistortionController({
    required this._config,
    required this._layout,
    required TickerProvider vsync,
    double displayScale = 1,
  }) : _geometryScale = displayScale > 0 ? displayScale : 1 {
    _translateYAnimation = AnimationController.unbounded(
      vsync: vsync,
    )..addListener(_onAnimate);
    _scaleXAnimation = AnimationController.unbounded(
      vsync: vsync,
      value: 1,
    )..addListener(_onAnimate);
    _pressedScaleAnimation = AnimationController.unbounded(
      vsync: vsync,
      value: 1,
    )..addListener(_onAnimate);
    _touchFeedbackOpacityAnimation = AnimationController.unbounded(
      vsync: vsync,
    )..addListener(_onAnimate);
  }

  final DistortionConfig _config;
  final JellyTabsLayout _layout;
  final double _geometryScale;

  late final AnimationController _translateYAnimation;
  late final AnimationController _scaleXAnimation;
  late final AnimationController _pressedScaleAnimation;
  late final AnimationController _touchFeedbackOpacityAnimation;

  /// The measured track width in pixels.
  double trackWidth = 0;

  /// The translateY captured when a drag begins, so a new drag compounds
  /// correctly instead of jumping.
  double dragOriginY = 0;

  /// The pointer's local Y, clamped to the track, used to place the glow.
  double pointerLocalY = 0;

  /// The X about which the track scales, clamped to the track.
  double transformOriginX = 0;

  /// The pointer's local X when the drag began.
  double pointerInitialLocalX = 0;

  /// The pointer's absolute X when the drag began.
  double pointerInitialAbsoluteX = 0;

  /// The current vertical translation of the track.
  double get translateY => _translateYAnimation.value;

  /// The current horizontal scale factor (1 = undistorted).
  double get scaleX => _scaleXAnimation.value;

  /// The current press inflation scale of the whole track.
  double get pressedScale => _pressedScaleAnimation.value;

  /// The current opacity of the radial glow (0 = hidden).
  double get touchFeedbackOpacity => _touchFeedbackOpacityAnimation.value;

  /// The track height in pixels, scaled by `displayScale`.
  double get trackHeight => _layout.trackHeight * _geometryScale;

  /// The vertical drag distance at which distortion saturates.
  double get distanceForMaxDistortion =>
      _config.verticalDrag.distanceForMaxDistortion * _geometryScale;

  /// The spring used for every settle animation.
  SpringDescription get springDescription => SpringDescription(
    mass: _config.spring.mass,
    stiffness: _config.spring.stiffness,
    damping: _config.spring.damping,
  );

  /// Called on pointer down. Cancels in-flight settle springs, captures the
  /// current translateY as the drag origin, and springs the press inflation
  /// values, matching `use-distortion.ts` `begin`.
  void begin(double localX, double localY, double absoluteX) {
    _translateYAnimation.stop();
    _scaleXAnimation.stop();

    dragOriginY = translateY;

    _springPressedScale(_config.pressedScale);
    _springTouchFeedbackOpacity(1);

    pointerInitialLocalX = localX;
    pointerInitialAbsoluteX = absoluteX;
    pointerLocalY = localY.clamp(0.0, trackHeight);
    transformOriginX = localX.clamp(0.0, trackWidth);

    notifyListeners();
  }

  /// Called each frame during a drag. Direct assignments (no spring),
  /// matching RN's un-sprung `update`.
  void update(double verticalTranslation, double absoluteX, [double? localX]) {
    final appliedTranslation =
        rubberBand(
          verticalTranslation,
          trackHeight,
          _config.verticalDrag.rubberBand,
        ) *
        _config.verticalDrag.follow;
    final progress =
        (verticalTranslation.abs() /
                distanceForMaxDistortion.clamp(0.0001, double.infinity))
            .clamp(0.0, 1.0);

    _translateYAnimation.value = dragOriginY + appliedTranslation;
    _scaleXAnimation.value = 1 - progress * _config.verticalDrag.distortion;
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

  /// Called on pointer up. Springs all values back to rest via
  /// `DistortionSpringConfig`, and resets [transformOriginX] once the scaleX
  /// spring finishes, matching `use-distortion.ts` `end`.
  void end() {
    _springTranslateY(0);
    _springScaleX(1);
    _springPressedScale(1);
    _springTouchFeedbackOpacity(0);

    notifyListeners();
  }

  /// Updates the measured track width and centers the scale origin.
  void setTrackWidth(double width) {
    trackWidth = width;
    transformOriginX = width / 2;
    notifyListeners();
  }

  void _onAnimate() {
    notifyListeners();
  }

  void _springPressedScale(double target) {
    unawaited(
      _pressedScaleAnimation.animateWith(
        SpringSimulation(
          springDescription,
          _pressedScaleAnimation.value,
          target,
          _pressedScaleAnimation.velocity,
        ),
      ),
    );
  }

  void _springTouchFeedbackOpacity(double target) {
    unawaited(
      _touchFeedbackOpacityAnimation.animateWith(
        SpringSimulation(
          springDescription,
          _touchFeedbackOpacityAnimation.value,
          target,
          _touchFeedbackOpacityAnimation.velocity,
        ),
      ),
    );
  }

  void _springTranslateY(double target) {
    unawaited(
      _translateYAnimation.animateWith(
        SpringSimulation(
          springDescription,
          _translateYAnimation.value,
          target,
          _translateYAnimation.velocity,
        ),
      ),
    );
  }

  void _springScaleX(double target) {
    unawaited(
      _scaleXAnimation
          .animateWith(
            SpringSimulation(
              springDescription,
              _scaleXAnimation.value,
              target,
              _scaleXAnimation.velocity,
            ),
          )
          .whenComplete(() {
            transformOriginX = trackWidth / 2;
            notifyListeners();
          }),
    );
  }

  @override
  void dispose() {
    _translateYAnimation.dispose();
    _scaleXAnimation.dispose();
    _pressedScaleAnimation.dispose();
    _touchFeedbackOpacityAnimation.dispose();
    super.dispose();
  }
}
