#!/usr/bin/env bash
set -euo pipefail

config_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
hyprctl_bin="${HYPRCTL_BIN:-hyprctl}"
jq_bin="${JQ_BIN:-jq}"

hypr() {
  if "$hyprctl_bin" -j instances >/dev/null 2>&1; then
    "$hyprctl_bin" -i 0 "$@"
  else
    "$hyprctl_bin" "$@"
  fi
}

systemctl --user is-active --quiet quickshell
printf 'unit: active\n'

ping="$("${QUICKSHELL_BIN:-quickshell}" ipc -p "$config_dir" call shell ping 2>/dev/null)"
[ "$ping" = "pong" ] || { echo "ipc: shell/ping did not return pong (got '$ping')" >&2; exit 1; }
printf 'ipc: shell/ping answered pong\n'

hypr -j monitors 2>/dev/null | "$jq_bin" -r '
  [ .[]
    | select((.name // "") != "")
    | select(.name != "FALLBACK")
    | select(((.name | ascii_downcase | contains("placeholder")) | not))
    | select(((.disabled // false) | not))
    | .name
  ] | if length == 0 then error("no real monitor") else "monitors: " + join(", ") end
'
