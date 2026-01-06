#!/usr/bin/env bash

MPD_HOST="127.0.0.1"
MPD_PORT="6600"

if ! nc -z $MPD_HOST $MPD_PORT 2>/dev/null; then
    echo ""
    exit 0
fi

TITLE=$(echo -e "status\ncurrentsong\nclose" | nc $MPD_HOST $MPD_PORT 2>/dev/null | grep "^Title:" | cut -d: -f2- | sed 's/^ *//' | head -n 1)

if [[ -z "$TITLE" ]]; then
    echo ""
else
    echo "[$TITLE]"
fi