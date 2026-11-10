#!/usr/bin/env bash
set -euo pipefail

config_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
hyprctl_bin="${HYPRCTL_BIN:-hyprctl}"
jq_bin="${JQ_BIN:-jq}"
quickshell_bin="${QUICKSHELL_BIN:-quickshell}"
launch_attempts="${LAUNCH_ATTEMPTS:-100}"
settle_seconds="${LAUNCH_SETTLE_SECONDS:-1}"

# The interactive zsh config wraps hyprctl this way because Hyprland 0.55
# exposes the running instance by index instead of always by signature.
hypr() {
  if "$hyprctl_bin" -j instances >/dev/null 2>&1; then
    "$hyprctl_bin" -i 0 "$@"
  else
    "$hyprctl_bin" "$@"
  fi
}

if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  signature="$("$hyprctl_bin" -j instances 2>/dev/null \
    | "$jq_bin" -r 'if length == 0 then empty else max_by(.time).instance end')"
  if [ -z "$signature" ]; then
    echo "quickshell: cannot find a running Hyprland instance" >&2
    exit 1
  fi
  export HYPRLAND_INSTANCE_SIGNATURE="$signature"
fi

has_real_monitor() {
  hypr -j monitors 2>/dev/null \
    | "$jq_bin" -e '
        [ .[]
          | select((.name // "") != "")
          | select(.name != "FALLBACK")
          | select(((.name | ascii_downcase | contains("placeholder")) | not))
          | select(((.disabled // false) | not))
        ] | length > 0
      ' >/dev/null 2>&1
}

hyprland_ready() {
  hypr -j workspaces >/dev/null 2>&1 && has_real_monitor
}

# Workspaces alone can be ready on FALLBACK after DPMS or suspend. Binding the
# bar to that placeholder leaves it invisible once the real output returns.
for ((attempt = 1; attempt <= launch_attempts; attempt++)); do
  if hyprland_ready; then
    # Qt can briefly report zero outputs after Hyprland reports a real one.
    sleep "$settle_seconds"
    if hyprland_ready; then
      break
    fi
  fi
  sleep 0.2
done

if ! hyprland_ready; then
  echo "quickshell: Hyprland has no real monitor yet" >&2
  exit 1
fi

exec "$quickshell_bin" -p "$config_dir" -n
