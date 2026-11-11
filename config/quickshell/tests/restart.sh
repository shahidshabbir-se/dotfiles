#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$here/../../.." && pwd)"
shell_dir="$repo_root/vendor/omarchy/shell"
script="$here/../scripts/restart.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fails=0
ok() { printf 'ok - %s\n' "$1"; }
fail() {
  printf 'not ok - %s\n' "$1"
  fails=$((fails + 1))
}

write_fakes() {
  local locked="$1"
  local ipc_ready="$2"

  cat >"$tmp/loginctl" <<'INNER'
#!/usr/bin/env bash
printf '%s\n' "@LOCKED@"
INNER
  sed -i "s/@LOCKED@/$locked/" "$tmp/loginctl"

  cat >"$tmp/systemctl" <<'INNER'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
case " $* " in
  *" is-active "*) exit 0 ;;
esac
exit 0
INNER

  # Omarchy's shell ping prints "ok" and exits 0. Readiness is the printed
  # value, not the exit code: a missing target also exits 0.
  cat >"$tmp/quickshell" <<'INNER'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$QUICKSHELL_LOG"
case " $* " in
  *" call shell ping "*)
    if [ "@IPC_READY@" = 1 ]; then printf 'ok\n'; fi
    exit 0
    ;;
esac
exit 0
INNER
  sed -i "s/@IPC_READY@/$ipc_ready/" "$tmp/quickshell"

  chmod +x "$tmp/loginctl" "$tmp/systemctl" "$tmp/quickshell"
}

run_restart() {
  OMARCHY_PATH="" \
  SYSTEMCTL_LOG="$tmp/systemctl.log" \
  QUICKSHELL_LOG="$tmp/quickshell.log" \
  XDG_SESSION_ID=test-session \
  LOGINCTL_BIN="$tmp/loginctl" \
  SYSTEMCTL_BIN="$tmp/systemctl" \
  QUICKSHELL_BIN="$tmp/quickshell" \
  RESTART_WAIT_TICKS=2 \
  "$script"
}

write_fakes yes 0
: >"$tmp/systemctl.log"
: >"$tmp/quickshell.log"
if run_restart >"$tmp/locked.out" 2>"$tmp/locked.err"; then
  fail "restart refuses while session is locked"
else
  if grep -q 'locked' "$tmp/locked.err" && [[ ! -s "$tmp/systemctl.log" ]]; then
    ok "restart refuses while session is locked"
  else
    fail "restart refuses while session is locked"
  fi
fi

write_fakes no 0
: >"$tmp/systemctl.log"
: >"$tmp/quickshell.log"
if run_restart >"$tmp/not-ready.out" 2>"$tmp/not-ready.err"; then
  fail "restart fails when ping prints nothing"
else
  if grep -q 'reset-failed' "$tmp/systemctl.log" \
    && grep -q 'restart quickshell' "$tmp/systemctl.log" \
    && grep -q "ipc -p $shell_dir call shell ping" "$tmp/quickshell.log"; then
    ok "restart fails when ping prints nothing"
  else
    fail "restart fails when ping prints nothing"
  fi
fi

write_fakes no 1
: >"$tmp/systemctl.log"
: >"$tmp/quickshell.log"
if run_restart >"$tmp/success.out" 2>"$tmp/success.err"; then
  if grep -q "ipc -p $shell_dir call shell ping" "$tmp/quickshell.log"; then
    ok "restart returns after Omarchy ping answers ok"
  else
    fail "restart returns after Omarchy ping answers ok"
  fi
else
  fail "restart returns after Omarchy ping answers ok"
fi

if ((fails)); then
  printf '%d test(s) failed\n' "$fails" >&2
  exit 1
fi
printf 'all restart tests passed\n'
