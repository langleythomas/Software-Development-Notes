" Instructing Neovim to use Vim's directory
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" Configuring Neovim to use Vim’s configuration file
source ~/.vimrc
