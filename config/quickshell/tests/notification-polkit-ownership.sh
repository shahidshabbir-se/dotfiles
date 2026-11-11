#!/usr/bin/env bash

# Live-safe ownership test for the shipped Omarchy shell (ticket #59).
#
# Static checks always run. Live checks prove org.freedesktop.Notifications is
# owned by a quickshell process, the Omarchy notification and polkit services
# are loaded, and polkit registered the Omarchy agent with no second agent.
# When no shell is running (or the user session bus is unreachable) the live
# checks are reported as skipped, never as a pass.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$here/../../.." && pwd)"
shell_dir="$repo_root/config/quickshell/shell"
shell_config="$repo_root/config/omarchy/shell.json"
hypr_bindings="$repo_root/modules/hyprland/bindings.nix"

busctl_bin="${BUSCTL_BIN:-busctl}"
journalctl_bin="${JOURNALCTL_BIN:-journalctl}"
jq_bin="${JQ_BIN:-jq}"
quickshell_bin="${QUICKSHELL_BIN:-quickshell}"
systemctl_bin="${SYSTEMCTL_BIN:-systemctl}"
timeout_bin="${TIMEOUT_BIN:-timeout}"
wait_ticks="${OWNERSHIP_WAIT_TICKS:-50}"

notification_service="org.freedesktop.Notifications"
notification_path="/org/freedesktop/Notifications"

fails=0
skips=0
ok() { printf 'ok - %s\n' "$1"; }
fail() {
  printf 'not ok - %s\n' "$1"
  fails=$((fails + 1))
}
skip() {
  printf 'skip - %s\n' "$1"
  skips=$((skips + 1))
}

summary() {
  if ((fails)); then
    printf '%d ownership check(s) failed\n' "$fails" >&2
    exit 1
  fi
  if ((skips)); then
    printf 'ownership: static checks passed; live checks skipped (%d)\n' "$skips"
  else
    printf 'all ownership checks passed\n'
  fi
}

manifest_is_service() {
  "$jq_bin" -e --arg id "$1" '
    .id == $id
    and ((.kinds // []) | index("service") != null)
    and (.entryPoints.service // "" | length > 0)
  ' "$2" >/dev/null 2>&1
}

plugin_disabled() {
  "$jq_bin" -e --arg id "$1" '(.disabledPlugins // []) | index($id) != null' "$shell_config" >/dev/null 2>&1
}

plugin_manifest() {
  find "$shell_dir/plugins" -name manifest.json -print0 \
    | while IFS= read -r -d '' manifest; do
        if "$jq_bin" -e --arg id "$1" '.id == $id' "$manifest" >/dev/null 2>&1; then
          printf '%s\n' "$manifest"
          break
        fi
      done
}

# ---------------------------------------------------------------- static checks

if ! "$jq_bin" -e '.version == 1' "$shell_config" >/dev/null 2>&1; then
  fail "config/omarchy/shell.json is version 1 JSON"
  summary
fi
ok "config/omarchy/shell.json is version 1 JSON"

disabled="$("$jq_bin" -c '(.disabledPlugins // []) | sort' "$shell_config")"
if [[ "$disabled" == '["omarchy.idle","omarchy.lock"]' ]]; then
  ok "shell.json disables only omarchy.idle and omarchy.lock"
else
  fail "shell.json disables only omarchy.idle and omarchy.lock (got $disabled)"
fi

for id in omarchy.notifications omarchy.polkit; do
  if plugin_disabled "$id"; then
    fail "$id is not disabled in shell.json"
  else
    ok "$id is not disabled in shell.json"
  fi

  manifest="$(plugin_manifest "$id")"
  if [[ -n "$manifest" ]] && manifest_is_service "$id" "$manifest"; then
    entry="$("$jq_bin" -r '.entryPoints.service' "$manifest")"
    plugin_dir="$(dirname "$manifest")"
    if [[ -f "$plugin_dir/$entry" ]]; then
      ok "$id is a loadable service plugin ($entry)"
    else
      fail "$id service entry point exists ($plugin_dir/$entry)"
    fi
  else
    fail "$id is a service plugin with a manifest entry point"
  fi
done

# The registry enables first-party service plugins unless shell.json disables
# them, so this is the shipped shell's enabled service list.
enabled_services=()
while IFS= read -r -d '' manifest; do
  id="$("$jq_bin" -r '.id // empty' "$manifest")"
  [[ -n "$id" ]] || continue
  "$jq_bin" -e '((.kinds // []) | index("service")) != null' "$manifest" >/dev/null 2>&1 || continue
  plugin_disabled "$id" && continue
  enabled_services+=("$id")
done < <(find "$shell_dir/plugins" -name manifest.json -print0 | sort -z)

for id in omarchy.notifications omarchy.polkit; do
  if printf '%s\n' "${enabled_services[@]}" | grep -Fxq "$id"; then
    ok "enabled plugins list contains $id"
  else
    fail "enabled plugins list contains $id"
  fi
done

# The independent QML and its duplicate notification/polkit services are archived
# under legacy/ and are not part of the shipped path.
if [[ -z "$(find "$repo_root/config/quickshell" -name '*.qml' -print -quit)" ]]; then
  ok "no independent QML ships from config/quickshell"
else
  fail "no independent QML ships from config/quickshell"
fi

if grep -rq 'legacy/independent-shell' \
  "$repo_root/config/quickshell/scripts" \
  "$repo_root/modules/quickshell.nix"; then
  fail "the shipped supervisor does not point at legacy/independent-shell"
else
  ok "the shipped supervisor does not point at legacy/independent-shell"
fi

if grep -q 'xdg.configFile.quickshell' "$repo_root/modules/quickshell.nix"; then
  fail "the legacy ~/.config/quickshell symlink is removed"
else
  ok "the legacy ~/.config/quickshell symlink is removed"
fi

if grep -q 'toggleCenter' "$hypr_bindings"; then
  fail "no binding calls the retired notifications toggleCenter"
else
  ok "no binding calls the retired notifications toggleCenter"
fi

if grep -Fq "config/quickshell/shell call notifications showHistory" "$hypr_bindings" \
  && grep -Fq "config/quickshell/shell call notifications toggleDnd" "$hypr_bindings"; then
  ok "notification bindings target the vendored Omarchy shell"
else
  fail "notification bindings target the vendored Omarchy shell"
fi

if [[ "$(grep -rl 'systemd.user.services.quickshell' "$repo_root/modules" | wc -l)" -eq 1 ]]; then
  ok "exactly one shipped quickshell systemd unit is declared"
else
  fail "exactly one shipped quickshell systemd unit is declared"
fi

other_agent_config="$(grep -RIlE '(hyprpolkitagent|polkit-gnome-authentication-agent|lxpolkit|polkit-kde-authentication-agent)' \
  "$repo_root/configuration.nix" "$repo_root/hosts" "$repo_root/modules" 2>/dev/null || true)"
if [[ -z "$other_agent_config" ]]; then
  ok "no second polkit authentication agent is configured"
else
  fail "no second polkit authentication agent is configured (${other_agent_config//$'\n'/; })"
fi

# ----------------------------------------------------------------- live checks

if ! "$busctl_bin" --user call org.freedesktop.DBus /org/freedesktop/DBus \
  org.freedesktop.DBus ListNames >/dev/null 2>&1; then
  skip "live ownership checks: user session bus is unreachable"
  summary
  exit 0
fi

shell_active=0
if "$systemctl_bin" --user is-active --quiet quickshell >/dev/null 2>&1; then
  shell_active=1
fi
if "$busctl_bin" --user call org.freedesktop.DBus /org/freedesktop/DBus \
  org.freedesktop.DBus GetNameOwner s "$notification_service" >/dev/null 2>&1; then
  shell_active=1
fi

if ((shell_active == 0)); then
  skip "live ownership checks: no running Omarchy shell"
  summary
  exit 0
fi

ping="$("$timeout_bin" 5 "$quickshell_bin" ipc -p "$shell_dir" call shell ping 2>/dev/null || true)"
if [[ "$ping" == "ok" ]]; then
  ok "Omarchy shell answers shell ping"
else
  fail "Omarchy shell answers shell ping (got '${ping:-no reply}')"
fi

notifications_ping="$("$timeout_bin" 5 "$quickshell_bin" ipc -p "$shell_dir" call notifications ping 2>/dev/null || true)"
if [[ "$notifications_ping" == "ok" ]]; then
  ok "Omarchy notifications service answers IPC"
else
  fail "Omarchy notifications service answers IPC (got '${notifications_ping:-no reply}')"
fi

owner=""
for ((attempt = 1; attempt <= wait_ticks; attempt++)); do
  if owner="$("$timeout_bin" 5 "$busctl_bin" --user call org.freedesktop.DBus \
    /org/freedesktop/DBus org.freedesktop.DBus GetNameOwner s "$notification_service" 2>/dev/null \
    | awk '{print $2}' | tr -d '"')" && [[ -n "$owner" ]]; then
    break
  fi
  owner=""
  sleep 0.2
done

if [[ -z "$owner" ]]; then
  fail "$notification_service is owned on the session bus"
else
  ok "$notification_service is owned ($owner)"

  pid_call="$("$timeout_bin" 5 "$busctl_bin" --user call org.freedesktop.DBus \
    /org/freedesktop/DBus org.freedesktop.DBus GetConnectionUnixProcessID \
    s "$owner" 2>/dev/null || true)"
  pid="$(printf '%s\n' "$pid_call" | awk '{print $2}')"
  exe=""
  cmdline=""
  if [[ -n "$pid" && -r "/proc/$pid/cmdline" ]]; then
    exe="$(readlink -f "/proc/$pid/exe" 2>/dev/null || true)"
    cmdline="$(tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null || true)"
  fi

  if [[ "$exe" == *quickshell* || "$cmdline" == *quickshell* ]]; then
    ok "a quickshell process owns $notification_service (pid ${pid:-unknown})"
  else
    fail "a quickshell process owns $notification_service (pid ${pid:-unknown}, exe ${exe:-unknown}, cmdline ${cmdline:-unknown})"
  fi

  if [[ "$cmdline" == *"config/quickshell/shell"* ]]; then
    ok "the notification owner is the vendored Omarchy shell"
  else
    fail "the notification owner is the vendored Omarchy shell (cmdline ${cmdline:-unknown})"
  fi

  capabilities="$("$timeout_bin" 5 "$busctl_bin" --user call "$notification_service" \
    "$notification_path" "$notification_service" GetCapabilities 2>/dev/null || true)"
  if [[ "$capabilities" == *'"actions"'* ]]; then
    ok "$notification_service advertises notification actions"
  else
    fail "$notification_service advertises notification actions"
  fi
fi

journal="$("$journalctl_bin" --user -u quickshell.service -b --no-pager -o cat 2>/dev/null || true)"
if [[ -z "$journal" ]]; then
  journal="$("$journalctl_bin" --user -b _COMM=quickshell --no-pager -o cat 2>/dev/null || true)"
fi

unit_active="$(systemctl --user is-active quickshell 2>/dev/null || true)"
if [[ "$unit_active" != "active" ]]; then
  skip "journal polkit registration check: shell is not running under systemd"
elif [[ -n "$journal" ]] && grep -Fq 'omarchy polkit agent registered' <<<"$journal"; then
  ok "journal records the Omarchy polkit agent registration"
else
  fail "journal records the Omarchy polkit agent registration"
fi

if [[ -n "$journal" ]] && grep -Fq 'another agent may be running' <<<"$journal"; then
  fail "journal shows no competing polkit agent warning"
else
  ok "journal shows no competing polkit agent warning"
fi

other_agents="$(ps -eo pid=,comm=,args= 2>/dev/null \
  | grep -E '(polkit-gnome-authentication-agent|lxpolkit|polkit-kde-authentication-agent|hyprpolkitagent)' \
  | grep -v 'grep -E' || true)"
if [[ -z "$other_agents" ]]; then
  ok "no process outside quickshell runs a polkit authentication agent"
else
  fail "no process outside quickshell runs a polkit authentication agent (${other_agents//$'\n'/; })"
fi

summary
