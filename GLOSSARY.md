# Quickshell Desktop

The desktop shell is a fork of Omarchy: its QML is vendored under
`config/quickshell/shell`, and our integration rewires it to the systemd
supervisor, config ownership, monitor readiness, and NixOS helper commands.
`OMARCHY_PATH` points at `config/quickshell`; the user shell config is
`config/omarchy/shell.json`. The old independent shell is archived at
`legacy/independent-shell` and is not shipped.

## Language

### The shell and its parts

**Shell**:
The single long-running Quickshell process that owns the bar, popups, panels,
and notification service.
_Avoid_: bar, desktop, compositor, status bar

**Composition**:
The top-level wiring that instantiates the shell, its services, and its bar.
The shipped fork uses Omarchy's `shell.qml`; this term describes the legacy
independent shell's `composition/` layer.
_Avoid_: root, shell file

**Plugin**:
A capability under `config/quickshell/shell/plugins/<id>/` with Omarchy's
`manifest.json`. The fork's plugin host mounts first-party plugins; local
plugins live under `~/.config/omarchy/plugins/`. The legacy independent shell
had built-in plugins mapped by its static registry.
_Avoid_: feature, addon, extension, module, third-party plugin

**Plugin entry**:
The QML component the registry returns for a plugin id.
_Avoid_: facade, entry point, loader

**Registry**:
Omarchy's `PluginRegistry.qml`, the manifest-driven host for first-party and
local plugins. The legacy independent shell used a static `Registry.qml` keyed
by plugin id.
_Avoid_: loader, host, plugin manager, discovery

**Shared module**:
Omarchy's `Commons/` and `Ui/` modules that more than one plugin imports. The
legacy independent shell had its own `Commons/` and `Ui/`; those moved to
`legacy/independent-shell`.
_Avoid_: utils, common, helpers

### Surfaces

**Bar**:
The always-visible surface that renders the layout and hosts widgets.
_Avoid_: panel, topbar, taskbar

**Widget**:
A plugin mounted in a bar section, such as the clock or workspaces.
_Avoid_: module, applet, plugin

**Bar section**:
One of the ordered places a widget can sit: `left`, `centerBegin`, `center`,
`centerEnd`, `tray`, `right`.
_Avoid_: zone, slot, cluster

**Popup**:
A surface a widget opens next to the bar (audio, network, calendar).
_Avoid_: panel, dialog, window

**Panel**:
A full floating surface summoned for a task (wallpaper picker, window
overview).
_Avoid_: popup, overlay, window

### Configuration

**Layout**:
The part of shell config that says which plugin ids occupy which bar section
and in what order.
_Avoid_: config, arrangement

**Widget options**:
Settings written inline on a widget's layout entry.
_Avoid_: config block, settings object

**Shell config**:
`config/omarchy/shell.json`, our user state for the fork: layout and widget
options. It is symlinked to `~/.config/omarchy/shell.json` and is the copy the
shell reads; the vendored `config/quickshell/config/omarchy/shell.json` is the
fallback. The legacy independent shell's config is
`legacy/independent-shell/shell.json`.
_Avoid_: settings file, config.json, preferences

### Appearance

**Theme**:
The fixed Tokyo Night palette and style tokens the shell renders with. There is one theme and no theme switch.
_Avoid_: theme set, colour scheme, skin

**Wallpaper**:
The desktop background the shell applies to every monitor, either a still image or a video.
_Avoid_: background, backdrop, desktop image

**Still wallpaper**:
A wallpaper image applied through awww.
_Avoid_: static background, image wallpaper

**Video wallpaper**:
A wallpaper video. The shipped fork's transition path calls Omarchy's OWE
renderer, which this repo does not package; that path is a known gap. The
independent shell used mpvpaper.
_Avoid_: animated background, live wallpaper

**Wallpaper picker**:
The panel that lists the wallpaper directory and applies a chosen still or video.
_Avoid_: background picker, image picker

**Wallpaper directory**:
`~/Pictures/Wallpapers`, the only source of wallpapers.
_Avoid_: backgrounds folder, wallpaper library


**Reference UI**:
The Omarchy desktop running on the user's other machine, in Tokyo Night, at
3440x1440 with a 1.33 scale.
_Avoid_: target, upstream, screenshot

**Reference capture**:
A screenshot of one desktop surface taken from the reference UI under the
capture protocol.
_Avoid_: screenshot, mockup, comp

**Visual parity**:
Our surface matches its reference capture in geometry, colour, typography, and
interaction state within the defined comparison threshold.
_Avoid_: similarity, lookalike, inspired by

**Visual harness**:
The script that captures our surface, crops the measured region, and compares
it with the reference capture.
_Avoid_: screenshot test, visual test, pixel test

**Design token**:
A named colour, spacing, radius, or type value taken from the reference theme.
_Avoid_: constant, magic value

**Pixel audit**:
The final full-desktop comparison against the reference UI.
_Avoid_: final review, visual check


**Legacy independent shell**:
The QML we wrote before the fork, archived at `legacy/independent-shell`. It is
reference material only and is not loaded by the supervisor.
_Avoid_: old shell, previous shell

**Vendored shell**:
Omarchy's `shell/`, themes, config defaults, and helpers copied into
`config/quickshell` at a pinned upstream commit. This is the shipped shell; see
`config/quickshell/README.md` for the sync procedure.
_Avoid_: upstream, dependency, submodule

**Upstream pin**:
The exact Omarchy commit the vendored shell came from; updates are deliberate
merges, not automatic.
_Avoid_: latest, branch, version

**Rewire**:
Adapting the vendored shell to our supervisor, config paths, theme state, and
NixOS helper commands without rewriting its QML.
_Avoid_: port, translate, rebuild

**Helper adaptation**:
Replacing an Arch-specific `omarchy-*` command with a NixOS equivalent or a
recorded known-broken entry.
_Avoid_: stub, shim, workaround


### Services the shell owns or defers to

**Notification service**:
The plugin that owns the `org.freedesktop.Notifications` bus name and renders
toasts, history, unread state, and do-not-disturb.
_Avoid_: notifier, daemon, OS notifications

**Launcher**:
Vicinae. It is not part of the shell; the shell at most triggers it.
_Avoid_: menu, runner, shell launcher

**Lock**:
Qylock. A separate Quickshell process, not a shell plugin.
_Avoid_: lockscreen, screen lock, shell lock

**Idle**:
Hypridle. It decides when to lock, blank, and suspend; it is not a shell
plugin.
_Avoid_: idle service, timeout

### Lifecycle and control

**Supervisor**:
The systemd user service and launch script that own the shell's lifecycle:
start order, crash restart, and logs.
_Avoid_: launcher, manager, daemon

**Restart**:
Replacing the running shell process without ending the session, through
`qs-restart`, so the lock check and notification readiness always run.
_Avoid_: reload, reseat

**IPC**:
Quickshell's own IpcHandler command surface, reached with
`quickshell ipc call <target> <method> [args]`.
_Avoid_: API, socket, RPC

**IPC call**:
The literal `quickshell ipc call` invocation used directly from bindings and
scripts. There is no wrapper command.
_Avoid_: client, qsctl, helper

**Monitor readiness**:
The condition that Hyprland reports a real output, not the fallback or a
placeholder, before the bar binds to it.
_Avoid_: screen wait, output check
