# Quickshell shell — implementation plan

Status: superseded by [0002-pixel-perfect-ui.md](./0002-pixel-perfect-ui.md)
for visual direction and by
[0003-omarchy-fork-rewire.md](./0003-omarchy-fork-rewire.md) for the shipped
shell. The independent QML is archived at `legacy/independent-shell`.

Related: [ADR 0001](../adr/0001-own-shell-not-omarchy-code.md) (own shell, no
Omarchy code), [ADR 0002](../adr/0002-systemd-supervises-the-shell.md)
(systemd supervision), [ADR 0003](../adr/0003-static-plugin-registry.md)
(static registry), [ADR 0004](../adr/0004-raw-ipc-no-cli.md) (raw IPC, one
restart script).

## Target

An independent Quickshell shell in `config/quickshell`, shaped like Omarchy's:

- one long-lived process, started and restarted by a systemd user service;
- `shell.qml` → `composition/ShellComposition.qml` → registry, bar, services;
- six bar sections (`left`, `centerBegin`, `center`, `centerEnd`, `tray`,
  `right`) rendered from `shell.json`;
- plugins as folders under `plugins/<id>/`, mapped by a static `Registry.qml`;
- notifications owned by the shell; swaync removed;
- a fixed Tokyo Night palette and wallpapers from `~/Pictures/Wallpapers`
  (stills through awww, videos through mpvpaper);
- no third-party plugin loading, no manifest host, no IPC wrapper CLI.

The full Omarchy built-in set is the target, delivered in phases. Three
Omarchy plugins are delegated instead of reimplemented, because the existing
tools stay: `menu` → Vicinae, `lock` → Qylock, `idle` → Hypridle.

## Plugin map

| Phase | Plugins |
|---|---|
| **0 — foundation** | `bar`, `notifications` (service + indicator + toasts + center + DND), `workspaces`, `clock` (with calendar popup), `launcher` (Vicinae button) |
| **1 — bar parity** | `wallpaper`, `wallpaperPicker`, `audio`, `network`, `bluetooth`, `battery`, `power`, `tray`, `media`, `weather`, `monitor`, `keyboardLayout`, `microphone`, `indicators`, `spacer`, `systemUpdate`, `tailscale`, `agents`, `elsewhen` |
| **2 — panels** | `osd`, `clipboard`, `emojis`, `imagePicker`, `reminders` |
| **3 — services** | `polkit`, `nightlight`, `dock`, `remoteSession` |
| **4 — polish** | drag-to-arrange widgets writing `shell.json`, animations |
| **delegated** | `menu` (Vicinae), `lock` (Qylock), `idle` (Hypridle) |

Phase 1 entries marked `tailscale`, `agents`, `elsewhen`, and Phase 3
`nightlight`, `remoteSession`, `dock`, `polkit` are parity items. Drop any
you do not use; none of them blocks the rest.

## Phase 0 — first implementation unit

Goal: replace swaync and stand up the managed shell, without touching the
rest of the desktop.

1. **Skeleton** in `config/quickshell/`:
   - `shell.qml`: `ShellRoot { ShellComposition {} }`.
   - `composition/ShellComposition.qml`: config service, notification service,
     registry, bar.
   - `Commons/`: `Color` (Tokyo Night palette), `Style` (spacing, radii, type
     scale), `Util`.
   - `Ui/`: `BarWidget`, `BarIconButton`, `Popup`.
   - `Registry.qml`: static id → component map.
   - `services/Config.qml`: loads and watches `shell.json`.
   - `plugins/bar/Bar.qml`: six sections, `Repeater` + `Loader` over each
     section's ids, options applied on load.
   - `plugins/workspaces/`, `plugins/clock/`, `plugins/launcher/`.
2. **Notification service** `plugins/notifications/`:
   - `NotificationServer` owning `org.freedesktop.Notifications`;
   - toast stack, history center, unread count, do-not-disturb;
   - bar indicator widget.
3. **Lifecycle**:
   - `scripts/launch.sh`: derive `HYPRLAND_INSTANCE_SIGNATURE` when missing,
     wait for a real monitor, then `exec quickshell -p`.
   - `scripts/restart.sh` (installed as `qs-restart`): refuse while
     `LockedHint` is set, `reset-failed`, restart the unit, wait for the
     notification bus name and a `shell ping` IPC call.
4. **Nix wiring** (`modules/quickshell.nix`):
   - enable the import in `hosts/nix/home.nix`;
   - `home.packages`: `quickshell`, `qt6.qtdeclarative`, `qt6.qtsvg`,
     `qt6.qtmultimedia`, `libnotify` (already present);
   - `xdg.configFile.quickshell.source = mkOutOfStoreSymlink
     "${homeDirectory}/dotfiles/config/quickshell"`;
   - systemd unit: `Type=exec`, `Restart=always`, `RestartSec=2`,
     `StartLimitIntervalSec=60`, `StartLimitBurst=5`,
     `After`/`PartOf`/`WantedBy=graphical-session.target`,
     `ConditionEnvironment=WAYLAND_DISPLAY`, `KillMode=control-group`.
5. **Remove swaync**: delete `swaynotificationcenter` from
   `modules/hyprland/desktop.nix` so D-Bus activation cannot race the shell.
6. **Bindings** (raw IPC): notification center toggle and DND toggle in
   `modules/hyprland/bindings.nix`.

### Phase 0 verification

- `systemctl --user status quickshell` is active; `journalctl --user -u
  quickshell -b` has no QML errors.
- `notify-send test body` shows a toast, appears in the center, and is
  suppressed by DND.
- `busctl --user get-property org.freedesktop.DBus /org/freedesktop/DBus
  org.freedesktop.DBus NameHasOwner s org.freedesktop.Notifications` is true
  and the owner is the shell.
- No `swaync` process or D-Bus activation entry exists after a switch.
- Bar appears on every real monitor, and returns after DPMS and suspend.
- `qs-restart` refuses while locked, succeeds while unlocked, and does not
  return before notifications and IPC answer.

## File tree

```text
config/quickshell/
├── shell.qml
├── shell.json
├── composition/ShellComposition.qml
├── Commons/{Color.qml,Style.qml,Util.qml,qmldir}
├── Ui/{BarWidget.qml,BarIconButton.qml,Popup.qml,qmldir}
├── Registry.qml
├── services/Config.qml
├── plugins/
│   ├── bar/Bar.qml
│   ├── workspaces/Workspaces.qml
│   ├── clock/{Clock.qml,CalendarPopup.qml}
│   ├── launcher/Launcher.qml
│   └── notifications/{Service.qml,Indicator.qml,ToastStack.qml,Center.qml}
└── scripts/{launch.sh,restart.sh}
```

Later phases add one folder per plugin under `plugins/` and one registry entry
each.

## shell.json

```json
{
  "version": 1,
  "wallpaper": {
    "directory": "~/Pictures/Wallpapers",
    "file": "night.png"
  },
  "bar": {
    "position": "top",
    "layout": {
      "left":        [{ "id": "workspaces" }],
      "centerBegin": [],
      "center":      [{ "id": "clock", "format": "ddd HH:mm" }],
      "centerEnd":   [],
      "tray":        [],
      "right":       [{ "id": "notifications" }, { "id": "launcher" }]
    }
  }
}
```

Widget options are inline on the entry, as in Omarchy. There is no
`idle` block: Hypridle owns it.

## Nix wiring (exact shape)

`modules/quickshell.nix` stays a Home Manager module; it does not become a
NixOS module. The systemd unit is a user unit so the shell lives in the user
session, and the config is a live symlink so editing QML or `shell.json` takes
effect immediately.

`qs-restart` is a `writeShellScriptBin` in `home.packages`, not a file managed
by `xdg.configFile`, so it is on `PATH` for bindings.

## Defaults taken unless you object

- Theme: fixed Tokyo Night palette; no theme switcher, no app retinting.
- Wallpapers: only `~/Pictures/Wallpapers`; stills through awww, videos through
  mpvpaper; the selected file persists in `shell.json`.
- Bar on every monitor, `position: "top"`, 36px horizontal.
- Quickshell from nixpkgs; pin a newer snapshot only if a needed fix is
  missing.
- File watcher left on: editing QML or `shell.json` reloads the shell.
- `tailscale`, `agents`, `elsewhen`, `nightlight`, `remoteSession`, `dock`
  stay in the phase plan but are cut if unused.
