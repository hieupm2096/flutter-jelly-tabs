---
type: Design Document
title: flutter_jelly_tabs — Design
description: Specification for the flutter_jelly_tabs package — goals, scope decisions, feature-parity matrix, public API, defaults, behavior, and fidelity verification strategy.
tags: [flutter, design, jelly-tabs]
timestamp: 2026-08-08T00:00:00Z
---

# flutter_jelly_tabs — Design

> **Status:** Approved for docs. Package skeleton + implementation are deferred to a dedicated follow-up session.
> **Date:** 2026-08-08
> **Source of truth:** the reference jelly-tabs implementation
> (see `reference/`), pinned at commit
> [`67f47f2`](https://github.com/felipe-software/react-native-jelly-tabs/commit/67f47f2b5ef665eb7c6d9fd4a3427e346f25cbb8)
> (MIT licensed — confirmed compatible with a from-scratch Dart reimplementation). A read-only
> snapshot of the analyzed source files is vendored at `reference/react-native-jelly-tabs/` so
> later sessions can re-verify fidelity claims against ground truth instead of trusting these
> docs alone. See `docs/architecture.md` for module mapping.

## 1. Overview

`flutter_jelly_tabs` is a Flutter package that reimplements the jelly-like
animated tab bar — the same behavior, appearance, parameters, and configuration —
as a **headless widget** with **zero runtime dependencies**.

The port is built on Very Good Ventures' AI harness: the `vgv-ai-flutter-plugin` supplies the
standards (ui-package, testing, animations, accessibility, very_good_analysis), and
`vgv-wingspan` supplies the four-phase workflow (brainstorm → plan → build → review) that this
document set follows.

### 1.1 What the reference does

The reference is a tab bar where a **pill indicator** snaps between tabs with a
custom jelly physics engine, supports **drag-to-switch**, **press inflation**, **track
distortion on vertical drag**, and a **radial touch-feedback glow**. It ships two components:

- `JellyTabBar` — drop-in integration for React Navigation / Expo Router bottom tabs.
- `JellyTabBarHeadless` — router-independent component taking explicit `items` and selection.

It is implemented with Reanimated (per-frame spring worklets), Gesture Handler (Pan + LongPress),
and MaskedView (pill reveal).

## 2. Goals and Non-Goals

### Goals

- **Fidelity:** Match the reference's behavior, appearance, parameters, and configuration.
- **Headless package:** a reusable Flutter package (`jelly_tabs`) consumers embed in their apps.
- **Zero runtime deps:** the package depends only on the Flutter SDK.
- **Cross-platform:** identical visuals on Android, iOS, and Web.
- **VGV standards:** `very_good_analysis` lints, VGV testing conventions, doc-commented public API.

### Non-Goals (current phase)

- No React Navigation / GoRouter adapter (headless only — confirmed with user).
- No Bloc / state-management integration inside the package (plain Flutter + controllers).
- No native plugins or platform channels (no MaskedView equivalent exists; we use a pure-Flutter clip).
- No Flutter-side "recording" UI or color laboratory (the reference example's extras).
- No RTL/bidi mirroring (drag direction, pill motion, badge placement) — matches the reference source,
  which is LTR-only. Revisit if a consumer requests it.

## 3. Confirmed Scope Decisions

| Decision | Choice | Rationale |
| --- | --- | --- |
| Integration surface | `JellyTabBarHeadless` only | Consumers wire it into their own navigators |
| Spring fidelity | **Exact** reimplementation of the reference analytical solver | Same params and feel, pixel-for-pixel |
| Package architecture | Plain Flutter + controllers | A UI package must not force Bloc on consumers |
| Lints / tooling | `very_good_analysis`, Very Good CLI templates | VGV standard |
| Example app | Web + Android + iOS | Prove integration on every target |
| Session scope | Docs now; skeleton + implementation in later sessions | User-directed |

## 4. Feature Parity Matrix

| Reference Feature | Flutter Port | Notes |
| --- | --- | --- |
| Jelly pill snapping | `JellyTabBarHeadless` | Same spring solver |
| Drag-to-switch | Pan gesture → pointer tracking | Min-distance-0 semantics |
| Press inflation | `pressedScale` on pill | Spring-driven |
| Snap-on-pointer-down | Same | Same default `true` |
| Track distortion (vertical drag) | `DistortionController` | Reanimated `withSpring` → Flutter `SpringSimulation` |
| Radial touch feedback | `TouchFeedback` | Radial gradient (no SVG dependency) |
| Rejectable `onTabPress` | Same (`bool \| void` return) | Rejected presses restore prior pill |
| `onTabChange` / `onTabLongPress` | Same | |
| Controlled / uncontrolled `selectedIndex` | Same | External changes animate the pill |
| Badges | Same | Positioned label, `#FF3B30` default |
| `colors`, `opacity` shallow-partial | Same | Shallow `{...defaults, ...partial}` — separate from `config` |
| `config` deep-partial | Same | `resolveJellyTabsConfig` |
| `maxWidth`, `displayScale` | Same | |
| Backdrops (`backdrop`, `selectedBackdrop`) | `Widget?` slots | No blur provider bundled |
| Per-tab accessibility | `Semantics` | tab role, selected state, activate + longpress |
| `testID` | `Key`/`Semantics` | Dart uses `ValueKey` |
| Icon render-functions | `TabsIconBuilder` typedef | Mirrors `TabsIcon` component signature |
| Router integration (`JellyTabBar`) | **Omitted** | Headless-only (confirmed) |

## 5. Public API

All public API mirrors the reference package. Public types are prefixed to avoid collisions with
Material widgets. `lib/jelly_tabs.dart` is the single import point (barrel).

### 5.1 Widget

```dart
JellyTabBarHeadless({
  required List<JellyTabsItem> items,
  double maxWidth = 400,
  int? selectedIndex,                    // null → uncontrolled
  Widget? backdrop,
  Widget? selectedBackdrop,
  JellyTabsColorsOverride? colors,      // shallow partial; every field optional
  JellyTabsOpacityOverride? opacity,    // shallow partial; every field optional
  JellyTabsConfig? config,               // deep-partial override
  double displayScale = 1,
  bool? Function(JellyTabsChangeEvent)? onTabPress,   // false rejects
  void Function(JellyTabsChangeEvent)? onTabChange,
  void Function(JellyTabsChangeEvent)? onTabLongPress,
  bool touchFeedbackEnabled = true,
  Color? touchFeedbackColor,
  double? touchFeedbackOpacity,
  double? touchFeedbackScale,
  bool recording = false,
})
```

### 5.2 Item and icons

```dart
class JellyTabsItem {
  final String key;
  final String label;
  final JellyTabsIconBuilder activeIcon;
  final JellyTabsIconBuilder inactiveIcon;
  final String? accessibilityLabel;
  final TextStyle? labelStyle;
  final Object? badge;              // number or string
  final TextStyle? badgeStyle;
  final Key? testID;
}

typedef JellyTabsIconBuilder = Widget Function(JellyTabsIconProps props);

class JellyTabsIconProps {
  final Color color;        // resolved active/inactive content color
  final JellyTabsColors colors;
  final double opacity;     // resolved layer opacity
  final double size;        // resolved icon size
}
```

### 5.3 Events

```dart
class JellyTabsChangeEvent {
  final int index;
  final JellyTabsItem item;
}
```

### 5.4 Config (deep-partial)

```dart
// Full resolved types (mirrors reference constants.ts)
class JellyTabsLayout { iconSize, itemHeight, maskOverscanX, maskOverscanY, trackHeight, trackInset }
class JellyTabsColors { activeContent, inactiveContent, selectedSurface, surface }
class JellyTabsOpacity { activeContent, inactiveContent, selectedSurface, surface }
class SpringConfig { stiffness, dampingRatio }
class PillJellyFrameConfig { releaseDistanceFraction, springs: {panel, press, scaleX, scaleY, value, velocity} }
class PillJellyConfig { pressedScale, snapOnPointerDown, frameConfig }
class DistortionConfig { pressedScale, touchFeedback, spring, verticalDrag }
class JellyTabsConfig { layout, pillJelly, distortion }   // colors/opacity are NOT part of config

// Deep-partial variants (every field nullable) used by the public props.
class JellyTabsConfigOverride { JellyTabsLayoutOverride? layout; ... }
class JellyTabsColorsOverride { Color? activeContent; Color? inactiveContent; Color? selectedSurface; Color? surface; }
class JellyTabsOpacityOverride { double? activeContent; double? inactiveContent; double? selectedSurface; double? surface; }

JellyTabsConfig resolveJellyTabsConfig([JellyTabsConfigOverride? override]);

// colors and opacity are separate shallow overrides, NOT part of config —
// resolved as `{...defaults, ...partial}` exactly like reference tabs.tsx, which
// shallow-spreads Partial<TabBarColors> / Partial<TabBarOpacity>.
```

All resolved config classes (`JellyTabsConfig`, `JellyTabsColors`, `JellyTabsOpacity`, etc.) and
their `*Override` counterparts implement value equality (`==`/`hashCode`). Consumers routinely
construct these inline inside `build()`; without value equality, a freshly-constructed-but-equal
config would look "changed" on every rebuild and could trigger spurious animation/ticker resets.

### 5.5 Defaults (copied verbatim from the reference)

| Constant | Value |
| --- | --- |
| `layout.iconSize` | `28` |
| `layout.itemHeight` | `56` |
| `layout.trackHeight` | `64` |
| `layout.trackInset` | `4` |
| `layout.maskOverscanX` | `48` |
| `layout.maskOverscanY` | `16` |
| `colors.activeContent` | `Color(0xFF11100F)` |
| `colors.inactiveContent` | `Color(0xFFB8B4AD)` |
| `colors.selectedSurface` | `Color(0xFFF2EEE7)` |
| `colors.surface` | `Color(0xFF22211F)` |
| `opacity.*` | `1` |
| `pillJelly.pressedScale` | `1.3` |
| `pillJelly.snapOnPointerDown` | `true` |
| `pillJelly.frameConfig.releaseDistanceFraction` | `0.025` |
| `pillJelly.frameConfig.springs.*` | panel `{300, 1}`, press `{1000, 1}`, scaleX `{250, 0.6}`, scaleY `{250, 0.7}`, value `{1000, 1}`, velocity `{300, 0.5}` |
| `distortion.pressedScale` | `1.025` |
| `distortion.touchFeedback` | `{middleOpacityRatio: 0.43, opacity: 0.15, radius: 150, scale: 2}` |
| `distortion.spring` | `{damping: 18, mass: 0.9, stiffness: 240}` |
| `distortion.verticalDrag` | `{distortion: 0.08, distanceForMaxDistortion: 700, follow: 0.25, rubberBand: 0.14}` |

## 6. Behavior Spec

Behavior is ported 1:1 from `src/hooks/use-pill-jelly.ts`, `src/utils/pill-jelly-animation.ts`,
`src/utils/animation.ts`, and `src/hooks/use-distortion.ts`. The canonical list:

1. **Selection model.** Uncontrolled starts at index 0 (or none if `items` is empty). Controlled
   `selectedIndex` (>= 0) animates the pill to the matching tab on external change; `null`/negative
   renders no pill.
2. **Tap / press.** A stationary gesture on a tab selects it. `onTabPress` runs after every
   completed tap or drag (including re-tapping the selected tab); returning `false` rejects the
   change and springs the pill back to the previous selection. `onTabChange` fires only after an
   accepted change that differs from the current selection.
3. **Drag.** A horizontal drag moves the pill continuously; release settles to the nearest tab
   index. Vertical drag distorts the track width and (with `follow`) translates it vertically.
4. **Snap on pointer down.** When enabled, pressing snaps the target toward the touched tab
   immediately (`floor((localX - trackInset) / tabWidth)`).
5. **Press inflation.** While pressed, the pill scales toward `pillJelly.pressedScale` (default
   `1.3`) and the whole track scales toward `distortion.pressedScale` (default `1.025`).
6. **Jelly settle.** On release, the pill is kept inflated until its distance to the snap point is
   below `releaseDistanceFraction * max(1, maxTabIndex)` (i.e. 0.025 tabs for a 2-tab bar, 0.075 for
   a 4-tab bar — see `docs/architecture.md` §4.2), then springs back to scale 1 — the signature
   "jelly" release.
7. **Velocity shearing.** While dragging, the pill's horizontal velocity shears its shape
   (scaleX up / scaleY down) via `filteredVelocity` so the jelly stretches as it moves.
8. **Touch feedback.** A radial gradient glow fades in at the pointer during press and fades out on
   release. Color follows `colors.selectedSurface` unless `touchFeedbackColor` overrides.
9. **Panel micro-shift.** While dragging, the whole panel shifts horizontally up to `4 * displayScale`
   px (eased) so the bar "pulls" toward the pointer.
10. **Long press.** Holding a tab (>= 500ms, max 10px movement) fires `onTabLongPress`.
11. **Badges.** Rendered top-right of the icon; `number`/`string`; default red `#FF3B30`.
12. **Empty items.** Render an empty track with no pill; gestures no-op.
13. **Accessibility.** Each tab exposes tab semantics with selected state; activate → select tab;
    long-press accessibility action → `onTabLongPress`.

## 7. Fidelity Verification Strategy

Because the reference runs on Reanimated worklets, the strongest fidelity evidence is:

1. **Algorithm parity.** The Dart spring solver, frame stepping, `easeOut`, `rubberBand`, and tab
   geometry functions are transcribed line-by-line from the reference and unit-tested against
   hand-derived analytic values (critical / under / over-damped closed forms).
2. **Frame-sequence tests.** A fixed input sequence (press, drag, release) at a fixed timestep is
   replayed through the Dart engine; expected shared-value trajectories are asserted.
3. **Golden tests.** Appearance (rest state, pressed pill, selected state, badge) captured as goldens
   and diffed against reference screenshots of the demo where feasible.
4. **Visual QA.** The example app (web) serves as the parity surface; run the demo
   (https://jelly.felipe.software/) and the Flutter demo side-by-side during implementation.

## 8. Testing Strategy (VGV)

- **Unit:** `test/src/math/` (spring solver, easeOut, rubberBand, geometry), `test/src/controller/`.
- **Widget:** `test/src/widgets/` via a `pumpApp` helper — press/drag/long-press behavior, controlled
  vs uncontrolled selection, rejected press restore, badges, semantics.
- **Golden:** appearance across configs, tagged `TestTag.golden`.
- **Gates:** `very_good_analysis` (no issues), `dart format`, `flutter test` with coverage —
  **100%** on `lib/src/config/` and `lib/src/math/` (pure, deterministic, cheap to fully cover),
  **90%+** package-wide — `flutter test --platform chrome` for web parity (as configured).
- **Example:** app builds/runs on android/ios/web; integration smoke test.

See `docs/architecture.md` §Testing for the full strategy and `docs/implementation-plan.md` for
per-task test-first steps.
