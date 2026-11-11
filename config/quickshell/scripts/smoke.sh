#!/usr/bin/env bash
set -euo pipefail

script_path="$(readlink -f "${BASH_SOURCE[0]}")"
repo_root="$(cd "$(dirname "$script_path")/../../.." && pwd)"

export OMARCHY_PATH="${OMARCHY_PATH:-$repo_root/config/quickshell}"
export PATH="$OMARCHY_PATH/bin:$PATH"

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

# Omarchy's shell/ping answers "ok", not the old shell's "pong".
ping="$("${QUICKSHELL_BIN:-quickshell}" ipc -p "$OMARCHY_PATH/shell" call shell ping 2>/dev/null)"
[ "$ping" = "ok" ] || { echo "ipc: shell/ping did not return ok (got '$ping')" >&2; exit 1; }
printf 'ipc: shell/ping answered ok\n'

hypr -j monitors 2>/dev/null | "$jq_bin" -r '
  [ .[]
    | select((.name // "") != "")
    | select(.name != "FALLBACK")
    | select(((.name | ascii_downcase | contains("placeholder")) | not))
    | select(((.disabled // false) | not))
    | .name
  ] | if length == 0 then error("no real monitor") else "monitors: " + join(", ") end
'
