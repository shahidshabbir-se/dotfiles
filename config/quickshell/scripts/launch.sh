#!/usr/bin/env bash
set -euo pipefail

if ! hyprctl -j workspaces >/dev/null 2>&1; then
  export HYPRLAND_INSTANCE_SIGNATURE="$(
    hyprctl -j instances | jq -r 'max_by(.time).instance'
  )"
fi

for _ in {1..50}; do
  hyprctl -j workspaces >/dev/null 2>&1 && break
  sleep 0.1
done

if ! hyprctl -j workspaces >/dev/null 2>&1; then
  echo "quickshell: hyprland not ready" >&2
  exit 1
fi

export BAR_ORIENTATION="${1:-${BAR_ORIENTATION:-horizontal}}"

# Quickshell owns org.freedesktop.Notifications.
systemctl --user stop swaync.service >/dev/null 2>&1 || true
pkill -x swaync >/dev/null 2>&1 || true

exec qs
