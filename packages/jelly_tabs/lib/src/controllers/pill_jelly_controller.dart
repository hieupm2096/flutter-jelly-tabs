import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:jelly_tabs/src/config/config.dart';
import 'package:jelly_tabs/src/config/defaults.dart';
import 'package:jelly_tabs/src/controllers/distortion_controller.dart';
import 'package:jelly_tabs/src/math/animation_math.dart';
import 'package:jelly_tabs/src/math/pill_jelly_animation.dart';
import 'package:jelly_tabs/src/models/jelly_tabs_change_event.dart';
import 'package:jelly_tabs/src/models/jelly_tabs_item.dart';

/// Owns the jelly pill's frame loop and gesture state machine, ported from
/// `use-pill-jelly.ts`.
///
/// A [Ticker] steps [PillJellyFrameState] via [advancePillJellyFrame] on every
/// frame while the pill is animating, and stops after a 500ms idle settle. The
/// controller also forwards vertical drag/scale work to [DistortionController]
/// and resolves accepted tab presses into `onTabPress`/`onTabChange` callbacks.
class PillJellyController extends ChangeNotifier {
  /// Creates a [PillJellyController].
  PillJellyController({
    required List<JellyTabsItem> items,
    required TickerProvider vsync,
    JellyTabsConfig config = const JellyTabsConfig(
      layout: JellyTabsLayout(
        iconSize: 28,
        itemHeight: 56,
        maskOverscanX: 48,
        maskOverscanY: 16,
        trackHeight: 64,
        trackInset: 4,
      ),
      pillJelly: DefaultPillJelly.config,
      distortion: DefaultDistortion.config,
    ),
    int? selectedIndex,
    double displayScale = 1,
    this._recording = false,
    this._onTabPress,
    this._onTabChange,
  }) : _config = config,
       _items = items,
       _geometryScale = displayScale > 0 ? displayScale : 1 {
    final initialIndex = _getControlledSelectedIndex(
      selectedIndex,
      items.length,
    );
    _selectedIndex = initialIndex;
    final initialPosition = math.max(initialIndex, 0);
    _frameState = PillJellyFrameState()
      ..value = initialPosition.toDouble()
      ..targetValue = initialPosition.toDouble();

    _distortion = DistortionController(
      config: config.distortion,
      layout: config.layout,
      displayScale: _geometryScale,
      vsync: vsync,
    );
    _ticker = vsync.createTicker(_onTick);
  }

  final JellyTabsConfig _config;
  final List<JellyTabsItem> _items;
  final bool _recording;
  final bool? Function(JellyTabsChangeEvent event)? _onTabPress;
  final void Function(JellyTabsChangeEvent event)? _onTabChange;
  final double _geometryScale;

  late final DistortionController _distortion;
  late final PillJellyFrameState _frameState;
  late final Ticker _ticker;

  int _selectedIndex = 0;

  /// The currently selected tab index, or -1 when nothing is selected.
  int get selectedIndex => _selectedIndex;

  // Gesture state
  double _downX = 0;
  double _movedDistance = 0;
  double _dragStartTarget = 0;
  double _dragStartPanelOffset = 0;

  // Frame loop settle deadline (in ticker elapsed time)
  Duration? _idleDeadline;
  Duration? _lastElapsed;

  /// The measured track width in pixels.
  double get trackWidth => _distortion.trackWidth;
  double get _trackInset => _config.layout.trackInset * _geometryScale;
  double get _tabWidth => getTabWidth(trackWidth, _trackInset, _items.length);

  // Widget-facing style accessors
  /// The pill's horizontal translation in the overscan layer.
  Offset get pillMaskTranslation => Offset(_frameState.value * _tabWidth, 0);

  /// The pill's velocity-shear corrected horizontal scale.
  double get pillMaskScaleX => _getPillMaskScaleX();

  /// The pill's velocity-shear corrected vertical scale.
  double get pillMaskScaleY => _getPillMaskScaleY();

  /// The panel's horizontal micro-shift while dragging.
  double get panelOffset => getHorizontalPanelOffset(
    _frameState.rawPanelOffset,
    trackWidth,
    _geometryScale,
  );

  /// The selected tab content's press-inflation scale.
  double get activeItemScale => 1 + 0.2 * _frameState.pressProgress;

  /// The raw frame state, exposed for tests.
  @visibleForTesting
  PillJellyFrameState get frameState => _frameState;

  /// Whether the pill frame ticker is currently running.
  @visibleForTesting
  bool get isFrameLoopActive => _ticker.isActive;

  // Distortion passthroughs
  /// The distortion controller backing the vertical/scale animations.
  DistortionController get distortion => _distortion;

  /// The track's current vertical translation.
  double get translateY => _distortion.translateY;

  /// The track's current horizontal scale factor.
  double get distortionScaleX => _distortion.scaleX;

  /// The whole track's press-inflation scale.
  double get pressedScale => _distortion.pressedScale;

  /// The radial glow's current opacity.
  double get touchFeedbackOpacity => _distortion.touchFeedbackOpacity;

  /// The pointer's local Y, used to place the radial glow.
  double get pointerLocalY => _distortion.pointerLocalY;

  /// The X about which the track scales.
  double get transformOriginX => _distortion.transformOriginX;

  // Velocity-shear corrected scales for the pill
  double _getPillMaskScaleX() {
    final velocity = _frameState.filteredVelocity / 10;
    final scaleXCorrection = (velocity * 0.75).clamp(-0.2, 0.2);
    return _frameState.baseScaleX / (1 - scaleXCorrection);
  }

  double _getPillMaskScaleY() {
    final velocity = _frameState.filteredVelocity / 10;
    final scaleYCorrection = (velocity * 0.25).clamp(-0.2, 0.2);
    return _frameState.baseScaleY * (1 - scaleYCorrection);
  }

  void _onTick(Duration elapsed) {
    final lastElapsed = _lastElapsed;
    _lastElapsed = elapsed;
    final dtMs = lastElapsed == null
        ? 16
        : math.max((elapsed - lastElapsed).inMilliseconds, 1);
    advancePillJellyFrame(
      _frameState,
      _config.pillJelly.frameConfig,
      tabCount: _items.length,
      dtMs: dtMs,
    );
    final deadline = _idleDeadline;
    if (deadline != null && elapsed >= deadline) {
      _idleDeadline = null;
      _ticker.stop();
    }
    notifyListeners();
  }

  /// Mirrors RN's `setFrameLoopActive`: start the ticker immediately, or
  /// schedule it to stop after a 500ms settle delay. A new activation
  /// cancels a pending stop so the loop is never halted mid-gesture.
  void _setFrameLoopActive(bool active) {
    if (active) {
      _idleDeadline = null;
      if (!_ticker.isActive) {
        unawaited(_ticker.start());
      }
    } else {
      _idleDeadline =
          (_lastElapsed ?? Duration.zero) + const Duration(milliseconds: 500);
      if (!_ticker.isActive) {
        unawaited(_ticker.start());
      }
    }
  }

  /// Records the measured track width and passes it to the distortion layer.
  void setTrackWidth(double width) {
    _distortion.setTrackWidth(width);
    notifyListeners();
  }

  /// Pointer-down entry point. Snaps the target toward the touched tab when
  /// `snapOnPointerDown` is enabled, inflates the press, and starts the loop.
  void beginGesture(double localX, double localY, double absoluteX) {
    _distortion.begin(localX, localY, absoluteX);
    _downX = localX;
    _movedDistance = 0;

    if (_config.pillJelly.snapOnPointerDown && _tabWidth > 0) {
      _frameState.targetValue = ((localX - _trackInset) / _tabWidth)
          .floorToDouble()
          .clamp(0.0, getMaxTabIndex(_items.length).toDouble());
    }

    _dragStartTarget = _frameState.targetValue;
    _dragStartPanelOffset = _frameState.rawPanelOffset;
    _frameState.isDragging = 1;
    _frameState.releasePending = 0;
    _frameState.pressTarget = 1;
    _frameState.shapeTarget = _config.pillJelly.pressedScale;
    _setFrameLoopActive(true);
    notifyListeners();
  }

  /// Pointer-move entry point. Moves the pill target by the horizontal drag
  /// distance (or vertical when recording) and forwards the vertical
  /// translation to the distortion layer.
  void updateGesture(
    double horizontalTranslation,
    double verticalTranslation,
    double absoluteX,
    double localX,
  ) {
    final tabWidth = _tabWidth;
    if (tabWidth <= 0) return;

    final hTrans = _recording ? verticalTranslation : horizontalTranslation;
    final vTrans = _recording ? -horizontalTranslation : verticalTranslation;

    _frameState.targetValue = (_dragStartTarget + hTrans / tabWidth).clamp(
      0.0,
      getMaxTabIndex(_items.length).toDouble(),
    );
    _frameState.rawPanelOffset = _dragStartPanelOffset + hTrans;

    _distortion.update(vTrans, absoluteX, localX);
    _movedDistance = math.max(
      _movedDistance,
      math.max(hTrans.abs(), vTrans.abs()),
    );
    _setFrameLoopActive(true);
    notifyListeners();
  }

  /// Pointer-up entry point. Settles to the tapped tab (stationary) or the
  /// nearest tab (after a drag), releases the pill, and confirms the press.
  void finishGesture() {
    _frameState.isDragging = 0;

    final tabWidth = _tabWidth;
    int nextIndex;

    if (_movedDistance < 4 && tabWidth > 0) {
      nextIndex = ((_downX - _trackInset) / tabWidth).floor();
    } else {
      nextIndex = _frameState.targetValue.round();
    }

    nextIndex = nextIndex.clamp(0, getMaxTabIndex(_items.length));
    _frameState.targetValue = nextIndex.toDouble();
    _frameState.releasePending = 1;

    _distortion.end();

    if (_items.isNotEmpty) {
      _confirmTabPress(nextIndex);
    }

    _setFrameLoopActive(false);
    notifyListeners();
  }

  /// Selects a tab programmatically (e.g. from a semantics tap action).
  void activateTab(int index) {
    if (_items.isEmpty) return;

    final nextIndex = index.clamp(0, getMaxTabIndex(_items.length));
    _frameState.targetValue = nextIndex.toDouble();
    _frameState.releasePending = 1;
    _setFrameLoopActive(true);
    _setFrameLoopActive(false);
    _confirmTabPress(nextIndex);
    notifyListeners();
  }

  void _confirmTabPress(int index) {
    final item = _items[index];
    final event = JellyTabsChangeEvent(index: index, item: item);

    final accepted = _onTabPress?.call(event);
    if (accepted == false) {
      // The controlled prop will not change after a rejected press, so
      // restore the pill directly. Guard against restoring to an empty
      // selection (-1), which would otherwise animate toward tab 0.
      if (_selectedIndex >= 0) {
        _frameState.targetValue = _selectedIndex.toDouble();
      }
      _frameState.releasePending = 1;
      _frameState.pressTarget = 0;
      _frameState.shapeTarget = 1;
      return;
    }

    if (index != _selectedIndex) {
      _selectedIndex = index;
      _onTabChange?.call(event);
    }
  }

  /// Animates the pill toward an externally-controlled selection index.
  void setControlledSelectedIndex(int? selectedIndex) {
    final nextIndex = _getControlledSelectedIndex(
      selectedIndex,
      _items.length,
    );
    _selectedIndex = nextIndex;
    if (nextIndex >= 0) {
      _frameState.targetValue = nextIndex.toDouble();
    }
    _frameState.releasePending = 1;
    _frameState.pressTarget = 0;
    _frameState.shapeTarget = 1;
    _setFrameLoopActive(true);
    _setFrameLoopActive(false);
    notifyListeners();
  }

  int _getControlledSelectedIndex(int? selectedIndex, int tabCount) {
    if (selectedIndex == null || selectedIndex < 0 || tabCount == 0) {
      return -1;
    }
    return math.min(selectedIndex, getMaxTabIndex(tabCount));
  }

  @override
  void dispose() {
    _ticker.dispose();
    _distortion.dispose();
    super.dispose();
  }
}
