import 'dart:math' as math;

import 'package:example/home/view/color_customizer/blur_view.dart';
import 'package:example/home/view/color_customizer/color_customizer.dart';
import 'package:example/home/view/color_customizer/config_helpers.dart';
import 'package:example/home/view/color_customizer/palettes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jelly_tabs/jelly_tabs.dart';

const _horizontalPadding = 16.0;
const _webTabBarMaxWidth = 400.0;
const _recordingMode = bool.fromEnvironment('RECORDING_MODE');

Widget _homeIcon(JellyTabsIconProps props) =>
    Icon(Icons.home, color: props.color, size: props.size);

Widget _cameraIcon(JellyTabsIconProps props) =>
    Icon(Icons.photo_camera, color: props.color, size: props.size);

Widget _settingsIcon(JellyTabsIconProps props) =>
    Icon(Icons.settings, color: props.color, size: props.size);

Widget _wallsIcon(JellyTabsIconProps props) =>
    Icon(Icons.format_paint, color: props.color, size: props.size);

const _items = [
  JellyTabsItem(
    key: 'home',
    label: 'Home',
    activeIcon: _homeIcon,
    inactiveIcon: _homeIcon,
  ),
  JellyTabsItem(
    key: 'camera',
    label: 'Camera',
    activeIcon: _cameraIcon,
    inactiveIcon: _cameraIcon,
  ),
  JellyTabsItem(
    key: 'settings',
    label: 'Settings',
    activeIcon: _settingsIcon,
    inactiveIcon: _settingsIcon,
  ),
  JellyTabsItem(
    key: 'walls',
    label: 'Walls',
    activeIcon: _wallsIcon,
    inactiveIcon: _wallsIcon,
  ),
];

String _randomBackground(int width, int height) =>
    'https://picsum.photos/$width/$height?random=${math.Random().nextInt(1000000)}';

/// The single-screen demo, mirroring the reference example's `HomeScreen`: a
/// full-bleed background, a live [ColorCustomizer], and a [JellyTabBarHeadless]
/// with blurred backdrops driven by the customizer's state.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  JellyTabsColors _colors = kInitialColors;
  JellyTabsOpacity _opacity = kThemeOpacity;
  JellyTabsConfig _config = resolveJellyTabsConfig();
  BlurConfig _blur = kInitialBlur;
  Color _touchFeedbackColor = kInitialColors.selectedSurface;
  String? _backgroundUrl;

  void _shuffleBackground() {
    final size = MediaQuery.sizeOf(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    setState(() {
      _backgroundUrl = _randomBackground(
        (size.width * pixelRatio).round(),
        (size.height * pixelRatio).round(),
      );
    });
  }

  void _resetCustomization() {
    setState(() {
      _backgroundUrl = null;
      _blur = kInitialBlur;
      _colors = kInitialColors;
      _config = resolveJellyTabsConfig();
      _opacity = kThemeOpacity;
      _touchFeedbackColor = kInitialColors.selectedSurface;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _recordingMode
          ? const SystemUiOverlayStyle(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF11100F),
        body: Stack(
          children: [
            Positioned.fill(child: _buildBackground(context)),
            SafeArea(
              child: _recordingMode
                  ? _buildRecordingLayout(context)
                  : _buildStandardLayout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final url = _backgroundUrl;
    if (url == null) {
      return const _LocalBackground();
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const _LocalBackground(),
    );
  }

  Widget _buildStandardLayout(BuildContext context) {
    final customizer = _buildCustomizer();
    final tabBar = _buildTabBar();
    if (kIsWeb) {
      return Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Padding(
                padding: _tabBarAnimationRoom(),
                child: SizedBox(width: _webTabBarMaxWidth, child: tabBar),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            width: 360,
            child: SingleChildScrollView(child: customizer),
          ),
        ],
      );
    }
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: customizer,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            _config.layout.maskOverscanY,
            16,
            12 + _config.layout.maskOverscanY,
          ),
          child: tabBar,
        ),
      ],
    );
  }

  /// Breathing room around the tab bar so the pill overscan, press inflation,
  /// and track distortion are never clipped by the bounded width/height.
  EdgeInsets _tabBarAnimationRoom() {
    const margin = 24.0;
    return EdgeInsets.only(
      left: _config.layout.maskOverscanX + margin,
      right: _config.layout.maskOverscanX + margin,
      top: _config.layout.maskOverscanY + margin,
      bottom: _config.layout.maskOverscanY + margin,
    );
  }

  Widget _buildRecordingLayout(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final trackHeight = _config.layout.trackHeight;
    final defaultTrackWidth = math
        .max(
          0,
          size.width - _horizontalPadding * 2,
        )
        .toDouble();
    final recordingScale = defaultTrackWidth > 0
        ? math.min(
            size.height / defaultTrackWidth,
            size.width / trackHeight,
          )
        : 1.0;
    return Center(
      child: Transform.rotate(
        angle: -math.pi / 2,
        child: SizedBox(
          width: defaultTrackWidth * recordingScale,
          height: trackHeight * recordingScale,
          child: _buildTabBar(
            displayScale: recordingScale,
            recording: true,
            maxWidth: defaultTrackWidth * recordingScale,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomizer() {
    return ColorCustomizer(
      blur: _blur,
      colors: _colors,
      config: _config,
      onBlurChange: (blur) => setState(() => _blur = blur),
      onColorsChange: (colors) => setState(() => _colors = colors),
      onConfigChange: (config) => setState(() => _config = config),
      onOpacityChange: (opacity) => setState(() => _opacity = opacity),
      onReset: _resetCustomization,
      onShuffleBackground: _shuffleBackground,
      onTouchFeedbackColorChange: (color) {
        setState(() => _touchFeedbackColor = color);
      },
      opacity: _opacity,
      touchFeedbackColor: _touchFeedbackColor,
    );
  }

  Widget _buildTabBar({
    double displayScale = 1,
    bool recording = false,
    double? maxWidth,
  }) {
    return JellyTabBarHeadless(
      items: _items,
      colors: JellyTabsColorsOverride(
        activeContent: _colors.activeContent,
        inactiveContent: _colors.inactiveContent,
        selectedSurface: _colors.selectedSurface,
        surface: _colors.surface,
      ),
      opacity: JellyTabsOpacityOverride(
        activeContent: _opacity.activeContent,
        inactiveContent: _opacity.inactiveContent,
        selectedSurface: _opacity.selectedSurface,
        surface: _opacity.surface,
      ),
      config: toConfigOverride(_config),
      displayScale: displayScale,
      recording: recording,
      maxWidth: maxWidth ?? 400,
      selectedIndex: _selectedIndex,
      touchFeedbackColor: _touchFeedbackColor,
      backdrop: BlurView(
        intensity: _blur.track,
        tint: Colors.black.withValues(alpha: 0.25),
      ),
      selectedBackdrop: BlurView(intensity: _blur.pill),
      onTabChange: (event) {
        debugPrint('Selected tab: ${event.item.key}');
        setState(() => _selectedIndex = event.index);
      },
    );
  }
}

/// Fallback background when no shuffled image is set (or a network image
/// fails to load). Mirrors the reference example's bundled
/// `color-lab-background.png`.
class _LocalBackground extends StatelessWidget {
  const _LocalBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1C1917),
            Color(0xFF292524),
            Color(0xFF451A03),
          ],
        ),
      ),
    );
  }
}
