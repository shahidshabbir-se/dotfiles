## Problem Statement

The independent shell has Omarchy's management model but not its UI. Rebuilding
every surface from scratch is slow, and after several iterations it still does
not look like Omarchy. Omarchy's shell QML is MIT-licensed and already contains
the exact bar, panels, typography, spacing, states, and interactions I want. I
want to stop reimplementing it, vendor that shell into my repo, and rewire it
to my NixOS system while keeping my systemd supervisor, config ownership,
monitor readiness, and restart semantics.

## Solution

Fork Omarchy's shell at a pinned upstream commit. Vendor `shell/`,
`themes/tokyo-night`, `config/omarchy/`, and the helper commands the shell
calls, with the MIT notice. Build the patched Quickshell the shell requires.
Point our systemd unit and launch script at the vendored shell, symlink our
config, set the Tokyo Night theme state, disable Omarchy's idle/lock so
Hypridle and Qylock stay in charge, and adapt Arch-specific helper commands to
NixOS. Verify the live desktop against the local reference pack.

## User Stories

1. As a desktop user, I want the real Omarchy bar and panels, so the UI matches the desktop I know.
2. As a desktop user, I want the Tokyo Night theme applied through Omarchy's theme tokens, so colors and spacing match.
3. As a desktop user, I want the same bar height, section order, fonts, icons, and interaction states, so the UI is exact.
4. As a desktop user, I want the menu, workspaces, indicators, clock, weather, audio, network, bluetooth, battery, power, tray, media, and secondary widgets to work, so the desktop is usable.
5. As a desktop user, I want notification toasts and history from Omarchy's notification service, so behavior matches.
6. As a desktop user, I want the polkit agent and OSD from Omarchy's shell, so authentication and feedback match.
7. As a desktop user, I want Omarchy's menu and app library, so the launcher surface matches.
8. As a desktop user, I want the dock and panels to match, so the desktop composes correctly.
9. As a desktop user, I want Hypridle to keep managing idle, so suspend-then-hibernate and HDR recovery are unchanged.
10. As a desktop user, I want Qylock to keep managing the lock screen, so my lock theme remains.
11. As a desktop user, I want Omarchy's idle and lock services disabled, so two systems do not fight.
12. As a desktop user, I want the shell to start under my systemd supervisor, so it survives crashes and logs in journald.
13. As a desktop user, I want the launch path to wait for a real monitor, so the bar never binds to a placeholder.
14. As a desktop user, I want restart to refuse while locked and wait for IPC readiness, so restarts are safe.
15. As a desktop user, I want my shell config in the repo, so the bar layout and plugin settings are versioned.
16. As a desktop user, I want the vendored shell pinned to a known upstream commit, so updates are deliberate.
17. As a desktop user, I want the MIT notice preserved, so the fork is legally clean.
18. As a desktop user, I want the Omarchy helper commands on PATH, so widget actions work.
19. As a desktop user, I want Arch-specific helper commands replaced with NixOS equivalents, so no action fails because `/usr/bin` or pacman is missing.
20. As a desktop user, I want the reference pack from the local Omarchy run, so I can compare our deployment with the real UI.
21. As a desktop user, I want audio, network, bluetooth, power, and brightness actions to work, so the panels are functional, not just decorative.
22. As a desktop user, I want theme switching and wallpapers to work, so the desktop feels complete.
23. As a desktop user, I want notifications owned by exactly one service, so the bus name does not race.
24. As a desktop user, I want polkit owned by exactly one agent, so authentication works consistently.
25. As a desktop user, I want the Omarchy menu and panels to open without helper errors, so the UI is trustworthy.
26. As a desktop user, I want a clear list of known broken helpers, so I know what is not yet adapted.
27. As a developer, I want the vendored tree isolated from our integration code, so upstream merges are manageable.
28. As a developer, I want the patched Quickshell package in our repo, so builds are reproducible.
29. As a developer, I want the supervisor scripts to know the vendored shell path, so launch and IPC are unambiguous.
30. As a developer, I want `shell ping` readiness to check Omarchy's `"ok"` response, so restart does not trust exit code.
31. As a developer, I want helper adaptation tested one surface at a time, so regressions are local.
32. As a developer, I want the old independent QML removed or archived, so the shipped path is obvious.
33. As a developer, I want an upstream update procedure, so a new Omarchy release is a deliberate sync.
34. As a developer, I want the reference pack and live checks in the verification flow, so "looks right" is evidence-based.
35. As a developer, I want the PR to describe the fork and the NixOS adaptation, so reviewers understand the trade-off.

## Implementation Decisions

- **Vendored tree.** Copy Omarchy's `shell/`, `themes/tokyo-night`, `config/omarchy/`, `default/`, and `bin/` into `vendor/omarchy/` at a pinned commit (currently `255acd9b9`), with the MIT `LICENSE`, `version`, and a README recording the source, local patches, and sync procedure. The shipped shell is `vendor/omarchy/shell`.
- **Patched Quickshell.** Build `0.3.2.r7.g2b4501a` from upstream source with Omarchy's `OmarchyLoadPatch` and the plugin-rescan fix. Package it in `modules/pkgs/quickshell/`; do not use nixpkgs' 0.3.1 for the shipped shell.
- **Supervisor remains ours.** Keep the systemd user unit and `launch.sh` monitor-readiness logic. Point `ExecStart` at `quickshell -p "$OMARCHY_PATH/shell" -n`; derive `WAYLAND_DISPLAY` from Hyprland; keep `qs-restart` lock and readiness checks, expecting Omarchy's `shell ping` value `"ok"`.
- **Config ownership.** `config/omarchy/shell.json` is our user config and is symlinked to `~/.config/omarchy/shell.json`. The vendored `config/omarchy/shell.json` remains the fallback. Keep `OMARCHY_PATH` as the vendored tree.
- **Theme state.** Point `~/.local/state/omarchy/current/theme` at `vendor/omarchy/themes/tokyo-night`; generate or vendor its `shell.toml` from Omarchy's template.
- **Keep Hypridle and Qylock.** Add `omarchy.idle` and `omarchy.lock` to `disabledPlugins`. The Omarchy power panel must not start a second lock service.
- **Helpers.** Put `vendor/omarchy/bin` on the unit PATH. Patch shebangs for NixOS. Replace Arch-specific commands (`pacman`, `/usr/bin`, `/usr/share/omarchy`) with NixOS equivalents as surfaces are exercised; record any remaining broken helper.
- **Notifications and polkit.** Use Omarchy's notification service and polkit agent; remove the independent shell's duplicate services from the shipped path.
- **Legacy independent QML.** Archive the independent QML at `legacy/independent-shell/`; it is superseded and not shipped. Keep `config/quickshell/scripts` and the non-QML tests in place for the supervisor, with legacy tests pointing at the archived tree.
- **Reference pack.** Use `/home/shahid/Pictures/omarchy-reference/` to compare the live deployment with real Omarchy. It is evidence, not shipped code.
- **Upstream sync.** Record the pinned commit, copied paths, local patches, rebuild, and live verification in `vendor/omarchy/README.md`; updates are explicit copies at a chosen commit, not automatic. Record helper gaps in `docs/known-broken-helpers.md`.

## Testing Decisions

- The shipped UI is verified live against the reference pack: bar, menu, panels, notifications, OSD, dock, and polkit.
- Supervisor tests remain: unit active, crash restart, monitor readiness, lock-aware `qs-restart`, and IPC readiness (`shell ping` = `"ok"`).
- Helper smoke tests cover the default bar: menu, audio, network, bluetooth, battery/power, brightness, media, weather, tray, and keyboard layout.
- Theme tests verify `colors.toml` and `shell.toml` are read and that the Tokyo Night state is active.
- Ownership tests assert exactly one notification service and one polkit agent.
- Each helper adaptation records the Arch-specific command it replaced and the NixOS equivalent.
- Known-broken helpers are listed in a tracked file rather than silently ignored.

## Out of Scope

- Independent pixel-perfect reimplementation; that branch is legacy.
- Rewriting Omarchy's QML from scratch.
- Omarchy's installer, pacman update flow, and application installer.
- App retinting/templates beyond the shell theme needed for the desktop.
- Visual parity on displays other than the reference 3440x1440 / 1.33 setup.

## Further Notes

- This spec supersedes the independent pixel-parity spec #28. The reference pack and the supervisor/config foundation remain useful.
- The fork is MIT-licensed; keep the notice and record local modifications.
- The first milestone is the real bar and panels running under our supervisor; helper adaptation follows surface by surface.
