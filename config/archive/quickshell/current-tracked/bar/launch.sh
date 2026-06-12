#!/usr/bin/env sh
set -eu

export QML2_IMPORT_PATH="/etc/profiles/per-user/$USER/lib/qt-6/qml${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"
export QS_ICON_THEME="Papirus-Dark"
export QS_NO_RELOAD_POPUP=1

banner_cache="$HOME/.cache/amadeus-bar/menu-banner.png"
wallpaper="$HOME/.cache/hyprlock.png"
fallback="$HOME/.config/quickshell/bar/assets/menu-banner.png"

mkdir -p "$HOME/.cache/amadeus-bar"

if [ -f "$wallpaper" ] && command -v magick >/dev/null 2>&1; then
  if [ ! -f "$banner_cache" ] || [ "$wallpaper" -nt "$banner_cache" ]; then
    magick "$wallpaper" \
      -resize "380x168^" \
      -gravity center \
      -extent "380x168" \
      "$banner_cache"
  fi
elif [ -f "$fallback" ] && [ ! -f "$banner_cache" ]; then
  cp "$fallback" "$banner_cache"
fi

if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ -d "/run/user/$(id -u)/hypr" ]; then
  HYPR_INSTANCE_DIR=$(find "/run/user/$(id -u)/hypr" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %f\n' | sort -nr | head -n1 | cut -d' ' -f2-)
  if [ -n "$HYPR_INSTANCE_DIR" ]; then
    export HYPRLAND_INSTANCE_SIGNATURE="$HYPR_INSTANCE_DIR"
  fi
fi

# Stop swaync so nothing else owns org.freedesktop.Notifications.
systemctl --user stop swaync 2>/dev/null || true
pkill -x swaync 2>/dev/null || true

exec quickshell --no-duplicate -c bar
