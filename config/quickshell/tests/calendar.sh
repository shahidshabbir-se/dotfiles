#!/usr/bin/env bash
set -euo pipefail

# Live acceptance harness for ticket #27. Run inside a Hyprland session with the
# shell already active. Mouse dismissal and Escape are visual/manual checks;
# this script proves the IPC target, current-month open, and month navigation.

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$(cd "$here/.." && pwd)"
timeout_bin="${TIMEOUT_BIN:-timeout}"
quickshell_bin="${QUICKSHELL_BIN:-quickshell}"
jq_bin="${JQ_BIN:-jq}"
wait_ticks="${CLOCK_WAIT_TICKS:-50}"

fails=0
ok() { printf 'ok - %s\n' "$1"; }
fail() {
  printf 'not ok - %s\n' "$1"
  fails=$((fails + 1))
}

ipc() {
  "$timeout_bin" 10 "$quickshell_bin" ipc -p "$config_dir" call clock "$@" 2>/dev/null || true
}

normalize_json() {
  "$jq_bin" -c 'if type == "string" then fromjson else . end'
}

clock_status() {
  ipc status | normalize_json
}

wait_status() {
  local expression="$1"
  local attempt
  local current
  for ((attempt = 1; attempt <= wait_ticks; attempt++)); do
    if current="$(clock_status 2>/dev/null)" \
      && printf '%s' "$current" | "$jq_bin" -e "$expression" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.1
  done
  printf 'calendar: timed out waiting for status: %s\n' "$expression" >&2
  return 1
}

ensure_closed() {
  local open
  open="$(clock_status 2>/dev/null | "$jq_bin" -r '.open' 2>/dev/null || true)"
  if [[ "$open" == "true" ]]; then
    ipc closeCalendar >/dev/null || true
  fi
}

trap ensure_closed EXIT

if wait_status '.open != null and .month != null and .today != null'; then
  ok "clock status answers over IPC"
else
  fail "clock status answers over IPC"
  printf 'the clock IPC target did not answer; restart the shell with qs-restart\n' >&2
  exit 1
fi

ensure_closed
today="$(date +%F)"
month="$(date +%Y-%m)"

opened="$(ipc toggleCalendar | normalize_json)"
if printf '%s' "$opened" | "$jq_bin" -e --arg today "$today" --arg month "$month" \
  '.open == true and .today == $today and (.month | startswith($month))' >/dev/null 2>&1; then
  ok "toggleCalendar opens the current month"
else
  fail "toggleCalendar opens the current month"
fi

before="$(clock_status | "$jq_bin" -r '.month')"
next="$(ipc nextMonth | normalize_json | "$jq_bin" -r '.month')"
if [[ "$next" != "$before" ]]; then
  ok "nextMonth moves to the next month"
else
  fail "nextMonth moves to the next month"
fi

previous="$(ipc previousMonth | normalize_json | "$jq_bin" -r '.month')"
if [[ "$previous" == "$before" ]]; then
  ok "previousMonth returns to the prior month"
else
  fail "previousMonth returns to the prior month"
fi

closed="$(ipc toggleCalendar | normalize_json)"
if printf '%s' "$closed" | "$jq_bin" -e '.open == false' >/dev/null 2>&1; then
  ok "toggleCalendar closes the popup"
else
  fail "toggleCalendar closes the popup"
fi

if ((fails)); then
  printf '%d calendar test(s) failed\n' "$fails" >&2
  exit 1
fi

printf 'all clock calendar IPC checks passed\n'
printf 'manual checks remaining: click the clock, click outside the card, press Escape\n'
