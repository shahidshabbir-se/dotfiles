#!/usr/bin/env bash
set -euo pipefail

# Open an image path with the default image application (xdg-mime).
raw="${1:-}"
[[ -n "$raw" ]] || exit 0

path="$raw"
if [[ "$path" == file://* ]]; then
  path="${path#file://}"
fi

if [[ "$path" != /* ]]; then
  if [[ -f "$HOME/Pictures/Screenshots/$path" ]]; then
    path="$HOME/Pictures/Screenshots/$path"
  fi
fi

if [[ -f "$path" ]]; then
  exec xdg-open "$path"
fi
