#!/usr/bin/env bash
# Bootstrap script for fresh NixOS installs
# Decrypts SSH key from age-encrypted secrets and sets up SSH access

set -euo pipefail

SSH_DIR="$HOME/.ssh"
DOTFILES="$HOME/dotfiles"
ENCRYPTED_KEY="$DOTFILES/secrets/id_ed25519.age"

echo "=== NixOS Fresh Install Bootstrap ==="

# Ensure dotfiles are cloned (via HTTPS first, since no SSH key yet)
if [ ! -d "$DOTFILES" ]; then
  echo "Cloning dotfiles via HTTPS..."
  git clone https://github.com/shahidshabbir-se/dotfiles.git "$DOTFILES"
fi

# Decrypt SSH key
if [ ! -f "$SSH_DIR/id_ed25519" ]; then
  echo "Decrypting SSH key..."
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
  age -d -o "$SSH_DIR/id_ed25519" "$ENCRYPTED_KEY"
  chmod 600 "$SSH_DIR/id_ed25519"
  echo "SSH key restored."
else
  echo "SSH key already exists, skipping."
fi

# Generate public key from private key
if [ ! -f "$SSH_DIR/id_ed25519.pub" ]; then
  ssh-keygen -y -f "$SSH_DIR/id_ed25519" > "$SSH_DIR/id_ed25519.pub"
  echo "Public key generated."
fi

# Switch dotfiles remote to SSH
CURRENT_REMOTE=$(git -C "$DOTFILES" remote get-url origin 2>/dev/null || true)
if [[ "$CURRENT_REMOTE" == https://* ]]; then
  echo "Switching dotfiles remote to SSH..."
  git -C "$DOTFILES" remote set-url origin git@github.com:shahidshabbir-se/dotfiles.git
fi

# Clone wallpapers repo
WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
if [ ! -d "$WALLPAPERS_DIR" ]; then
  echo "Cloning wallpapers repo..."
  git clone git@github.com:shahidshabbir-se/wallpapers.git "$WALLPAPERS_DIR"
  echo "Wallpapers cloned."
else
  echo "Wallpapers repo already exists, skipping."
fi

echo ""
echo "=== Bootstrap complete ==="
echo "Next steps:"
echo "  1. cd ~/dotfiles"
echo "  2. sudo nixos-rebuild switch --flake .#nixos"
