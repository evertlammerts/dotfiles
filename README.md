# 🏠 Dotfiles

Shell, git, editor and terminal configuration for macOS on Apple Silicon, plus
the Homebrew packages that go with it.

<img src="https://github.com/evertlammerts/dotfiles/blob/main/header.jpeg?raw=true" title="" alt="header" />

## Setup

Install the Xcode Command Line Tools (`xcode-select --install`), clone this
repository, then run the setup script with a profile:

```bash
git clone https://github.com/evertlammerts/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./setup.sh work        # shared tools and configuration
./setup.sh personal    # also homelab hosts, huisarchief and personal packages
```

`./setup.sh <profile> links` only links the configuration and sets the iTerm2
profile, without installing anything. Setup logs to
`setup.log` next to the script.

The full run:

- installs Homebrew and everything in `Brewfile` (and `personal/Brewfile`)
- links GNU `timeout` from coreutils into `~/.local/bin`
- installs Python 3.12 and 3.13 with uv, pins 3.13 globally, and installs the
  uv tools pre-commit, git-filter-repo, just and py-spy
- installs Oh My Zsh and the Neovim plugins
- generates `~/.ssh/id_ed25519` if it is missing and writes the allowed signers
  file for SSH commit signing
- sets Finder defaults, disables system sleep on the power adapter, and
  excludes `~/.cache` and `~/.ccache` from Time Machine
- links the iTerm2 profile and makes it the default

## After setup

- Add `~/.ssh/id_ed25519.pub` to GitHub as an authentication key and as a
  signing key. Commits are signed with it, and GitHub shows them as unverified
  until the signing key is registered.
- Add `~/projects` to System Settings, Spotlight, Search Privacy so builds do
  not trigger indexing.
- Put machine-specific settings in `~/.zshrc.local`, `~/.gitconfig.local` or
  `~/.ssh/config.local`. The personal profile links its own files there.

## Layout

| File | Linked to | Notes |
|---|---|---|
| `zshenv` | `~/.zshenv` | PATH and environment for every zsh, including non-interactive shells |
| `zshrc` | `~/.zshrc` | Interactive shell: Oh My Zsh, history, completion, prompt |
| `aliases` | `~/.aliases` | Aliases never shadow a standard command |
| `gitconfig` | `~/.gitconfig` | Includes `~/.gitconfig.local` last |
| `gitignore_global` | `~/.gitignore_global` | |
| `gitattributes` | `~/.gitattributes` | |
| `ssh_config` | `~/.ssh/config` | Includes `~/.ssh/config.local` first |
| `tmux.conf` | `~/.tmux.conf` | |
| `init.vim` | `~/.config/nvim/init.vim` | |
| `iterm2/dotfiles_profile.json` | iTerm2 `DynamicProfiles` | |
| `personal/zshrc` | `~/.zshrc.local` | Personal profile only |
| `personal/ssh_config` | `~/.ssh/config.local` | Personal profile only |

## Maintenance

```bash
brew bundle --file=Brewfile    # install what is missing
# list what is installed but not listed; add personal/Brewfile on a personal machine
cat Brewfile | brew bundle cleanup --file=-
```

## License

MIT
