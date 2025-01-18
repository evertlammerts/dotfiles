# Path to Oh My Zsh installation
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
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Editor configuration
export EDITOR="`which nvim`"

# History settings
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=erasedups
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS

# Less configuration
export LESS="--raw-control-chars --ignore-case"

# Path configurations
export PATH="$PATH:/Users/evert/.cache/lm-studio/bin"
export PATH="$HOME/.local/bin:$PATH"

# Tool configurations
alias cat="bat"
alias ls="exa"
alias ll="exa -l"
alias la="exa -la"
alias grep="rg"
export GREP_OPTIONS='--exclude-dir=.venv'

# Load aliases
test -s "${HOME}/.aliases" && . "${HOME}/.aliases" || true

# Load syntax highlighting and autosuggestions
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Initialize Starship prompt
eval "$(starship init zsh)"
