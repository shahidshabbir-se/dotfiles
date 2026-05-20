#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")"

export QML2_IMPORT_PATH="/etc/profiles/per-user/$USER/lib/qt-6/qml${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"

if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ -d "/run/user/$(id -u)/hypr" ]; then
  HYPR_INSTANCE_DIR=$(find "/run/user/$(id -u)/hypr" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %f\n' | sort -nr | head -n1 | cut -d' ' -f2-)
  if [ -n "$HYPR_INSTANCE_DIR" ]; then
    export HYPRLAND_INSTANCE_SIGNATURE="$HYPR_INSTANCE_DIR"
  fi
fi

exec quickshell --no-duplicate --path "$PWD"
