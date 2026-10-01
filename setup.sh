#!/usr/bin/env zsh
#
# Usage: ./setup.sh work|personal [links]
#
#   work      shared tools and configuration
#   personal  also the personal Brewfile, homelab hosts and huisarchief
#   links     only link configuration, set the iTerm2 profile and set up commit
#             signing, install nothing

SCRIPT_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"
PROFILE="${1:-}"
STEP="${2:-all}"

if [[ $PROFILE != (work|personal) || $STEP != (all|links) ]]; then
    echo "usage: $0 work|personal [links]" >&2
    exit 2
fi

LOG_FILE="$SCRIPT_DIR/setup.log"
: > "$LOG_FILE"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

failed_steps=()

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

error() {
    echo "[ERROR] $1" >&2
    failed_steps+=("$1")
}

setup_directories() {
    log "Creating necessary directories..."
    mkdir -p "$HOME/.config/nvim/colors" \
             "$HOME/.local/share/nvim/site/autoload" \
             "$HOME/.local/bin" \
             "$HOME/.config/git" \
             "$HOME/.ssh/control" \
             "$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    chmod 700 "$HOME/.ssh" "$HOME/.ssh/control" || error "Failed to set permissions on ~/.ssh directories"
}

install_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error "Failed to install Homebrew"
    else
        log "Homebrew is already installed, skipping..."
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_packages() {
    log "Installing Homebrew packages..."
    brew bundle --file="$SCRIPT_DIR/Brewfile" || error "brew bundle failed for Brewfile"
    if [[ $PROFILE == personal ]]; then
        brew bundle --file="$SCRIPT_DIR/personal/Brewfile" || error "brew bundle failed for personal/Brewfile"
    fi

    # coreutils installs GNU timeout as gtimeout so it does not shadow BSD tools.
    local gtimeout="$(brew --prefix)/bin/gtimeout"
    if [ -x "$gtimeout" ]; then
        ln -sf "$gtimeout" "$HOME/.local/bin/timeout" || error "Failed to link timeout"
    else
        error "gtimeout not found, is coreutils installed?"
    fi
}

install_python() {
    log "Installing Python versions and uv tools..."
    uv python install 3.12 3.13 || error "Failed to install Python versions"
    # cmake-format (cmakelang) fails under Python 3.14.
    uv python pin --global 3.13 || error "Failed to pin the global Python version"
    # pre-commit install bakes this interpreter into git hooks, and its
    # cmake-format hook crashes under Python 3.14.
    uv tool install --python 3.12 pre-commit || error "Failed to install pre-commit"
    for tool in git-filter-repo rust-just py-spy; do
        uv tool install "$tool" || error "Failed to install $tool"
    done
}

setup_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "Installing Oh My Zsh..."

        # Backup existing .zshrc if it exists
        if [ -f "$HOME/.zshrc" ]; then
            log "Backing up existing .zshrc..."
            if ! mv "$HOME/.zshrc" "$HOME/.zshrc.pre-oh-my-zsh"; then
                error "Failed to backup .zshrc"
                return
            fi
        fi

        # Install Oh My Zsh
        if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
            # Restore backup if installation fails
            if [ -f "$HOME/.zshrc.pre-oh-my-zsh" ]; then
                mv "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/.zshrc" || error "Failed to restore backup .zshrc"
            fi
            error "Failed to install Oh My Zsh"
            return
        fi

        # Remove the default .zshrc created by Oh My Zsh
        if [ -f "$HOME/.zshrc" ]; then
            log "Removing default Oh My Zsh .zshrc..."
            if ! rm "$HOME/.zshrc"; then
                error "Failed to remove default .zshrc"
                return
            fi
        fi

        # If we had a backup, save it with a timestamp
        if [ -f "$HOME/.zshrc.pre-oh-my-zsh" ]; then
            if ! mv "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/.zshrc.backup.$(date +%Y%m%d)"; then
                log "WARNING: Failed to rename backup .zshrc"
            fi
        fi
    else
        log "Oh My Zsh is already installed, skipping..."
    fi
}

setup_neovim() {
    log "Setting up Neovim..."

    # molokai color scheme
    if ! curl -fLo "$HOME/.config/nvim/colors/molokai.vim" --create-dirs \
        https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim; then
        error "Failed to install molokai color scheme"
    fi

    # vim-plug
    if [ ! -e "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
        if ! curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
            error "Failed to install vim-plug"
            return
        fi

        if ! nvim --headless +PlugInstall +q +q; then
            error "Failed to install vim plugins via vim-plug"
        fi
    else
        log "vim-plug is already installed, skipping..."
    fi
}

setup_git_signing() {
    log "Setting up SSH commit signing..."
    local key="$HOME/.ssh/id_ed25519"
    local email="$(git -C "$HOME" config user.email)"

    if [ ! -f "$key" ]; then
        log "Generating $key..."
        if ! ssh-keygen -t ed25519 -C "$email" -f "$key"; then
            error "Failed to generate $key"
            return
        fi
        ssh-add --apple-use-keychain "$key" || error "Failed to add $key to ssh-agent and the keychain"
        log "Add $key.pub to GitHub twice: as an authentication key and as a signing key"
    fi

    if [ ! -f "$key.pub" ]; then
        error "Missing $key.pub, regenerate it with ssh-keygen -y -f $key"
        return
    fi
    echo "$email $(cat "$key.pub")" > "$HOME/.config/git/allowed_signers" || error "Failed to write allowed_signers"
}

setup_macos() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log "Configuring macOS settings..."
        # Show hidden files in Finder
        defaults write com.apple.finder AppleShowAllFiles YES || error "Failed to show hidden files in Finder"
        # Show path bar in Finder
        defaults write com.apple.finder ShowPathbar -bool true || error "Failed to show path bar in Finder"
        # Show status bar in Finder
        defaults write com.apple.finder ShowStatusBar -bool true || error "Failed to show status bar in Finder"
        # Use list view in Finder windows by default
        defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" || error "Failed to set Finder view style to list"

        # Apply Finder changes
        if ! killall Finder; then
            error "Failed to restart Finder"
        fi

        # Long builds and test runs otherwise die when the machine idles to sleep.
        if [[ $(pmset -g custom | awk '/^AC Power/ {ac = 1} ac && $1 == "sleep" {print $2; exit}') != 0 ]]; then
            log "Disabling system sleep on power adapter (asks for your password)..."
            sudo pmset -c sleep 0 || error "Failed to disable system sleep on power adapter"
        fi

        for dir in "$HOME/.cache" "$HOME/.ccache"; do
            if [ -d "$dir" ]; then
                tmutil addexclusion "$dir" || error "Failed to exclude $dir from Time Machine"
            fi
        done
    fi
}

setup_iterm2() {
    log "Linking iTerm2 profile..."
    local profile="$SCRIPT_DIR/iterm2/dotfiles_profile.json"
    # A backup copy in DynamicProfiles would load as a second profile with the same Guid.
    ln -sf "$profile" "$HOME/Library/Application Support/iTerm2/DynamicProfiles/dotfiles_profile.json" \
        || error "Failed to link iTerm2 profile"
    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$(plutil -extract Profiles.0.Guid raw "$profile")" \
        || error "Failed to set default iTerm2 profile"
}

setup_symlinks() {
    log "Setting up symlinks..."

    # Array of files to symlink (source:destination)
    local links=(
        "init.vim:.config/nvim/init.vim"
        "zshenv:.zshenv"
        "zprofile:.zprofile"
        "zshrc:.zshrc"
        "aliases:.aliases"
        "gitconfig:.gitconfig"
        "gitattributes:.gitattributes"
        "gitignore_global:.gitignore_global"
        "tmux.conf:.tmux.conf"
        "ssh_config:.ssh/config"
    )
    if [[ $PROFILE == personal ]]; then
        links+=(
            "personal/zshrc:.zshrc.personal"
            "personal/ssh_config:.ssh/config.personal"
        )
    fi

    local failed_links=()

    for link in "${links[@]}"; do
        local src="${link%%:*}"
        local dst="${link#*:}"
        local target="$HOME/$dst"
        local source_file="$SCRIPT_DIR/$src"

        if [ -L "$target" ]; then
            if [[ $(readlink "$target") == "$source_file" ]]; then
                log "Symlink for $dst already exists, skipping..."
                continue
            fi
            log "Replacing $dst, which links to $(readlink "$target")..."
            rm "$target"
        fi

        # Backup existing file if it's not a symlink
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            log "Backing up existing $dst..."
            if ! mv "$target" "${target}.backup.$(date +%Y%m%d)"; then
                log "WARNING: Failed to backup $dst"
                failed_links+=("$dst")
                continue
            fi
        fi

        # Create symlink
        if ! ln -s "$source_file" "$target"; then
            log "WARNING: Failed to create symlink for $dst"
            failed_links+=("$dst")
        else
            log "Created symlink: $target -> $source_file"
        fi
    done

    for dst in "${failed_links[@]}"; do
        error "Failed to link $dst"
    done
}

main() {
    log "Starting dotfiles setup ($PROFILE, $STEP)..."

    setup_directories
    if [[ $STEP == all ]]; then
        install_homebrew
        install_packages
        install_python
        setup_zsh
    fi
    setup_symlinks
    setup_iterm2
    setup_git_signing
    if [[ $STEP == all ]]; then
        setup_neovim
        setup_macos
    fi

    if [ ${#failed_steps[@]} -ne 0 ]; then
        log "The following errors occurred during setup:"
        for step in "${failed_steps[@]}"; do
            log "  - $step"
        done
        exit 1
    fi

    log "Setup completed successfully!"
}

main
