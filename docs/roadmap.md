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

A production-grade, dependency-free Flutter port of `react-native-jelly-tabs` — a jelly-like
animated tab bar — with exact behavior/parameter/config parity, shipped as a publishable package
with a cross-platform example, all built on the VGV AI harness.

## Phase Guide

Each phase produces a reviewable artifact and ends with a VGV quality gate. Phases build on each
other; `S1`/`S2` are the immediate next milestones.

### ✅ D0 — Documentation (this session) — DONE

- [x] `docs/design.md` — spec, API surface, defaults, behavior, parity matrix
- [x] `docs/architecture.md` — RN→Flutter module mapping, rendering/spring/gesture design
- [x] `docs/implementation-plan.md` — TDD task breakdown
- [x] `docs/roadmap.md` — this file
- [x] `docs/index.md` — index

### 🚧 S1 — Scaffold (follow-up session 1)

- [ ] Monorepo: `melos.yaml`, root `pubspec.yaml`, CI workflow, `.gitignore`
- [ ] `jelly_tabs` package from Very Good CLI template (`very_good_analysis`, barrel, `pumpApp`)
- [ ] `melos bootstrap`; gates green (analyze/format/test baseline)
- **Exit criteria:** clean repo, CI green, package + example scaffolding compiles.

### ⏳ S2 — Core engine (follow-up session 2)

- [ ] Config & defaults (design.md §5.4/§5.5) — `config.dart`, `defaults.dart`, `spring_config.dart`
- [ ] Models — `JellyTabsItem`, `JellyTabsChangeEvent`, `JellyTabsIconProps`
- [ ] Math engine — `animation_math.dart` (spring solver, easeOut, rubberBand, geometry),
      `pill_jelly_animation.dart` (frame stepping)
- [ ] Controllers — `DistortionController`, `PillJellyController` (ticker + gestures)
- **Exit criteria:** pure-Dart engine fully unit-tested; no UI yet.

### ⏳ S3 — Widgets (follow-up session 3)

- [ ] `TouchFeedback`, `TabItem`, `PillMaskedView` + `PillPathClipper`
- [ ] `JellyTabBarHeadless` static render (layers, clip, backdrops, badges)
- [ ] Gesture layer (`Listener` pointer tracking, long-press) + semantics
- **Exit criteria:** interactive tab bar works in widget tests; goldens baseline committed.

### ⏳ S4 — Example + parity validation

- [ ] Example app (VGV `flutter_app` template) — web/android/iOS
- [ ] Side-by-side visual parity vs RN demo (https://jelly.felipe.software/)
- [ ] Behavior parity: press/drag/long-press/snap/jelly-settle/velocity-shear
- **Exit criteria:** builds on all 3 targets; visual/behavior parity confirmed.

### ⏳ S5 — Release hardening

- [ ] Package README (props/config tables = Flutter CUSTOMIZATION.md)
- [ ] VGV green-gate (analyze/format/test/coverage) — observed numbers
- [ ] `flutter-reviewer` + wingspan `/review` pass; fix findings
- [ ] `v0.1.0` tag
- **Exit criteria:** review clean, release ready.

### 🔭 Post-MVP (deferred ideas — explicitly out of current scope)

- [ ] `JellyTabBar` GoRouter / `StatefulShellRoute.indexedStack` adapter (reactivation of RN's
      navigation-integrated component) — headless-only was confirmed, so this is a future option.
- [ ] Router-agnostic shell helper (auto_route / custom navigator).
- [ ] Widgetbook catalog (VGV `ui-package` convention) for the package.
- [ ] `recording` mode polish / exportable animation recording for docs.
- [ ] Cursor/hover states for desktop/web (beyond RN parity).
- [ ] pub.dev publish + `flutter pub publish --dry-run` + changelog automation (melos/release-please).
- [ ] Optional side-by-side automated fidelity harness: replay a recorded RN gesture sequence
      against the Dart engine and diff trajectories.

## Delivery Model

Work is executed in **dedicated sessions** (fresh context per phase), driven by the VGV harness:

| Layer | Tool |
| --- | --- |
| Standards (during build) | `vgv-ai-flutter-plugin` skills + `flutter-reviewer` agent |
| Workflow (plan→build→review) | `vgv-wingspan` (`/plan`, `/build`, `/review`) |
| Quality gates | `very_good_analysis`, `dart format`, `flutter test` + coverage, green-gate |
| Repo | monorepo (`packages/jelly_tabs` + `example`), melos, GitHub Actions |

Each session's handoff is recorded by updating this roadmap's checkboxes and the
`docs/implementation-plan.md` checkboxes as tasks complete.
