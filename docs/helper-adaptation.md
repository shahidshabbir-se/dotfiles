# Helper adaptation for the vendored Omarchy shell

This note records the local modifications ticket #58 makes to
`config/quickshell/bin` and the helper path the systemd unit uses. It complements
[the vendored tree README](../config/quickshell/README.md) and
[the known broken list](known-broken-helpers.md); those two files are owned by
the upstream-sync ticket and are not edited here.

Scope: the default bar's menu, audio, network, Bluetooth, battery/power, and
brightness actions. The rest of the 500-command tree is untouched, and the
installer, pacman update flow, idle/lock, notifications, and polkit remain with
their own tickets.

## Shebangs

Every top-level script in `config/quickshell/bin` used `#!/bin/bash` or
`#!/bin/bash -p`. NixOS has no `/bin/bash`, so the kernel cannot exec them even
when the directory is first on `PATH`.

Mechanical local change:

- `#!/bin/bash` -> `#!/usr/bin/env bash`
- `#!/bin/bash -p` -> `#!/usr/bin/env bash`

That covers 558 vendored scripts (548 plain, 10 with `-p`); the new
`uwsm-app` shim below brings the directory to 559 bash scripts. `bash -p` was Omarchy's
privileged-mode guard; the helpers that act through the shell do not rely on it
on NixOS, and the scripts that need root already re-exec through sudo or
pkexec. Three shebangs embedded inside generated files or heredocs
(`omarchy-dev-benchmark-theme-switcher`, `omarchy-mise-install`,
`omarchy-upgrade-to-quattro`) are not script entry points and stay as they
were.

The 29 `#!/usr/bin/python3` scripts are **not** patched here; they are tracked
as an open gap in `docs/known-broken-helpers.md`.

## Replacements by surface

| Surface | Helper | Arch assumption | NixOS adaptation |
|---|---|---|---|
| Menu | `shell/services/AppLibrary.qml` | `uwsm-app -- gtk-launch` | Run `gtk-launch` directly; UWSM is not the session manager here. |
| Menu | all vendored launchers | `uwsm-app -- <command>` | New `config/quickshell/bin/uwsm-app` shim executes the command directly and rejects unknown options. |
| Menu | `omarchy-menu`, `omarchy-menu-select` | none found | They only need `OMARCHY_PATH` and `jq`, both on the unit path. |
| Audio | `omarchy-audio-output-sink` | `pactl get-default-sink` | Falls back to `wpctl inspect @DEFAULT_AUDIO_SINK@`; without `pactl` it returns the node itself instead of following a DSP sink. |
| Audio | `omarchy-audio-output-volume` | `pactl` get/set/mute | Uses `pactl` when present, otherwise `wpctl` for get-volume, mute, and set-volume. |
| Audio | `omarchy-audio-sink-availability` | `pactl list` | Without `pactl` it exits 0 with no rows, so every node stays available. |
| Audio | `omarchy-audio-output-switch` | `pactl` sink list | Fails clearly: cycling needs the sink list, which `wpctl` has no equivalent for. `pactl` is on the unit path below. |
| Audio | `omarchy-audio-input-mute` | `wpctl` | Fails clearly when `wpctl` is absent. |
| Network | `omarchy-network-status`, `omarchy-network-wifi-connected` | none beyond `ip`/`nmcli` | Tools added to the unit path. |
| Network | `omarchy-network-band` | `iw` | Fails clearly when `iw` is absent; `nmcli` alone cannot read the per-link SSID/frequency. |
| Network | `omarchy-network-qr` | `qrencode` | Fails clearly when `qrencode` is absent. |
| Network | `omarchy-network-speedtest` | `/usr/lib/omarchy/speedtest` | Prefer an `omarchy-speedtest` client on `PATH`, keep the old path as a fallback, and name the missing client. |
| Network | `omarchy-dns` | `/usr/bin/omarchy-dns`, writes `/etc/systemd/resolved.conf` and NetworkManager drop-ins | Read-only `omarchy dns` stays; applying a provider fails clearly and changes nothing because NixOS generates those files. |
| Bluetooth | `omarchy-bluetooth-device`, `omarchy-bluetooth-power` | `bluetoothctl`/`rfkill` | Fail clearly when the binaries are absent; they use the standard BlueZ and rfkill state on NixOS. |
| Battery/power | `omarchy-battery-status` | `upower` | Fails clearly when `upower` is absent. |
| Battery/power | `omarchy-powerprofiles-list`, `omarchy-powerprofiles-set` | `powerprofilesctl` | Fail clearly when `powerprofilesctl` is absent. |
| Brightness | `omarchy-brightness-display`, `omarchy-brightness-keyboard` | `brightnessctl` | Fail clearly when `brightnessctl` is absent. |
| Brightness | `omarchy-brightness-display-ddc` | `ddcutil` | Fails clearly when `ddcutil` is absent. |
| Brightness | `omarchy-hw-display` | `/usr/share/omarchy-platform/displays.conf` | The file is optional; a missing platform package keeps the default device order. |

The `/usr/share/omarchy-platform` reads in `omarchy-hw-display`,
`omarchy-brightness-display`, and `omarchy-menu-keybindings` already tolerate a
missing file. No NixOS package supplies those data files, so the reads stay
optional.

## Unit PATH

`modules/quickshell.nix` pins the systemd unit's `PATH` so it does not depend on
the graphical session. Ticket #56 established that list for the supervisor; this
ticket extends it with the binaries the surface helpers call:

- `pactl`, `pw-link`, `wpctl` (pulseaudio, pipewire, wireplumber)
- `nmcli`, `bluetoothctl`, `rfkill`, `ip`, `curl`, `qrencode`
- `upower`, `powerprofilesctl`
- `brightnessctl`, `ddcutil`
- `gtk-launch` (gtk3; the menu app library and the `uwsm-app` shim)
- `top`, `pgrep`, `ps` (procps), `find`, `awk`, `grep`, `sed`, `fc-match`,
  `xkbcli`

`iw` is not added: it is an explicit missing dependency for Wi-Fi band changes
and the helper says so. Add `pkgs.iw` to the unit path when band pinning is
needed.

## Verification

`config/quickshell/tests/helpers.sh` runs with no live Hyprland session. Every
helper invocation is under `timeout`, expected exit codes are explicit, and any
stderr containing a bad interpreter, `/usr/bin/`, `pacman`, `omarchy-pkg-`, or
a bare `command not found` fails the check. It also scans every file in
`config/quickshell/bin` for an approved shebang and runs `bash -n` over the
modified helpers.

Run it from the repository root:

```bash
bash config/quickshell/tests/helpers.sh
```

The shell still needs a live session to prove the panel UI end to end; see
`config/quickshell/README.md` for that procedure.

## Remaining gaps reported for the tracked list

- 29 `#!/usr/bin/python3` helpers (agent usage collectors, input-method,
  file-select, dev helpers).
- Menu package metadata and install/remove rows still use `pacman` in
  `MenuModel.js`; installer work is out of scope, and the guards degrade to
  "missing" rather than erroring.
- `xdg-terminal-exec` is absent, so `omarchy-launch-tui` and the menu's
  terminal entries cannot launch a terminal yet.
- `omarchy-audio-tuning` still expects `pactl` and the Arch LV2 path
  `/usr/lib/lv2/lsp-plugins.lv2`; speaker tuning is out of scope.
- `omarchy-network-speedtest` needs the Omarchy speedtest client; the helper now
  names it, but the client is not packaged here.
- `omarchy-brightness-display-apple` needs `sudo` and `asdcontrol` plus a
  hiddev device; it fails clearly when no device is present.
- `omarchy-menu-keybindings` still reads `/usr/share/omarchy-platform/key-names`
  and may call `xkbcli`; both are optional, and the platform file is absent.
- Other bar widgets (system update, weather, agents, tray, media) are not part
  of this ticket and keep their own gaps.
