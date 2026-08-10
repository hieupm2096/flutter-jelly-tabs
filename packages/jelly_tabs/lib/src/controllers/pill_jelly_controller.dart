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

class PillJellyController extends ChangeNotifier {
  PillJellyController({
    required List<JellyTabsItem> items,
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
    bool recording = false,
    bool? Function(JellyTabsChangeEvent event)? onTabPress,
    void Function(JellyTabsChangeEvent event)? onTabChange,
    void Function(JellyTabsChangeEvent event)? onTabLongPress,
  })  : _config = config,
        _items = items,
        _recording = recording,
        _onTabPress = onTabPress,
        _onTabChange = onTabChange,
        _onTabLongPress = onTabLongPress,
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
    );
  }

  final JellyTabsConfig _config;
  final List<JellyTabsItem> _items;
  final bool _recording;
  final bool? Function(JellyTabsChangeEvent event)? _onTabPress;
  final void Function(JellyTabsChangeEvent event)? _onTabChange;
  final void Function(JellyTabsChangeEvent event)? _onTabLongPress;
  final double _geometryScale;

  late final DistortionController _distortion;
  late final PillJellyFrameState _frameState;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  // Gesture state
  double _downX = 0;
  double _movedDistance = 0;
  double _dragStartTarget = 0;
  double _dragStartPanelOffset = 0;

  // Ticker
  Ticker? _ticker;

  double get trackWidth => _distortion.trackWidth;
  double get _trackInset => _config.layout.trackInset * _geometryScale;
  double get _tabWidth =>
      getTabWidth(trackWidth, _trackInset, _items.length);

  // Widget-facing style accessors
  Offset get pillMaskTranslation =>
      Offset(_frameState.value * _tabWidth, 0);
  double get pillMaskScaleX => _getPillMaskScaleX();
  double get pillMaskScaleY => _getPillMaskScaleY();
  double get panelOffset => getHorizontalPanelOffset(
        _frameState.rawPanelOffset,
        trackWidth,
        _geometryScale,
      );
  double get activeItemScale => 1 + 0.2 * _frameState.pressProgress;

  // Distortion passthroughs
  DistortionController get distortion => _distortion;
  double get translateY => _distortion.translateY;
  double get distortionScaleX => _distortion.scaleX;
  double get pressedScale => _distortion.pressedScale;
  double get touchFeedbackOpacity => _distortion.touchFeedbackOpacity;
  double get pointerLocalY => _distortion.pointerLocalY;
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

  void setTicker(Ticker ticker) {
    _ticker = ticker;
    ticker.start();
  }

  void _onTick(Duration elapsed) {
    advancePillJellyFrame(
      _frameState,
      _config.pillJelly.frameConfig,
      tabCount: _items.length,
      dtMs: 16, // Fixed 60fps timestep
    );
    notifyListeners();
  }

  void setTrackWidth(double width) {
    _distortion.setTrackWidth(width);
    notifyListeners();
  }

  void setTrackPosition(double pageX) {
    _webTrackPageX = pageX;
  }

  double _webTrackPageX = double.nan;

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
    _ticker?.start();
    notifyListeners();
  }

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

    _frameState.targetValue = (_dragStartTarget + hTrans / tabWidth)
        .clamp(0.0, getMaxTabIndex(_items.length).toDouble());
    _frameState.rawPanelOffset = _dragStartPanelOffset + hTrans;

    _distortion.update(vTrans, absoluteX, localX);
    _movedDistance = math.max(
      _movedDistance,
      math.max(hTrans.abs(), vTrans.abs()),
    );
    _ticker?.start();
    notifyListeners();
  }

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

    // Schedule ticker stop after 500ms settle
    Future.delayed(const Duration(milliseconds: 500), () {
      _ticker?.stop();
    });

    notifyListeners();
  }

  void activateTab(int index) {
    if (_items.isEmpty) return;

    final nextIndex = index.clamp(0, getMaxTabIndex(_items.length));
    _frameState.targetValue = nextIndex.toDouble();
    _frameState.releasePending = 1;
    _ticker?.start();
    Future.delayed(const Duration(milliseconds: 500), () {
      _ticker?.stop();
    });
    _confirmTabPress(nextIndex);
    notifyListeners();
  }

  void _confirmTabPress(int index) {
    final item = _items[index];
    final event = JellyTabsChangeEvent(index: index, item: item);

    final accepted = _onTabPress?.call(event);
    if (accepted == false) {
      _frameState.targetValue = _selectedIndex.toDouble();
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
    _ticker?.start();
    Future.delayed(const Duration(milliseconds: 500), () {
      _ticker?.stop();
    });
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
    _ticker?.stop();
    _ticker?.dispose();
    _distortion.dispose();
    super.dispose();
  }
}
