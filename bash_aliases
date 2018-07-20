alias ll='ls -lahtr'
alias git=hub
alias vim='nvim'
alias vi='nvim'
alias show_hidden_files='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hide_hidden_files='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
alias code='/Applications/Visual\ Studio\ Code.app/Contents/MacOS/Electron'

newpwd() {
  len=${1:-12}
  LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w $len | head -n 1
}

# create a python 3.6 venv as .venv in the current directoy, with the promptname being the current dir's name
venv() {
  [ -z "$VIRTUAL_ENV" ] || deactivate
  [ -e .venv ] ||
    python3.6 -m venv --prompt "`basename "$PWD"`" .venv
  ACTIVATE='.venv/bin/activate'
  [ -e "$ACTIVATE" ] && . "$ACTIVATE" && pip install --upgrade setuptools || echo "File not found: $ACTIVATE" >&2
}

