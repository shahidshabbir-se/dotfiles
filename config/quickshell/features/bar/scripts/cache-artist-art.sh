#!/usr/bin/env bash

set -u

artist="${1:-}"
output="${2:-}"

if [[ -z "$artist" || -z "$output" ]]; then
  exit 2
fi

artist_url="$({
  curl --fail --silent --get \
    --proto '=https' \
    --proto-redir '=https' \
    --connect-timeout 5 \
    --max-time 12 \
    --data-urlencode "s=$artist" \
    'https://www.theaudiodb.com/api/v1/json/123/search.php'
} | jq -r '
  .artists[0]
  | .strArtistFanart
    // .strArtistFanart2
    // .strArtistWideThumb
    // .strArtistBanner
    // .strArtistThumb
    // empty
')"

if [[ -z "$artist_url" ]]; then
  exit 1
fi

curl --fail --silent --location \
  --proto '=https' \
  --proto-redir '=https' \
  --connect-timeout 5 \
  --max-time 20 \
  --max-filesize 10000000 \
  --output "$output" \
  "$artist_url"
