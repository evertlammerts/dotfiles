#!/usr/bin/env zsh

# Set up logging
LOG_FILE="$HOME/projects/dotfiles/make.log"
# Clear previous log
: > "$LOG_FILE"
# Redirect all output to both terminal and log file
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

# Initialize an array to collect failed steps
failed_steps=()

# Logging functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

error() {
    echo "[ERROR] $1" >&2
    failed_steps+=("$1")
}

# Determine the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"

# Create necessary directories
setup_directories() {
    log "Creating necessary directories..."
    mkdir -p "$HOME/.config/nvim/colors" \
             "$HOME/.local/share/nvim/site/autoload" \
             "$HOME/.ssh" \
             "$HOME/.ssh/control"
    chmod 700 "$HOME/.ssh" "$HOME/.ssh/control" || error "Failed to set permissions on ~/.ssh directories"
}

# Install Homebrew if not present
install_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error "Failed to install Homebrew"
    else
        log "Homebrew is already installed, skipping..."
    fi
}

# Install essential tools
install_tools() {
    log "Installing command line tools..."

    # Define tools
    tools=(
        "neovim"
        "gh"
        "bat"
        "ripgrep"
        "lsd"
        "starship"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "tmux"
        "git-delta"
        "fd"
        "duf"
        "ncdu"
        "jq"
        "yq"
        "xsv"
        "btop"
        "tldr"
        "httpie"
        "mtr"
        "bandwhich"
        "direnv"
    )

    # Define descriptions
    descriptions=(
        "Text editor"
        "GitHub CLI"
        "Cat clone with syntax highlighting"
        "Fast search tool"
        "Modern ls replacement with icons"
        "Shell prompt"
        "ZSH autosuggestions"
        "ZSH syntax highlighting"
        "Terminal multiplexer"
        "Better diff viewer"
        "User-friendly find alternative"
        "Better disk usage viewer"
        "NCurses disk usage analyzer"
        "JSON processor"
        "YAML processor"
        "CSV toolkit"
        "Process/system monitor"
        "Simplified man pages"
        "Modern HTTP client"
        "Network diagnostic tool"
        "Network usage monitor"
        "Direnv clean shell envs"
    )

    # Verify that tools and descriptions have the same number of elements
    if [ ${#tools[@]} -ne ${#descriptions[@]} ]; then
        error "The number of tools and descriptions do not match."
        return
    fi

    # Install JetBrains Mono Nerd Font for terminal icons and special characters
    if ! brew list --cask font-jetbrains-mono-nerd-font > /dev/null 2>&1; then
        log "Installing JetBrains Mono Nerd Font..."
        brew install --cask font-jetbrains-mono-nerd-font || error "Failed to install JetBrains Mono Nerd Font"
    else
        log "JetBrains Mono Nerd Font is already installed, skipping..."
    fi

    failed_installs=()

    for ((i=1; i<=${#tools}; i++)); do
        tool=${tools[i]}
        description=${descriptions[i]}
        
        if ! brew list "$tool" > /dev/null 2>&1; then
            log "Installing ${tool} (${description})..."
            if ! brew install "$tool"; then
                log "WARNING: Failed to install ${tool}"
                failed_installs+=("$tool")
            fi
        else
            log "${tool} is already installed, skipping..."
        fi
    done

    # Remove hub if installed (replacing with gh)
    if brew list hub > /dev/null 2>&1; then
        log "Removing hub in favor of gh..."
        if ! brew uninstall hub 2>/dev/null; then
            log "WARNING: Failed to uninstall hub"
            failed_steps+=("Failed to uninstall hub")
        fi
    fi

    # Report any failures at the end
    if (( ${#failed_installs[@]} > 0 )); then
        log "WARNING: The following tools failed to install:"
        for tool in "${failed_installs[@]}"; do
            # Find the description for the failed tool
            for ((i=1; i<=${#tools}; i++)); do
                if [ "$tool" = "${tools[i]}" ]; then
                    log "  - $tool (${descriptions[i]})"
                    break
                fi
            done
        done
    fi
}

# Install and configure Oh My Zsh
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

# Set up Neovim
setup_neovim() {
    log "Setting up Neovim..."

    # Create Python virtual environment for neovim
    local venv_path="$HOME/.config/nvim/venv/neovim"
    if [ ! -d "$venv_path" ]; then
        log "Creating Python virtual environment for neovim..."
        if ! python3 -m venv "$venv_path"; then
            error "Failed to create Python virtual environment for neovim"
            return
        fi
    fi

    # Install pynvim in the virtual environment
    log "Installing pynvim in virtual environment..."
    if ! "$venv_path/bin/pip" install --upgrade pip pynvim; then
        error "Failed to install pynvim in virtual environment"
        return
    fi

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

# macOS specific configurations
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
    fi
}

# Set up iTerm2
setup_iterm2() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log "Starting iTerm2 configuration..."
        
        # Create iTerm2 dynamic profiles directory if it doesn't exist
        local profiles_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
        log "Creating profiles directory: $profiles_dir"
        if ! mkdir -p "$profiles_dir"; then
            log "WARNING: Failed to create iTerm2 profiles directory"
            failed_steps+=("Failed to create iTerm2 profiles directory")
            return
        fi
        
        # Generate a valid UUID for the GUID
        local guid
        if command -v uuidgen >/dev/null 2>&1; then
            guid=$(uuidgen)
        else
            # Fallback if uuidgen is not available
            guid=$(LC_ALL=C tr -dc 'a-f0-9' < /dev/urandom | head -c 32)
            guid="${guid:0:8}-${guid:8:4}-${guid:12:4}-${guid:16:4}-${guid:20:12}"
        fi
        
        # Create a dynamic profile with our preferred settings
        local profile_file="$profiles_dir/dotfiles_profile.json"
        log "Creating profile file: $profile_file"
        cat > "$profile_file" << EOL
{
    "Profiles": [
        {
            "Name": "Dotfiles Profile",
            "Guid": "$guid",
            "Normal Font": "JetBrainsMonoNFM-Regular 14",
            "Use Non-ASCII Font": false,
            "ASCII Anti Aliased": true,
            "Use Bold Font": true,
            "Use Bright Bold": true,
            "Use Italic Font": true,
            "Horizontal Spacing": 1,
            "Vertical Spacing": 1,
            "Use Custom Window Title": false,
            "Window Type": 0,
            "Background Color": {
                "Red Component": 0.0,
                "Green Component": 0.0,
                "Blue Component": 0.0
            },
            "Foreground Color": {
                "Red Component": 1.0,
                "Green Component": 1.0,
                "Blue Component": 1.0
            }
        }
    ]
}
EOL
        if [ $? -ne 0 ]; then
            log "WARNING: Failed to create iTerm2 profile"
            failed_steps+=("Failed to create iTerm2 profile")
            return
        fi
        
        log "Created iTerm2 profile successfully"
        log "Attempting to set default profile..."
        
        if defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$guid" > /dev/null 2>&1; then
            log "Successfully set default iTerm2 profile"
        else
            log "WARNING: Failed to set default iTerm2 profile"
            failed_steps+=("Failed to set default iTerm2 profile")
        fi
        
        log "iTerm2 configuration completed"
        log "Note: Please restart iTerm2 and select 'Dotfiles Profile' from the profiles menu if it's not set automatically."
    fi
}

# Create symlinks
setup_symlinks() {
    log "Setting up symlinks..."
    
    # Array of files to symlink (source:destination)
    local links=(
        "init.vim:.config/nvim/init.vim"
        "zshrc:.zshrc"
        "aliases:.aliases"
        "gitconfig:.gitconfig"
        "gitignore_global:.gitignore_global"
        "tmux.conf:.tmux.conf"
        "ssh_config:.ssh/config"
    )
    
    local failed_links=()
    
    for link in "${links[@]}"; do
        local src="${link%%:*}"
        local dst="${link#*:}"
        local target="$HOME/$dst"
        local source_file="$SCRIPT_DIR/$src"
        
        # Skip if symlink already exists
        if [ -L "$target" ]; then
            log "Symlink for $dst already exists, skipping..."
            continue
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
    
    # Report any failures
    if [ ${#failed_links[@]} -gt 0 ]; then
        log "WARNING: Failed to create the following symlinks:"
        for dst in "${failed_links[@]}"; do
            log "  - $dst"
        done
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
    setup_iterm2
    setup_symlinks
    
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

