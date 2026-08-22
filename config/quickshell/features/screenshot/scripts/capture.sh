#!/usr/bin/env bash
# Capture / record / open editor for qs.features.screenshot
set -euo pipefail

CAPTURE="$(cd -- "$(dirname "$0")" && pwd)/grimblast-copysave.sh"
SHOT_DIR="${HOME}/Pictures/Screenshots"
REC_DIR="${HOME}/Videos/Recordings"
REC_PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/qs-screenshot-record.pid"
REC_OUT_FILE="${XDG_RUNTIME_DIR:-/tmp}/qs-screenshot-record.out"
DELAY_SEC="${SCREENSHOT_DELAY:-5}"
LOG="${XDG_RUNTIME_DIR:-/tmp}/qs-screenshot.log"

mkdir -p "$SHOT_DIR" "$REC_DIR"

stamp() { date +%Y%m%d-%H%M%S; }

log() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*" >>"$LOG"; }

notify() {
  local app="${NOTIFY_APP:-Screenshot}"
  notify-send -a "$app" -t 7000 "$1" "${2:-}" || true
}

notify_rec() {
  NOTIFY_APP=Recording notify "$@"
}

# QS overlay holds exclusive keyboard focus briefly after close — wait it out.
settle() { sleep 0.35; }

open_editor() {
  local file="$1"
  if command -v swash >/dev/null 2>&1; then
    swash "$file" &
    return
  fi
  if command -v satty >/dev/null 2>&1; then
    satty --filename "$file" --output-filename "$file" --copy-command wl-copy --early-exit &
    return
  fi
  notify "Editor missing" "Install swash (or satty) to annotate / OCR"
}

handle_actions() {
  local out="$1"
  local dir action
  dir="$(dirname "$out")"
  action="$(notify-send -a "Screenshot" -t 10000 \
    -i "$out" \
    -A "edit=Edit" \
    -A "open=Open" \
    -A "folder=Folder" \
    "Screenshot saved" \
    "$out" || true)"
  case "$action" in
  edit) open_editor "$out" ;;
  open) xdg-open "$out" >/dev/null 2>&1 || true ;;
  folder) xdg-open "$dir" >/dev/null 2>&1 || true ;;
  esac
}

open_recording() {
  # Dedicated app-id so Hyprland can float only this launch, not normal mpv.
  if command -v mpv >/dev/null 2>&1; then
    mpv --force-window=immediate --wayland-app-id=qs-screenshot-rec "$1" >/dev/null 2>&1 &
    return
  fi
  xdg-open "$1" >/dev/null 2>&1 || true
}

handle_recording_actions() {
  local out="$1"
  local dir action
  dir="$(dirname "$out")"
  action="$(notify-send -a "Recording" -t 10000 \
    -A "open=Open" \
    -A "folder=Folder" \
    "Recording saved" \
    "$out" || true)"
  case "$action" in
  open) open_recording "$out" ;;
  folder) xdg-open "$dir" >/dev/null 2>&1 || true ;;
  esac
}

do_capture() {
  local mode="$1" delay="${2:-0}"
  local out="$SHOT_DIR/screenshot-$(stamp).png"

  settle
  if [[ "$delay" -gt 0 ]]; then
    notify "Screenshot" "Capturing in ${delay}s…"
    sleep "$delay"
  fi

  log "capture mode=$mode out=$out"
  SCREENSHOT_NO_NOTIFY=1 sh "$CAPTURE" copysave "$mode" "$out"
  handle_actions "$out" &
  disown
}

recording_active() {
  [[ -f "$REC_PID_FILE" ]] || return 1
  local pid
  pid="$(cat "$REC_PID_FILE" 2>/dev/null || true)"
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

start_record() {
  if recording_active; then
    notify_rec "Recording" "Already recording — click REC on the bar to stop"
    return 0
  fi

  if ! command -v wf-recorder >/dev/null 2>&1; then
    notify_rec "Recorder missing" "Install wf-recorder (home-manager switch)"
    return 1
  fi

  settle

  local geom out
  if ! geom="$(slurp 2>>"$LOG")"; then
    log "slurp cancelled/failed"
    exit 0
  fi
  [[ -z "$geom" ]] && exit 0

  out="$REC_DIR/recording-$(stamp).mp4"
  printf '%s\n' "$out" >"$REC_OUT_FILE"

  wf-recorder -g "$geom" -f "$out" >>"$LOG" 2>&1 &
  echo $! >"$REC_PID_FILE"
  log "recording pid=$! out=$out geom=$geom"
}

stop_record() {
  if ! recording_active; then
    notify_rec "Recording" "Nothing to stop"
    rm -f "$REC_PID_FILE"
    return 0
  fi

  local pid out
  pid="$(cat "$REC_PID_FILE")"
  out="$(cat "$REC_OUT_FILE" 2>/dev/null || true)"
  kill -INT "$pid" 2>/dev/null || kill "$pid" 2>/dev/null || true
  for _ in 1 2 3 4 5; do
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.2
  done
  kill -KILL "$pid" 2>/dev/null || true
  rm -f "$REC_PID_FILE"
  log "stopped pid=$pid out=$out"
  if [[ -n "$out" && -f "$out" ]]; then
    handle_recording_actions "$out" &
    disown
  else
    notify_rec "Recording stopped" ""
  fi
}

action="${1:-}"
log "action=$action"
case "$action" in
screen) do_capture screen 0 ;;
area) do_capture area 0 ;;
window) do_capture active 0 ;;
screen-delay) do_capture screen "$DELAY_SEC" ;;
area-delay) do_capture area "$DELAY_SEC" ;;
record) start_record ;;
stop) stop_record ;;
edit)
  [[ -n "${2:-}" ]] || exit 1
  open_editor "$2"
  ;;
*)
  echo "Usage: $0 screen|area|window|screen-delay|area-delay|record|stop|edit <file>" >&2
  exit 1
  ;;
esac
