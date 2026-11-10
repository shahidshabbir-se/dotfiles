# Quickshell Desktop

Our own Quickshell-based desktop shell: independent QML in `config/quickshell`,
shaped like Omarchy's shell (one long-lived process, declarative layout,
supervised lifecycle, IPC) but containing none of its code and loading no
external plugins.

## Language

### The shell and its parts

**Shell**:
The single long-running Quickshell process that owns the bar, popups, panels,
and notification service.
_Avoid_: bar, desktop, compositor, status bar

**Composition**:
The top-level wiring that instantiates the shell, its services, and its bar.
_Avoid_: root, shell file

**Plugin**:
A built-in capability under `plugins/<id>/` that the registry maps to an entry
component. It ships with the shell; nothing is discovered or loaded from
outside the tree.
_Avoid_: feature, addon, extension, module, third-party plugin

**Plugin entry**:
The QML component the registry returns for a plugin id.
_Avoid_: facade, entry point, loader

**Registry**:
`Registry.qml`, the single static map from plugin id to entry component.
_Avoid_: loader, host, plugin manager, discovery

**Shared module**:
Code under `shared/` that a second plugin already needs. Code moves there only
after the second need appears.
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
`shell.json`, the canonical user state for the shell: layout and widget
options. Live-editable from the repo and reloaded when it changes.
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
A wallpaper video played through mpvpaper.
_Avoid_: animated background, live wallpaper

**Wallpaper picker**:
The panel that lists the wallpaper directory and applies a chosen still or video.
_Avoid_: background picker, image picker

**Wallpaper directory**:
`~/Pictures/Wallpapers`, the only source of wallpapers.
_Avoid_: backgrounds folder, wallpaper library


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
