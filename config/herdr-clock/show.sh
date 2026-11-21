#!/usr/bin/env bash
set -u
herdr="${HERDR_BIN_PATH:-herdr}"
exec "$herdr" plugin pane open --plugin herdr.clock --entrypoint clock --placement overlay --focus
