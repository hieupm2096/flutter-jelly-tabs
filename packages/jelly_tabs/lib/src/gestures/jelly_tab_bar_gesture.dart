import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:jelly_tabs/src/controllers/pill_jelly_controller.dart';
import 'package:jelly_tabs/src/math/animation_math.dart';

/// Raw-pointer gesture layer for the tab bar, ported from the RN
/// `Gesture.Pan().minDistance(0)` + `Gesture.LongPress()` worklets.
///
/// Flutter's `GestureDetector` pan applies a touch-slop that breaks RN's
/// min-distance-0 semantics, so this uses a [Listener] with raw pointer events
/// (see `architecture.md` §6). Pointer down/move/up are forwarded to
/// [PillJellyController], and a 500ms long-press [Timer] (cancelled on >10px
/// movement or pointer up) fires [onTabLongPress] with the tab under the
/// pointer.
class JellyTabBarGestureDetector extends StatefulWidget {
  /// Creates a [JellyTabBarGestureDetector].
  const JellyTabBarGestureDetector({
    required this.controller,
    required this.recording,
    required this.trackInset,
    required this.trackHeight,
    required this.tabCount,
    required this.child,
    super.key,
    this.onTabLongPress,
  });

  /// The controller that owns the gesture state machine.
  final PillJellyController controller;

  /// Swaps X/Y gesture axes for vertical-scroll recording demos.
  final bool recording;

  /// Scaled track inset, used to map a pointer to its tab index.
  final double trackInset;

  /// Scaled track height, used as the recording local Y origin.
  final double trackHeight;

  /// Number of tabs, bounding the long-press index.
  final int tabCount;

  /// Runs with the index of the tab long-pressed.
  final void Function(int index)? onTabLongPress;

  /// The bar content wrapped by the [Listener].
  final Widget child;

  @override
  State<JellyTabBarGestureDetector> createState() =>
      _JellyTabBarGestureDetectorState();
}

class _JellyTabBarGestureDetectorState
    extends State<JellyTabBarGestureDetector> {
  Timer? _longPressTimer;
  int? _pointer;
  Offset _down = Offset.zero;
  double _maxMoveDistance = 0;

  @override
  void dispose() {
    _cancelLongPress();
    super.dispose();
  }

  double _localX(Offset position) =>
      widget.recording ? position.dy : position.dx;

  double _localY(Offset position) =>
      widget.recording ? widget.trackHeight / 2 : position.dy;

  double _absoluteX(PointerEvent event) =>
      widget.recording ? event.position.dy : event.position.dx;

  void _onPointerDown(PointerDownEvent event) {
    _pointer = event.pointer;
    _down = event.localPosition;
    _maxMoveDistance = 0;
    widget.controller.beginGesture(
      _localX(_down),
      _localY(_down),
      _absoluteX(event),
    );
    _startLongPressTimer();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer) return;
    final current = event.localPosition;
    final horizontalTranslation = current.dx - _down.dx;
    final verticalTranslation = current.dy - _down.dy;
    _maxMoveDistance = math.max(
      _maxMoveDistance,
      math.max(horizontalTranslation.abs(), verticalTranslation.abs()),
    );
    widget.controller.updateGesture(
      horizontalTranslation,
      verticalTranslation,
      _absoluteX(event),
      _localX(current),
    );
    if (_maxMoveDistance > 10) {
      _cancelLongPress();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _pointer) return;
    _cancelLongPress();
    widget.controller.finishGesture();
    _pointer = null;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _pointer) return;
    _cancelLongPress();
    widget.controller.finishGesture();
    _pointer = null;
  }

  void _startLongPressTimer() {
    _cancelLongPress();
    _longPressTimer = Timer(
      const Duration(milliseconds: 500),
      _handleLongPress,
    );
  }

  void _cancelLongPress() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  void _handleLongPress() {
    final onLongPress = widget.onTabLongPress;
    if (onLongPress == null || widget.tabCount <= 0) return;
    final tabWidth = getTabWidth(
      widget.controller.trackWidth,
      widget.trackInset,
      widget.tabCount,
    );
    if (tabWidth <= 0) return;
    final index = ((_localX(_down) - widget.trackInset) / tabWidth)
        .floor()
        .clamp(0, getMaxTabIndex(widget.tabCount));
    onLongPress(index);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: widget.child,
    );
  }
}
