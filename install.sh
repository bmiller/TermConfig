#!/usr/bin/env bash
#
# install.sh — install Homebrew packages and symlink configs into $HOME.
# Safe to re-run.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(zsh ghostty herdr worktrunk git scripts)

if ! command -v brew >/dev/null 2>&1; then
  echo "Error: Homebrew is not installed. See README.md." >&2
  exit 1
fi

echo "Installing Homebrew packages..."
brew bundle --file="$REPO_DIR/Brewfile"

echo "Symlinking configs..."
stow --no-folding --dir="$REPO_DIR" --target="$HOME" --restow "${PACKAGES[@]}"

echo "Done. Open a new shell or run: source ~/.zshrc"
