#!/usr/bin/env bash
set -euo pipefail

if ! hyprctl -j workspaces >/dev/null 2>&1; then
  export HYPRLAND_INSTANCE_SIGNATURE="$(
    hyprctl -j instances | jq -r 'max_by(.time).instance'
  )"
fi

has_real_monitor() {
  hyprctl -j monitors 2>/dev/null |
    jq -e '[.[] | select(.name != "FALLBACK" and .name != "" and (.disabled | not))] | length > 0' \
      >/dev/null 2>&1
}

# Workspaces alone can be ready on FALLBACK after DPMS/sleep. Wait for a real
# output or qs binds a placeholder and the bar never remounts.
for _ in {1..100}; do
  if hyprctl -j workspaces >/dev/null 2>&1 && has_real_monitor; then
    # Qt often still has zero outputs briefly after Hyprland reports DP-*.
    sleep 1.0
    if hyprctl -j workspaces >/dev/null 2>&1 && has_real_monitor; then
      break
    fi
  fi
  sleep 0.1
done

if ! hyprctl -j workspaces >/dev/null 2>&1 || ! has_real_monitor; then
  echo "quickshell: hyprland monitor not ready" >&2
  exit 1
fi

export BAR_ORIENTATION="${1:-${BAR_ORIENTATION:-horizontal}}"

# Quickshell owns org.freedesktop.Notifications.
systemctl --user stop swaync.service >/dev/null 2>&1 || true
pkill -x swaync >/dev/null 2>&1 || true

exec qs
