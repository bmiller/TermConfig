#!/usr/bin/env bash
#
# install.sh — install Homebrew packages, symlink configs into $HOME, and
# set up herdr integrations and plugins.
# Safe to re-run.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(zsh ghostty herdr worktrunk git fresh gh lazygit scripts)
HERDR_INTEGRATIONS=(claude)
HERDR_PLUGINS=(
  crokily/herdr-lazygit
  devashish2203/herdr-worktrunk
  smarzban/herdr-file-viewer
)

if ! command -v brew >/dev/null 2>&1; then
  echo "Error: Homebrew is not installed. See README.md." >&2
  exit 1
fi

echo "Installing Homebrew packages..."
brew bundle --file="$REPO_DIR/Brewfile"

echo "Symlinking configs..."
stow --no-folding --dir="$REPO_DIR" --target="$HOME" --restow "${PACKAGES[@]}"

echo "Enabling git hooks (gitleaks secret scan)..."
git -C "$REPO_DIR" config core.hooksPath .githooks

echo "Setting up herdr integrations..."
integration_status="$(herdr integration status 2>&1)"
for target in "${HERDR_INTEGRATIONS[@]}"; do
  if grep -q "^${target}: current" <<<"$integration_status"; then
    echo "  $target: already current"
  else
    herdr integration install "$target"
  fi
done

echo "Installing herdr plugins..."
installed_plugins="$(herdr plugin list)"
for plugin in "${HERDR_PLUGINS[@]}"; do
  if grep -q "\[github:${plugin}@" <<<"$installed_plugins"; then
    echo "  $plugin: already installed"
  else
    herdr plugin install --yes "$plugin"
  fi
done

echo "Done. Open a new shell or run: source ~/.zshrc"
echo "Then: herdr server reload-config"
echo "Still manual (see README): gh auth login, nvm + Node, and the herdr agent skill (npx)."
