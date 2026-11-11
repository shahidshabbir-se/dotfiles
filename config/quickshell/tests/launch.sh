#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="$(cd "$here/.." && pwd)"
repo_root="$(cd "$config_dir/../.." && pwd)"
shell_dir="$repo_root/vendor/omarchy/shell"
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
printf 'args: %s\n' "$*" >>"$QUICKSHELL_LOG"
printf 'omarchy: %s\n' "${OMARCHY_PATH:-}" >>"$QUICKSHELL_LOG"
printf 'path: %s\n' "${PATH:-}" >>"$QUICKSHELL_LOG"
INNER
chmod +x "$tmp/quickshell"

run_launch() {
  OMARCHY_PATH="" \
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
  if grep -q -- "-p $shell_dir -n" "$tmp/quickshell.log"; then
    ok "launch execs the vendored Omarchy shell with -n"
  else
    fail "launch execs the vendored Omarchy shell with -n"
  fi
  if grep -qx "omarchy: $repo_root/vendor/omarchy" "$tmp/quickshell.log"; then
    ok "launch exports OMARCHY_PATH as the vendored tree"
  else
    fail "launch exports OMARCHY_PATH as the vendored tree"
  fi
  if grep -q "path: $repo_root/vendor/omarchy/bin:" "$tmp/quickshell.log"; then
    ok "launch puts the vendored bin first on PATH"
  else
    fail "launch puts the vendored bin first on PATH"
  fi
else
  fail "launch execs the vendored Omarchy shell with -n"
fi

if ((fails)); then
  printf '%d test(s) failed\n' "$fails" >&2
  exit 1
fi
printf 'all launch tests passed\n'
