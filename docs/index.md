---
okf_version: "0.1"
---

# flutter_jelly_tabs — Docs Index

A Flutter port of [`react-native-jelly-tabs`](https://github.com/felipe-software/react-native-jelly-tabs):
a jelly-like animated tab bar with exact behavior, appearance, parameters, and configuration parity,
delivered as a headless, dependency-free Flutter package. Built on the VGV AI harness
([`vgv-ai-flutter-plugin`](https://github.com/VeryGoodOpenSource/vgv-ai-flutter-plugin) +
[`vgv-wingspan`](https://github.com/VeryGoodOpenSource/vgv-wingspan)).

## Documents

- [design.md](./design.md) — Spec: goals, scope decisions, feature-parity matrix, public API, defaults, behavior, verification strategy
- [architecture.md](./architecture.md) — Technical design: RN→Flutter module mapping, rendering, spring engine, controllers, gestures, testing
- [implementation-plan.md](./implementation-plan.md) — TDD task-by-task build plan (scaffold → engine → widgets → example → release)
- [roadmap.md](./roadmap.md) — Phased milestones, session-by-session delivery model, post-MVP backlog
- [adr/](./adr/) — Architecture decision records (numbered, one decision each)

## How to Read Them

Start with **design.md** (what we're building and why), then **architecture.md** (how), then
**implementation-plan.md** (the ordered work), and **roadmap.md** (when, and what's deferred).

## Status

- **D0 — Docs:** ✅ done (grilled and revised 2026-08-10 — see `log.md`)
- **S1 — Scaffold:** not started (dedicated follow-up session). Very Good CLI upgraded to >= 1.3.0
  (2026-08-10) — no longer a blocker.
- **S2 — Core engine:** not started
- **S3 — Widgets:** not started
- **S4 — Example + parity:** not started
- **S5 — Release hardening:** not started
