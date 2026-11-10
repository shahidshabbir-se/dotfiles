# Pixel-perfect Omarchy UI — plan

Status: proposed. Supersedes the visual assumptions of
[0001-quickshell-shell.md](./0001-quickshell-shell.md).

Related: [ADR 0005](../adr/0005-pixel-perfect-omarchy-visual-parity.md),
[visual reference protocol](../visual-reference.md),
[spec 0002](../specs/0002-pixel-perfect-omarchy-ui.md).

## Principles

- Independent QML; Omarchy is a read-only reference.
- One surface per ticket, with its own reference capture and diff.
- Foundation first: harness, tokens, bar geometry.
- Behaviour is not regressed: the existing IPC/systemd tests keep running.
- A ticket without its reference capture is blocked, not "done by eye".

## Ticket graph

| # | Ticket | Blocked by |
|---|---|---|
| V1 | Reference pack and visual diff harness | None |
| V2 | Design tokens and typography | V1 |
| V3 | Bar shell geometry and chrome | V2 |
| V4 | Clock widget and calendar | V3 |
| V5 | Workspaces widget | V3 |
| V6 | Menu widget and menu surface | V3 |
| V7 | Indicators widget | V3 |
| V8 | Audio widget and panel | V3 |
| V9 | Network widget and panel | V3 |
| V10 | Bluetooth widget and panel | V3 |
| V11 | Battery and power widget/panel | V3 |
| V12 | Tray widget | V3 |
| V13 | Media widget | V3 |
| V14 | Weather widget and panel | V3 |
| V15 | Elsewhen, system update, keyboard layout, agents, monitor | V3 |
| V16 | Notification toasts and center | V3 |
| V17 | OSD | V3 |
| V18 | Dock | V3 |
| V19 | Clipboard panel | V3 |
| V20 | Emoji and image picker | V3 |
| V21 | Reminders panel | V3, V16 |
| V22 | Polkit dialog | V3 |
| V23 | Wallpaper service and picker | V3 |
| V24 | Animations and transitions | V3, V4-V18 |
| V25 | Full-desktop pixel audit | V1-V24 |

## Phases

- **V0 foundation:** V1-V3. Harness, tokens, 26px bar.
- **V1 bar:** V4-V15. Widgets, one at a time.
- **V2 overlays:** V16-V23. Panels, dialogs, wallpaper.
- **V3 finish:** V24-V25. Motion and full-frame audit.

## Reference dependency

The reference pack is the first blocker for every visual acceptance. The
harness and token work can start without it; the per-surface diffs cannot be
signed off until the corresponding capture exists.
