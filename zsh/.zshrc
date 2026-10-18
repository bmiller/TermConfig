# ---- PATH ----
eval "$(/opt/homebrew/bin/brew shellenv)"   # Homebrew bin/sbin, plus its completions in fpath
typeset -U path fpath                        # drop duplicate entries
path=("$HOME/.local/bin" $path)

# Default editor (used by git, lazygit, and herdr-file-viewer's `e` key)
export EDITOR="fresh"
export VISUAL="fresh"

export NVM_DIR="$HOME/.nvm"
path=(${path:#$NVM_DIR/*})   # drop inherited nvm entries so nvm re-adds its node at the front
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PS1="%F{135}%1~ %# "

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=50000
HISTSIZE=55000   # larger than SAVEHIST so hist_expire_dups_first has room to drop dups
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ---- Tab completion ----
autoload -Uz compinit && compinit

# ---- fzf: Ctrl-R history search, Ctrl-T insert file path, Alt-C cd into dir ----
source <(fzf --zsh)

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# ---- Eza (better ls) -----
alias ls="eza --icons --grid --group-directories-first"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# ---- herdr completions ----
if command -v herdr >/dev/null 2>&1; then source <(herdr completion zsh); fi

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"

# Machine-specific settings and secrets (not tracked in git)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Must be sourced last so it can wrap every widget defined above
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
