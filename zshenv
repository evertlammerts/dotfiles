# Every zsh reads this file, including the non-interactive shells that agents,
# editors and build tools start, so keep it fast and free of output, and keep
# values a caller already set.

export LANG="${LANG:-en_US.UTF-8}"
export EDITOR="${EDITOR:-nvim}"

export HOMEBREW_PREFIX=/opt/homebrew
dotfiles_path=(
    $HOME/.local/bin
    $HOME/.duckdb/cli/latest
    $HOMEBREW_PREFIX/opt/curl/bin
    $HOMEBREW_PREFIX/bin
    $HOMEBREW_PREFIX/sbin
    "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
)
typeset -U path PATH
# Prepend only missing entries, so a caller's venv or direnv PATH keeps its order.
for dir in ${(Oa)dotfiles_path}; do
    (( ${path[(Ie)$dir]} )) || path=($dir $path)
done
unset dir

fdlimit=$(ulimit -n)
[[ $fdlimit == unlimited ]] || (( fdlimit >= 8192 )) || ulimit -n 8192 2>/dev/null
unset fdlimit

# The 10G default is smaller than one debug build per active DuckDB worktree,
# so worktrees on different commits evict each other's objects.
export SCCACHE_CACHE_SIZE="${SCCACHE_CACHE_SIZE:-50G}"

# Apple's ar only writes 32 bit archives and aborts once a debug
# libduckdb_static.a passes 4GB. scikit-build reads CMAKE_ARGS; the core
# Makefile does not.
if [[ -x $HOMEBREW_PREFIX/opt/llvm/bin/llvm-ar && $CMAKE_ARGS != *-DCMAKE_AR=* ]]; then
    export CMAKE_ARGS="${CMAKE_ARGS:+$CMAKE_ARGS }-DCMAKE_AR=$HOMEBREW_PREFIX/opt/llvm/bin/llvm-ar -DCMAKE_RANLIB=$HOMEBREW_PREFIX/opt/llvm/bin/llvm-ranlib"
fi

if [[ -r ~/.zshenv.work ]]; then
    source ~/.zshenv.work
fi
