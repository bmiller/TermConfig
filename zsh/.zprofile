# Login shells (including non-interactive ones like `ssh host cmd`) read this
# but not .zshrc, so set up Homebrew here too. .zshrc repeats it for
# interactive non-login shells; duplicate PATH entries are removed there.
eval "$(/opt/homebrew/bin/brew shellenv)"
