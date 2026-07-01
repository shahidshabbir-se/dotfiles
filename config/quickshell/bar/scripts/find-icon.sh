#!/usr/bin/env bash

set -euo pipefail

declare -A ICON_CACHE
declare -A DESKTOP_CACHE

desktop_dirs() {
  local dir

  printf '%s\n' "${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  IFS=':' read -ra data_dirs <<<"${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
  for dir in "${data_dirs[@]}"; do
    printf '%s\n' "$dir/applications"
  done
}

find_desktop() {
  local class_key="$1"
  local dir file

  if [[ -n "${DESKTOP_CACHE[$class_key]+set}" ]]; then
    printf '%s' "${DESKTOP_CACHE[$class_key]}"
    return
  fi

  while IFS= read -r dir; do
    [[ -d "$dir" ]] || continue

    file="$(find "$dir" -maxdepth 1 -type f -iname "${class_key}.desktop" -print -quit 2>/dev/null || true)"
    if [[ -n "$file" ]]; then
      DESKTOP_CACHE[$class_key]="$file"
      printf '%s' "$file"
      return
    fi

    file="$(rg -l -i "^(StartupWMClass|Name|Exec)=.*${class_key}" "$dir"/*.desktop 2>/dev/null | head -n 1 || true)"
    if [[ -n "$file" ]]; then
      DESKTOP_CACHE[$class_key]="$file"
      printf '%s' "$file"
      return
    fi
  done < <(desktop_dirs)

  file="$(find /nix/store -maxdepth 4 -path '*/share/applications/*.desktop' -iname "${class_key}.desktop" -print -quit 2>/dev/null || true)"
  if [[ -z "$file" ]]; then
    file="$(rg -l -i "^(StartupWMClass|Name|Exec)=.*${class_key}" /nix/store/*/share/applications/*.desktop 2>/dev/null | head -n 1 || true)"
  fi

  DESKTOP_CACHE[$class_key]="$file"
  printf '%s' "$file"
}

desktop_icon_name() {
  local desktop="$1"
  [[ -f "$desktop" ]] || return
  awk -F= '/^Icon=/ {print $2; exit}' "$desktop"
}

resolve_icon_in_dir() {
  local icon="$1"
  local dir="$2"
  local png_path

  [[ -d "$dir" ]] || return

  if [[ "$icon" = /* ]]; then
    if [[ "$icon" == *.svg ]]; then
      png_path="${icon%.svg}.png"
      if [[ -f "$png_path" ]]; then
        printf '%s' "$png_path"
        return
      fi
      [[ -f "$icon" ]] && printf '%s' "$icon"
      return
    fi
    [[ -f "$icon" ]] && printf '%s' "$icon"
    return
  fi

  find "$dir" -type f \( -iname "${icon}.png" -o -iname "${icon}.xpm" -o -iname "${icon}.svg" \) \
    | awk '
      function ext_score(path) {
        if (path ~ /\.png$/) return 1000
        if (path ~ /\.xpm$/) return 500
        if (path ~ /\.svg$/) return 250
        return 0
      }
      function size_score(path) {
        if (path ~ /32x32/) return 650
        if (path ~ /48x48/) return 600
        if (path ~ /64x64/) return 550
        if (path ~ /24x24/) return 500
        if (path ~ /128x128/) return 350
        if (path ~ /256x256/) return 200
        if (path ~ /512x512/) return 100
        if (path ~ /16x16/) return 50
        return 250
      }
      {
        score = ext_score($0) + size_score($0)
        if (score > best_score) {
          best_score = score
          best = $0
        }
      }
      END {if (best != "") print best}
    '
}

resolve_icon() {
  local class_key="$1"
  local desktop icon package_root dir path

  if [[ -n "${ICON_CACHE[$class_key]+set}" ]]; then
    printf '%s' "${ICON_CACHE[$class_key]}"
    return
  fi

  desktop="$(find_desktop "$class_key")"
  if [[ -n "$desktop" ]]; then
    desktop="$(readlink -f "$desktop" 2>/dev/null || printf '%s' "$desktop")"
  fi
  icon="$(desktop_icon_name "$desktop" || true)"

  if [[ -z "$icon" ]]; then
    ICON_CACHE[$class_key]=""
    return
  fi

  if [[ "$icon" = /* && -f "$icon" ]]; then
    ICON_CACHE[$class_key]="$icon"
    printf '%s' "$icon"
    return
  fi

  if [[ "$desktop" == /nix/store/*/share/applications/* ]]; then
    package_root="${desktop%%/share/applications/*}"
    path="$(resolve_icon_in_dir "$icon" "$package_root/share/icons" | head -n 1 || true)"
    if [[ -n "$path" ]]; then
      ICON_CACHE[$class_key]="$path"
      printf '%s' "$path"
      return
    fi
  fi

  while IFS= read -r dir; do
    path="$(resolve_icon_in_dir "$icon" "${dir%/applications}/icons" | head -n 1 || true)"
    if [[ -n "$path" ]]; then
      ICON_CACHE[$class_key]="$path"
      printf '%s' "$path"
      return
    fi
  done < <(desktop_dirs)

  for dir in /nix/store/*/share/icons; do
    path="$(resolve_icon_in_dir "$icon" "$dir" | head -n 1 || true)"
    if [[ -n "$path" ]]; then
      ICON_CACHE[$class_key]="$path"
      printf '%s' "$path"
      return
    fi
  done

  ICON_CACHE[$class_key]=""
}

class_key="$(tr '[:upper:]' '[:lower:]' <<<"${1:-}")"
[[ -n "$class_key" ]] || exit 0

resolve_icon "$class_key"
