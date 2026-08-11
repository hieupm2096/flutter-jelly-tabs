import 'dart:async';

import 'package:example/home/view/customization_page.dart';
import 'package:jelly_tabs/jelly_tabs.dart';

Widget _homeActive(JellyTabsIconProps props) =>
    Icon(Icons.home_filled, color: props.color, size: props.size);

Widget _homeInactive(JellyTabsIconProps props) =>
    Icon(Icons.home_outlined, color: props.color, size: props.size);

Widget _cameraActive(JellyTabsIconProps props) =>
    Icon(Icons.photo_camera, color: props.color, size: props.size);

Widget _cameraInactive(JellyTabsIconProps props) =>
    Icon(Icons.photo_camera_outlined, color: props.color, size: props.size);

Widget _settingsActive(JellyTabsIconProps props) =>
    Icon(Icons.settings, color: props.color, size: props.size);

Widget _settingsInactive(JellyTabsIconProps props) =>
    Icon(Icons.settings_outlined, color: props.color, size: props.size);

Widget _wallsActive(JellyTabsIconProps props) =>
    Icon(Icons.format_paint, color: props.color, size: props.size);

Widget _wallsInactive(JellyTabsIconProps props) =>
    Icon(Icons.format_paint_outlined, color: props.color, size: props.size);

const _items = [
  JellyTabsItem(
    key: 'home',
    label: 'Home',
    activeIcon: _homeActive,
    inactiveIcon: _homeInactive,
  ),
  JellyTabsItem(
    key: 'camera',
    label: 'Camera',
    badge: 3,
    activeIcon: _cameraActive,
    inactiveIcon: _cameraInactive,
  ),
  JellyTabsItem(
    key: 'settings',
    label: 'Settings',
    activeIcon: _settingsActive,
    inactiveIcon: _settingsInactive,
  ),
  JellyTabsItem(
    key: 'walls',
    label: 'Walls',
    activeIcon: _wallsActive,
    inactiveIcon: _wallsInactive,
  ),
];

const _resolvedColors = JellyTabsColors(
  activeContent: Color(0xFF451A03),
  inactiveContent: Color(0xFFA8A29E),
  selectedSurface: Color(0xFFF59E0B),
  surface: Color(0xFF1C1917),
);

const _bodyDescriptions = [
  'Home feed',
  'Camera roll',
  'Preferences',
  'Wall gallery',
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _openCustomization() {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const CustomizationPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Jelly Tabs',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Customization',
                    onPressed: _openCustomization,
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: JellyTabBarHeadless(
                items: _items,
                colors: const JellyTabsColorsOverride(
                  activeContent: Color(0xFF451A03),
                  inactiveContent: Color(0xFFA8A29E),
                  selectedSurface: Color(0xFFF59E0B),
                  surface: Color(0xFF1C1917),
                ),
                touchFeedbackColor: const Color(0xFFF59E0B),
                onTabChange: (event) {
                  setState(() => _selectedIndex = event.index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final item = _items[_selectedIndex];
    final icon = item.activeIcon(
      JellyTabsIconProps(
        color: _resolvedColors.selectedSurface,
        colors: _resolvedColors,
        opacity: 1,
        size: 56,
      ),
    );
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: 16),
          Text(
            _bodyDescriptions[_selectedIndex],
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
