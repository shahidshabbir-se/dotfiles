#!/usr/bin/env bash

# Legacy live harness for the archived independent shell (legacy/independent-shell).
# It edits that tree's shell.json and does not exercise the shipped vendor/omarchy
# fork.
set -euo pipefail

# Live acceptance harness for ticket #3. Run inside a Hyprland session with the
# shell already active. It edits legacy/independent-shell/shell.json, waits for IPC to
# report the new effective layout, and restores the file on exit.

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${QUICKSHELL_CONFIG_DIR:-$(cd "$here/../../legacy/independent-shell" && pwd)}"
config_file="$config_dir/shell.json"
quickshell_bin="${QUICKSHELL_BIN:-quickshell}"
jq_bin="${JQ_BIN:-jq}"
wait_ticks="${LAYOUT_WAIT_TICKS:-100}"

backup="$(mktemp)"
cp "$config_file" "$backup"
restore() {
  cp "$backup" "$config_file"
  rm -f "$backup"
}
trap restore EXIT

main_pid=""
if systemctl --user show -p MainPID --value quickshell >/dev/null 2>&1; then
  main_pid="$(systemctl --user show -p MainPID --value quickshell)"
fi

normalize() {
  "$jq_bin" -c 'if type == "string" then fromjson else . end'
}

query_layout() {
  "$quickshell_bin" ipc -p "$config_dir" call bar layout 2>/dev/null \
    | normalize
}

wait_for() {
  local expression="$1"
  local attempt
  for ((attempt = 1; attempt <= wait_ticks; attempt++)); do
    if query_layout 2>/dev/null | "$jq_bin" -e "$expression" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.1
  done
  echo "layout-ipc: timed out waiting for: $expression" >&2
  return 1
}

wait_for '[.layout.center[] | select(.id == "clock")] | length == 1'
printf 'ok - initial layout has clock in center\n'

tmp="$(mktemp)"
"$jq_bin" '.bar.layout.center = [] | .bar.layout.right = [{"id": "clock", "format": "h:mm:ss AP"}]' \
  "$config_file" >"$tmp"
mv "$tmp" "$config_file"
wait_for '.layout.center | length == 0'
wait_for '.layout.right[0].id == "clock" and .layout.right[0].format == "h:mm:ss AP"'
printf 'ok - shell.json edit moved the clock and changed its format\n'

tmp="$(mktemp)"
"$jq_bin" '.bar.layout.right = [{"id": "missingPlugin"}]' \
  "$config_file" >"$tmp"
mv "$tmp" "$config_file"
wait_for '.unknown[] | select(.id == "missingPlugin")'
printf 'ok - unknown plugin id is reported\n'

if [[ -n "$main_pid" ]]; then
  after_pid="$(systemctl --user show -p MainPID --value quickshell)"
  if [[ "$after_pid" != "$main_pid" ]]; then
    echo "layout-ipc: shell process restarted ($main_pid -> $after_pid)" >&2
    exit 1
  fi
  printf 'ok - shell process did not restart (pid %s)\n' "$main_pid"
fi

printf 'all layout IPC checks passed\n'
