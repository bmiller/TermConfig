# Login shells: macOS's /etc/zprofile runs path_helper after .zshenv, which
# moves system dirs ahead of Homebrew. Re-run shellenv to put Homebrew first.
eval "$(/opt/homebrew/bin/brew shellenv)"
