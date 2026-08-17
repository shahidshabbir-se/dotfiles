#!/usr/bin/env bash
# Standalone Omarchy network panel preview. Leaves production quickshell alone.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
export PATH="$ROOT/scripts:$PATH"
export QML2_IMPORT_PATH="$ROOT${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"
export QML_IMPORT_PATH="$ROOT${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"

# qs resolves qs.* from config root; -p points at this folder's shell.qml
exec qs -p "$ROOT" --no-duplicate "$@"
