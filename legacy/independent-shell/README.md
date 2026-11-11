# Legacy independent shell

This directory is the archived independent Quickshell shell: the QML we wrote
before [ADR 0006](../../docs/adr/0006-fork-omarchy-shell.md) replaced it with
the vendored Omarchy fork.

It is **not shipped**. The shipped shell is
[`config/quickshell/shell`](../../config/quickshell/shell), started by the systemd
user unit through `config/quickshell/scripts/launch.sh`. Nothing in the
supervisor or the NixOS configuration should load this tree.

## Contents

- `Commons/`, `Ui/`, `composition/`, `plugins/`, `Registry/`, `services/`:
  the independent shell's QML and JavaScript modules.
- `shell.qml`: the independent shell entry point.
- `shell.json`: the independent shell's layout and widget options.
- `tests/qml/`: QtTest cases that import these modules by relative path.

The QML test imports stay valid because the tests moved with the modules at the
same relative depth.

## Why it is kept

- It records the management model, supervisor contract, IPC surfaces, and
  behaviour that predate the fork.
- Some non-QML tests still live in `config/quickshell/tests` and exercise this
  tree:
  - `calendar-grid.test.mjs`, `notifications-format.test.mjs`,
    `notifications-history.test.mjs`, and `remote-session-format.test.mjs`
    import the archived JavaScript modules by relative path.
  - `polkit.sh` and `remote-session.sh` run the archived plugins offscreen.
  - `calendar.sh` and `layout-ipc.sh` are live harnesses for the archived
    shell. They target `legacy/independent-shell` by default and only work if
    that shell is started manually; they do not test the shipped fork.
  - `tests/notifications.sh` is the archived independent shell's live
    notification harness, moved here so it cannot be mistaken for the shipped
    Omarchy ownership test.
- It is reference material for the supervisor tests (`launch.sh`,
  `restart.sh`) and for any behaviour the fork must preserve.

## Status

Archived, read-only. Do not add features here and do not point the supervisor
back at it. New shell work belongs in the vendored fork or in our integration
code, not in this tree.
