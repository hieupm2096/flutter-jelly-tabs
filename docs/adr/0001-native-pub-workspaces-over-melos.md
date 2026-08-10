# Use Dart's native pub workspaces instead of melos

`architecture.md`'s original package layout left the root `pubspec.yaml` marked
"workspace root (optional; see plan)," and `roadmap.md`'s Delivery Model table listed melos as
the repo tool — the VGV default for monorepos. For a repo with exactly one package
(`jelly_tabs`) plus an `example` app, melos's scripts (`bootstrap`, cross-package `run`, version
bumping) buy little, and Dart's native `resolution: workspace` (stable since Dart 3.6) covers
shared dependency resolution without an extra dev dependency. Decided to use native pub
workspaces for `flutter_jelly_tabs`; revisit if the repo grows to multiple publishable packages
where melos's scripting conveniences start to earn their keep.
