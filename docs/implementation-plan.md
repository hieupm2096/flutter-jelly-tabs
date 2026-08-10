---
type: Implementation Plan
title: flutter_jelly_tabs Implementation Plan
description: TDD task-by-task build plan for the jelly_tabs package — workspace scaffold, config, math engine, controllers, widgets, goldens, example app, and release prep.
tags: [flutter, plan, jelly-tabs]
timestamp: 2026-08-08T00:00:00Z
---

# flutter_jelly_tabs Implementation Plan

> **For agentic workers:** Execute with the VGV harness. Use the `vgv-ai-flutter-plugin` skills
> (`create-project`, `ui-package`, `testing`, `animations`, `accessibility`,
> `very-good-analysis-upgrade`, `green-gate`) and the `flutter-reviewer` agent during build, and
> `vgv-wingspan`'s `/review` pass before each PR. Follow TDD — test first, then implement, then
> commit. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a `jelly_tabs` Flutter package (headless jelly tab bar) with parity to
`react-native-jelly-tabs`, plus a web/android/iOS example app, built to VGV standards.

**Architecture:** Pure-Flutter port — analytical damped-spring solver driven by a `Ticker`,
ClipPath-based pill reveal, pointer-event gesture layer, `SpringSimulation` distortion. See
`docs/architecture.md`.

**Tech Stack:** Flutter SDK (no runtime deps), `very_good_analysis`, `melos`, Very Good CLI
templates, Flutter test + goldens, GitHub Actions.

**Spec:** `docs/design.md` · **Architecture:** `docs/architecture.md` · **Roadmap:** `docs/roadmap.md`

---

## Phase 0 — Workspace Scaffold

### Task 0.1: Create the monorepo skeleton

**Files:**
- Create: `melos.yaml`
- Create: `pubspec.yaml` (workspace root, no deps)
- Create: `.gitignore`
- Create: `.github/workflows/ci.yaml`
- Create: `README.md` (root — repo overview)

- [ ] **Step 1: Write the failing check** — n/a (scaffold, no test yet; gate is `flutter analyze` clean).
- [ ] **Step 2: Create root files**

```yaml
# melos.yaml
name: flutter_jelly_tabs
packages:
  - packages/**
  - example
```

```yaml
# pubspec.yaml
name: flutter_jelly_tabs
environment:
  sdk: ^3.10.0
dev_dependencies:
  melos: ^6.0.0
```

- [ ] **Step 3: Add CI workflow** — matrix job: `flutter analyze`, `dart format --set-exit-if-changed`,
      `flutter test`, coverage, then `flutter build` on android/ios/web inside `example/`.
      Follow the VGV `green-gate` gate order (analyze → format → test → coverage).
- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "feat: scaffold flutter_jelly_tabs monorepo"
```

### Task 0.2: Scaffold the `jelly_tabs` package via Very Good CLI

**Files:**
- Create: `packages/jelly_tabs/**` (from template)

- [ ] **Step 1: Run the `create-project` skill** — scaffold with `very_good create
      flutter_package jelly_tabs` (VGV `ui-package` skill: scaffold from `app_ui_package`/
      `flutter_package` template, NOT bare `flutter create`).
- [ ] **Step 2: Trim the template** — remove sample widget/tests; keep barrel, `pumpApp` helper,
      analysis options, CI.
- [ ] **Step 3: Set package metadata** — `name: jelly_tabs`, `version: 0.1.0`, description,
      `sdk`/`flutter` environment, `very_good_analysis` dev dep.
- [ ] **Step 4: Add example app reference** — `example/` app depends on
      `jelly_tabs: path: ../packages/jelly_tabs` via melos workspace.
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat: scaffold jelly_tabs package"`

### Task 0.3: Register melos + verify baseline

- [ ] **Step 1:** `melos bootstrap`
- [ ] **Step 2: Run gates** — `flutter analyze`, `dart format --set-exit-if-changed`,
      `flutter test` in `packages/jelly_tabs`. Expected: all clean (template baseline).
- [ ] **Step 3: Commit any lockfile/format fixes** — `git commit -m "chore: melos bootstrap"`

## Phase 1 — Config & Models

### Task 1.1: Defaults (port `constants.ts`)

**Files:**
- Test: `packages/jelly_tabs/test/src/config/defaults_test.dart`
- Create: `packages/jelly_tabs/lib/src/config/defaults.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/src/config/defaults.dart';

void main() {
  group(DefaultJellyTabsLayout, () {
    test('matches react-native-jelly-tabs TABBAR_LAYOUT', () {
      expect(DefaultJellyTabsLayout.iconSize, 28);
      expect(DefaultJellyTabsLayout.itemHeight, 56);
      expect(DefaultJellyTabsLayout.maskOverscanX, 48);
      expect(DefaultJellyTabsLayout.maskOverscanY, 16);
      expect(DefaultJellyTabsLayout.trackHeight, 64);
      expect(DefaultJellyTabsLayout.trackInset, 4);
    });
  });
  // ... colors (#11100F/#B8B4AD/#F2EEE7/#22211F), opacity (all 1),
  // pillJelly springs table, distortion table — assert every default
  // from design.md §5.5.
}
```

- [ ] **Step 2: Run to verify it fails** — `flutter test`. Expected: FAIL (file/class missing).
- [ ] **Step 3: Implement** — const classes `DefaultJellyTabsLayout`, `DefaultJellyTabsColors`,
      `DefaultJellyTabsOpacity`, `DefaultPillJelly`, `DefaultDistortion` with all RN defaults.
- [ ] **Step 4: Run to verify it passes** — `flutter test`. Expected: PASS.
- [ ] **Step 5: Commit** — `git commit -am "feat: jelly tabs default config"`

### Task 1.2: Resolved config + deep-partial override

**Files:**
- Test: `packages/jelly_tabs/test/src/config/config_test.dart`
- Create: `packages/jelly_tabs/lib/src/config/config.dart`
- Create: `packages/jelly_tabs/lib/src/config/spring_config.dart`

- [ ] **Step 1: Write the failing test** — `resolveJellyTabsConfig()` returns all defaults;
      `resolveJellyTabsConfig(override: layout: {trackHeight: 80})` keeps siblings
      (iconSize 28, itemHeight 56); nested `pillJelly.frameConfig.springs.panel` override keeps
      other springs; `distortion.verticalDrag.follow` override keeps `distortion`.
      `SpringConfig` exposes `stiffness` + `dampingRatio`.
- [ ] **Step 2: Run to verify it fails**
- [ ] **Step 3: Implement** — immutable `SpringConfig`, `JellyTabsLayout/Colors/Opacity/
      PillJellyFrameConfig/PillJellyConfig/DistortionConfig/JellyTabsConfig` + nullable
      `*Override` deep-partial forms + `resolveJellyTabsConfig([override])` merging
      nested-object-per-key exactly like RN `resolveTabBarConfig`.
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** — `git commit -am "feat: resolved jelly tabs config"`

### Task 1.3: Models (port `types.ts`)

**Files:**
- Test: `packages/jelly_tabs/test/src/models/..._test.dart`
- Create: `packages/jelly_tabs/lib/src/models/jelly_tabs_item.dart`
- Create: `packages/jelly_tabs/lib/src/models/jelly_tabs_change_event.dart`
- Create: `packages/jelly_tabs/lib/src/models/jelly_tabs_icon_props.dart`

- [ ] **Step 1: Write the failing test** — `JellyTabsItem` carries key/label/icons/a11y/badge/
      labelStyle/testID; `JellyTabsIconProps` carries color/colors/opacity/size;
      `JellyTabsChangeEvent` carries index+item.
- [ ] **Step 2: Run to verify it fails**
- [ ] **Step 3: Implement** — `typedef JellyTabsIconBuilder = Widget Function(JellyTabsIconProps)`;
      `class JellyTabsItem` (fields per §5.2); `class JellyTabsChangeEvent`;
      `class JellyTabsIconProps`.
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** — `git commit -am "feat: jelly tabs item/event/icon models"`

## Phase 2 — Math Engine

### Task 2.1: Spring solver

**Files:**
- Test: `packages/jelly_tabs/test/src/math/animation_math_test.dart`
- Create: `packages/jelly_tabs/lib/src/math/animation_math.dart`

- [ ] **Step 1: Write the failing test**

```dart
group('advanceSpring', () {
  test('snaps to target when at rest', () {
    final step = advanceSpring(5, 0, 5, spring: SpringConfig(stiffness: 300, dampingRatio: 1), dt: 0.016);
    expect(step.value, 5);
    expect(step.velocity, 0);
  });
  test('critical damping reaches target without overshoot', () {
    var v = 100.0; var x = 0.0;
    const config = SpringConfig(stiffness: 300, dampingRatio: 1);
    for (var i = 0; i < 300; i++) {
      final step = advanceSpring(x, v, 1, spring: config, dt: 0.016);
      x = step.value; v = step.velocity;
    }
    expect(x, closeTo(1, 1e-3));
    expect(v, closeTo(0, 1e-3));
  });
  test('underdamped overshoots then settles', () { /* assert max(x) > target */ });
  test('overdamped is monotonic', () { /* assert no overshoot */ });
});
```

- [ ] **Step 2: Run to verify it fails**
- [ ] **Step 3: Implement** — `advanceSpring` with the exact critical/under/over closed forms
      from `animation.ts` (naturalFrequency = sqrt(stiffness), rest epsilon 1e-4).
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** — `git commit -am "feat: analytical spring solver"`

### Task 2.2: Easing, rubber band, geometry

**Files:**
- Test: `packages/jelly_tabs/test/src/math/animation_math_test.dart` (extend)
- Modify: `packages/jelly_tabs/lib/src/math/animation_math.dart`

- [ ] **Step 1: Write the failing test** — `easeOut(0)==0`, `easeOut(1)==1`, monotonic,
      `easeOut(0.5)` within [0.5, 1] (matches Compose `(0,0,0.58,1)`); `rubberBand(0)==0`,
      sign preserved, bounded by dimension; `getTabWidth(400, 4, 4) == 98`;
      `getTabWidth(0,4,4)==0`; `getMaxTabIndex(4)==3`, `getMaxTabIndex(0)==0`;
      `getHorizontalPanelOffset` returns 0 at rest and ±≤4 px elsewhere; `getPointerOrigin` clamps.
- [ ] **Step 2: Run to verify it fails**
- [ ] **Step 3: Implement** — `easeOut` bisection, `rubberBand`, `getTabWidth`,
      `getMaxTabIndex`, `getHorizontalPanelOffset`, `getPointerOrigin` — transcribed verbatim.
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** — `git commit -am "feat: easing, rubber band, tab geometry"`

### Task 2.3: Frame stepping state machine

**Files:**
- Test: `packages/jelly_tabs/test/src/math/pill_jelly_animation_test.dart`
- Create: `packages/jelly_tabs/lib/src/math/pill_jelly_animation.dart`

- [ ] **Step 1: Write the failing test**

```dart
// Fixed dt = 1/60. Build a fresh PillJellyFrameState.
test('press→release keeps pill inflated until within releaseDistanceFraction', () {
  // pressTarget=1, shapeTarget=1.3, releasePending=0 → inflate
  // then releasePending=1, target reached → pressTarget 0, shapeTarget 1
});
test('value spring advances toward targetValue', () { ... });
test('filteredVelocity tracks valueVelocity only while dragging', () { ... });
test('rawPanelOffset springs back to 0 when not dragging', () { ... });
test('clampTargetValue bounds to [0, maxTabIndex]', () { ... });
```

- [ ] **Step 2: Run to verify it fails**
- [ ] **Step 3: Implement** — `PillJellyFrameState` (mutable doubles),
      `PillJellyFrameConfig`, `advancePillJellyFrame(state, config, tabCount, dtMs)` — exact
      step order from `pill-jelly-animation.ts`.
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** — `git commit -am "feat: pill jelly frame stepping"`

## Phase 3 — Controllers

### Task 3.1: `DistortionController`

**Files:**
- Test: `packages/jelly_tabs/test/src/controllers/distortion_controller_test.dart`
- Create: `packages/jelly_tabs/lib/src/controllers/distortion_controller.dart`

- [ ] **Step 1: Write the failing test** — with a fake `TickerProvider`: `begin` sets
      pressedScale/glow targets; `update` with vertical translation applies
      `rubberBand*verticalDrag.follow` to translateY and `1 - progress*distortion` to scaleX;
      `update` with horizontal-only input keeps scaleX ~1; `end` springs everything to rest;
      `setTrackWidth` centers `transformOriginX`.
- [ ] **Step 2: Run to verify it fails**
- [ ] **Step 3: Implement** — `DistortionController` with `SpringDescription(mass, stiffness,
      damping)` simulations (RN distortion.spring), `ValueNotifier`s for each animated value.
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** — `git commit -am "feat: distortion controller"`

### Task 3.2: `PillJellyController` — state + ticker

**Files:**
- Test: `packages/jelly_tabs/test/src/controllers/pill_jelly_controller_test.dart`
- Create: `packages/jelly_tabs/lib/src/controllers/pill_jelly_controller.dart`

- [ ] **Step 1: Write the failing test** — `setTrackWidth` → `getTabWidth` correct;
      controlled index set → value animates toward it; `advancePillJellyFrame` invoked per tick
      (fake ticker); frame loop settles to inactive after 500ms idle.
- [ ] **Step 2: Run to verify it fails**
- [ ] **Step 3: Implement** — controller owning `PillJellyFrameState`, `Ticker`, 500ms-settle
      logic; `ValueNotifier`s for `pillMaskStyle`, `panelStyle`, `pressedStyle`,
      `activeItemStyle`.
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** — `git commit -am "feat: pill jelly controller (ticker)"`

### Task 3.3: `PillJellyController` — gesture entry points

**Files:**
- Test: `packages/jelly_tabs/test/src/controllers/pill_jelly_controller_test.dart` (extend)
- Modify: `packages/jelly_tabs/lib/src/controllers/pill_jelly_controller.dart`

- [ ] **Step 1: Write the failing test** — `beginGesture` with `snapOnPointerDown=true` snaps
      target toward touched tab, isDragging=1, pressTarget=1, shapeTarget=pressedScale;
      `updateGesture` moves targetValue by `hTrans/tabWidth` and delegates to distortion;
      `finishGesture` (stationary, movedDistance<4) selects touched tab; `finishGesture`
      (dragged) settles to nearest index; `onTabPress` returning false restores prior selection
      and fires no `onTabChange`; accepted change fires `onTabChange`.
- [ ] **Step 2: Run to verify it fails**
- [ ] **Step 3: Implement** — port `beginGesture/updateGesture/finishGesture/confirmTabPress`
      logic from `use-pill-jelly.ts` (including `recording` X/Y swap).
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** — `git commit -am "feat: pill jelly gesture logic"`

## Phase 4 — Widgets

### Task 4.1: `TouchFeedback` widget

**Files:**
- Test: `packages/jelly_tabs/test/src/widgets/touch_feedback_test.dart`
- Create: `packages/jelly_tabs/lib/src/widgets/touch_feedback.dart`

- [ ] **Step 1: Write the failing test** — renders gradient container sized `diameter`; positioned
      by animated translate; stops match `centerOpacity`/`middleOpacity`/0.
- [ ] **Step 2: Run to verify it fails**
- [ ] **Step 3: Implement** — `TouchFeedback` using `BoxDecoration(RadialGradient(...))` + `Transform`.
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** — `git commit -am "feat: touch feedback widget"`

### Task 4.2: `TabItem` widget

**Files:**
- Test: `packages/jelly_tabs/test/src/widgets/tab_item_test.dart`
- Create: `packages/jelly_tabs/lib/src/widgets/tab_item.dart`

- [ ] **Step 1: Write the failing test** — renders active vs inactive icon (different builders),
      label with color/fontWeight, badge when provided, labelStyle applied, `displayScale` scales.
- [ ] **Step 2: Run to verify it fails**
- [ ] **Step 3: Implement** — `TabItem` mirroring `tab-item.tsx` (icon + translateY 2*scale, label
      fontSize 13*scale, badge positioned top-right, overflow hidden, fontWeight active 700/400).
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** — `git commit -am "feat: tab item widget"`

### Task 4.3: `PillMaskedView`

**Files:**
- Test: `packages/jelly_tabs/test/src/widgets/pill_masked_view_test.dart`
- Create: `packages/jelly_tabs/lib/src/widgets/pill_masked_view.dart`
- Create: `packages/jelly_tabs/lib/src/widgets/pill_path_clipper.dart`

- [ ] **Step 1: Write the failing test** — `PillPathClipper.getClip` produces a capsule (radius =
      itemHeight/2) at `value * tabWidth + tabWidth/2` with scaleX/scaleY applied about the pill
      center; hidden when no selection (returns `null`/empty via parent `Visibility`).
- [ ] **Step 2: Run to verify it fails**
- [ ] **Step 3: Implement** — `PillMaskedView` (ClipPath + selected-content layer) and
      `PillPathClipper` with the velocity-shear math folded in.
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** — `git commit -am "feat: pill masked view"`

### Task 4.4: `JellyTabBarHeadless` — static rendering

**Files:**
- Test: `packages/jelly_tabs/test/src/widgets/jelly_tab_bar_headless_test.dart`
- Create: `packages/jelly_tabs/lib/src/widgets/jelly_tab_bar_headless.dart`
- Modify: `packages/jelly_tabs/lib/jelly_tabs.dart` (barrel export)

- [ ] **Step 1: Write the failing test** — renders track with surface color/opacity, inactive
      icons, no pill when `items` empty, pill+selected surface when selected, badge visible,
      maxWidth centers the bar.
- [ ] **Step 2: Run to verify it fails**
- [ ] **Step 3: Implement** — widget assembling the layer tree (§3.1 architecture) with
      `SingleTickerProviderStateMixin`, controllers, `ListenableBuilder`s, `RepaintBoundary` on
      the clip, `ExcludeSemantics` on visual layers.
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** — `git commit -am "feat: jelly tab bar headless (render)"`

### Task 4.5: Gesture layer + semantics

**Files:**
- Test: `packages/jelly_tabs/test/src/widgets/jelly_tab_bar_headless_test.dart` (extend)
- Create: `packages/jelly_tabs/lib/src/gestures/jelly_tab_bar_gesture.dart`
- Modify: `packages/jelly_tabs/lib/src/widgets/jelly_tab_bar_headless.dart`

- [ ] **Step 1: Write the failing test** — tap selects tab + fires `onTabPress`/`onTabChange`;
      drag across tabs selects on release; long-press fires `onTabLongPress`; `onTabPress`
      returning false rejects + restores; controlled `selectedIndex` animates on external change;
      semantics: role tab, selected state, tap action, long-press action.
- [ ] **Step 2: Run to verify it fails**
- [ ] **Step 3: Implement** — `Listener`-based pointer tracking (down/move/up/cancel) feeding
      controller gesture methods, long-press `Timer`, and `Semantics` per tab.
- [ ] **Step 4: Run to verify it passes**
- [ ] **Step 5: Commit** — `git commit -am "feat: jelly tab gestures + semantics"`

## Phase 5 — Golden Tests

### Task 5.1: Golden baseline

**Files:**
- Create: `packages/jelly_tabs/test/goldens/...`
- Create: `packages/jelly_tabs/test/src/widgets/golden_test.dart`
- Modify: `packages/jelly_tabs/dart_test.yaml` (golden tag config)

- [ ] **Step 1: Write the test** — `testWidgets` with `TestTag.golden` asserting rest state,
      selected state, pressed pill (pump fixed progress), badge appearance — via `pumpApp` +
      `matchesGoldenFile`.
- [ ] **Step 2: Generate goldens** — `flutter test --update-goldens`.
- [ ] **Step 3: Review generated images** against RN demo screenshots (manual parity check).
- [ ] **Step 4: Commit** — `git commit -am "test: golden baseline"`

## Phase 6 — Example App (web/android/iOS)

### Task 6.1: Scaffold + integrate

**Files:**
- Create: `example/**` (VGV `flutter_app` template)
- Modify: `example/lib/main.dart`

- [ ] **Step 1: Scaffold** via `create-project` skill (`flutter_app` template).
- [ ] **Step 2: Write the failing test** — `example/test/...` asserting the example renders the
      tab bar with configured items.
- [ ] **Step 3: Implement** — `main.dart` demonstrating `JellyTabBarHeadless` with custom icons,
      colors, badge, `onTabChange` switching a body index; a customization showcase page
      (displayScale, maxWidth, backdrops).
- [ ] **Step 4: Run to verify it passes** — `flutter test` in `example/`.
- [ ] **Step 5: Build all targets** — `flutter build apk --debug`, `flutter build ios --simulator`,
      `flutter build web`. Verify all three succeed.
- [ ] **Step 6: Commit** — `git commit -am "feat: jelly tabs example app"`

## Phase 7 — Documentation, Release Prep, Review

### Task 7.1: Package docs

- [ ] **Step 1:** Write `packages/jelly_tabs/README.md` (usage, install, all props table — the
      Flutter equivalent of RN's `CUSTOMIZATION.md`).
- [ ] **Step 2:** Ensure dartdoc on every public member (`dart doc` clean).
- [ ] **Step 3: Commit** — `git commit -am "docs: package readme + dartdoc"`

### Task 7.2: VGV green-gate + review pass

- [ ] **Step 1:** Run `green-gate` skill across analyze/format/test/coverage until green with
      observed numbers.
- [ ] **Step 2:** Dispatch `flutter-reviewer` (vgv-ai-flutter-plugin) on the diff; fix findings.
- [ ] **Step 3:** Run `vgv-wingspan` `/review` (VGV standards, architecture, test quality,
      simplicity); address `FINDING-NN`s.
- [ ] **Step 4:** Final commit + tag `v0.1.0`.

## Definition of Done (whole project)

- [ ] `flutter analyze` clean; `dart format` clean; tests + goldens pass; coverage target met.
- [ ] Behavior parity: press/drag/long-press/snap/jelly-settle/velocity-shear verified vs RN demo.
- [ ] Example app builds and runs on Android, iOS, and Web.
- [ ] Public API matches `docs/design.md` §5; every default matches §5.5.
- [ ] PR opened with VGV review pass applied.
