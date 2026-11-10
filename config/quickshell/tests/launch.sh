#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$(cd "$here/.." && pwd)"
script="$config_dir/scripts/launch.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fails=0
ok() { printf 'ok - %s\n' "$1"; }
fail() {
  printf 'not ok - %s\n' "$1"
  fails=$((fails + 1))
}

cat >"$tmp/hyprctl" <<'INNER'
#!/usr/bin/env bash
case " $* " in
  *" -j instances "*)
    printf '[{"time":1,"instance":"test-signature"}]\n'
    ;;
  *" -j workspaces "*)
    printf '[]\n'
    ;;
  *" -j monitors "*)
    cat "$MONITORS_FILE"
    ;;
  *)
    exit 1
    ;;
esac
INNER
chmod +x "$tmp/hyprctl"

cat >"$tmp/jq" <<'INNER'
#!/usr/bin/env bash
exec jq "$@"
INNER
chmod +x "$tmp/jq"

cat >"$tmp/quickshell" <<'INNER'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$QUICKSHELL_LOG"
INNER
chmod +x "$tmp/quickshell"

run_launch() {
  QUICKSHELL_LOG="$tmp/quickshell.log" \
  MONITORS_FILE="$tmp/monitors.json" \
  HYPRCTL_BIN="$tmp/hyprctl" \
  JQ_BIN="$tmp/jq" \
  QUICKSHELL_BIN="$tmp/quickshell" \
  LAUNCH_ATTEMPTS=2 \
  LAUNCH_SETTLE_SECONDS=0 \
  "$script"
}

printf '%s\n' '[{"name":"FALLBACK","disabled":false}]' >"$tmp/monitors.json"
: >"$tmp/quickshell.log"
if run_launch >"$tmp/fallback.out" 2>"$tmp/fallback.err"; then
  fail "launch waits for a real monitor"
else
  if [[ ! -s "$tmp/quickshell.log" ]] && grep -q 'no real monitor' "$tmp/fallback.err"; then
    ok "launch waits for a real monitor"
  else
    fail "launch waits for a real monitor"
  fi
fi

printf '%s\n' '[{"name":"DP-4","disabled":false}]' >"$tmp/monitors.json"
: >"$tmp/quickshell.log"
if run_launch >"$tmp/real.out" 2>"$tmp/real.err"; then
  if grep -q -- "-p $config_dir -n" "$tmp/quickshell.log"; then
    ok "launch execs quickshell at the live config with -n"
  else
    fail "launch execs quickshell at the live config with -n"
  fi
else
  fail "launch execs quickshell at the live config with -n"
fi

if ((fails)); then
  printf '%d test(s) failed\n' "$fails" >&2
  exit 1
fi
printf 'all launch tests passed\n'
