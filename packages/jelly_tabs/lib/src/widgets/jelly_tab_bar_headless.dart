import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:jelly_tabs/src/config/config.dart';
import 'package:jelly_tabs/src/config/defaults.dart';
import 'package:jelly_tabs/src/controllers/pill_jelly_controller.dart';
import 'package:jelly_tabs/src/gestures/jelly_tab_bar_gesture.dart';
import 'package:jelly_tabs/src/math/animation_math.dart';
import 'package:jelly_tabs/src/models/jelly_tabs_change_event.dart';
import 'package:jelly_tabs/src/models/jelly_tabs_item.dart';
import 'package:jelly_tabs/src/widgets/pill_masked_view.dart';
import 'package:jelly_tabs/src/widgets/tab_item.dart';
import 'package:jelly_tabs/src/widgets/touch_feedback.dart';

/// A headless, jelly-animated tab bar, ported from `react-native-jelly-tabs`'s
/// `JellyTabBarHeadless`.
///
/// Renders the track layers described in `architecture.md` §3.1 — surface,
/// touch feedback glow, inactive tabs, and the pill-revealed selected content —
/// driven by an internal [PillJellyController]. Gesture handling and the
/// accessibility row are layered on in `gestures/`.
class JellyTabBarHeadless extends StatefulWidget {
  /// Creates a [JellyTabBarHeadless].
  const JellyTabBarHeadless({
    required this.items,
    super.key,
    this.maxWidth = 400,
    this.selectedIndex,
    this.backdrop,
    this.selectedBackdrop,
    this.colors,
    this.opacity,
    this.config,
    this.displayScale = 1,
    this.onTabPress,
    this.onTabChange,
    this.onTabLongPress,
    this.touchFeedbackEnabled = true,
    this.touchFeedbackColor,
    this.touchFeedbackOpacity,
    this.touchFeedbackScale,
    this.recording = false,
  });

  /// The tabs to render.
  final List<JellyTabsItem> items;

  /// Maximum width of the bar; it is centered when the parent is wider.
  final double maxWidth;

  /// The selected tab index. Null selects tab 0 in uncontrolled mode.
  final int? selectedIndex;

  /// An optional widget drawn behind the track surface.
  final Widget? backdrop;

  /// An optional widget drawn behind the selected pill surface.
  final Widget? selectedBackdrop;

  /// Shallow partial overrides for the tab bar colors.
  final JellyTabsColorsOverride? colors;

  /// Shallow partial overrides for the layer opacities.
  final JellyTabsOpacityOverride? opacity;

  /// Deep-partial overrides for layout, pill jelly, and distortion config.
  final JellyTabsConfigOverride? config;

  /// Scales all geometry; defaults to 1.
  final double displayScale;

  /// Runs after every completed tap or drag; returning false rejects the
  /// selection change and springs the pill back.
  final bool? Function(JellyTabsChangeEvent event)? onTabPress;

  /// Runs after an accepted selection change.
  final void Function(JellyTabsChangeEvent event)? onTabChange;

  /// Runs when a tab is long-pressed.
  final void Function(JellyTabsChangeEvent event)? onTabLongPress;

  /// Whether the radial press glow is rendered.
  final bool touchFeedbackEnabled;

  /// Overrides the glow color (defaults to `selectedSurface`).
  final Color? touchFeedbackColor;

  /// Overrides the glow's center opacity (defaults to `touchFeedback.opacity`).
  final double? touchFeedbackOpacity;

  /// Overrides the glow's scale (defaults to `touchFeedback.scale`).
  final double? touchFeedbackScale;

  /// Swaps X/Y gesture axes for vertical-scroll recording demos.
  final bool recording;

  @override
  State<JellyTabBarHeadless> createState() => _JellyTabBarHeadlessState();
}

class _JellyTabBarHeadlessState extends State<JellyTabBarHeadless>
    with TickerProviderStateMixin {
  late JellyTabsConfig _config;
  late JellyTabsColors _colors;
  late JellyTabsOpacity _opacity;
  late PillJellyController _controller;
  double _lastTrackWidth = double.nan;

  @override
  void initState() {
    super.initState();
    _resolveDerived();
    _controller = _createController();
  }

  @override
  void didUpdateWidget(JellyTabBarHeadless oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controlledChanged = oldWidget.selectedIndex != widget.selectedIndex;
    if (controlledChanged && widget.selectedIndex != null) {
      _controller.setControlledSelectedIndex(widget.selectedIndex);
    }

    final wasControlled = oldWidget.selectedIndex != null;
    final isControlled = widget.selectedIndex != null;
    final coreChanged =
        !identical(oldWidget.items, widget.items) ||
        oldWidget.displayScale != widget.displayScale ||
        oldWidget.recording != widget.recording ||
        wasControlled != isControlled;
    final configChanged = resolveJellyTabsConfig(widget.config) != _config;
    if (coreChanged || configChanged) {
      _controller.dispose();
      _resolveDerived();
      _controller = _createController();
    } else {
      final colorsChanged =
          oldWidget.colors?.activeContent != widget.colors?.activeContent ||
          oldWidget.colors?.inactiveContent != widget.colors?.inactiveContent ||
          oldWidget.colors?.selectedSurface != widget.colors?.selectedSurface ||
          oldWidget.colors?.surface != widget.colors?.surface;
      final opacityChanged =
          oldWidget.opacity?.activeContent != widget.opacity?.activeContent ||
          oldWidget.opacity?.inactiveContent !=
              widget.opacity?.inactiveContent ||
          oldWidget.opacity?.selectedSurface !=
              widget.opacity?.selectedSurface ||
          oldWidget.opacity?.surface != widget.opacity?.surface;
      if (colorsChanged || opacityChanged) {
        _resolveDerived();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resolveDerived() {
    _config = resolveJellyTabsConfig(widget.config);
    _colors = JellyTabsColors(
      activeContent:
          widget.colors?.activeContent ?? DefaultJellyTabsColors.activeContent,
      inactiveContent:
          widget.colors?.inactiveContent ??
          DefaultJellyTabsColors.inactiveContent,
      selectedSurface:
          widget.colors?.selectedSurface ??
          DefaultJellyTabsColors.selectedSurface,
      surface: widget.colors?.surface ?? DefaultJellyTabsColors.surface,
    );
    _opacity = JellyTabsOpacity(
      activeContent:
          widget.opacity?.activeContent ??
          DefaultJellyTabsOpacity.activeContent,
      inactiveContent:
          widget.opacity?.inactiveContent ??
          DefaultJellyTabsOpacity.inactiveContent,
      selectedSurface:
          widget.opacity?.selectedSurface ??
          DefaultJellyTabsOpacity.selectedSurface,
      surface: widget.opacity?.surface ?? DefaultJellyTabsOpacity.surface,
    );
  }

  PillJellyController _createController() {
    final isUncontrolled = widget.selectedIndex == null;
    return PillJellyController(
      items: widget.items,
      vsync: this,
      config: _config,
      selectedIndex: isUncontrolled ? 0 : widget.selectedIndex,
      displayScale: widget.displayScale,
      recording: widget.recording,
      onTabPress: (event) => widget.onTabPress?.call(event),
      onTabChange: (event) => widget.onTabChange?.call(event),
    );
  }

  void _scheduleTrackWidth(double width) {
    if (width == _lastTrackWidth) return;
    _lastTrackWidth = width;
    final controller = _controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && identical(controller, _controller)) {
        controller.setTrackWidth(width);
      }
    });
  }

  double get _geometryScale =>
      widget.displayScale > 0 ? widget.displayScale : 1;

  @override
  Widget build(BuildContext context) {
    final geometryScale = _geometryScale;
    final trackHeight = _config.layout.trackHeight * geometryScale;
    final itemHeight = _config.layout.itemHeight * geometryScale;
    final trackInset = _config.layout.trackInset * geometryScale;
    final iconSize = _config.layout.iconSize * geometryScale;

    final inactiveTabs = _buildInactiveTabsRow(
      trackInset: trackInset,
      iconSize: iconSize,
      itemHeight: itemHeight,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, widget.maxWidth);
        _scheduleTrackWidth(width);
        return Center(
          child: SizedBox(
            width: widget.maxWidth,
            height: trackHeight,
            child: JellyTabBarGestureDetector(
              controller: _controller,
              recording: widget.recording,
              trackInset: trackInset,
              trackHeight: trackHeight,
              tabCount: widget.items.length,
              onTabLongPress: widget.onTabLongPress == null
                  ? null
                  : _handleTabLongPress,
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  _controller,
                  _controller.distortion,
                ]),
                builder: (context, _) {
                  return _buildTrack(
                    trackHeight: trackHeight,
                    itemHeight: itemHeight,
                    trackInset: trackInset,
                    geometryScale: geometryScale,
                    width: width,
                    inactiveTabs: inactiveTabs,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrack({
    required double trackHeight,
    required double itemHeight,
    required double trackInset,
    required double geometryScale,
    required double width,
    required Widget inactiveTabs,
  }) {
    final maskOverscanX = _config.layout.maskOverscanX * geometryScale;
    final maskOverscanY = _config.layout.maskOverscanY * geometryScale;
    final trackWidth = _controller.trackWidth;
    final tabCount = widget.items.length;
    final tabWidth = getTabWidth(trackWidth, trackInset, tabCount);
    final pillVisible = _controller.selectedIndex >= 0 && tabCount > 0;

    final tfConfig = _config.distortion.touchFeedback;
    final centerOpacity = (widget.touchFeedbackOpacity ?? tfConfig.opacity)
        .clamp(0.0, 1.0);
    final radius =
        tfConfig.radius *
        math.max(widget.touchFeedbackScale ?? tfConfig.scale, 0) *
        geometryScale;
    final tfColor = widget.touchFeedbackColor ?? _colors.selectedSurface;

    return Transform.scale(
      scale: _controller.pressedScale,
      child: Transform(
        alignment: Alignment.center,
        transform: _distortionTransform(trackWidth),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ExcludeSemantics(
              child: Transform.translate(
                offset: Offset(_controller.panelOffset, 0),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildSurface(trackHeight),
                    if (widget.touchFeedbackEnabled)
                      _buildTouchFeedback(
                        trackHeight: trackHeight,
                        centerOpacity: centerOpacity,
                        radius: radius,
                        color: tfColor,
                      ),
                    inactiveTabs,
                    _buildPill(
                      trackHeight: trackHeight,
                      itemHeight: itemHeight,
                      maskOverscanX: maskOverscanX,
                      maskOverscanY: maskOverscanY,
                      trackInset: trackInset,
                      tabWidth: tabWidth,
                      pillVisible: pillVisible,
                      centerOpacity: centerOpacity,
                      radius: radius,
                      color: tfColor,
                    ),
                  ],
                ),
              ),
            ),
            _buildSemanticsRow(
              trackInset: trackInset,
              trackHeight: trackHeight,
            ),
          ],
        ),
      ),
    );
  }

  void _handleTabLongPress(int index) {
    if (index < 0 || index >= widget.items.length) return;
    final item = widget.items[index];
    widget.onTabLongPress?.call(
      JellyTabsChangeEvent(index: index, item: item),
    );
  }

  Widget _buildSemanticsRow({
    required double trackInset,
    required double trackHeight,
  }) {
    final selectedIndex = _controller.selectedIndex;
    return Positioned.fill(
      child: IgnorePointer(
        child: Shortcuts(
          shortcuts: const {
            SingleActivator(
              LogicalKeyboardKey.arrowLeft,
            ): DirectionalFocusIntent(
              TraversalDirection.left,
            ),
            SingleActivator(
              LogicalKeyboardKey.arrowRight,
            ): DirectionalFocusIntent(
              TraversalDirection.right,
            ),
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: trackInset),
              child: Row(
                children: [
                  for (var index = 0; index < widget.items.length; index++)
                    Expanded(
                      child: _FocusableTab(
                        focusRadius: trackHeight / 2,
                        label:
                            widget.items[index].accessibilityLabel ??
                            widget.items[index].label,
                        selected: index == selectedIndex,
                        onActivate: () => _controller.activateTab(index),
                        onLongPress: widget.onTabLongPress == null
                            ? null
                            : () => _handleTabLongPress(index),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Matrix4 _distortionTransform(double trackWidth) {
    final halfWidth = trackWidth / 2;
    return Matrix4.identity()
      ..translateByDouble(
        _controller.transformOriginX - halfWidth,
        _controller.translateY,
        0,
        1,
      )
      ..scaleByDouble(_controller.distortionScaleX, 1, 1, 1)
      ..translateByDouble(halfWidth - _controller.transformOriginX, 0, 0, 1);
  }

  Widget _buildSurface(double trackHeight) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(trackHeight / 2),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.backdrop != null) widget.backdrop!,
          ColoredBox(
            color: _colors.surface.withValues(
              alpha: _opacity.surface.clamp(0.0, 1.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTouchFeedback({
    required double trackHeight,
    required double centerOpacity,
    required double radius,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(trackHeight / 2),
      child: Stack(
        fit: StackFit.expand,
        children: [
          TouchFeedback(
            translate: Offset(
              _controller.transformOriginX - radius,
              _controller.pointerLocalY - radius,
            ),
            diameter: radius * 2,
            centerOpacity: centerOpacity,
            middleOpacity:
                centerOpacity *
                _config.distortion.touchFeedback.middleOpacityRatio,
            color: color,
            opacity: _controller.touchFeedbackOpacity,
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveTabsRow({
    required double trackInset,
    required double iconSize,
    required double itemHeight,
  }) {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: trackInset),
        child: Row(
          children: [
            for (final item in widget.items)
              Expanded(
                child: _buildTab(
                  item,
                  isActive: false,
                  iconSize: iconSize,
                  itemHeight: itemHeight,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    JellyTabsItem item, {
    required bool isActive,
    required double iconSize,
    required double itemHeight,
  }) {
    return TabItem(
      text: item.label,
      colors: _colors,
      activeIcon: item.activeIcon,
      inactiveIcon: item.inactiveIcon,
      badge: item.badge,
      badgeStyle: item.badgeStyle,
      labelStyle: item.labelStyle,
      activeColor: _colors.activeContent,
      inactiveColor: _colors.inactiveContent,
      activeOpacity: _opacity.activeContent.clamp(0.0, 1.0),
      inactiveOpacity: _opacity.inactiveContent.clamp(0.0, 1.0),
      iconSize: iconSize,
      itemHeight: itemHeight,
      displayScale: _geometryScale,
      isActive: isActive,
    );
  }

  Widget _buildPill({
    required double trackHeight,
    required double itemHeight,
    required double maskOverscanX,
    required double maskOverscanY,
    required double trackInset,
    required double tabWidth,
    required bool pillVisible,
    required double centerOpacity,
    required double radius,
    required Color color,
  }) {
    final contentLeft = maskOverscanX + trackInset;
    final contentTop = maskOverscanY + trackInset;
    final iconSize = _config.layout.iconSize * _geometryScale;

    return Positioned(
      left: -maskOverscanX,
      right: -maskOverscanX,
      top: -maskOverscanY,
      bottom: -maskOverscanY,
      child: RepaintBoundary(
        child: PillMaskedView(
          visible: pillVisible,
          translationX: _controller.pillMaskTranslation.dx,
          scaleX: _controller.pillMaskScaleX,
          scaleY: _controller.pillMaskScaleY,
          tabWidth: tabWidth,
          itemHeight: itemHeight,
          left: contentLeft,
          top: contentTop,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.selectedBackdrop != null) widget.selectedBackdrop!,
              ColoredBox(
                color: _colors.selectedSurface.withValues(
                  alpha: _opacity.selectedSurface.clamp(0.0, 1.0),
                ),
              ),
              if (widget.touchFeedbackEnabled)
                Positioned(
                  left: maskOverscanX,
                  top: maskOverscanY,
                  child: TouchFeedback(
                    translate: Offset(
                      _controller.transformOriginX - radius,
                      _controller.pointerLocalY - radius,
                    ),
                    diameter: radius * 2,
                    centerOpacity: centerOpacity,
                    middleOpacity:
                        centerOpacity *
                        _config.distortion.touchFeedback.middleOpacityRatio,
                    color: color,
                    opacity: _controller.touchFeedbackOpacity,
                  ),
                ),
              Positioned(
                left: contentLeft,
                right: contentLeft,
                top: contentTop,
                height: itemHeight,
                child: Row(
                  children: [
                    for (final item in widget.items)
                      Expanded(
                        child: Transform.scale(
                          scale: _controller.activeItemScale,
                          child: _buildTab(
                            item,
                            isActive: true,
                            iconSize: iconSize,
                            itemHeight: itemHeight,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps a single tab in keyboard focus support: a [Focus] node (traversal
/// order = item order), an [ActivateIntent] handler so Enter/Space select the
/// tab, and a theme-derived focus ring. Owns the tab's [Semantics] node so the
/// semantics tree exposes exactly one node per tab.
class _FocusableTab extends StatefulWidget {
  /// Creates a [_FocusableTab].
  const _FocusableTab({
    required this.label,
    required this.selected,
    required this.onActivate,
    required this.focusRadius,
    this.onLongPress,
  });

  /// The accessible label for the tab.
  final String label;

  /// Whether the tab is currently selected.
  final bool selected;

  /// Invoked when the tab is activated (tap or Enter/Space).
  final VoidCallback onActivate;

  /// Invoked on a long press, when configured.
  final VoidCallback? onLongPress;

  /// Corner radius of the focus ring.
  final double focusRadius;

  @override
  State<_FocusableTab> createState() => _FocusableTabState();
}

class _FocusableTabState extends State<_FocusableTab> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusColor = Theme.of(context).focusColor;
    return Actions(
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onActivate();
            return null;
          },
        ),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: (_) {
            widget.onActivate();
            return null;
          },
        ),
      },
      child: Focus(
        focusNode: _focusNode,
        includeSemantics: false,
        child: AnimatedBuilder(
          animation: _focusNode,
          builder: (context, child) {
            final focused = _focusNode.hasFocus;
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.focusRadius),
                border: focused
                    ? Border.all(color: focusColor, width: 2)
                    : null,
              ),
              child: Semantics(
                role: SemanticsRole.tab,
                label: widget.label,
                selected: widget.selected,
                focusable: true,
                focused: focused,
                onTap: widget.onActivate,
                onLongPress: widget.onLongPress,
                child: child,
              ),
            );
          },
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
