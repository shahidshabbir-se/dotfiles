#!/usr/bin/env sh
set -eu

config_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

export QML2_IMPORT_PATH="/etc/profiles/per-user/$USER/lib/qt-6/qml${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"
export QS_NO_RELOAD_POPUP=1

systemctl --user stop swaync 2>/dev/null || true

exec quickshell --no-duplicate -p "$config_dir"
