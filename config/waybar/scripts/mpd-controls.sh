#!/usr/bin/env bash

MPD_HOST="127.0.0.1"
MPD_PORT="6600"

STATUS=$(nc -z $MPD_HOST $MPD_PORT 2>/dev/null && echo "online" || echo "offline")

if [[ "$STATUS" == "offline" ]]; then
    echo " No Music"
else
    OUTPUT=""
    OUTPUT+=$(echo -e "%{T2}\uf048 ")
    OUTPUT+=$(echo -e "%{T2}\uf04c ")
    OUTPUT+=$(echo -e "%{T2}\uf051")
    echo "$OUTPUT"
fi