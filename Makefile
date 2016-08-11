all:
	[ -f ~/.config/nvim/init.vim ] || ln -s $(PWD)/init.vim ~/.config/nvim/init.vim
	[ -f ~/.bashrc ] || ln -s $(PWD)/bashrc ~/.bashrc
	[ -f ~/.bash_aliases ] || ln -s $(PWD)/bash_aliases ~/.bash_aliases


clean:
	[ -f ~/.config/nvim/init.vim ] && rm ~/.config/nvim/init.vim

.PHONY: all
