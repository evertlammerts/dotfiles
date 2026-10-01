export LC_ALL="en_US.UTF-8"

export ZSH="$HOME/.oh-my-zsh"

# Oh My Zsh theme (using Starship instead)
ZSH_THEME=""

# Oh My Zsh plugins
plugins=(
    git
    python
    macos
    brew
    history
    dirhistory
    z
    colored-man-pages
    command-not-found
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Tool-specific configurations
export BAT_THEME="Dracula"
export JQ_COLORS="1;31:0;37:0;37:0;37:0;32:1;37:1;37"
export TLDR_LANGUAGE="en"
export TLDR_CACHE_ENABLED=1
export TLDR_CACHE_MAX_AGE=720

# History settings
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS

# Less configuration
export LESS="--raw-control-chars --ignore-case --status-column"
export LESSHISTFILE="-"

# FZF Configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_DEFAULT_COMMAND='fd --type f --follow --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export FZF_ALT_C_OPTS="--preview 'lsd --tree {} | head -50'"
bindkey '^T' fzf-file-widget
bindkey '^R' fzf-history-widget

# JSON/YAML/CSV functions
function jsonview() { cat "$1" | jq -C '.' | less -R }
function yamlview() { cat "$1" | yq -p=yaml -o=json | jq -C '.' | less -R }
function csvview() { qsv table "$1" | less -S }

# Network monitoring functions
function port() { sudo lsof -i ":$1" }
function listen() { sudo lsof -iTCP -sTCP:LISTEN -P }
# Load aliases
test -s "${HOME}/.aliases" && . "${HOME}/.aliases" || true

# Completions configuration
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Commit signing needs the key in ssh-agent, which stays empty after login
# until the first ssh connection loads it from the keychain.
ssh-add -T ~/.ssh/id_ed25519.pub >/dev/null 2>&1 || ssh-add --apple-load-keychain -q 2>/dev/null

# Load the personal profile, then machine-specific configuration
test -s "${HOME}/.zshrc.personal" && . "${HOME}/.zshrc.personal" || true
test -s "${HOME}/.zshrc.local" && . "${HOME}/.zshrc.local" || true

source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Initialize Starship prompt
eval "$(starship init zsh)"

eval "$(direnv hook zsh)"
