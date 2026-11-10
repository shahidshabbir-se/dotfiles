## Problem Statement

I like how Omarchy manages its Quickshell desktop: one long-lived process, the
bar and panels as plugins, layout in `shell.json`, a supervised launcher, and
IPC for bindings. I run NixOS with my own Hyprland config, and I want that
management model without Omarchy's code, its Arch-oriented helper commands, or
its patched Quickshell. I also do not want my old hand-built shell restored.

Today the pieces are fragmented: my Quickshell module points at a config that
no longer exists, Quickshell is disabled, swaync is installed but not wired up,
and there is no notification service that belongs to the desktop. I want a
shell I own, shaped like Omarchy's, that keeps Vicinae, Qylock, and Hypridle
exactly as they are and takes over notifications. It also has to carry my
Tokyo Night palette and manage wallpapers from `~/Pictures/Wallpapers`,
including videos.

## Solution

Build an independent Quickshell shell in the repo's Quickshell config
directory, shaped like Omarchy's shell: one long-lived process, a static
registry of built-in plugins, a six-section bar driven by `shell.json`, a
systemd supervisor with monitor readiness and a lock-aware restart, a
notification service the shell owns, and raw Quickshell IPC for bindings. The
full Omarchy built-in plugin set is delivered in phases. Menu, lock, and idle
are delegated to Vicinae, Qylock, and Hypridle. The shell renders in a fixed
Tokyo Night palette and manages still and video wallpapers from
`~/Pictures/Wallpapers`.

## User Stories

1. As a desktop user, I want one long-lived shell process, so the bar, popups, and notifications share state instead of running separate daemons.
2. As a desktop user, I want the shell to start with my Hyprland session, so I never start it by hand.
3. As a desktop user, I want the shell supervised by systemd, so a crash restarts it without a re-login.
4. As a desktop user, I want shell logs in journald, so I can diagnose a failed start after a reboot.
5. As a desktop user, I want the bar to wait for a real monitor, so it never binds to a placeholder after DPMS or suspend.
6. As a desktop user, I want the bar to reappear after sleep, so I do not lose the desktop when the output comes back.
7. As a desktop user, I want six bar sections, so I can arrange widgets left, center, tray, and right the way Omarchy does.
8. As a desktop user, I want to place any plugin id in any section through shell config, so I can shape the bar without editing QML.
9. As a desktop user, I want widget options inline on the layout entry, so settings stay next to placement.
10. As a desktop user, I want shell config reloaded when I save it, so layout changes apply immediately.
11. As a desktop user, I want an unknown plugin id to fail loudly, so a typo never leaves a silently missing widget.
12. As a desktop user, I want only built-in plugins, so no third-party code runs inside my shell.
13. As a desktop user, I want a static registry, so the set of plugins is auditable in one place.
14. As a desktop user, I want a workspaces widget, so I can see and switch workspaces.
15. As a desktop user, I want a clock with a calendar popup, so I can check the date and time.
16. As a desktop user, I want an audio widget and popup, so I can see and change volume and output.
17. As a desktop user, I want a network widget and popup, so I can see and change connectivity.
18. As a desktop user, I want a bluetooth widget and popup, so I can connect devices.
19. As a desktop user, I want battery and power widgets, so I can see charge and act on the power state.
20. As a desktop user, I want a media widget, so I can see and control playback.
21. As a desktop user, I want a weather widget, so I can see the forecast without opening a browser.
22. As a desktop user, I want a tray, so application indicators have a home in the bar.
23. As a desktop user, I want an OSD, so volume and brightness changes give feedback.
24. As a desktop user, I want clipboard, emoji, image picker, and reminder panels, so those tasks do not need another app.
25. As a desktop user, I want the notification service inside the shell, so toasts and history match the bar.
26. As a desktop user, I want swaync removed, so two notification daemons cannot race for the bus name.
27. As a desktop user, I want toasts with app name, icon, summary, body, and actions, so I can act on notifications.
28. As a desktop user, I want a notification center with history, so I can review what I missed.
29. As a desktop user, I want unread counts, so I know when something new arrived.
30. As a desktop user, I want do-not-disturb, so I can silence interruptions.
31. As a desktop user, I want do-not-disturb and the notification center reachable from the keyboard, so I do not need the mouse.
32. As a desktop user, I want the bar launcher button to open Vicinae, so my existing launcher workflows stay intact.
33. As a desktop user, I want Qylock to remain my lock screen, so its appearance and behaviour do not change.
34. As a desktop user, I want Hypridle to remain my idle manager, so suspend-then-hibernate and HDR recovery keep working.
35. As a desktop user, I want restart to refuse while the session is locked, so I cannot strand myself behind the lock screen.
36. As a desktop user, I want restart to wait for notifications and IPC, so the desktop is usable when the command returns.
37. As a desktop user, I want a failed unit to be reset before restart, so a crash loop does not leave the shell permanently failed.
38. As a desktop user, I want bindings to call Quickshell IPC directly, so there is no wrapper CLI to maintain.
39. As a desktop user, I want IPC targets named after plugins, so commands read the same as the layout.
40. As a desktop user, I want the bar on every monitor, so every screen is usable.
41. As a desktop user, I want the bar at the top with a 36px height, so the desktop keeps its current shape.
42. As a desktop user, I want Catppuccin Mocha with a blue accent, so the shell matches my GTK theme.
43. As a developer, I want a plugin to be a folder plus one registry entry, so adding one is predictable.
44. As a developer, I want shared UI primitives, so widgets and popups look and behave consistently.
45. As a developer, I want one shared theme and style module, so colour, spacing, and type changes happen in one place.
46. As a developer, I want phases that each end usable, so I can daily-drive the shell while parity grows.
47. As a developer, I want a single acceptance harness, so I can prove behaviour without reading QML internals.
48. As a developer, I want the harness to assert D-Bus ownership, so I know the shell owns notifications.
49. As a developer, I want the harness to assert IPC ping and targets, so regressions are caught.
50. As a developer, I want the harness to assert shell config reload, so layout changes are tested.
51. As a developer, I want the harness to assert restart and lock behaviour, so lifecycle changes are safe.
52. As a desktop user, I want drag-to-arrange to write shell config later, so I can arrange widgets with the mouse.
53. As a desktop user, I want the shell rendered in Tokyo Night, so the bar and popups match my terminals and launcher.
54. As a desktop user, I want wallpapers only from `~/Pictures/Wallpapers`, so there is one place for backgrounds.
55. As a desktop user, I want to pick a wallpaper from a panel, so I can change it without a terminal.
56. As a desktop user, I want still images applied through awww, so scaling and transitions match my desktop.
57. As a desktop user, I want videos played through mpvpaper, so I can use animated wallpapers.
58. As a desktop user, I want switching from a video to a still to stop the video, so backgrounds do not overlap.
59. As a desktop user, I want the chosen wallpaper to return at login, so I do not re-pick it.
60. As a desktop user, I want a clear unavailable state when a wallpaper file is missing, so a deleted file does not break the shell.
61. As a desktop user, I want the remaining built-ins (tailscale, agents, elsewhen, nightlight, remote session, dock, polkit) in later phases, so parity is complete.

## Implementation Decisions

- **Own the shell, borrow only the shape.** The shell is our QML. No Omarchy source, no Arch helper commands, no patched Quickshell snapshot, and no third-party NixOS port. See ADR 0001.
- **Static registry, not a manifest host.** Each built-in plugin is a folder plus one entry in a single registry keyed by plugin id. There is no discovery, no manifest, no settings schema, and no enable/disable state. An unknown id fails at load. See ADR 0003.
- **`shell.json` is the layout contract.** Versioned shell config holds bar position and the six ordered sections; widget options are inline on each entry. No idle block, because Hypridle owns idle. Shape:

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
        "left": [],
        "centerBegin": [],
        "center": [{ "id": "clock", "format": "ddd HH:mm" }],
        "centerEnd": [],
        "tray": [],
        "right": []
      }
    }
  }
  ```

- **Shell config is watched.** A config service loads the file and reloads the layout when it changes; the bar rebuilds from the new plan without a process restart.
- **One bar surface per monitor.** The bar renders all six sections in order, on every real output, with widget options applied on load.
- **Plugin folder contract.** A plugin folder holds its entry component, its popups, and its helpers; the registry maps id to entry; shared chrome lives in shared UI primitives; code moves to shared modules only after a second plugin needs it.
- **The shell owns notifications.** A notification service owns `org.freedesktop.Notifications` and provides toasts, history, unread state, and do-not-disturb, plus a bar indicator. The swaync package is removed so D-Bus activation cannot race the shell.
- **Systemd supervises the shell.** A user service with `Type=exec`, `Restart=always`, `RestartSec=2`, `StartLimitIntervalSec=60`, `StartLimitBurst=5`, `After`/`PartOf`/`WantedBy=graphical-session.target`, `ConditionEnvironment=WAYLAND_DISPLAY`, and `KillMode=control-group`. The launch script derives the Hyprland signature when missing, waits for a real monitor, then execs Quickshell. See ADR 0002.
- **Restart is one audited path.** The restart script refuses while `LockedHint` is set, resets a failed unit, restarts it, then waits for the notification bus name and an IPC ping before returning.
- **Raw IPC.** Hyprland bindings call `quickshell ipc call <target> <method>` directly; targets are named after plugins; there is no wrapper CLI. The restart script is lifecycle, not IPC. See ADR 0004.
- **Delegations.** Menu is a bar launcher button that runs Vicinae. Lock remains Qylock. Idle remains Hypridle. The shell implements none of those three.
- **Phased parity.** Phase 0: foundation, bar, workspaces, clock, launcher, notifications. Phase 1: wallpaper service and picker, then audio, network, bluetooth, battery, power, tray, media, weather, monitor, keyboard layout, microphone, indicators, spacer, system update. Phase 2: OSD, clipboard, emojis, image picker, reminders. Phase 3: tailscale, agents, elsewhen, nightlight, remote session, dock, polkit. Phase 4: drag-to-arrange writing shell config and animations.
- **Theme is fixed to Tokyo Night.** One palette and style set for the shell; there is no theme switcher and no app retinting. SF Pro Display for UI, SpaceMono Nerd Font for monospace, 36px top bar on every monitor.
- **Wallpaper service.** The wallpaper directory is `~/Pictures/Wallpapers`. Stills are applied through awww; videos are played through mpvpaper. The chosen file persists in shell config and is restored when the shell starts. Switching from a video to a still stops the video process; a missing file yields a clear unavailable state.
- **Wallpaper picker.** A panel lists images and videos from the wallpaper directory and applies the chosen file on every monitor.
- **Wallpaper state lives in shell config.** The `wallpaper` block holds the directory and the selected file, so one canonical file describes the desktop.
- **Nix wiring stays in Home Manager.** The shell is a user session service, not a NixOS module. The config directory is a live symlink into the repo so QML and `shell.json` edits take effect immediately. Quickshell comes from nixpkgs; a newer snapshot is pinned only if a needed fix is missing.
- **Domain docs govern vocabulary.** Plugin, bar section, widget, popup, panel, shell config, layout, theme, wallpaper, wallpaper picker, notification service, supervisor, restart, IPC call, and monitor readiness mean what `GLOSSARY.md` says. ADR conflicts must be surfaced, not silently overridden.

## Testing Decisions

- A good test asserts observable behaviour at the session boundary: systemd unit state, D-Bus ownership, IPC responses, notification flow, shell config reload, and restart semantics. It does not import QML internals or assert component structure.
- One seam: a live-session acceptance harness that runs in the real Hyprland session after a switch. It is manual for now and reusable as the driver of a future NixOS VM check.
- Cases the harness must cover: the unit is active and journald has no QML errors; the notification bus name is owned by the shell; `notify-send` appears in history; do-not-disturb suppresses it; editing `shell.json` changes the layout reported over IPC; `shell ping` and every registered target answer; `qs-restart` refuses while locked and returns only after notifications and IPC are ready; swaync is absent; the bar returns after DPMS and suspend; a chosen still applies through awww; a chosen video plays through mpvpaper and stops when replaced by a still; the saved wallpaper returns after a shell restart.
- No QML unit tests for layout or visuals. Pure config parsing is exercised through the config/IPC seam, not through imports.
- Prior art: none in this repo. The harness is new and Phase 0 is where it is proven.

## Out of Scope

- Third-party plugins, a plugin marketplace, manifests, plugin settings schemas, and enable/disable state.
- Omarchy source, Arch helper commands, the patched Quickshell snapshot, SDDM theming, and the Omarchy application installer.
- Replacing Vicinae, Qylock, or Hypridle, and implementing shell menu, lock, or idle plugins.
- Multiple themes, theme switching, app retinting from templates, login intro videos, and drag-to-arrange until Phase 4.
- Non-Hyprland compositors and multi-user desktops.

## Further Notes

- Phase 0 is the first implementation unit; notifications must work before swaync is removed.
- The shell's design plan and the four ADRs are in the repo's docs tree and should be read before implementation.
- The issue tracker for this repo is GitHub Issues; this spec is published as an issue labelled `ready-for-agent`.
