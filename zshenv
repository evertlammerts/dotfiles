# Every zsh reads this file, including the non-interactive shells that agents,
# editors and build tools start, so keep it fast and free of output.

export LANG="en_US.UTF-8"
export EDITOR=nvim

export HOMEBREW_PREFIX=/opt/homebrew
typeset -U path PATH
path=(
    $HOME/.local/bin
    $HOME/.duckdb/cli/latest
    $HOMEBREW_PREFIX/opt/curl/bin
    $HOMEBREW_PREFIX/bin
    $HOMEBREW_PREFIX/sbin
    $path
)

ulimit -n 8192

# The 10G default is smaller than one debug build per active DuckDB worktree,
# so worktrees on different commits evict each other's objects.
export SCCACHE_CACHE_SIZE=50G

# Apple's ar only writes 32 bit archives and aborts once a debug
# libduckdb_static.a passes 4GB. scikit-build reads CMAKE_ARGS; the core
# Makefile does not.
if [[ -x $HOMEBREW_PREFIX/opt/llvm/bin/llvm-ar ]]; then
    export CMAKE_ARGS="-DCMAKE_AR=$HOMEBREW_PREFIX/opt/llvm/bin/llvm-ar -DCMAKE_RANLIB=$HOMEBREW_PREFIX/opt/llvm/bin/llvm-ranlib"
fi
