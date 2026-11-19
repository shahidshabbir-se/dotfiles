#!/usr/bin/env bash
set -euo pipefail

# Compatibility entry point; screenshot capture is provided by Omashell/Omasnap.
exec omashell ipc call omashell captureScreenshot
