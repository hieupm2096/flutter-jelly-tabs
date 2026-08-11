# Example

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A demo app for the [`jelly_tabs`](../packages/jelly_tabs) package, mirroring the
[`react-native-jelly-tabs` example](https://github.com/felipe-software/react-native-jelly-tabs/tree/main/example).

---

## Getting Started 🚀

The app runs on iOS, Android, Web, macOS, and Windows.

```sh
# Run on your current device/simulator
$ flutter run

# Run for a specific target
$ flutter run -d chrome
```

The home screen is the single-screen "color lab" from the RN example:

- A full-bleed background image that can be shuffled with **Change bg**.
- A **ColorCustomizer** panel with collapsible **Palette**, **Layout**,
  **Motion**, and **Touch** sections — preset palettes, per-token color/opacity
  sliders, touch-feedback and backdrop-blur controls, geometry sliders, spring
  tuning, and distortion tuning. **Reset** restores the default amber look, and
  **GitHub** opens the upstream repository.
- A live `JellyTabBarHeadless` with `expo-blur`-style backdrop blur driven by
  the customizer state.

### Recording mode

Mirrors the RN example's `EXPO_PUBLIC_RECORDING_MODE` flag:

```sh
$ flutter run -d chrome --dart-define=RECORDING_MODE=true
```

In recording mode the customizer is hidden, the system bars are hidden, and the
tab bar is rotated 90° and scaled to fill the viewport.

---

## Running Tests 🧪

```sh
$ flutter test
```

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
