#!/usr/bin/env sh
set -eu

quickshell -c bar ipc call notifications toggle >/dev/null 2>&1 || true
sleep 0.5

hyprctl layers -j | python3 -c "
import json, sys
layers = json.load(sys.stdin)
found = False
for mon, info in layers.items():
    for level, ws in info.get('levels', {}).items():
        for w in ws:
            ns = w.get('namespace', '')
            if 'notification' in ns or 'popup_dismiss' in ns:
                found = True
                print(f\"{ns}: {w['w']}x{w['h']} @ ({w['x']},{w['y']})\")
if not found:
    print('no notification/dismiss layers visible')
"
