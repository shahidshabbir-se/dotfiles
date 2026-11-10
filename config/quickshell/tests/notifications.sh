#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$(cd "$here/.." && pwd)"
busctl_bin="${BUSCTL_BIN:-busctl}"
notify_send_bin="${NOTIFY_SEND_BIN:-notify-send}"
wait_ticks="${NOTIFY_WAIT_TICKS:-50}"
timeout_bin="${TIMEOUT_BIN:-timeout}"

fails=0
ok() { printf 'ok - %s\n' "$1"; }
fail() {
  printf 'not ok - %s\n' "$1"
  fails=$((fails + 1))
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
