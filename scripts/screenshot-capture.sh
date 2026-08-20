#!/usr/bin/env bash
set -euo pipefail

# grim/grimblast on Hyprland 0.55 HDR can return an empty first frame.
# https://github.com/hyprwm/Hyprland/discussions/14931
# fix-hdr-screenshare plugin + a short settle delay before capture helps.

min_png_bytes=2048

png_too_small() {
  local file="$1"
  [[ ! -s "$file" ]] && return 0
  [[ "$(wc -c <"$file")" -lt "$min_png_bytes" ]]
}

screenshot_feedback() {
  local out="$1"
  # qs.features.screenshot sends its own action-bearing notify.
  [[ "${SCREENSHOT_NO_NOTIFY:-}" == "1" ]] && return 0
  notify-send -a "Screenshot" -t 5000 "Screenshot saved" \
    "Copied to clipboard · $(basename "$out")"
}

capture_copysave() {
  local mode="$1"
  local out="$2"
  local tmp

  tmp="$(mktemp --suffix=.png)"
  trap 'rm -f "$tmp"' RETURN

  if [[ "$mode" == "area" ]]; then
    sleep 0.15
  fi

  grimblast save "$mode" "$tmp"
  if [[ "$mode" == "area" ]] && png_too_small "$tmp"; then
    sleep 0.2
    grimblast save area "$tmp"
  fi

  cp -- "$tmp" "$out"
  wl-copy <"$out"
  screenshot_feedback "$out"
}

if [[ "${1:-}" == "--notify" && "${2:-}" == "copysave" && -n "${3:-}" && -n "${4:-}" ]]; then
  capture_copysave "$3" "$4"
  exit 0
fi

if [[ "${1:-}" == "copysave" && -n "${2:-}" && -n "${3:-}" ]]; then
  capture_copysave "$2" "$3"
  exit 0
fi

exec grimblast "$@"
