#!/usr/bin/env bash
set -euo pipefail

edge="${1:?usage: set-bar-edge.sh top|bottom|left|right}"
case "$edge" in
  top|bottom) style=slide ;;
  left|right) style=slidevert ;;
  *) echo "invalid bar edge: $edge" >&2; exit 2 ;;
esac

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/quickshell"
mkdir -p "$state_dir"
printf '%s\n' "$edge" > "$state_dir/bar-edge"

hyprctl keyword animation "workspaces,1,3,easeInOutCubic,$style" >/dev/null
