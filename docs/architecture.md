---
type: Architecture Document
title: flutter_jelly_tabs — Architecture
description: Technical design for the Flutter port — RN-to-Flutter module mapping, rendering model, spring engine, controllers, gesture layer, and testing strategy.
tags: [flutter, architecture, jelly-tabs]
timestamp: 2026-08-08T00:00:00Z
---

# flutter_jelly_tabs — Architecture

> **Status:** Approved. Skeleton + implementation deferred to a follow-up session.
> **Date:** 2026-08-08

## 1. Overview

`flutter_jelly_tabs` is a Flutter **UI package** (per the VGV `ui-package` skill) that ports the
RN `react-native-jelly-tabs` engine. The architecture mirrors the RN source module-for-module so
behavior, parameters, and config stay 1:1, while replacing Reanimated / Gesture Handler /
MaskedView with pure-Flutter equivalents.

| RN module | Flutter port | Responsibilities |
| --- | --- | --- |
| `src/constants.ts` | `lib/src/config/` | Defaults, resolved config, deep-partial override |
| `src/utils/animation.ts` | `lib/src/math/animation_math.dart` | `easeOut`, `rubberBand`, spring solver, tab geometry |
| `src/utils/pill-jelly-animation.ts` | `lib/src/math/pill_jelly_animation.dart` | Frame stepping state machine |
| `src/hooks/use-pill-jelly.ts` | `lib/src/controllers/pill_jelly_controller.dart` | Ticker-driven controller, gesture entry points |
| `src/hooks/use-distortion.ts` | `lib/src/controllers/distortion_controller.dart` | Press scale, vertical drag distortion, glow |
| `src/components/tabs.tsx` | `lib/src/widgets/jelly_tab_bar_headless.dart` | Widget tree, layers, semantics |
| `src/components/tab-item.tsx` | `lib/src/widgets/tab_item.dart` | Icon + label + badge |
| `src/components/pill-masked-view.tsx` | `lib/src/widgets/pill_masked_view.dart` | Pill reveal (ClipPath) |
| `src/components/touch-feedback.tsx` | `lib/src/widgets/touch_feedback.dart` | Radial gradient glow |
| `src/types.ts` | `lib/src/models/` | `JellyTabsItem`, events, props |
| `src/index.ts` | `lib/jelly_tabs.dart` | Barrel export |
| `src/hooks/use-stable-array.ts` | **omitted** | Used only by the omitted navigation adapter |
| `src/components/navigation-tab-bar.tsx` | **omitted** | Headless-only (confirmed) |
| `src/utils/navigation*.ts` | **omitted** | Headless-only (confirmed) |

## 2. Package Layout

Uses Dart's native pub workspaces (`resolution: workspace`), not melos — see
[ADR-0001](./adr/0001-native-pub-workspaces-over-melos.md).

```
flutter-jelly-tabs/
├── pubspec.yaml                      # workspace root: `workspace: [packages/jelly_tabs, example]`
├── reference/
│   └── react-native-jelly-tabs/      # vendored read-only snapshot @ 67f47f2, for fidelity re-checks
├── packages/
│   └── jelly_tabs/
│       ├── pubspec.yaml              # sdk-only dependency, very_good_analysis dev dep
│       ├── lib/
│       │   ├── jelly_tabs.dart       # barrel: exports material + all public API
│       │   └── src/
│       │       ├── config/           # config.dart, defaults.dart, spring_config.dart
│       │       ├── math/             # animation_math.dart, pill_jelly_animation.dart
│       │       ├── controllers/      # pill_jelly_controller.dart, distortion_controller.dart
│       │       ├── models/           # jelly_tabs_item.dart, jelly_tabs_change_event.dart, jelly_tabs_icon_props.dart
│       │       ├── widgets/          # jelly_tab_bar_headless.dart, tab_item.dart, pill_masked_view.dart, touch_feedback.dart
│       │       └── gestures/         # jelly_tab_bar_gesture.dart (pointer tracking)
│       └── test/
│           ├── helpers/pump_app.dart # shared test harness
│           ├── src/math/…
│           ├── src/controllers/…
│           └── src/widgets/…
└── example/                          # example app (android/ios/web)
    └── lib/main.dart                 # demo of JellyTabBarHeadless + customization
```

## 3. Rendering Model

### 3.1 Widget tree (mirrors `tabs.tsx`)

```
GestureHandler  →  PointerListener / GestureDetector   (gesture layer)
└── PressWrapper (pressedStyle: whole-track scale, height: trackHeight, maxWidth, centered)
    └── Track (AnimatedContainer, height: trackHeight)
        ├── Panel (Stack, animated translateX from panel offset)
    │   ├── SurfaceClip (ClipRRect, radius: trackHeight/2)
    │   │   ├── backdrop (optional)
    │   │   └── Surface (surface color + opacity)
    │   ├── TouchFeedbackClip (ClipRRect)  → TouchFeedback (radial glow)
    │   └── TabsRow (Row, padding: trackInset)  → inactive TabItems
    └── MaskOverscan (Stack, inset by ±maskOverscanX/Y, hidden when no selection)
        └── PillMaskedView
            ├── SelectedSurface (selectedBackdrop + selectedSurface color + opacity)
            ├── Selected TouchFeedback (radial glow)
            └── SelectedTabsRow (Row at inset)  → active TabItems (animated scale)
```

All animated layers read from controllers via `ListenableBuilder`/`AnimatedBuilder` — no
per-frame `setState`. Static subtrees (icons, labels) pass through the `child` slot so they
are not rebuilt every frame (VGV `animations` skill).

### 3.2 Pill reveal — the MaskedView replacement

RN uses `@react-native-masked-view/masked-view` (native) with a CSS-clip fallback (web).
Flutter has no MaskedView; we implement the pill reveal **identically on all platforms**
using `ClipPath` with a custom `CustomClipper<Path>` that rebuilds the pill shape each frame
from the controller's animated values (position `value`, `baseScaleX`, `baseScaleY`,
velocity shear corrections, `tabWidth`, `itemHeight`).

```dart
class PillPathClipper extends CustomClipper<Path> {
  const PillPathClipper({required this.pill}); // reads controller values
  @override Path getClip(Size size) {
    // Rounded rect in the overscan-sized content layer's coordinate space:
    // centerX = maskOverscanX + trackInset + value * tabWidth + tabWidth/2,
    // centerY = maskOverscanY + trackInset + itemHeight/2,
    // plus scale about the pill center; radius = itemHeight / 2 (capsule).
    // (Offsets mirror PillMaskedView's left/top insets from tabs.tsx.)
  }
  @override bool shouldReclip(PillPathClipper old) =>
      old.pill != pill; // ValueNotifier identity; reclips when values change
}
```

The selected-content layer (selected surface + active icons) is `ClipPath`'d to the pill
capsule. The clipper returns the fully transformed rounded-rect path, so we get translate +
scale + velocity shear in one place — the same math as RN's `getPillMaskStyle` +
`pillContentStyle`, folded into a single path (no inverse-transform bookkeeping needed).

### 3.3 Touch feedback (SVG → Flutter gradient)

RN renders an SVG `RadialGradient`. Flutter equivalent: a `Container` with
`BoxDecoration(gradient: RadialGradient(...))`, sized `diameter x diameter`, positioned by an
animated `Transform.translate` driven by `transformOriginX`/`pointerLocalY`. Stops copied from
`touch-feedback.tsx`:

| Stop | Opacity |
| --- | --- |
| 0% | centerOpacity (base) |
| 45% | middleOpacity = base × `middleOpacityRatio` |
| 100% | 0 |

## 4. The Spring Engine

### 4.1 `animation_math.dart` — pure functions

Port of `src/utils/animation.ts`, all pure and unit-testable:

- `advanceSpring(value, velocity, target, {stiffness, dampingRatio}, dtSeconds)` — unit-mass,
  analytical damped-spring closed form. Branches on `dampingRatio`: `==1` critical, `>1`
  overdamped (hyperbolic), `<1` underdamped. `naturalFrequency = sqrt(stiffness)`. Rest epsilon
  `1e-4` snap-to-target.
- `getFrameDeltaSeconds(dtMs)` — clamps to `MAX_FRAME_DELTA_SECONDS = 0.064`.
- `easeOut(t)` — bisection solver for Compose's cubic-bezier `(0, 0, 0.58, 1)`.
- `getHorizontalPanelOffset(rawOffset, trackWidth, scale)` — `±4 * scale` px eased micro-shift.
- `getTabWidth(trackWidth, trackInset, tabCount)` — `max(0, (trackWidth - 2*inset) / count)`.
- `getMaxTabIndex(count)` — `max(0, count - 1)`.
- `rubberBand(distance, dimension, coefficient)` — damped resistance.
- `getPointerOrigin(current, dim, initialAbs, initialLocal)` — clamped pointer position.

### 4.2 `pill_jelly_animation.dart` — frame stepping

Port of `src/utils/pill-jelly-animation.ts`. Holds the full jelly state machine:

```
advancePillJellyFrame(state, config, tabCount, dtMs):
  dt = getFrameDeltaSeconds(dtMs); if null return
  clampTargetValue
  advanceSpring(value, targetValue,      springs.value)
  advanceSpring(filteredVelocity,        target = (dragging && maxTabIndex > 0)
                                                   ? valueVel/maxIndex : 0,
                                         springs.velocity)
  advanceSpring(rawPanelOffset, 0,       springs.panel)   // only when not dragging
  settleReleasedIndicator (releasePending && |value-target| < releaseDistanceFraction*max(1,maxIndex)
                           → releasePending=0, pressTarget=0, shapeTarget=1)
  advanceSpring(pressProgress, pressTarget, springs.press)
  advanceSpring(baseScaleX, shapeTarget, springs.scaleX)
  advanceSpring(baseScaleY, shapeTarget, springs.scaleY)
```

State is a mutable struct of `double`s (a `PillJellyFrameState` class) — the Dart equivalent of
Reanimated shared values. The controller exposes them as `ValueNotifier`s / a single
`ChangeNotifier` the widgets listen to.

## 5. Controllers

### 5.1 `PillJellyController` (port of `use-pill-jelly.ts`)

- Owns `PillJellyFrameState` + gesture bookkeeping (`downX`, `movedDistance`,
  `dragStartTarget`, `dragStartPanelOffset`, `isDragging`, `webTrackPageX`/local offset).
- Owns a `Ticker` (via `TickerProviderStateMixin` in the widget, or a passed-in `TickerProvider`)
  with the same active/inactive + 500ms-settle logic as RN's `setFrameLoopActive`.
- Public API (called from the gesture layer and the widget):
  - `beginGesture(localX, localY, absoluteX)` — snap-on-pointer-down, pressTarget=1,
    shapeTarget=pressedScale, isDragging=1.
  - `updateGesture(horizontalTranslation, verticalTranslation, absoluteX, localX)` — targetValue,
    rawPanelOffset, delegate to distortion controller, movedDistance.
  - `finishGesture()` — click vs drag settle, `onTabPress` → `onTabChange`, restore on reject.
  - `activateTab(index)` — accessibility select.
  - `setTrackWidth`, `setTrackPosition` (web/local page offset).
  - `controlledIndex` setter — external selection changes animate the pill.
- Produces animated styles via `ValueListenable`s consumed by widgets:
  `pillMaskStyle` (path inputs), `panelStyle`, `pressedStyle`, `activeItemStyle`.

### 5.2 `DistortionController` (port of `use-distortion.ts`)

Verified against the vendored source (`reference/react-native-jelly-tabs/src/hooks/use-distortion.ts`
@ `67f47f2`): only two of the five animated values are ever spring-driven; the rest are direct,
synchronously-computed assignments. This matters for engine choice (§11) — it means no value here
ever needs continuous per-frame retargeting of a running spring.

- **Spring-driven (fire-and-forget, `withSpring` → Flutter `SpringSimulation`):**
  - `begin()` — `pressedScale` animates `1 → distortion.pressedScale`; `touchFeedbackOpacity`
    animates `0 → 1`. Both use `distortion.spring` (`{damping: 18, mass: 0.9, stiffness: 240}`).
  - `end()` — `translateY → 0`, `scaleX → 1`, `pressedScale → 1`, `touchFeedbackOpacity → 0`, all
    via `distortion.spring`; `transformOriginX` resets to `trackWidth / 2` once the `scaleX` spring
    finishes.
  - Flutter: `AnimationController.animateWith(SpringSimulation(spring, controller.value, target,
    controller.velocity))` per value. Starting a new `animateWith` while one is in flight
    interrupts it and `controller.velocity` reflects the in-flight simulation's current velocity —
    this reproduces Reanimated's "retarget from current value+velocity, cancel the previous
    animation" behavior (RN calls `cancelAnimation` explicitly in `begin()`) without any custom
    stepper.
- **Direct, computed every frame during `update()` (no spring, no interpolation):**
  - `progress = min(|verticalTranslation| / max(distanceForMaxDistortion, 1e-4), 1)`
  - `translateY = dragOriginY + rubberBand(verticalTranslation, trackHeight, verticalDrag.rubberBand) * verticalDrag.follow`
    (`dragOriginY` is `translateY`'s value captured at `begin()`, so a new drag starting before the
    previous release-spring finishes compounds correctly instead of jumping)
  - `scaleX = 1 - progress * verticalDrag.distortion`
  - `transformOriginX` = clamped pointer X (via `getPointerOrigin`), tracking the finger directly.
  - Flutter: plain field assignment on each `updateGesture` call — these three do **not** go
    through `SpringSimulation`/`ValueNotifier` interpolation, just direct value + `notifyListeners()`.
- `setTrackWidth` — recenters `transformOriginX` to `trackWidth / 2`.

## 6. Gesture Layer

RN uses `Gesture.Pan().minDistance(0)` + optional simultaneous `Gesture.LongPress()`.

Flutter's `GestureDetector` pan recognizer applies a touch-slop, which breaks min-distance-0
semantics. Instead, mirror the RN worklets with raw pointer events:

- `Listener(onPointerDown/Move/Up/Cancel)` on the track provides touch-slop-free tracking,
  computing `localX`, `localY`, `absoluteX` like RN's `onTouchesDown`/`onUpdate` worklets.
- A long-press `Timer` (500ms, cancelled on move >10px or up) fires `onTabLongPress`.
- Recording mode keeps RN's X/Y swap for vertical-scroll demos.

All gesture math (downX, targetValue, rawPanelOffset, movedDistance, nearest-tab settle) lives in
`pill_jelly_controller.dart` exactly as in RN, so behavior is preserved. This is the **only** place
we intentionally diverge from Flutter's default gesture API, and the divergence is invisible to
consumers.

## 7. Config Resolution

`config.dart` mirrors `constants.ts`:

- `JellyTabsLayout`, `JellyTabsColors`, `JellyTabsOpacity`, `PillJellyFrameConfig`,
  `SpringConfig`, `PillJellyConfig`, `DistortionConfig`, `JellyTabsConfig` — immutable resolved
  values.
- `JellyTabsConfigOverride` — the deep-partial form (all fields nullable) accepted by the widget.
- `resolveJellyTabsConfig([override])` — merges nested `springs` and `touchFeedback`/`verticalDrag`
  maps exactly like RN's `resolveTabBarConfig` (spread-per-nested-object, not a generic deep merge,
  so partial overrides don't wipe sibling defaults).

Defaults are copied verbatim from RN (see `docs/design.md` §5.5).

## 8. Accessibility & Semantics

- Each tab gets `Semantics` with role `tab`, `selected`, label (from `accessibilityLabel` or
  `label`), and `SemanticsAction.tap` → `activateTab`, plus a custom long-press action when
  `onTabLongPress` is set.
- The visual-only layers (surface, pill, icons, glow) are excluded from the semantics tree
  (`ExcludeSemantics`) so screen readers hit exactly one tab node per item, like RN's
  `accessibilityTabsRow`.
- **Keyboard/focus (web/desktop, no RN equivalent).** Each tab is wrapped in a `Focus` node
  (traversal order = item order); `Enter`/`Space` while focused calls the same `activateTab(index)`
  path as a tap, via `Actions`/`CallbackAction` on `ActivateIntent`. Focus ring uses the default
  Flutter focus highlight (no custom styling required for v0.1.0). This has no RN source to port
  from — RN targets touch only — so it's new surface area, not a port, and is tested separately
  from behavior-parity tests.

## 9. Testing Strategy

Conventions follow the VGV `testing` skill (descriptive names, hierarchical groups, `late`+`setUp`
in `group`, `pumpApp` helper, `TestTag.golden` for goldens).

| Layer | Coverage |
| --- | --- |
| `math/animation_math_test.dart` | spring closed forms (critical/under/over), `easeOut` monotonic, `rubberBand`, tab geometry, panel offset |
| `math/pill_jelly_animation_test.dart` | frame-step sequences: press→release settle, drag→nearest-index, velocity filter, panel return |
| `controllers/pill_jelly_controller_test.dart` | begin/update/finish, reject restore, controlled-index animation, activateTab |
| `controllers/distortion_controller_test.dart` | begin/update/end transforms, vertical rubber-band |
| `widgets/jelly_tab_bar_headless_test.dart` | tap selects, drag selects, long-press fires, controlled `selectedIndex`, empty items, rejected press restore |
| `widgets/tab_item_test.dart` | icon/label/badge rendering, active vs inactive |
| `widgets/pill_masked_view_test.dart` | pill clip geometry, hidden state |
| `widgets/touch_feedback_test.dart` | gradient stops, sizing, positioning |
| Golden (`TestTag.golden`) | rest state, selected state, pressed pill, badge — per config |
| Example | `flutter build` on android/ios/web; optional integration smoke test |

**Test harness note:** the pill jelly controller drives a `Ticker`. Tests inject a fake ticker or
drive `tester.pump(Duration)` in widget tests; unit tests call `advancePillJellyFrame` directly
with fixed `dtMs`. Follow VGV `animations` reference (`injected controllers`, `animation-testing`).

## 10. Build & Quality Gates (VGV)

- Scaffold: Very Good CLI (`flutter_package` template) — the follow-up session runs the
  `create-project` skill.
- Lints: `very_good_analysis`; `flutter analyze` clean.
- Format: `dart format --set-exit-if-changed`.
- Tests: `flutter test` with coverage gate — **100%** on `lib/src/config/` and `lib/src/math/`,
  **90%+** package-wide (see `docs/design.md` §8).
- Web: `flutter test --platform chrome` for the pure-Dart layers where relevant.
- CI: GitHub Actions matrix (analyze → format → test → coverage → build example on android/ios/web),
  mirroring VGV `green-gate` gate order.

## 11. Risks & Mitigations

| Risk | Mitigation |
| --- | --- |
| Reanimated `withSpring` ≠ Flutter `SpringSimulation` in edge cases | **Resolved (§5.2).** Verified against source: `DistortionController` only springs on `begin()`/`end()` (fire-and-forget, never retargeted mid-drag) — `SpringSimulation` via `AnimationController.animateWith(current value, current velocity)` reproduces Reanimated's retarget-and-cancel semantics exactly. Mid-drag `translateY`/`scaleX`/`transformOriginX` are direct computed assignments in RN too, not springs — ported the same way, no interpolation engine needed there |
| `ClipPath` reclip performance on every frame | Reclip only on `ValueNotifier` change; small clip subtree (`RepaintBoundary`) |
| Velocity-shear sign conventions | Transcribe `getPillMaskStyle`/`pillContentStyle` math verbatim; frame-sequence tests pin exact values |
| Web parity (hover/scroll vs touch) | `Listener` works on web; example QA on web + native |
| Icon API ergonomics vs RN | `JellyTabsIconBuilder` typedef mirrors RN's component signature; documented in dartdoc + example |
