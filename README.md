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

`./setup.sh <profile> links` only links the configuration, sets the iTerm2
profile and sets up commit signing, without installing anything. Setup logs to
`setup.log` next to the script.

The full run:

- installs Homebrew and everything in `Brewfile` (and `personal/Brewfile`)
- links GNU `timeout` from coreutils into `~/.local/bin`
- installs Python 3.12 and 3.13 with uv, pins 3.13 globally, and installs the
  uv tools pre-commit, git-filter-repo, just and py-spy
- installs Oh My Zsh and the Neovim plugins
- generates `~/.ssh/id_ed25519` on the personal profile if it is missing, and
  writes the allowed signers file for SSH commit signing
- sets Finder defaults, disables system sleep on the power adapter, and
  excludes `~/.cache` and `~/.ccache` from Time Machine
- links the iTerm2 profile and makes it the default

## Work machines: approval for every commit and push

On the work profile the GitHub key lives only in Bitwarden's SSH agent, which
asks before every signature and every SSH authentication. A coding agent can
then not sign a commit or push without a click. Before running
`./setup.sh work`:

1. Install the Xcode Command Line Tools: `xcode-select --install`.
2. In Bitwarden desktop, enable the SSH agent and set "Ask for authorization"
   to Always. "Remember until locked" lets any process sign until the vault
   locks.
3. Create an SSH key item in Bitwarden, save its public half as
   `~/.ssh/id_ed25519.pub`, and add it to GitHub twice: as an authentication
   key and as a signing key. Keep no private key in `~/.ssh/id_ed25519`;
   setup reports an error with one there.
4. Run setup from Terminal.app, then `gh auth login` with HTTPS.

The work overlay points `SSH_AUTH_SOCK` at Bitwarden, fetches from GitHub over
HTTPS with gh's login, and pushes over SSH. The shared `ssh_config` turns off
connection sharing for github.com, so every push asks.

It stops the default paths, not a determined agent: committing with signing
disabled, pushing to a URL with a token in it, and writes through `gh` all
bypass it.

## After setup

- Add `~/.ssh/id_ed25519.pub` to GitHub as an authentication key and as a
  signing key. Commits are signed with it, and GitHub shows them as unverified
  until the signing key is registered.
- Add `~/projects` to System Settings, Spotlight, Search Privacy so builds do
  not trigger indexing.
- Put machine-specific settings in `~/.zshrc.local`, `~/.gitconfig.local` or
  `~/.ssh/config.local`, which stay untracked. The personal profile links its
  files to `~/.zshrc.personal` and `~/.ssh/config.personal` instead.

## Layout

| File | Linked to | Notes |
|---|---|---|
| `zshenv` | `~/.zshenv` | PATH and environment for every zsh, including non-interactive shells |
| `zprofile` | `~/.zprofile` | Restores the PATH order after macOS path_helper in login shells |
| `zshrc` | `~/.zshrc` | Interactive shell: Oh My Zsh, history, completion, prompt |
| `aliases` | `~/.aliases` | Aliases never shadow a standard command |
| `gitconfig` | `~/.gitconfig` | Includes `~/.gitconfig.work`, then `~/.gitconfig.local`, last |
| `gitignore_global` | `~/.gitignore_global` | |
| `gitattributes` | `~/.gitattributes` | |
| `ssh_config` | `~/.ssh/config` | Includes `~/.ssh/config.local` and `~/.ssh/config.personal` first |
| `tmux.conf` | `~/.tmux.conf` | |
| `init.vim` | `~/.config/nvim/init.vim` | |
| `iterm2/dotfiles_profile.json` | iTerm2 `DynamicProfiles` | |
| `personal/zshrc` | `~/.zshrc.personal` | Personal profile only |
| `personal/ssh_config` | `~/.ssh/config.personal` | Personal profile only |
| `work/zshenv` | `~/.zshenv.work` | Work profile only: Bitwarden SSH agent |
| `work/gitconfig` | `~/.gitconfig.work` | Work profile only: HTTPS fetch, SSH push |

## Maintenance

```bash
brew bundle --file=Brewfile    # install what is missing
# list what is installed but not listed (work, then personal)
cat Brewfile | brew bundle cleanup --file=-
cat Brewfile personal/Brewfile | brew bundle cleanup --file=-
```

## License

MIT
