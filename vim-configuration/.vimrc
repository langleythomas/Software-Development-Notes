" ---------------------------------------------------------------------------------------------------------------------
" Vundle Configuration, as documented in https://github.com/vundlevim/vundle.vim?tab=readme-ov-file#quick-start
" ---------------------------------------------------------------------------------------------------------------------

set nocompatible
filetype off

" Set the runtime path to include Vundle and initialise
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle
Plugin 'VundleVim/Vundle.vim'

" Let Vundle manage Markdown Preview, as documented in:
" https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#installation--usage
Plugin 'iamcco/markdown-preview.nvim'

" Let Vundle manage the Dracula theme, as documented in:
" https://draculatheme.com/vim
Plugin 'dracula/vim', { 'name': 'dracula' }

" All of your Plugins must be added before the following line.
call vundle#end()

" ---------------------------------------------------------------------------------------------------------------------
" MarkdownPreview Configuration
" ---------------------------------------------------------------------------------------------------------------------

" Enabling an automatic Markdown Preview window to be opened after entering the Markdown buffer, as documented in
" https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#markdownpreview-config
let g:mkdp_auto_start = 1

" Enabling the Markdown Preview window to only be updated after saving the buffer or when leaving insert mode, as
" documented in https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#markdownpreview-config
let g:mkdp_refresh_slow = 1 

" ---------------------------------------------------------------------------------------------------------------------
" Text Rendering
" ---------------------------------------------------------------------------------------------------------------------

" Enable syntax highlighting
filetype plugin indent on

" ---------------------------------------------------------------------------------------------------------------------
" Spell Checking
" ---------------------------------------------------------------------------------------------------------------------

" Enable spellcheck
set spell

" Set dictionary
set spelllang=en_gb

" ---------------------------------------------------------------------------------------------------------------------
" Spaces & Tabs
" ---------------------------------------------------------------------------------------------------------------------

" Number of visual spaces per TAB
set tabstop=2

" Number of spaces in TAB when editing
set softtabstop=2

" Tabs are spaces
set expandtab

" Indentations are 2 spaces
set shiftwidth=2

" New lines inherit the indentation of previous lines
" set autoindent

" Round the indentation to the nearest multiple of shiftwidth
set shiftround

" Insert 'tabstop' number of spaces when the '<TAB>' key is pressed
set smarttab

" ---------------------------------------------------------------------------------------------------------------------
" UI Configuration
" ---------------------------------------------------------------------------------------------------------------------

" Show line numbers
set number

" Set the window's title to match the current file being edited
set title

" Highlight matching curly braces, parentheses and square brackets
set showmatch

" Show (partial) command in the last line of the screen
set showcmd

"Setting the colour scheme
colorscheme dracula

" ---------------------------------------------------------------------------------------------------------------------
" Searching
" ---------------------------------------------------------------------------------------------------------------------

"Search as characters are entered
set incsearch

" Ignore case when searching
set ignorecase

" Highlight matches
set hlsearch

" Automatically switch search to case-sensitive when search query contains an uppercase letter
set smartcase

" ---------------------------------------------------------------------------------------------------------------------
" Clipboard
" ---------------------------------------------------------------------------------------------------------------------

" Ensure that Vim uses the system clipboard when copying and pasting test
" Linux
" set clipboard+=unnamedplus
" Windows/MacOS
" set clipboard+=unnamed

" ---------------------------------------------------------------------------------------------------------------------
" File Type
" ---------------------------------------------------------------------------------------------------------------------

" Set file format
set fileformat=unix

" Set file encoding type
set encoding=UTF-8

" ---------------------------------------------------------------------------------------------------------------------
" Vim Exit
" ---------------------------------------------------------------------------------------------------------------------

" Display confirmation dialogue when closing an unsaved dialogue
set confirm

" Enable Vim to resume editing a file from the previous location
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
