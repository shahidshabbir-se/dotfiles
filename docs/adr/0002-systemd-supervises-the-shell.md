# Systemd supervises the shell; no custom respawn loop

The shell's lifecycle belongs to a systemd user service: `Type=exec`,
`Restart=always`, `RestartSec=2`, `StartLimitIntervalSec=60`,
`StartLimitBurst=5`, ordered `After`/`PartOf`/`WantedBy`
`graphical-session.target`, and `ConditionEnvironment=WAYLAND_DISPLAY`.
`launch.sh` waits for a real monitor before exec'ing Quickshell, and
`qs-restart` checks the session's `LockedHint` and waits for the notification
bus name and an IPC ping before returning. Omarchy's supervisor script was
rejected because it duplicates systemd and must reconstruct session-env
recovery; a bare Hyprland `exec-once` was rejected because a crash leaves no
bar until re-login.

## Consequences

- The systemd user manager must receive the Wayland environment; the Hyprland
  module already imports it.
- `StartLimitBurst` is coarse: after the burst, the unit stays failed until a
  reset. `qs-restart` should reset the failed state before starting.
- Qylock is a separate process in its own cgroup, so restarting the shell unit
  cannot kill an active lock screen.
