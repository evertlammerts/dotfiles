CONFIG_DIRS = ~/.config/nvim/colors ~/.local/share/nvim/site/autoload ~/.ssh ~/.config/git

all: directories setup symlinks

directories:
	mkdir -p $(CONFIG_DIRS)

symlinks:
	[ -f ~/.config/nvim/init.vim ] || ln -s $(PWD)/init.vim ~/.config/nvim/init.vim
	[ -f ~/.zshrc ] || ln -s $(PWD)/zshrc ~/.zshrc
	[ -f ~/.aliases ] || ln -s $(PWD)/aliases ~/.aliases
	[ -f ~/.gitconfig ] || ln -s $(PWD)/gitconfig ~/.gitconfig
	[ -f ~/.gitattributes ] || ln -s $(PWD)/gitattributes ~/.gitattributes
	[ -f ~/.gitignore_global ] || ln -s $(PWD)/gitignore_global ~/.gitignore_global
	[ -f ~/.tmux.conf ] || ln -s $(PWD)/tmux.conf ~/.tmux.conf
	[ -f ~/.ssh/config ] || ln -s $(PWD)/ssh_config ~/.ssh/config
	[ -f ~/.envrc ] || ln -s $(PWD)/envrc ~/.envrc

clean:
	-rm -f ~/.config/nvim/init.vim
	-rm -f ~/.zshrc
	-rm -f ~/.aliases
	-rm -f ~/.gitconfig
	-rm -f ~/.gitattributes
	-rm -f ~/.gitignore_global
	-rm -f ~/.tmux.conf
	-rm -f ~/.ssh/config

setup:
	/bin/zsh $(PWD)/setup.sh

.PHONY: all directories symlinks clean setup
