---
type: Roadmap
title: flutter_jelly_tabs — Roadmap
description: Phased milestones and session-by-session delivery model for flutter_jelly_tabs, including the post-MVP backlog.
tags: [flutter, roadmap, jelly-tabs]
timestamp: 2026-08-08T00:00:00Z
---

# flutter_jelly_tabs — Roadmap

> **Date:** 2026-08-08
> Docs live in this `./docs` folder. Phase status is tracked with checkboxes and updated as work proceeds.

## Vision

A production-grade, dependency-free Flutter package — a jelly-like
animated tab bar — with exact behavior/parameter/config parity, shipped as a publishable package
with a cross-platform example, all built on the VGV AI harness.

## Phase Guide

Each phase produces a reviewable artifact and ends with a VGV quality gate. Phases build on each
other; `S1`/`S2` are the immediate next milestones.

### ✅ D0 — Documentation (this session) — DONE

- [x] `docs/design.md` — spec, API surface, defaults, behavior, parity matrix
- [x] `docs/architecture.md` — reference-to-Flutter module mapping, rendering/spring/gesture design
- [x] `docs/implementation-plan.md` — TDD task breakdown
- [x] `docs/roadmap.md` — this file
- [x] `docs/index.md` — index

### ✅ S1 — Scaffold (DONE — 2026-08-10)

- [x] Workspace: root `pubspec.yaml` (native pub workspaces), CI workflow, `.gitignore`
- [x] Vendor `reference/react-native-jelly-tabs/` @ pinned commit `67f47f2` for fidelity re-checks
- [x] `jelly_tabs` package from Very Good CLI template (`very_good_analysis`, barrel, `pumpApp`)
- [x] `dart pub get` at workspace root; gates green (analyze/format/test baseline)
- **Exit criteria:** clean repo, CI green, package + example scaffolding compiles.

### ✅ S2 — Core engine (DONE — 2026-08-10)

- [x] Config & defaults (design.md §5.4/§5.5) — `config.dart`, `defaults.dart`, `spring_config.dart`
- [x] Models — `JellyTabsItem`, `JellyTabsChangeEvent`, `JellyTabsIconProps`
- [x] Math engine — `animation_math.dart` (spring solver, easeOut, rubberBand, geometry),
      `pill_jelly_animation.dart` (frame stepping)
- [x] Controllers — `DistortionController`, `PillJellyController` (ticker + gestures)
- **Exit criteria:** pure-Dart engine fully unit-tested; no UI yet.

### ✅ S3 — Widgets (DONE — 2026-08-10)

- [x] `TouchFeedback`, `TabItem`, `PillMaskedView` + `PillPathClipper`
- [x] `JellyTabBarHeadless` static render (layers, clip, backdrops, badges)
- [x] Gesture layer (`Listener` pointer tracking, long-press) + semantics
- **Exit criteria:** interactive tab bar works in widget tests; goldens baseline committed.

### ✅ S4 — Example + parity validation (DONE — 2026-08-11)

- [x] Example app (VGV `flutter_app` template) — web/android/iOS
- [x] De-flavored Android/iOS so plain `flutter build apk --debug` / `ios --simulator` / `web` work
- [x] Home demo (`JellyTabBarHeadless` with icons/colors/badge/`onTabChange`) + customization
      showcase (`displayScale`, `maxWidth`, backdrops)
- **Exit criteria:** builds on all 3 targets; 10 example tests pass.

### ✅ S5 — Release hardening (DONE — 2026-08-11)

- [x] Package README (props/config tables = Flutter CUSTOMIZATION.md)
- [x] VGV green-gate (analyze/format/test/coverage) — 150 tests, 95.8% coverage
      (config/math at 100%)
- [x] `flutter-reviewer` + wingspan `/review` pass; fix findings
- [x] `v0.1.0` tag
- **Exit criteria:** review clean, release ready.

### 🔭 Post-MVP (deferred ideas — explicitly out of current scope)

- [x] Keyboard / focus support (web/desktop, no reference equivalent) — `FocusTraversalGroup` +
      `OrderedTraversalPolicy`, per-tab `Focus`, `Shortcuts`/`Actions` for arrow keys and
      Enter/Space → `activateTab`, theme `focusColor` ring, `focusable`/`focused` semantics.
      Implemented TDD (`keyboard_focus_test.dart`, 10 tests) in a post-MVP session.
- [ ] `JellyTabBar` GoRouter / `StatefulShellRoute.indexedStack` adapter (reactivation of the
      reference's navigation-integrated component) — headless-only was confirmed, so this is a
      future option.
- [ ] Router-agnostic shell helper (auto_route / custom navigator).
- [ ] Widgetbook catalog (VGV `ui-package` convention) for the package.
- [ ] `recording` mode polish / exportable animation recording for docs.
- [ ] Cursor/hover states for desktop/web (beyond reference parity).
- [ ] pub.dev publish + `flutter pub publish --dry-run` + changelog automation (release-please).
- [ ] Optional side-by-side automated fidelity harness: replay a recorded reference gesture
      sequence against the Dart engine and diff trajectories.

## Delivery Model

Work is executed in **dedicated sessions** (fresh context per phase), driven by the VGV harness:

| Layer | Tool |
| --- | --- |
| Standards (during build) | `vgv-ai-flutter-plugin` skills + `flutter-reviewer` agent |
| Workflow (plan→build→review) | `vgv-wingspan` (`/plan`, `/build`, `/review`) |
| Quality gates | `very_good_analysis`, `dart format`, `flutter test` + coverage, green-gate |
| Repo | monorepo (`packages/jelly_tabs` + `example`), native pub workspaces, GitHub Actions |

Each session's handoff is recorded by updating this roadmap's checkboxes and the
`docs/implementation-plan.md` checkboxes as tasks complete.
