#!/bin/zsh

# Set up logging
LOG_FILE="$HOME/dotfiles_setup.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Create necessary directories
setup_directories() {
    log "Creating necessary directories..."
    mkdir -p ~/.config/nvim/colors \
            ~/.local/share/nvim/site/autoload \
            ~/.ssh \
            ~/.ssh/control
    chmod 700 ~/.ssh ~/.ssh/control
}

# Install Homebrew if not present
install_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error "Failed to install Homebrew"
    fi
}

# Install essential tools
install_tools() {
    log "Installing command line tools..."
    brew install \
        neovim \
        gh \
        bat \
        ripgrep \
        exa \
        starship \
        zsh-autosuggestions \
        zsh-syntax-highlighting \
        tmux \
        git-delta || error "Failed to install tools"

    # Remove hub if installed (replacing with gh)
    brew uninstall hub 2>/dev/null || true
}

# Install and configure Oh My Zsh
setup_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || error "Failed to install Oh My Zsh"
    fi
}

# Set up Neovim
setup_neovim() {
    log "Setting up Neovim..."
    # molokai color scheme
    curl -fLo ~/.config/nvim/colors/molokai.vim --create-dirs \
        https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim || error "Failed to install molokai"

    # vim-plug
    [ -e ~/.local/share/nvim/site/autoload/plug.vim ] || \
        (curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
        nvim --headless +PlugInstall +q +q) || error "Failed to install vim-plug"
}

# macOS specific configurations
setup_macos() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log "Configuring macOS settings..."
        # Show hidden files in Finder
        defaults write com.apple.finder AppleShowAllFiles YES
        # Show path bar in Finder
        defaults write com.apple.finder ShowPathbar -bool true
        # Show status bar in Finder
        defaults write com.apple.finder ShowStatusBar -bool true
        # Use list view in Finder windows by default
        defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
        
        killall Finder
    fi
}

# Main setup
main() {
    log "Starting dotfiles setup..."
    
    setup_directories
    install_homebrew
    install_tools
    setup_zsh
    setup_neovim
    setup_macos
    
    log "Setup completed successfully!"
}

main
