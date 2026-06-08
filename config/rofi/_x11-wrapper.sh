# ────────────────────────────────────────────────────────────
# Rofi X11 wrapper — sourced by rofi launch scripts.
# On GNOME/Mutter, rofi's Wayland backend can't connect
# (no wlr-layer-shell protocol), so we force X11/XWayland.
#
# This discovers the XWayland auth file from the running
# Xwayland process and sets DISPLAY + XAUTHORITY correctly,
# then unsets WAYLAND_DISPLAY so rofi uses the X11 backend.
# ────────────────────────────────────────────────────────────

_rofi_x11_env() {
	# Only needed under Wayland (GNOME)
	[ "$XDG_SESSION_TYPE" != "wayland" ] && return 0
	# Only needed when the desktop is GNOME
	case "${XDG_CURRENT_DESKTOP,,}" in
	*gnome* | *mutter*) ;; # proceed
	*) return 0 ;;         # not GNOME — skip
	esac

	# Find XWayland auth file from the process command line
	local xauth_file
	xauth_file="$(
		command -v pgrep >/dev/null 2>&1 &&
			pgrep -a Xwayland 2>/dev/null |
			grep -oP '(?<=-auth )\S+' |
				head -1
	)"

	if [ -n "$xauth_file" ] && [ -f "$xauth_file" ]; then
		export XAUTHORITY="$xauth_file"
	fi

	# Ensure DISPLAY is set (GNOME typically uses :1)
	[ -z "$DISPLAY" ] && export DISPLAY=":0"

	# Unset Wayland so rofi falls through to X11
	unset WAYLAND_DISPLAY
}

_rofi_x11_env
