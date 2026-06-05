#!/usr/bin/env bash
set -euo pipefail

# ───────────────────────────────────────────────
# Post-install setup script
# Run after nixos-rebuild / home-manager switch
# ───────────────────────────────────────────────

REPO="git@github.com:shahidshabbir-se/lock-screen.git"
TARGET="$HOME/.config/lock-screen"

echo "→ Setting up lock-screen..."

if [ ! -d "$TARGET" ]; then
  git clone "$REPO" "$TARGET"
  chmod +x "$TARGET/lock.sh"
  echo "  ✓ lock-screen cloned to $TARGET"
else
  echo "  ✓ lock-screen already exists at $TARGET"
  echo "  → Run 'cd $TARGET && git pull' to update"
fi

echo "→ Done. Lock screen ready at $TARGET/lock.sh"
