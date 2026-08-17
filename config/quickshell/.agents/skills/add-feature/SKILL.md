---
name: add-feature
description: Add a new qs.features.* module with a public facade, internal types, qmldir, and composition wiring. Use when creating a new Quickshell capability (panel, popup, service).
---

Follow @docs/ARCHITECTURE.md. Do not invent a second layout.

## Layout

```text
features/<name>/
├── <Name>.qml          Public facade only
├── <Internal>.qml      Private implementation (as many as needed)
├── assets/             Optional, feature-owned
├── scripts/            Optional, feature-owned
└── qmldir
```

`qmldir`:

```
module qs.features.<name>
<Name> 1.0 <Name>.qml
internal <Internal> 1.0 <Internal>.qml
```

Every non-facade type is `internal`.

## Wire it

Import the facade only from `composition/ShellComposition.qml`:

```qml
import qs.features.<name> as <Name>Feature

<Name>Feature.<Name> {}
```

Cross-feature data goes through facade properties and signals. Never reach into another feature's child ids.

## Leave alone

- `shell.qml` stays `ShellRoot { ShellComposition {} }`.
- Do not create `shared/` types for a first consumer.
- Do not copy archived bar/island QML. Reference old logic if needed; invent the UI.
- Support both bar orientations when the feature attaches to the bar (`BAR_ORIENTATION=vertical` is real).
- Colors come from `qs.shared.theme` (`Colors`, `Constants`). Do not hardcode a parallel palette.

## After

Trust hot-reload. If the new module does not appear, `systemctl --user restart quickshell.service` and check `qs log`.
