#!/usr/bin/env bash
set -euo pipefail

config_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
loginctl_bin="${LOGINCTL_BIN:-loginctl}"
systemctl_bin="${SYSTEMCTL_BIN:-systemctl}"
quickshell_bin="${QUICKSHELL_BIN:-quickshell}"
wait_ticks="${RESTART_WAIT_TICKS:-150}"

if [ -z "${XDG_SESSION_ID:-}" ]; then
  echo "qs-restart: XDG_SESSION_ID is unset; cannot verify the lock state" >&2
  exit 1
fi

if ! locked="$("$loginctl_bin" show-session "$XDG_SESSION_ID" -p LockedHint --value 2>/dev/null)"; then
  echo "qs-restart: cannot read the lock state for session $XDG_SESSION_ID" >&2
  exit 1
fi
locked="${locked//[[:space:]]/}"

if [ "$locked" = "yes" ]; then
  echo "qs-restart: session $XDG_SESSION_ID is locked; refusing to restart" >&2
  exit 1
fi
if [ "$locked" != "no" ]; then
  echo "qs-restart: unknown lock state '$locked'; refusing to restart" >&2
  exit 1
fi

"$systemctl_bin" --user reset-failed quickshell
"$systemctl_bin" --user restart quickshell

# Return only once the restarted process is alive and its IPC surface answers.
for ((attempt = 1; attempt <= wait_ticks; attempt++)); do
  if "$systemctl_bin" --user is-active --quiet quickshell \
    && [ "$("$quickshell_bin" ipc -p "$config_dir" call shell ping 2>/dev/null)" = "pong" ]; then
    echo "quickshell restarted and IPC is ready"
    exit 0
  fi
  sleep 0.2
done

echo "qs-restart: quickshell did not answer IPC within $((wait_ticks * 2 / 10))s" >&2
exit 1
