import 'package:example/home/view/color_customizer/fields.dart';
import 'package:example/home/view/color_customizer/palettes.dart';
import 'package:jelly_tabs/jelly_tabs.dart';
import 'package:url_launcher/url_launcher.dart';

const _githubUrl = 'https://github.com/felipe-software/react-native-jelly-tabs';

const _colorFields = <({String key, String label})>[
  (key: 'surface', label: 'Track'),
  (key: 'selectedSurface', label: 'Selected pill'),
  (key: 'activeContent', label: 'Active content'),
  (key: 'inactiveContent', label: 'Inactive content'),
];

const _springKeys = ['panel', 'press', 'scaleX', 'scaleY', 'value', 'velocity'];

const _touchFeedbackKeys = [
  'middleOpacityRatio',
  'opacity',
  'radius',
  'scale',
];

const _distortionSpringKeys = ['damping', 'mass', 'stiffness'];

const _verticalDragKeys = [
  'distortion',
  'distanceForMaxDistortion',
  'follow',
  'rubberBand',
];

/// The customization panel from the RN example, ported to the Flutter package.
///
/// Renders a header (Change bg / GitHub / Reset) and four collapsible
/// sections — Palette, Layout, Motion, Touch — whose controls call back into
/// the owning screen so the live `JellyTabBarHeadless` updates in real time.
class ColorCustomizer extends StatefulWidget {
  const ColorCustomizer({
    required this.blur,
    required this.colors,
    required this.config,
    required this.onBlurChange,
    required this.onColorsChange,
    required this.onConfigChange,
    required this.onOpacityChange,
    required this.onReset,
    required this.onShuffleBackground,
    required this.onTouchFeedbackColorChange,
    required this.opacity,
    required this.touchFeedbackColor,
    super.key,
  });

  final BlurConfig blur;
  final JellyTabsColors colors;
  final JellyTabsConfig config;
  final ValueChanged<BlurConfig> onBlurChange;
  final ValueChanged<JellyTabsColors> onColorsChange;
  final ValueChanged<JellyTabsConfig> onConfigChange;
  final ValueChanged<JellyTabsOpacity> onOpacityChange;
  final VoidCallback onReset;
  final VoidCallback onShuffleBackground;
  final ValueChanged<Color> onTouchFeedbackColorChange;
  final JellyTabsOpacity opacity;
  final Color touchFeedbackColor;

  @override
  State<ColorCustomizer> createState() => _ColorCustomizerState();
}

class _ColorCustomizerState extends State<ColorCustomizer> {
  String? _activePanel;

  void _togglePanel(String panel) {
    setState(() => _activePanel = _activePanel == panel ? null : panel);
  }

  void _updateLayout({
    double? iconSize,
    double? itemHeight,
    double? maskOverscanX,
    double? maskOverscanY,
    double? trackHeight,
    double? trackInset,
  }) {
    final layout = widget.config.layout;
    widget.onConfigChange(
      JellyTabsConfig(
        layout: JellyTabsLayout(
          iconSize: iconSize ?? layout.iconSize,
          itemHeight: itemHeight ?? layout.itemHeight,
          maskOverscanX: maskOverscanX ?? layout.maskOverscanX,
          maskOverscanY: maskOverscanY ?? layout.maskOverscanY,
          trackHeight: trackHeight ?? layout.trackHeight,
          trackInset: trackInset ?? layout.trackInset,
        ),
        pillJelly: widget.config.pillJelly,
        distortion: widget.config.distortion,
      ),
    );
  }

  void _updatePillJelly({
    double? pressedScale,
    bool? snapOnPointerDown,
    double? releaseDistanceFraction,
  }) {
    final pillJelly = widget.config.pillJelly;
    final frame = pillJelly.frameConfig;
    widget.onConfigChange(
      JellyTabsConfig(
        layout: widget.config.layout,
        pillJelly: PillJellyConfig(
          pressedScale: pressedScale ?? pillJelly.pressedScale,
          snapOnPointerDown: snapOnPointerDown ?? pillJelly.snapOnPointerDown,
          frameConfig: PillJellyFrameConfig(
            releaseDistanceFraction:
                releaseDistanceFraction ?? frame.releaseDistanceFraction,
            springs: frame.springs,
          ),
        ),
        distortion: widget.config.distortion,
      ),
    );
  }

  void _updateJellySpring(String spring, String key, double value) {
    final springs = widget.config.pillJelly.frameConfig.springs;
    final current = switch (spring) {
      'panel' => springs.panel,
      'press' => springs.press,
      'scaleX' => springs.scaleX,
      'scaleY' => springs.scaleY,
      'value' => springs.value,
      _ => springs.velocity,
    };
    final updated = SpringConfig(
      stiffness: key == 'stiffness' ? value : current.stiffness,
      dampingRatio: key == 'dampingRatio' ? value : current.dampingRatio,
    );
    widget.onConfigChange(
      JellyTabsConfig(
        layout: widget.config.layout,
        pillJelly: PillJellyConfig(
          pressedScale: widget.config.pillJelly.pressedScale,
          snapOnPointerDown: widget.config.pillJelly.snapOnPointerDown,
          frameConfig: PillJellyFrameConfig(
            releaseDistanceFraction:
                widget.config.pillJelly.frameConfig.releaseDistanceFraction,
            springs: PillJellySpringsConfig(
              panel: spring == 'panel' ? updated : springs.panel,
              press: spring == 'press' ? updated : springs.press,
              scaleX: spring == 'scaleX' ? updated : springs.scaleX,
              scaleY: spring == 'scaleY' ? updated : springs.scaleY,
              value: spring == 'value' ? updated : springs.value,
              velocity: spring == 'velocity' ? updated : springs.velocity,
            ),
          ),
        ),
        distortion: widget.config.distortion,
      ),
    );
  }

  void _updateDistortion(DistortionConfig distortion) {
    widget.onConfigChange(
      JellyTabsConfig(
        layout: widget.config.layout,
        pillJelly: widget.config.pillJelly,
        distortion: distortion,
      ),
    );
  }

  void _updateDistortionSpring(String key, double value) {
    final spring = widget.config.distortion.spring;
    _updateDistortion(
      DistortionConfig(
        pressedScale: widget.config.distortion.pressedScale,
        touchFeedback: widget.config.distortion.touchFeedback,
        spring: DistortionSpringConfig(
          damping: key == 'damping' ? value : spring.damping,
          mass: key == 'mass' ? value : spring.mass,
          stiffness: key == 'stiffness' ? value : spring.stiffness,
        ),
        verticalDrag: widget.config.distortion.verticalDrag,
      ),
    );
  }

  void _updateVerticalDrag(String key, double value) {
    final drag = widget.config.distortion.verticalDrag;
    _updateDistortion(
      DistortionConfig(
        pressedScale: widget.config.distortion.pressedScale,
        touchFeedback: widget.config.distortion.touchFeedback,
        spring: widget.config.distortion.spring,
        verticalDrag: VerticalDragConfig(
          distortion: key == 'distortion' ? value : drag.distortion,
          distanceForMaxDistortion: key == 'distanceForMaxDistortion'
              ? value
              : drag.distanceForMaxDistortion,
          follow: key == 'follow' ? value : drag.follow,
          rubberBand: key == 'rubberBand' ? value : drag.rubberBand,
        ),
      ),
    );
  }

  void _updateTouchFeedback(String key, double value) {
    final touchFeedback = widget.config.distortion.touchFeedback;
    _updateDistortion(
      DistortionConfig(
        pressedScale: widget.config.distortion.pressedScale,
        touchFeedback: TouchFeedbackConfig(
          middleOpacityRatio: key == 'middleOpacityRatio'
              ? value
              : touchFeedback.middleOpacityRatio,
          opacity: key == 'opacity' ? value : touchFeedback.opacity,
          radius: key == 'radius' ? value : touchFeedback.radius,
          scale: key == 'scale' ? value : touchFeedback.scale,
        ),
        spring: widget.config.distortion.spring,
        verticalDrag: widget.config.distortion.verticalDrag,
      ),
    );
  }

  void _updateColor(String key, Color color) {
    widget.onColorsChange(
      JellyTabsColors(
        activeContent: key == 'activeContent'
            ? color
            : widget.colors.activeContent,
        inactiveContent: key == 'inactiveContent'
            ? color
            : widget.colors.inactiveContent,
        selectedSurface: key == 'selectedSurface'
            ? color
            : widget.colors.selectedSurface,
        surface: key == 'surface' ? color : widget.colors.surface,
      ),
    );
  }

  void _updateOpacity(String key, double value) {
    widget.onOpacityChange(
      JellyTabsOpacity(
        activeContent: key == 'activeContent'
            ? value
            : widget.opacity.activeContent,
        inactiveContent: key == 'inactiveContent'
            ? value
            : widget.opacity.inactiveContent,
        selectedSurface: key == 'selectedSurface'
            ? value
            : widget.opacity.selectedSurface,
        surface: key == 'surface' ? value : widget.opacity.surface,
      ),
    );
  }

  Future<void> _openGithub() async {
    try {
      await launchUrl(Uri.parse(_githubUrl));
    } on Exception {
      // url_launcher may be unavailable on some test platforms.
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFCBD5E1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2E0F172A),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              child: Column(
                children: [
                  _buildPaletteSection(),
                  _buildLayoutSection(),
                  _buildMotionSection(),
                  _buildTouchSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'react-native-jelly-tabs',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontFamily: 'monospace',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.end,
            children: [
              _HeaderButton(
                icon: Icons.image,
                label: 'Change bg',
                onPressed: widget.onShuffleBackground,
              ),
              _HeaderButton(
                icon: Icons.code,
                label: 'GitHub',
                onPressed: _openGithub,
              ),
              _ResetButton(onPressed: widget.onReset),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaletteSection() {
    return AccordionSection(
      title: 'Palette',
      expanded: _activePanel == 'palette',
      onPress: () => _togglePanel('palette'),
      children: [
        _buildPaletteGrid(),
        Section(
          title: 'Color and opacity',
          children: [for (final field in _colorFields) _buildColorRow(field)],
        ),
        _buildTouchFeedbackSection(),
        Section(
          title: 'Backdrop blur',
          children: [
            _buildTwoColumn([
              NumberField(
                label: 'Track intensity',
                decimals: 0,
                min: 0,
                max: 100,
                step: 5,
                value: widget.blur.track,
                onChange: (track) => widget.onBlurChange(
                  BlurConfig(pill: widget.blur.pill, track: track),
                ),
              ),
              NumberField(
                label: 'Pill intensity',
                decimals: 0,
                min: 0,
                max: 100,
                step: 5,
                value: widget.blur.pill,
                onChange: (pill) => widget.onBlurChange(
                  BlurConfig(pill: pill, track: widget.blur.track),
                ),
              ),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _buildPaletteGrid() {
    final selected = widget.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * 0.18;
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final palette in kPalettes)
              Semantics(
                key: Key('palette-${palette.label}'),
                label: 'Apply ${palette.label} palette',
                button: true,
                selected: selected == palette.colors,
                child: InkWell(
                  onTap: () {
                    widget.onColorsChange(palette.colors);
                    widget.onOpacityChange(kThemeOpacity);
                    widget.onTouchFeedbackColorChange(
                      palette.colors.selectedSurface,
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: width,
                    height: 30,
                    decoration: BoxDecoration(
                      color: palette.selectedSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected == palette.colors
                            ? const Color(0xFF0F172A)
                            : palette.label == 'Mono'
                            ? const Color(0xFFCBD5E1)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildColorRow(({String key, String label}) field) {
    final color = _colorFor(field.key);
    final opacity = _opacityFor(field.key);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          _ColorPreview(color: color, opacity: opacity),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.label,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ColorHexInput(
                  key: Key('hex-${field.key}'),
                  label: field.label,
                  value: toHex(color),
                  onChange: (hex) => _updateColor(field.key, colorFromHex(hex)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 13,
            child: NumberField(
              label: 'Opacity',
              min: 0,
              max: 1,
              step: 0.05,
              value: opacity,
              onChange: (value) => _updateOpacity(field.key, value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTouchFeedbackSection() {
    final touchFeedback = widget.config.distortion.touchFeedback;
    return Section(
      title: 'Touch feedback',
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              _ColorPreview(
                color: widget.touchFeedbackColor,
                opacity: touchFeedback.opacity,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Color',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ColorHexInput(
                      label: 'Touch feedback',
                      value: toHex(widget.touchFeedbackColor),
                      onChange: (hex) =>
                          widget.onTouchFeedbackColorChange(colorFromHex(hex)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildTwoColumn([
          for (final key in _touchFeedbackKeys)
            NumberField(
              label: _touchFeedbackLabel(key),
              decimals: _touchFeedbackDecimals(key),
              min: 0,
              max: _touchFeedbackMax(key),
              step: _touchFeedbackStep(key),
              value: _touchFeedbackValue(key),
              onChange: (value) => _updateTouchFeedback(key, value),
            ),
        ]),
      ],
    );
  }

  Widget _buildLayoutSection() {
    final layout = widget.config.layout;
    return AccordionSection(
      title: 'Layout',
      expanded: _activePanel == 'layout',
      onPress: () => _togglePanel('layout'),
      children: [
        Section(
          title: 'Geometry',
          children: [
            _buildTwoColumn([
              NumberField(
                label: 'Icon size',
                decimals: 0,
                min: 8,
                max: 64,
                step: 1,
                value: layout.iconSize,
                onChange: (value) => _updateLayout(iconSize: value),
              ),
              NumberField(
                label: 'Item height',
                decimals: 0,
                min: 24,
                max: 120,
                step: 1,
                value: layout.itemHeight,
                onChange: (value) => _updateLayout(itemHeight: value),
              ),
              NumberField(
                label: 'Track height',
                decimals: 0,
                min: 32,
                max: 128,
                step: 1,
                value: layout.trackHeight,
                onChange: (value) => _updateLayout(trackHeight: value),
              ),
              NumberField(
                label: 'Track inset',
                decimals: 0,
                min: 0,
                max: 32,
                step: 1,
                value: layout.trackInset,
                onChange: (value) => _updateLayout(trackInset: value),
              ),
              NumberField(
                label: 'Mask overscan X',
                decimals: 0,
                min: 0,
                max: 160,
                step: 1,
                value: layout.maskOverscanX,
                onChange: (value) => _updateLayout(maskOverscanX: value),
              ),
              NumberField(
                label: 'Mask overscan Y',
                decimals: 0,
                min: 0,
                max: 80,
                step: 1,
                value: layout.maskOverscanY,
                onChange: (value) => _updateLayout(maskOverscanY: value),
              ),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _buildMotionSection() {
    final pillJelly = widget.config.pillJelly;
    return AccordionSection(
      title: 'Motion',
      expanded: _activePanel == 'motion',
      onPress: () => _togglePanel('motion'),
      children: [
        Section(
          title: 'Jelly behavior',
          children: [
            ToggleField(
              label: 'Snap on pointer down',
              value: pillJelly.snapOnPointerDown,
              onChange: (value) => _updatePillJelly(snapOnPointerDown: value),
            ),
            _buildTwoColumn([
              NumberField(
                label: 'Pressed scale',
                min: 0.5,
                max: 2,
                step: 0.05,
                value: pillJelly.pressedScale,
                onChange: (value) => _updatePillJelly(pressedScale: value),
              ),
              NumberField(
                label: 'Release distance',
                decimals: 3,
                min: 0,
                max: 1,
                step: 0.005,
                value: pillJelly.frameConfig.releaseDistanceFraction,
                onChange: (value) =>
                    _updatePillJelly(releaseDistanceFraction: value),
              ),
            ]),
          ],
        ),
        for (final spring in _springKeys)
          Section(
            title: '${_capitalize(spring)} spring',
            children: [
              _buildTwoColumn([
                NumberField(
                  label: 'Stiffness',
                  decimals: 0,
                  min: 1,
                  max: 3000,
                  step: 10,
                  value: _springValue(spring).stiffness,
                  onChange: (value) =>
                      _updateJellySpring(spring, 'stiffness', value),
                ),
                NumberField(
                  label: 'Damping ratio',
                  min: 0.05,
                  max: 2,
                  step: 0.05,
                  value: _springValue(spring).dampingRatio,
                  onChange: (value) =>
                      _updateJellySpring(spring, 'dampingRatio', value),
                ),
              ]),
            ],
          ),
      ],
    );
  }

  Widget _buildTouchSection() {
    final distortion = widget.config.distortion;
    return AccordionSection(
      title: 'Touch',
      expanded: _activePanel == 'touch',
      onPress: () => _togglePanel('touch'),
      children: [
        Section(
          title: 'Press transform',
          children: [
            _buildTwoColumn([
              NumberField(
                label: 'Pressed scale',
                min: 0.5,
                max: 1.5,
                step: 0.025,
                value: distortion.pressedScale,
                onChange: (value) => _updateDistortion(
                  DistortionConfig(
                    pressedScale: value,
                    touchFeedback: distortion.touchFeedback,
                    spring: distortion.spring,
                    verticalDrag: distortion.verticalDrag,
                  ),
                ),
              ),
            ]),
          ],
        ),
        Section(
          title: 'Distortion spring',
          children: [
            _buildTwoColumn([
              for (final key in _distortionSpringKeys)
                NumberField(
                  label: _capitalize(key),
                  decimals: key == 'mass' ? 2 : 0,
                  min: key == 'mass' ? 0.05 : 1,
                  max: key == 'mass' ? 10 : 2000,
                  step: key == 'mass' ? 0.1 : 5,
                  value: _distortionSpringValue(key),
                  onChange: (value) => _updateDistortionSpring(key, value),
                ),
            ]),
          ],
        ),
        Section(
          title: 'Vertical drag',
          children: [
            _buildTwoColumn([
              for (final key in _verticalDragKeys)
                NumberField(
                  label: _verticalDragLabel(key),
                  decimals: key == 'distanceForMaxDistortion' ? 0 : 2,
                  min: 0,
                  max: key == 'distanceForMaxDistortion' ? 2000 : 1,
                  step: key == 'distanceForMaxDistortion' ? 25 : 0.05,
                  value: _verticalDragValue(key),
                  onChange: (value) => _updateVerticalDrag(key, value),
                ),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _buildTwoColumn(List<Widget> children) {
    return Column(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(height: 6),
          children[index],
        ],
      ],
    );
  }

  Color _colorFor(String key) => switch (key) {
    'surface' => widget.colors.surface,
    'selectedSurface' => widget.colors.selectedSurface,
    'activeContent' => widget.colors.activeContent,
    _ => widget.colors.inactiveContent,
  };

  double _opacityFor(String key) => switch (key) {
    'surface' => widget.opacity.surface,
    'selectedSurface' => widget.opacity.selectedSurface,
    'activeContent' => widget.opacity.activeContent,
    _ => widget.opacity.inactiveContent,
  };

  SpringConfig _springValue(String spring) => switch (spring) {
    'panel' => widget.config.pillJelly.frameConfig.springs.panel,
    'press' => widget.config.pillJelly.frameConfig.springs.press,
    'scaleX' => widget.config.pillJelly.frameConfig.springs.scaleX,
    'scaleY' => widget.config.pillJelly.frameConfig.springs.scaleY,
    'value' => widget.config.pillJelly.frameConfig.springs.value,
    _ => widget.config.pillJelly.frameConfig.springs.velocity,
  };

  double _touchFeedbackValue(String key) => switch (key) {
    'middleOpacityRatio' =>
      widget.config.distortion.touchFeedback.middleOpacityRatio,
    'opacity' => widget.config.distortion.touchFeedback.opacity,
    'radius' => widget.config.distortion.touchFeedback.radius,
    _ => widget.config.distortion.touchFeedback.scale,
  };

  double _distortionSpringValue(String key) => switch (key) {
    'damping' => widget.config.distortion.spring.damping,
    'mass' => widget.config.distortion.spring.mass,
    _ => widget.config.distortion.spring.stiffness,
  };

  double _verticalDragValue(String key) => switch (key) {
    'distortion' => widget.config.distortion.verticalDrag.distortion,
    'distanceForMaxDistortion' =>
      widget.config.distortion.verticalDrag.distanceForMaxDistortion,
    'follow' => widget.config.distortion.verticalDrag.follow,
    _ => widget.config.distortion.verticalDrag.rubberBand,
  };

  String _capitalize(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';

  String _touchFeedbackLabel(String key) =>
      key == 'middleOpacityRatio' ? 'Middle opacity ratio' : _capitalize(key);

  String _verticalDragLabel(String key) => switch (key) {
    'distanceForMaxDistortion' => 'Max distortion distance',
    'rubberBand' => 'Rubber band',
    _ => _capitalize(key),
  };

  int _touchFeedbackDecimals(String key) => key == 'radius' ? 0 : 2;

  double _touchFeedbackMax(String key) =>
      key == 'radius' ? 400 : (key == 'scale' ? 5 : 1);

  double _touchFeedbackStep(String key) => key == 'radius' ? 5 : 0.05;
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: const Color(0xFFF8FAFC)),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE2E8F0),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            'Reset',
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorPreview extends StatelessWidget {
  const _ColorPreview({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFD4D4D8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: ColoredBox(color: color.withValues(alpha: opacity)),
      ),
    );
  }
}
