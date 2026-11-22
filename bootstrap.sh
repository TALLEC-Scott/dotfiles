#!/usr/bin/env bash
# Set up this dotfiles repo on any Linux distro (or WSL) with Nix + Home Manager.
# Usage: ./bootstrap.sh [host]   (host = a key of homeConfigurations in flake.nix, default: scott)
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="${1:-scott}"

if ! command -v nix >/dev/null 2>&1; then
  echo ">> Installing Nix (multi-user)"
  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon --yes
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

mkdir -p "$HOME/.config/nix"
if ! grep -qs 'flakes' "$HOME/.config/nix/nix.conf"; then
  echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
fi

echo ">> Activating Home Manager config '$HOST' from $REPO"
# -b backup: existing ~/.bashrc, ~/.vimrc, ... are renamed to *.backup instead of failing
nix run home-manager/master -- switch -b backup --flake "$REPO#$HOST"

echo ">> Done. Open a new shell (or run: exec bash)."
