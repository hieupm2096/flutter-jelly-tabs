# Jelly Tabs

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A headless, jelly-animated tab bar for Flutter, ported from
[`react-native-jelly-tabs`](https://github.com/felipe-software/react-native-jelly-tabs)
with **zero runtime dependencies** — it depends only on the Flutter SDK.

The pill indicator snaps between tabs with a custom analytical damped-spring
physics engine, and supports drag-to-switch, press inflation, track distortion
on vertical drag, a radial touch-feedback glow, and per-tab accessibility.

## Installation 💻

Install via `flutter pub add`:

```sh
flutter pub add jelly_tabs
```

## Quick Start 🚀

Wire a `JellyTabBarHeadless` into any layout — it is router-independent, so
you drive the selected body yourself via `onTabChange`.

```dart
import 'package:flutter/material.dart';
import 'package:jelly_tabs/jelly_tabs.dart';

Widget _homeIcon(JellyTabsIconProps props) =>
    Icon(Icons.home, color: props.color, size: props.size);

Widget _searchIcon(JellyTabsIconProps props) =>
    Icon(Icons.search, color: props.color, size: props.size);

class MyTabs extends StatefulWidget {
  const MyTabs({super.key});

  @override
  State<MyTabs> createState() => _MyTabsState();
}

class _MyTabsState extends State<MyTabs> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(child: Text('Tab $_selectedIndex')),
            ),
            JellyTabBarHeadless(
              items: const [
                JellyTabsItem(
                  key: 'home',
                  label: 'Home',
                  activeIcon: _homeIcon,
                  inactiveIcon: _homeIcon,
                ),
                JellyTabsItem(
                  key: 'search',
                  label: 'Search',
                  badge: 3,
                  activeIcon: _searchIcon,
                  inactiveIcon: _searchIcon,
                ),
              ],
              onTabChange: (event) {
                setState(() => _selectedIndex = event.index);
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

See the [`example/`](../example) app for a live demo with a customization
showcase (`displayScale`, `maxWidth`, backdrops).

## API 📖

### `JellyTabBarHeadless`

The only widget you need. All parameters mirror the React Native component.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<JellyTabsItem>` | — (required) | The tabs to render. |
| `maxWidth` | `double` | `400` | Max width of the bar; centered when the parent is wider. |
| `selectedIndex` | `int?` | `null` | Controlled selection. `null` → uncontrolled (starts at tab 0); a negative value hides the pill. |
| `backdrop` | `Widget?` | `null` | Drawn behind the track surface. |
| `selectedBackdrop` | `Widget?` | `null` | Drawn behind the selected pill surface. |
| `colors` | `JellyTabsColorsOverride?` | `null` | Shallow partial overrides for the bar colors. |
| `opacity` | `JellyTabsOpacityOverride?` | `null` | Shallow partial overrides for the layer opacities. |
| `config` | `JellyTabsConfigOverride?` | `null` | Deep-partial overrides for layout, pill-jelly, and distortion config. |
| `displayScale` | `double` | `1` | Scales all geometry. |
| `onTabPress` | `bool? Function(JellyTabsChangeEvent)?` | `null` | Runs after every completed tap/drag; return `false` to reject the change and spring the pill back. |
| `onTabChange` | `void Function(JellyTabsChangeEvent)?` | `null` | Runs after an accepted selection change. |
| `onTabLongPress` | `void Function(JellyTabsChangeEvent)?` | `null` | Runs when a tab is long-pressed (≥500ms, ≤10px movement). |
| `touchFeedbackEnabled` | `bool` | `true` | Whether the radial press glow is rendered. |
| `touchFeedbackColor` | `Color?` | `null` | Overrides the glow color (defaults to `selectedSurface`). |
| `touchFeedbackOpacity` | `double?` | `null` | Overrides the glow's center opacity (defaults to `touchFeedback.opacity`). |
| `touchFeedbackScale` | `double?` | `null` | Overrides the glow's scale (defaults to `touchFeedback.scale`). |
| `recording` | `bool` | `false` | Swaps X/Y gesture axes for vertical-scroll recording demos. |

### `JellyTabsItem`

| Field | Type | Description |
| --- | --- | --- |
| `key` | `String` | Stable identifier. |
| `label` | `String` | Label shown under the icon. |
| `activeIcon` | `JellyTabsIconBuilder` | Builds the icon for the selected tab. |
| `inactiveIcon` | `JellyTabsIconBuilder` | Builds the icon for unselected tabs. |
| `accessibilityLabel` | `String?` | Overrides the semantics label (defaults to `label`). |
| `labelStyle` | `TextStyle?` | Merged over the base label style. |
| `badge` | `Object?` | A number or string shown in a pill anchored to the icon's top-right. |
| `badgeStyle` | `TextStyle?` | Style overrides for the badge text. |
| `testID` | `Key?` | A key for tests. |

`JellyTabsIconBuilder` is `Widget Function(JellyTabsIconProps)`, and
`JellyTabsIconProps` carries the resolved `color`, `colors`, `opacity`, and
`size` so your icon render-function can mirror the RN `TabsIcon` signature.

### Configuration

`JellyTabsConfigOverride` is a deep partial — override only what you need and
the rest fall back to the defaults. `JellyTabsColorsOverride` and
`JellyTabsOpacityOverride` are shallow partials resolved as
`{...defaults, ...override}`.

```dart
JellyTabBarHeadless(
  items: items,
  colors: const JellyTabsColorsOverride(
    selectedSurface: Color(0xFFF59E0B),
    surface: Color(0xFF1C1917),
  ),
  config: const JellyTabsConfigOverride(
    layout: JellyTabsLayoutOverride(trackHeight: 72),
    pillJelly: PillJellyConfigOverride(pressedScale: 1.4),
  ),
)
```

`resolveJellyTabsConfig([override])` returns the fully-resolved
`JellyTabsConfig`. Defaults (verbatim from the RN source — see
`docs/design.md` §5.5 for the full table): `iconSize 28`, `itemHeight 56`,
`trackHeight 64`, `trackInset 4`, `maskOverscanX 48`, `maskOverscanY 16`,
`colors {activeContent #11100F, inactiveContent #B8B4AD, selectedSurface
#F2EEE7, surface #22211F}`, `opacity {all 1}`, `pillJelly {pressedScale 1.3,
snapOnPointerDown true, frameConfig.releaseDistanceFraction 0.025, springs
panel {300,1}, press {1000,1}, scaleX {250,0.6}, scaleY {250,0.7}, value
{1000,1}, velocity {300,0.5}}`, and `distortion {pressedScale 1.025,
touchFeedback {middleOpacityRatio 0.43, opacity 0.15, radius 150, scale 2},
spring {damping 18, mass 0.9, stiffness 240}, verticalDrag {distortion 0.08,
distanceForMaxDistortion 700, follow 0.25, rubberBand 0.14}}`.

## Accessibility ♿

Each tab exposes a single `Semantics` node (`role: tab`, `selected`, label,
`focusable`/`focused`) — screen readers announce the label, position, and
selection state, and a semantics tap action selects the tab. On desktop/web the
bar is fully keyboard-operable: Tab/arrow keys move focus between tabs in item
order, and Enter/Space selects the focused tab through the same
`activateTab(index)` path as a tap. A theme-derived focus ring
(`Theme.of(context).focusColor`) shows the focused tab.

## Testing 🧪

```sh
flutter test
```

Golden tests are tagged `TestTag.golden`; regenerate with
`flutter test --update-goldens`.

## License 📄

MIT — see [LICENSE](LICENSE). The port is a from-scratch Dart
reimplementation of the MIT-licensed
[`react-native-jelly-tabs`](https://github.com/felipe-software/react-native-jelly-tabs).

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
