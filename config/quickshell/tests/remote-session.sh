#!/usr/bin/env bash

# Offscreen test for the archived independent remote-session plugin
# (legacy/independent-shell/plugins/remoteSession).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
legacy_plugins="$(cd "$here/../../legacy/independent-shell/plugins" && pwd)"
qs="${QUICKSHELL_BIN:-quickshell}"
jq_bin="${JQ_BIN:-jq}"
timeout_seconds="${REMOTE_SESSION_TIMEOUT:-15}"

tmp="$(mktemp -d)"
server_pid=""
server_runtime=""

cleanup() {
  stop_shell
  rm -rf "$tmp"
}
trap cleanup EXIT

stop_shell() {
  if [[ -n "$server_pid" ]]; then
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
    server_pid=""
  fi
}

ln -s "$legacy_plugins/remoteSession" "$tmp/remoteSession"
cat >"$tmp/shell.qml" <<'INNER'
import Quickshell
import "remoteSession"

ShellRoot {
    RemoteSession {}
}
INNER

start_shell() {
  local runtime="$1"
  shift
  mkdir -p "$runtime"
  chmod 700 "$runtime"
  server_runtime="$runtime"
  env QT_QPA_PLATFORM=offscreen \
    XDG_RUNTIME_DIR="$runtime" \
    QS_NO_RELOAD_POPUP=1 \
    "$@" \
    timeout "$timeout_seconds" "$qs" -p "$tmp" -n --no-color \
    >"$tmp/run.log" 2>&1 &
  server_pid=$!
}

ipc_call() {
  local target="$1"
  local method="$2"
  shift 2
  XDG_RUNTIME_DIR="$server_runtime" \
    "$qs" ipc -p "$tmp" call "$target" "$method" "$@" 2>/dev/null || true
}

wait_for_value() {
  local target="$1"
  local method="$2"
  local expected="$3"
  local attempts=$((timeout_seconds * 4))
  local reply

  for ((i = 0; i < attempts; i++)); do
    reply="$(ipc_call "$target" "$method")"
    if [[ "$reply" == "$expected" ]]; then
      return 0
    fi
    sleep 0.25
  done
  return 1
}

ok() { printf 'ok - %s\n' "$1"; }
fail() {
  printf 'not ok - %s\n' "$1"
  printf '%s\n' '--- quickshell log ---' >&2
  tail -n 40 "$tmp/run.log" >&2 || true
  exit 1
}

# Case 1: a local Wayland session has no SSH environment and logind reports
# Remote=no, so the service must answer local.
start_shell "$tmp/runtime-local" \
  env -u SSH_CONNECTION -u SSH_CLIENT -u SSH_TTY
if ! wait_for_value remoteSession isRemote no; then
  fail "local session reports not remote"
fi
status="$(ipc_call remoteSession status)"
if [[ "$(printf '%s' "$status" | "$jq_bin" -r '.remote')" == "false" ]] \
  && [[ "$(printf '%s' "$status" | "$jq_bin" -r '.reason')" == "local" ]] \
  && [[ "$(printf '%s' "$status" | "$jq_bin" -r '.summary')" == "local session" ]]; then
  ok "local session status is local"
else
  fail "local session status is local (got: $status)"
fi
stop_shell

# Case 2: SSH environment marks the session remote even if logind says local.
start_shell "$tmp/runtime-ssh" \
  env SSH_CONNECTION="1.2.3.4 1234 10.0.0.1 22" SSH_CLIENT="1.2.3.4 1234 22" SSH_TTY="/dev/pts/0"
if ! wait_for_value remoteSession isRemote yes; then
  fail "ssh session reports remote"
fi
status="$(ipc_call remoteSession status)"
if [[ "$(printf '%s' "$status" | "$jq_bin" -r '.remote')" == "true" ]] \
  && [[ "$(printf '%s' "$status" | "$jq_bin" -r '.reason')" == "ssh" ]] \
  && [[ "$(printf '%s' "$status" | "$jq_bin" -r '.summary')" == "remote session (ssh)" ]]; then
  ok "ssh session status is remote"
else
  fail "ssh session status is remote (got: $status)"
fi
if [[ "$(ipc_call remoteSession summary)" == "remote session (ssh)" ]]; then
  ok "remoteSession summary IPC answers"
else
  fail "remoteSession summary IPC answers"
fi
stop_shell

printf 'all remote session tests passed\n'
