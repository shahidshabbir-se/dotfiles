# Known broken helpers

Helper status for the vendored Omarchy fork at
`vendor/omarchy` pin `255acd9b9f752478365a1207f499e5d558bf7f75`.
Everything here is about the NixOS integration, not about Omarchy's upstream
code.

Status meanings:

- **open** — the helper has no NixOS adaptation in this repo and is expected to
  fail, degrade, or is unproven on the target.
- **adapted** — the repo already supplies a NixOS equivalent or a wrapper, and
  the surface has been exercised.
- **not-needed** — we deliberately do not ship or run that helper; the reason
  says what replaces it.

The gaps below were found while bringing up the fork. Entries marked
**(static)** come from reading the vendored tree; they have not been exercised
live yet. Do not silently drop a helper from this list: if a live run finds a
new failure, add it here before calling the surface done.

## Helpers called by the default bar and shell

| Helper / gap | Surface | Evidence in the vendored tree | Status | Notes |
|---|---|---|---|---|
| `/usr/bin/python3` shebangs | 29 scripts in `vendor/omarchy/bin`; `InputMethodState.qml` | `grep -rl '^#!/usr/bin/python3' vendor/omarchy/bin`; `grep '/usr/bin/python3' vendor/omarchy/shell` | open | NixOS has no `/usr/bin/python3`. Patch shebangs to the Nix store interpreter, or wrap the scripts, when packaging `vendor/omarchy/bin`. The affected set includes 23 `omarchy-agent-usage-*` collectors, `omarchy-agent-account-state`, `omarchy-agent-account-transfer`, `omarchy-file-select`, `omarchy-dev-notification-demo`, `omarchy-dev-font`, and `omarchy-hw-software-rendering`. |
| Agent usage collectors | `omarchy.agents`, in the default bar | `bin/omarchy-agent-usage-update`, `bin/omarchy-agent-usage-*`, `shell/plugins/agents/collectors.py` | open | All Python collectors die on the shebang above. They also need the agent CLIs and credentials to produce records; an empty panel without those is expected, not a failure of the shell. |
| Clipboard `capture.sh` | `omarchy.clipboard` overlay | `shell/plugins/clipboard/capture.sh`, `Clipboard.qml` | open | `capture.sh` needs `wl-paste`, `setpriv`, `timeout`, `sha256sum`, `jq`, `perl` with core `Encode`/`JSON::PP`, and the vendored `omarchy-language`. `wl-clipboard` is installed in `modules/hyprland/desktop.nix`, but it is not on the systemd unit's pinned PATH. `setpriv` and `perl` are also not guaranteed there. The shebang is `#!/bin/bash`, which NixOS provides. |
| `.webp` decode in the shell background | Wallpaper layer | `shell/plugins/background/Background.qml` lists `.webp`; `Image` decodes the path | open | The repo installs `webp-pixbuf-loader`, which is a GTK loader and does not give Qt's `Image` a WebP plugin. Add the Qt image-format plugin (for example `qt6.qtimageformats`) to the shell environment, and check the AVIF/HEIC entries used by the image picker and Dropbox panel at the same time. Without it, WebP wallpapers fail to load or fall into the recovery path. |
| Input-method indicator | `omarchy.keyboard-layout`, in the default bar | `shell/Commons/InputMethodState.qml` hard-codes `/usr/bin/python3` and runs `default/input-methods/indicator.py`; `bin/omarchy-input-method`, `omarchy-setup-input`, `omarchy-setup-keyboard`, `omarchy-font-cjk`, and `omarchy-language` use `/usr/bin/python3` too | open | The indicator exits immediately on NixOS, then restarts every five seconds, so the keyboard widget has no input-method state. Fix the interpreter path and verify fcitx5 is packaged and running before claiming the widget works. |
| `inotifywait` | `omarchy.keyboard-layout` input-device watch; plugin registry watcher | `shell/Commons/InputDevices.qml`; `shell/services/PluginRegistry.qml` | open | `inotify-tools` is not in the repo or the unit PATH. Both watchers retry when the process dies; a missing binary means they never stay up. The plugin-registry reaper also needs `pgrep` and `ps` from `procps`. |
| `owe` | Video wallpaper transitions and boot intro | `shell/services/BackgroundSwitch.qml`; `shell/services/BackgroundIntro.qml` | open (static) | Static wallpapers are drawn by the shell. Video wallpapers and their transition/intro path call `owe render`, `owe intro`, and `owe render-status`. This repo ships `mpvpaper` and `awww`, not `owe`, so the video path is unproven. |

## Other gaps found in the vendored tree

| Helper / gap | Surface | Evidence in the vendored tree | Status | Notes |
|---|---|---|---|---|
| `pacman` package metadata | Menu app library; System Update widget | `shell/plugins/menu/MenuModel.js` builds `pacman -Qq`/`pacman -Qi` queries; `bin/omarchy-update-available` checks `pacman -Qq` | open (static) | There is no pacman on NixOS. The menu loses package descriptions and the System Update widget has no NixOS update check. Replace with a flake/`nix` check or hide the widget. |
| `uwsm-app` | Menu app library launch | `shell/services/AppLibrary.qml` runs `uwsm-app -- gtk-launch <id>.desktop` | open (static) | This repo does not use UWSM. Use `gtk-launch` or `gio launch` directly, or provide a wrapper. |
| `curl` | Weather widget and panel | `shell/plugins/panels/weather/Panel.qml` | open (static) | `curl` is not on the pinned unit PATH. |
| `nmcli` and `ip` | Network widget and panel | `shell/plugins/panels/network/Panel.qml`; `bin/omarchy-network-status` | open (static) | Needs NetworkManager and `iproute2` on the unit PATH. |
| `pactl` | Audio widget/panel and audio-input subscription | `shell/Commons/UntypedInput.qml`; `bin/omarchy-audio-*` helpers | open (static) | Needs the `pactl` client on the unit PATH. `wpctl` may already be available through the session, but the unit PATH is pinned. |
| `xkbcli` | Keyboard-layout widget | `shell/plugins/bar/widgets/KeyboardLayout.qml` | open (static) | Needs `xkbcommon` on the unit PATH for exotic layouts. |
| `fc-match` | Font resolution in the shell style | `shell/Commons/Style.qml` | open (static) | Needs `fontconfig` on the unit PATH; otherwise font tokens fall back. |
| `upower` | Battery widget and power panel | `bin/omarchy-battery-status` | open (static) | Needs `upower` on the unit PATH. `powerprofilesctl` is provided by the NixOS power-profile setup. |
| `find` | Agents panel and image picker | `shell/plugins/agents/Main.qml`; `shell/plugins/image-picker/ImagePicker.qml` | open (static) | Needs `findutils` on the unit PATH. |
| `pgrep` / `ps` | Plugin-registry watcher reaper | `shell/services/PluginRegistry.qml` | open (static) | Needs `procps` on the unit PATH. |
| `/usr/share/omarchy-platform/audio.json` and `display-cutouts.json` | Audio-node hints; bar cutouts | `shell/Commons/AudioNodes.qml`; `shell/plugins/bar/Bar.qml` | not-needed | These are fixed platform-package paths. Both readers handle a missing file (no hints, no cutouts), so the shell works without them. Add data only if a monitor needs a cutout or an audio node must be hidden. |
| Omarchy idle, lock, and screensaver helpers | `omarchy.idle`, `omarchy.lock` | `shell/plugins/services/idle/Service.qml`; `shell/plugins/lock/Service.qml` | not-needed | We disable both plugins. Hypridle owns idle/suspend and Qylock owns the lock screen, so the Omarchy helper paths (`omarchy-screensaver`, lock service) never run. |
| Passwordless-sudo indicator | `omarchy.indicators` | `shell/plugins/bar/indicators/PasswordlessSudo.qml`; `bin/omarchy-sudo-passwordless` | not-needed | We do not enable passwordless sudo. The helper assumes Arch sudoers layout and `/usr/bin` paths and is intentionally out of scope. |
| Arch package-management commands | Menu/system surfaces | `bin/omarchy-apply-pacman`, `omarchy-upgrade-to-quattro`, `omarchy-migrate`, `omarchy-reinstall-pkgs`, `omarchy-snapshot` | not-needed | Package management is NixOS's job. Do not wire these into the fork. |
| Agent account commands | Agents panel account switching | `bin/omarchy-agent-account-*` | open (static) | Python shebang problem above; `omarchy-agent-account-transfer` also hard-codes `/usr/bin/python3` and assumes ssh/sudo tooling. Account switching is unproven on NixOS. |

## Supervisor PATH note

Many rows above are the same root cause: `modules/quickshell.nix` pins a small
`runtimePath` so the systemd unit does not depend on the graphical session
environment. The rewire (ticket #56) owns that list; this document records what
the list must cover before a helper can move from **open** to **adapted**.

## Updating this list

When a live run exercises a helper:

1. Record the command, the surface, and the exact failure.
2. Change the status to **adapted** only when the NixOS replacement has been
   run against that surface. A package appearing in the store is not proof.
3. Keep **not-needed** entries, with the replacement named; do not delete them
   because a future sync may re-enable the surface.
4. Re-run the smoke checks in `vendor/omarchy/README.md` after a sync.
