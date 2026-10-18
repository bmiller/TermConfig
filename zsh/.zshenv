# Read by every zsh, including non-interactive ones like `ssh host cmd` and
# `herdr --remote`, so Homebrew tools are found there too.
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
