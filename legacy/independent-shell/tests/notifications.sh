#!/usr/bin/env bash

# Live harness for the archived independent shell (legacy/independent-shell).
# It is kept outside config/quickshell/tests because it does not exercise the
# shipped config/quickshell fork; the Omarchy ownership test lives there instead.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${QUICKSHELL_CONFIG_DIR:-$(cd "$here/.." && pwd)}"
busctl_bin="${BUSCTL_BIN:-busctl}"
notify_send_bin="${NOTIFY_SEND_BIN:-notify-send}"
wait_ticks="${NOTIFY_WAIT_TICKS:-50}"
timeout_bin="${TIMEOUT_BIN:-timeout}"
quickshell_bin="${QUICKSHELL_BIN:-quickshell}"
jq_bin="${JQ_BIN:-jq}"
ipc_wait_ticks="${IPC_WAIT_TICKS:-50}"

fails=0
ok() { printf 'ok - %s\n' "$1"; }
fail() {
  printf 'not ok - %s\n' "$1"
  fails=$((fails + 1))
}

ipc() {
  "$timeout_bin" 10 "$quickshell_bin" ipc -p "$config_dir" call notifications "$@" 2>/dev/null || true
}

normalize_json() {
  "$jq_bin" -c 'if type == "string" then fromjson else . end'
}

status_json() {
  ipc status | normalize_json
}

wait_status() {
  local expression="$1"
  local attempt
  local current
  for ((attempt = 1; attempt <= ipc_wait_ticks; attempt++)); do
    if current="$(status_json 2>/dev/null)" \
      && printf '%s' "$current" | "$jq_bin" -e "$expression" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.1
  done
  printf 'notifications: timed out waiting for status: %s\n' "$expression" >&2
  return 1
}

wait_history_app() {
  local app="$1"
  local attempt
  local current
  for ((attempt = 1; attempt <= ipc_wait_ticks; attempt++)); do
    if current="$(ipc history | normalize_json 2>/dev/null)" \
      && printf '%s' "$current" | "$jq_bin" -e --arg app "$app" '.[0].appName == $app' >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.1
  done
  printf 'notifications: timed out waiting for history entry from %s\n' "$app" >&2
  return 1
}

ensure_closed() {
  local open
  open="$(status_json 2>/dev/null | "$jq_bin" -r '.open' 2>/dev/null || true)"
  if [[ "$open" == "true" ]]; then
    ipc toggleCenter >/dev/null || true
  fi
}

ensure_dnd_off() {
  local dnd
  dnd="$(status_json 2>/dev/null | "$jq_bin" -r '.dnd' 2>/dev/null || true)"
  if [[ "$dnd" == "true" ]]; then
    ipc toggleDnd >/dev/null || true
  fi
}

cleanup_notifications() {
  local state open dnd
  state="$(status_json 2>/dev/null || true)"
  [[ -n "$state" ]] || return 0
  open="$(printf '%s' "$state" | "$jq_bin" -r '.open // false' 2>/dev/null || true)"
  dnd="$(printf '%s' "$state" | "$jq_bin" -r '.dnd // false' 2>/dev/null || true)"
  if [[ "$open" == "true" ]]; then
    ipc toggleCenter >/dev/null || true
  fi
  if [[ "$dnd" == "true" ]]; then
    ipc toggleDnd >/dev/null || true
  fi
}

service="org.freedesktop.Notifications"
path="/org/freedesktop/Notifications"
iface="$service"

owner_call() {
  "$timeout_bin" 5 "$busctl_bin" --user call org.freedesktop.DBus /org/freedesktop/DBus \
    org.freedesktop.DBus GetNameOwner s "$service" 2>/dev/null
}

owner=""
for ((attempt = 1; attempt <= wait_ticks; attempt++)); do
  if owner="$(owner_call)"; then
    break
  fi
  sleep 0.2
done

if [[ -z "$owner" ]]; then
  fail "$service is owned"
  printf 'the shell is not available on the session bus; start it with qs-restart\n' >&2
  exit 1
fi
ok "$service is owned"

owner_name="$(printf '%s\n' "$owner" | awk '{print $2}' | tr -d '"')"
if [[ -z "$owner_name" ]]; then
  fail "resolve the owner of $service"
else
  pid_call="$("$timeout_bin" 5 "$busctl_bin" --user call org.freedesktop.DBus \
    /org/freedesktop/DBus org.freedesktop.DBus GetConnectionUnixProcessID \
    s "$owner_name" 2>/dev/null || true)"
  pid="$(printf '%s\n' "$pid_call" | awk '{print $2}')"
  exe=""
  cmdline=""
  if [[ -n "$pid" && -r "/proc/$pid/exe" ]]; then
    exe="$(readlink -f "/proc/$pid/exe" 2>/dev/null || true)"
    cmdline="$(tr '\0' ' ' </proc/"$pid"/cmdline 2>/dev/null || true)"
  fi

  if [[ "$exe" == *quickshell* || "$cmdline" == *quickshell* ]]; then
    ok "the shell process owns $service (pid $pid)"
  else
    fail "the shell process owns $service (owner pid ${pid:-unknown}, exe ${exe:-unknown})"
  fi
fi

caps="$("$timeout_bin" 5 "$busctl_bin" --user call "$service" "$path" "$iface" \
  GetCapabilities 2>/dev/null || true)"
if [[ "$caps" == *'"actions"'* ]]; then
  ok "the service advertises notification actions"
else
  fail "the service advertises notification actions"
fi

if command -v "$notify_send_bin" >/dev/null 2>&1; then
  id_a="$("$timeout_bin" 10 "$notify_send_bin" \
    --print-id \
    --app-name="Ticket 5 App A" \
    --app-icon="dialog-information" \
    --expire-time=2000 \
    "App A summary" "App A body" 2>/dev/null || true)"
  if [[ "$id_a" =~ ^[0-9]+$ ]]; then
    ok "notify-send reaches App A (id $id_a)"
  else
    fail "notify-send reaches App A (no notification id: ${id_a:-timed out})"
  fi

  id_b="$("$timeout_bin" 10 "$notify_send_bin" \
    --print-id \
    --app-name="Ticket 5 App B" \
    --app-icon="dialog-warning" \
    --expire-time=2000 \
    "App B summary" "App B body" 2>/dev/null || true)"
  if [[ "$id_b" =~ ^[0-9]+$ ]]; then
    ok "notify-send reaches App B (id $id_b)"
  else
    fail "notify-send reaches App B (no notification id: ${id_b:-timed out})"
  fi
else
  fail "notify-send is installed"
fi

# Notification center, unread count, DND, and IPC targets (ticket #6).
if wait_status '.open != null and .dnd != null and .unread != null and .history != null and .toasts != null'; then
  ok "notifications status answers over IPC"
else
  fail "notifications status answers over IPC"
  printf 'the notifications IPC target did not answer; restart the shell with qs-restart\n' >&2
  exit 1
fi

trap cleanup_notifications EXIT
ensure_closed

center_open="$("$timeout_bin" 10 "$quickshell_bin" ipc -p "$config_dir" call notifications toggleCenter 2>/dev/null | normalize_json || true)"
if printf '%s' "$center_open" | "$jq_bin" -e '.open == true and .unread == 0' >/dev/null 2>&1; then
  ok "toggleCenter opens the center and clears unread"
else
  fail "toggleCenter opens the center and clears unread"
fi

center_close="$("$timeout_bin" 10 "$quickshell_bin" ipc -p "$config_dir" call notifications toggleCenter 2>/dev/null | normalize_json || true)"
if printf '%s' "$center_close" | "$jq_bin" -e '.open == false' >/dev/null 2>&1; then
  ok "toggleCenter closes the center"
else
  fail "toggleCenter closes the center"
fi

ensure_closed
ensure_dnd_off
base_unread="$(status_json | "$jq_bin" -r '.unread')"
center_id="$("$timeout_bin" 10 "$notify_send_bin" \
  --print-id \
  --app-name="Ticket 6 Center" \
  --expire-time=10000 \
  "Center summary" "Center body" 2>/dev/null || true)"
if [[ "$center_id" =~ ^[0-9]+$ ]]; then
  ok "a new notification reaches the shell for unread tracking"
else
  fail "a new notification reaches the shell for unread tracking"
fi

if wait_status '(.unread >= '"$((base_unread + 1))"') and (.history >= 1)' \
  && wait_status '.toasts >= 1'; then
  ok "unread and toast count update for a new notification"
else
  fail "unread and toast count update for a new notification"
fi

open_after_unread="$("$timeout_bin" 10 "$quickshell_bin" ipc -p "$config_dir" call notifications toggleCenter 2>/dev/null | normalize_json || true)"
if printf '%s' "$open_after_unread" | "$jq_bin" -e '.open == true and .unread == 0' >/dev/null 2>&1 \
  && wait_status '.toasts == 0'; then
  ok "opening the center clears unread and dismisses toasts"
else
  fail "opening the center clears unread and dismisses toasts"
fi
ensure_closed

ensure_dnd_off
dnd_on="$("$timeout_bin" 10 "$quickshell_bin" ipc -p "$config_dir" call notifications toggleDnd 2>/dev/null | normalize_json || true)"
if printf '%s' "$dnd_on" | "$jq_bin" -e '.dnd == true' >/dev/null 2>&1 \
  && wait_status '.dnd == true and .toasts == 0'; then
  ok "toggleDnd turns do-not-disturb on"
else
  fail "toggleDnd turns do-not-disturb on"
fi

base_history="$(status_json | "$jq_bin" -r '.history')"
base_unread="$(status_json | "$jq_bin" -r '.unread')"
dnd_id="$("$timeout_bin" 10 "$notify_send_bin" \
  --print-id \
  --app-name="Ticket 6 DND" \
  --expire-time=10000 \
  "DND summary" "DND body" 2>/dev/null || true)"
if [[ "$dnd_id" =~ ^[0-9]+$ ]]; then
  ok "a notification is accepted while do-not-disturb is on"
else
  fail "a notification is accepted while do-not-disturb is on"
fi

if wait_status '.dnd == true and (.history >= '"$((base_history + 1))"') and (.unread >= '"$((base_unread + 1))"')' \
  && wait_history_app "Ticket 6 DND" \
  && wait_status '.toasts == 0'; then
  ok "do-not-disturb records history and unread without a toast"
else
  fail "do-not-disturb records history and unread without a toast"
fi

dnd_off="$("$timeout_bin" 10 "$quickshell_bin" ipc -p "$config_dir" call notifications toggleDnd 2>/dev/null | normalize_json || true)"
if printf '%s' "$dnd_off" | "$jq_bin" -e '.dnd == false' >/dev/null 2>&1; then
  ok "toggleDnd turns do-not-disturb off"
else
  fail "toggleDnd turns do-not-disturb off"
fi

clear_result="$("$timeout_bin" 10 "$quickshell_bin" ipc -p "$config_dir" call notifications clearHistory 2>/dev/null | normalize_json || true)"
history_result="$("$timeout_bin" 10 "$quickshell_bin" ipc -p "$config_dir" call notifications history 2>/dev/null | normalize_json || true)"
if printf '%s' "$clear_result" | "$jq_bin" -e '.history == 0 and .unread == 0' >/dev/null 2>&1 \
  && printf '%s' "$history_result" | "$jq_bin" -e 'length == 0' >/dev/null 2>&1; then
  ok "clearHistory empties history and unread"
else
  fail "clearHistory empties history and unread"
fi

if command -v swaync >/dev/null 2>&1; then
  fail "swaync is not installed"
else
  ok "swaync is not installed"
fi

data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
data_dirs="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}:${HOME}/.nix-profile/share:/run/current-system/sw/share"
IFS=: read -r -a activation_dirs <<<"$data_home:$data_dirs"
activation_hit=""
for dir in "${activation_dirs[@]}"; do
  [[ -n "$dir" && -d "$dir/dbus-1/services" ]] || continue
  if grep -R -l -i 'swaync' "$dir/dbus-1/services" >/dev/null 2>&1; then
    activation_hit="$dir/dbus-1/services"
    break
  fi
done

if [[ -n "$activation_hit" ]]; then
  fail "swaync has no D-Bus activation entry ($activation_hit)"
else
  ok "swaync has no D-Bus activation entry"
fi

if ((fails)); then
  printf '%d notification test(s) failed\n' "$fails" >&2
  exit 1
fi
printf 'all notification tests passed\n'
