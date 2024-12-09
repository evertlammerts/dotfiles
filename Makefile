all: setup
	[ -f ~/.config/nvim/init.vim ] || ln -s $(PWD)/init.vim ~/.config/nvim/init.vim
	[ -f ~/.zshrc ] || ln -s $(PWD)/zshrc ~/.zshrc
	[ -f ~/.aliases ] || ln -s $(PWD)/aliases ~/.aliases
	[ -f ~/.gitignore_global ] || ln -s $(PWD)/gitignore_global ~/.gitignore_global


clean:
	[ -f ~/.config/nvim/init.vim ] && rm ~/.config/nvim/init.vim

setup:
	/bin/bash $(PWD)/setup.sh

.PHONY: all
