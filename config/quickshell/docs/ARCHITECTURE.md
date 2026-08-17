# Quickshell architecture

The project scales by adding **feature modules**, not by adding global component
folders or wiring every window directly from `shell.qml`.

## Structure

```text
shell.qml                 Required Quickshell entry point
composition/              Cross-feature wiring and environment policy
features/<feature>/       One independently owned capability
shared/<module>/          Code used by at least two features
scripts/                  Shell-wide operational entry points
```

## Module rules

1. `shell.qml` only creates `ShellComposition`.
2. Each feature exposes one small facade through its `qmldir`.
3. Feature implementation types are marked `internal` in `qmldir`.
4. Assets, helper scripts, and configuration stay with their owning feature.
5. Move code into `shared/` only after a second feature needs the same behavior.
6. Features communicate through facade properties and signals, never child IDs.
7. Use `qs.*` project-root imports; avoid directory-depth imports such as `../../`.

## Adding a feature

```text
features/example/
├── Example.qml            Public facade
├── InternalPart.qml       Private implementation
├── assets/                Optional feature-owned resources
└── qmldir
```

```qmldir
module qs.features.example
Example 1.0 Example.qml
internal InternalPart 1.0 InternalPart.qml
```

Import the facade only in `composition/ShellComposition.qml`:

```qml
import qs.features.example as ExampleFeature

ExampleFeature.Example {}
```

This keeps the composition graph small even when the project contains thousands
of implementation files.
