#!/bin/bash

# homebrew
which brew > /dev/null || ( echo "Installing homebrew" && /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" )
# hub
which hub > /dev/null || ( echo "Installing hub" && brew install hub )
# neovim
which nvim > /dev/null || ( echo "Installing NeoVim" && brew install neovim )
# molokai
[ -e ~/.config/nvim/colors/molokai.vim ] || ( echo "Installing molokai color scheme" && curl -fLo ~/.config/nvim/colors/molokai.vim --create-dirs \
  https://github.com/tamelion/neovim-molokai/raw/master/colors/molokai.vim )
# vim-plug
[ -e ~/.local/share/nvim/site/autoload/plug.vim ] || ( echo "Installing vim-plug" && curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && nvim --headless +PlugInstall +q +q )

