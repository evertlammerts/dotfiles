# 🏠 Dotfiles

A curated collection of dotfiles and scripts for setting up a productive development environment on macOS. This repository provides an automated setup of development tools, shell configurations, and application preferences to get you up and running quickly with a well-configured system.

<img src="https://github.com/evertlammerts/dotfiles/blob/main/header.jpeg?raw=true" title="" alt="header" />

## ✨ Features & Highlights

- **Automated Setup**: One-command installation of all development tools and configurations
- **ZSH Configuration**: Custom prompt, syntax highlighting, auto-suggestions, and intelligent completions
- **Development Tools**: Neovim, tmux, git, and modern CLI alternatives
- **macOS Optimization**: Sensible macOS defaults for developers
- **Modular Design**: Easy to customize and extend

## 📋 Prerequisites

- macOS (primarily tested on the latest version)
- Command Line Tools for Xcode (`xcode-select --install`)
- Git (for cloning this repository)

## 🚀 Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Run the setup script:
```bash
./setup.sh
```

The setup script will:
- Install Homebrew if not already installed
- Install all required packages and applications
- Create necessary directories
- Set up symlinks for configuration files
- Configure macOS preferences

Alternatively, for manual control:
```bash
make install    # Creates directories and symlinks
make symlinks   # Only creates symlinks
make clean      # Removes all symlinks
```

## 📦 What Gets Installed

### Homebrew Packages
The setup script automatically installs:
- Essential tools: `coreutils`, `moreutils`, `findutils`, `gnu-sed`
- Shell: `zsh`, `zsh-completions`, `starship`
- Development tools: `git`, `neovim`, `tmux`, `fzf`
- Modern CLI tools: `bat`, `exa`, `ripgrep`, `fd`, `jq`, `tree`
- Languages and runtimes: `node`, `python`
- Applications: `iterm2`, `visual-studio-code`

### Configuration Files
The following configs are automatically symlinked:
- `zshrc` → `~/.zshrc`
- `gitconfig` → `~/.gitconfig`
- `gitignore_global` → `~/.gitignore_global`
- `tmux.conf` → `~/.tmux.conf`
- `init.vim` → `~/.config/nvim/init.vim`
- `ssh_config` → `~/.ssh/config`
- `aliases` → `~/.aliases`
- `editconfig` → `~/.editorconfig`
- `gitattributes` → `~/.gitattributes`

### macOS Configurations
Optimizes macOS settings for development:
- Faster key repeat and lower key delay
- Dock and Mission Control improvements
- Finder enhancements
- Security and privacy preferences
- Development-friendly system defaults

## 📁 Repository Structure

```
.
├── aliases              # Shell aliases
├── editcorconfig        # EditorConfig configuration
├── gitattributes        # Git attributes configuration
├── gitconfig           # Git configuration
├── gitignore_global    # Global Git ignore patterns
├── header.jpeg         # Repository header image
├── init.vim            # Neovim configuration
├── make.log            # Setup log file
├── Makefile            # Installation automation
├── README.md           # Repository documentation
├── setup.sh            # Main setup script
├── ssh_config          # SSH configuration
├── tmux.conf           # Tmux configuration
└── zshrc               # ZSH configuration
```

## ⚙️ Customization

### Local Overrides
Create these files for machine-specific settings (they're git-ignored):
- `~/.zshrc.local` - Local shell settings
- `~/.gitconfig.local` - Local git configuration
- `~/.tmux.conf.local` - Local tmux settings

### Adding New Tools
1. Add Homebrew packages to `setup.sh`
2. Create configuration files in the appropriate directory
3. Update the Makefile to include new symlinks

## Tool-Specific Features

### ZSH Setup
- Customized prompt with git status integration
- Syntax highlighting for commands
- Auto-suggestions based on history
- Enhanced tab completion
- Useful aliases and functions

### Neovim Configuration
- Modern IDE-like experience with custom plugins
- Built-in LSP support with Mason for package management
- Fuzzy finding with Telescope
- Git integration via Fugitive and Gitsigns
- Dedicated Python virtual environment for Neovim plugins
- TreeSitter for enhanced syntax highlighting
- WhichKey for keybinding documentation

### Tmux Configuration
- Informative status bar
- Mouse mode enabled
- Enhanced copy mode
- Session management
- Productive key bindings

### Git Configuration
- Productivity-focused aliases
- Enhanced diff output
- Sensible defaults
- Global ignore patterns
- Attribute configurations

## 🔄 Maintenance

### Updates
To update your dotfiles:
```bash
cd ~/.dotfiles
git pull
make install
```

To update installed packages:
```bash
brew update && brew upgrade
```

### Backup
Recommended backup practices:
- Regularly commit and push changes
- Generate a Brewfile: `brew bundle dump`
- Document significant changes

## 📝 License

MIT


