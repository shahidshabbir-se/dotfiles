#!/usr/bin/env bash

# Offscreen test for the archived independent polkit plugin
# (legacy/independent-shell/plugins/polkit).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
legacy_plugins="$(cd "$here/../../legacy/independent-shell/plugins" && pwd)"
qs="${QUICKSHELL_BIN:-quickshell}"
jq_bin="${JQ_BIN:-jq}"
timeout_seconds="${POLKIT_TEST_TIMEOUT:-20}"
server_timeout="${POLKIT_SERVER_TIMEOUT:-60}"
live_auth="${POLKIT_LIVE_AUTH:-0}"

tmp="$(mktemp -d)"
server_pid=""
server_runtime=""
pkexec_pid=""

cleanup() {
  stop_shell
  if [[ -n "$pkexec_pid" ]]; then
    kill "$pkexec_pid" 2>/dev/null || true
    wait "$pkexec_pid" 2>/dev/null || true
  fi
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

ok() { printf 'ok - %s\n' "$1"; }
fail() {
  printf 'not ok - %s\n' "$1"
  printf '%s\n' '--- quickshell log ---' >&2
  tail -n 60 "$tmp/run.log" >&2 || true
  exit 1
}

ln -s "$legacy_plugins/polkit" "$tmp/polkit"
cat >"$tmp/shell.qml" <<'INNER'
import Quickshell
import Quickshell.Io
import "polkit"

ShellRoot {
    Agent { id: agent }

    IpcHandler {
        target: "polkitTest"

        function registered(): string {
            return agent.registered ? "yes" : "no";
        }

        function flowState(): string {
            const flow = agent.flow;
            return JSON.stringify({
                present: flow !== null,
                awaiting: flow ? flow.isResponseRequired : false,
                completed: flow ? flow.isCompleted : false,
                successful: flow ? flow.isSuccessful : false,
                cancelled: flow ? flow.isCancelled : false,
                failed: flow ? flow.failed : false,
                message: flow ? String(flow.message || "") : "",
                prompt: flow ? String(flow.inputPrompt || "") : "",
                supplementary: flow ? String(flow.supplementaryMessage || "") : "",
                supplementaryIsError: flow
                    ? Boolean(flow.supplementaryIsError) : false
            });
        }

        function submit(value: string): void {
            if (agent.flow)
                agent.flow.submit(value);
        }

        function cancel(): void {
            if (agent.flow)
                agent.flow.cancelAuthenticationRequest();
        }
    }
}
INNER

start_shell() {
  local runtime="$1"
  mkdir -p "$runtime"
  chmod 700 "$runtime"
  server_runtime="$runtime"
  env QT_QPA_PLATFORM=offscreen \
    XDG_RUNTIME_DIR="$runtime" \
    QS_NO_RELOAD_POPUP=1 \
    timeout "$server_timeout" "$qs" -p "$tmp" -n --no-color \
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
  local attempts="${4:-$((timeout_seconds * 4))}"
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

wait_for_flow() {
  local field="$1"
  local attempts="${2:-$((timeout_seconds * 4))}"
  local flow

  for ((i = 0; i < attempts; i++)); do
    flow="$(ipc_call polkitTest flowState)"
    if [[ -n "$flow" ]] \
      && [[ "$(printf '%s' "$flow" | "$jq_bin" -r ".${field} // false")" == "true" ]]; then
      return 0
    fi
    sleep 0.25
  done
  return 1
}

start_shell "$tmp/runtime"

# Registration is asynchronous: polkitd must accept the listener after the
# agent starts, so poll the agent's own isRegistered property.
if ! wait_for_value polkitTest registered yes; then
  fail "polkit agent registers with polkitd"
fi
ok "polkit agent registers with polkitd"

status="$(ipc_call polkit status)"
if [[ "$(printf '%s' "$status" | "$jq_bin" -r '.registered')" == "true" ]] \
  && [[ "$(printf '%s' "$status" | "$jq_bin" -r '.path')" == "/org/quickshell/PolkitAgent" ]]; then
  ok "polkit status IPC reports the registered agent"
else
  fail "polkit status IPC reports the registered agent (got: $status)"
fi

# A real authentication needs a triggering polkit action. The default run
# stops after registration; set POLKIT_LIVE_AUTH=1 to drive one.
if [[ "$live_auth" != "1" ]]; then
  ok "live authentication skipped (POLKIT_LIVE_AUTH=1 to enable)"
  stop_shell
  printf 'all polkit tests passed\n'
  exit 0
fi

pkexec_bin="$(command -v pkexec || true)"
if [[ -z "$pkexec_bin" ]]; then
  fail "live authentication requires pkexec"
fi
true_bin="$(command -v true || true)"
if [[ -z "$true_bin" ]]; then
  fail "live authentication requires true"
fi

timeout 30 "$pkexec_bin" "$true_bin" >"$tmp/pkexec.out" 2>"$tmp/pkexec.err" &
pkexec_pid=$!

flow=""
for ((i = 0; i < timeout_seconds * 4; i++)); do
  flow="$(ipc_call polkitTest flowState)"
  if [[ -n "$flow" ]] \
    && [[ "$(printf '%s' "$flow" | "$jq_bin" -r '.present // false')" == "true" ]] \
    && [[ "$(printf '%s' "$flow" | "$jq_bin" -r '.awaiting // false')" == "true" ]]; then
    break
  fi
  sleep 0.25
done

if [[ -z "$flow" ]] || [[ "$(printf '%s' "$flow" | "$jq_bin" -r '.awaiting // false')" != "true" ]]; then
  fail "live authentication produced an awaiting polkit flow"
fi
ok "live authentication produced an awaiting polkit flow"

ipc_call polkitTest submit "wrong-password" >/dev/null

# Polkit restarts the PAM conversation after a failed attempt, so the flow
# stays open with failed=true instead of completing. A bad password must
# mark the flow failed and never successful; cancelling then denies the
# action and makes pkexec return.
if ! wait_for_flow 'failed'; then
  fail "wrong credentials mark the polkit flow failed"
fi
ok "wrong credentials mark the polkit flow failed"

flow="$(ipc_call polkitTest flowState)"
if [[ "$(printf '%s' "$flow" | "$jq_bin" -r '.successful // false')" == "false" ]]; then
  ok "wrong credentials do not authorize the action"
else
  fail "wrong credentials do not authorize the action (got: $flow)"
fi

ipc_call polkitTest cancel >/dev/null

denied=0
for ((i = 0; i < timeout_seconds * 4; i++)); do
  flow="$(ipc_call polkitTest flowState)"
  if [[ "$(printf '%s' "$flow" | "$jq_bin" -r '.present == false')" == "true" ]]; then
    denied=1
    break
  fi
  sleep 0.25
done

if ((denied == 1)); then
  ok "cancelling after a bad password denies the request"
else
  fail "cancelling after a bad password denies the request (got: $flow)"
fi

if wait "$pkexec_pid"; then
  fail "pkexec exits nonzero after denied authentication"
else
  ok "pkexec exits nonzero after denied authentication"
fi
pkexec_pid=""

ok "correct credentials not proven (no non-interactive test credential)"

stop_shell
printf 'all polkit tests passed\n'
