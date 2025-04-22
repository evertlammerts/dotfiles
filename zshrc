# Path to Oh My Zsh installation

# Set up locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export ZSH="$HOME/.oh-my-zsh"

# Oh My Zsh theme (using Starship instead)
ZSH_THEME=""

# Oh My Zsh plugins
plugins=(
    git
    docker
    python
    pip
    macos
    brew
    kubectl
    history
    dirhistory
    z
    colored-man-pages
    command-not-found
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Editor configuration
export EDITOR="`which nvim`"

# Tool-specific configurations
export BAT_THEME="Dracula"
export JQ_COLORS="1;31:0;37:0;37:0;37:0;32:1;37:1;37"
export TLDR_LANGUAGE="en"
export TLDR_CACHE_ENABLED=1
export TLDR_CACHE_MAX_AGE=720

# History settings
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=erasedups
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS

# Less configuration
# Less configuration
export LESS="--raw-control-chars --ignore-case --status-column"
export LESSHISTFILE="-"

# Path configurations
export PATH="$PATH:/Users/evert/.cache/lm-studio/bin"
export PATH="$HOME/.local/bin:$PATH"

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
function csvview() { xsv table "$1" | less -S }

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

# Load machine-specific configurations
test -s "${HOME}/.zshrc.local" && . "${HOME}/.zshrc.local" || true

# Initialize Starship prompt
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Initialize Starship prompt
eval "$(starship init zsh)"
