# macOS path_helper in /etc/zprofile moves the system directories to the front
# of PATH in login shells, after ~/.zshenv ran.
path=($dotfiles_path $path)
