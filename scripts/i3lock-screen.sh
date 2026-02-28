#!/bin/sh
# =============================================================
# Screen locker with blur effect - adapted from gh0stzk/dotfiles
# =============================================================

TEMP_IMAGE="/tmp/i3lock.jpg"

# Colors (Catppuccin Mocha / Tokyo Night)
bg=#1a1b26
fg=#c0caf5
ring=#15161e
wrong=#f7768e
date=#c0caf5
verify=#9ece6a

# Get screen resolution dynamically
get_screen_resolution() {
    if command -v xrandr >/dev/null 2>&1; then
        resolution=$(xrandr | grep '\*' | awk '{print $1}' | head -n1)
    elif command -v xdpyinfo >/dev/null 2>&1; then
        resolution=$(xdpyinfo | awk '/dimensions:/ {print $2}')
    else
        resolution="1920x1080"
    fi

    SCREEN_WIDTH=$(echo $resolution | cut -d'x' -f1)
    SCREEN_HEIGHT=$(echo $resolution | cut -d'x' -f2)
}

# Calculate positions based on screen resolution
calculate_positions() {
    CENTER_X=$((SCREEN_WIDTH * 25 / 100))

    TIME_Y=$((SCREEN_HEIGHT * 36 / 100))
    DATE_Y=$((SCREEN_HEIGHT * 42 / 100))
    IND_Y=$((SCREEN_HEIGHT * 56 / 100))
    VERIF_Y=$((SCREEN_HEIGHT * 76 / 100))
    GREETER_Y=$((SCREEN_HEIGHT * 72 / 100))
    WRONG_Y=$((SCREEN_HEIGHT * 76 / 100))

    BASE_WIDTH=1920
    BASE_HEIGHT=1080

    SCALE_FACTOR=$(echo "scale=2; sqrt(($SCREEN_WIDTH * $SCREEN_HEIGHT) / ($BASE_WIDTH * $BASE_HEIGHT))" | bc)

    if [ -z "$SCALE_FACTOR" ]; then
        if [ $SCREEN_WIDTH -le 1366 ]; then
            SCALE_FACTOR=0.8
        elif [ $SCREEN_WIDTH -le 1920 ]; then
            SCALE_FACTOR=1.0
        elif [ $SCREEN_WIDTH -le 2560 ]; then
            SCALE_FACTOR=1.3
        else
            SCALE_FACTOR=1.5
        fi
    fi

    TIME_SIZE=$(echo "140 * $SCALE_FACTOR" | bc | cut -d. -f1)
    DATE_SIZE=$(echo "45 * $SCALE_FACTOR" | bc | cut -d. -f1)
    TEXT_SIZE=$(echo "23 * $SCALE_FACTOR" | bc | cut -d. -f1)
    RADIUS=$(echo "30 * $SCALE_FACTOR" | bc | cut -d. -f1)
    RING_WIDTH=$(echo "60 * $SCALE_FACTOR" | bc | cut -d. -f1)

    if [ -z "$TIME_SIZE" ]; then
        TIME_SIZE=140
        DATE_SIZE=45
        TEXT_SIZE=23
        RADIUS=30
        RING_WIDTH=60
    fi
}

get_screen_resolution
calculate_positions

maim -d 0.3 -u ${TEMP_IMAGE}
magick $TEMP_IMAGE -blur 5x4 $TEMP_IMAGE
i3lock -n --force-clock -i $TEMP_IMAGE -e --indicator \
    --radius=$RADIUS --ring-width=$RING_WIDTH --inside-color=$bg \
    --ring-color=$ring --insidever-color=$verify --ringver-color=$verify \
    --insidewrong-color=$wrong --ringwrong-color=$wrong --line-uses-inside \
    --keyhl-color=$verify --separator-color=$verify --bshl-color=$verify \
    --time-str="%H:%M" --time-size=$TIME_SIZE --date-str="%a, %d %b" \
    --date-size=$DATE_SIZE --verif-text="Verifying Password..." --wrong-text="Wrong Password!" \
    --noinput-text="" --greeter-text="Type the password to Unlock" --ind-pos="$CENTER_X:$IND_Y" \
    --time-font="JetBrainsMono NF:style=Bold" --date-font="JetBrainsMono NF" --verif-font="JetBrainsMono NF" \
    --greeter-font="JetBrainsMono NF" --wrong-font="JetBrainsMono NF" --verif-size=$TEXT_SIZE \
    --greeter-size=$TEXT_SIZE --wrong-size=$TEXT_SIZE --time-pos="$CENTER_X:$TIME_Y" \
    --date-pos="$CENTER_X:$DATE_Y" --greeter-pos="$CENTER_X:$GREETER_Y" --wrong-pos="$CENTER_X:$WRONG_Y" \
    --verif-pos="$CENTER_X:$VERIF_Y" --date-color=$date --time-color=$date \
    --greeter-color=$fg --wrong-color=$wrong --verif-color=$verify \
    --pointer=default --refresh-rate=0 \
    --pass-media-keys --pass-volume-keys
