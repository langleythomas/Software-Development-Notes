" -----------------------------------------------------------------------------
" Plugin Configuration
" -----------------------------------------------------------------------------

" Only calling the Vundle configuration if the Vundle.vim directory exists
if !empty(glob("~/.vim/bundle/Vundle.vim"))
    " ---------------------------------------------------------------------------
    " Vundle Configuration, as documented in
    " https://github.com/vundlevim/vundle.vim?tab=readme-ov-file#quick-start
    " ---------------------------------------------------------------------------

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

    " -----------------------------------------------------------------------------
    " MarkdownPreview Configuration
    " -----------------------------------------------------------------------------

    " Enabling an automatic Markdown Preview window to be opened after entering the
    " Markdown buffer, as documented in:
    " https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#markdownpreview-config
    "let g:mkdp_auto_start = 1

    " Enabling the Markdown Preview window to only be updated after saving the
    " buffer or when leaving insert mode, as documented in:
    " https://github.com/iamcco/markdown-preview.nvim?tab=readme-ov-file#markdownpreview-config
    let g:mkdp_refresh_slow = 1 
endif



" -----------------------------------------------------------------------------
" Text Rendering
" -----------------------------------------------------------------------------

" Enable syntax highlighting
filetype plugin on



" -----------------------------------------------------------------------------
" Text Navigation
" -----------------------------------------------------------------------------

" Allow backspace over indentation, line breaks, and insertion start
set backspace=indent,eol,start

" Enable wrapping to new/previous lines with arrow keys
set whichwrap+=<,>,[,]



" -----------------------------------------------------------------------------
" Spell Checking
" -----------------------------------------------------------------------------

" Enable spellcheck
set spell

" Set dictionary
set spelllang=en_gb



" -----------------------------------------------------------------------------
" Spaces & Tabs
" -----------------------------------------------------------------------------

" Tabs are spaces
set expandtab

" Insert 'tabstop' number of spaces when the '<TAB>' key is pressed
set smarttab

" Set indentation by file type
" Markdown indentation configuration
autocmd FileType markdown set tabstop=8|set shiftwidth=2|set expandtab



" -----------------------------------------------------------------------------
" UI Configuration
" -----------------------------------------------------------------------------

" Show line numbers
set number

" Set the window's title to match the current file being edited
set title

" Highlight matching curly braces, parentheses and square brackets
set showmatch

" Show (partial) command in the last line of the screen
set showcmd

" Add a column ruler to help identify any lines longer than desired
set colorcolumn=120

"Setting the colour scheme
try
    colorscheme dracula
catch /^Vim\%((\a\+)\)\=:E185/
    try
        colorscheme slate
    catch /^Vim\%((\a\+)\)\=:E185/
        colorscheme default
    endtry
endtry

" -----------------------------------------------------------------------------
" Searching
" -----------------------------------------------------------------------------

"Search as characters are entered
set incsearch

" Ignore case when searching
set ignorecase

" Highlight matches
set hlsearch

" Automatically switch search to case-sensitive when search query contains an
" uppercase letter
set smartcase



" -----------------------------------------------------------------------------
" Clipboard
" -----------------------------------------------------------------------------

" Ensure that Vim uses the system clipboard when copying and pasting. Comment
" out one of the following options depending on your operating system of
" choice.
" Option 1: Linux
" set clipboard+=unnamedplus
" Option 2: Windows/MacOS
" set clipboard+=unnamed



" -----------------------------------------------------------------------------
" File Type
" -----------------------------------------------------------------------------

" Set file format
set fileformat=unix

" Set file encoding type
set encoding=UTF-8



" -----------------------------------------------------------------------------
" Vim Exit
" -----------------------------------------------------------------------------

" Display confirmation dialogue when closing an unsaved dialogue
set confirm

" Enable Vim to resume editing a file from the previous location
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif



" -----------------------------------------------------------------------------
" Mouse Control
" -----------------------------------------------------------------------------

" Disable mouse control and navigation in the buffer.
set mouse=



" -----------------------------------------------------------------------------
" Memory Configuration
" -----------------------------------------------------------------------------
set maxmempattern=2000000
