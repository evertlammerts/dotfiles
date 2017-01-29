
# Always use nvim
export EDITOR="`which nvim`"
# Defaults for less
export LESS="--raw-control-chars --ignore-case"
# Source aliases if we have them
test -s "${HOME}/.bash_aliases" && . "${HOME}/.bash_aliases" || true

# History control
export HISTCONTROL=erasedups
export HISTSIZE=10000
export HISTFILESIZE=10000

# Git completion, first download https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
_git_completion='/usr/local/etc/bash_completion.d/git-completion.bash'
test -s ${_git_completion} && . ${_git_completion} || true

