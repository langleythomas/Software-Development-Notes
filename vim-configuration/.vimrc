" ---------------------------------------------------------------------------------------------------------------------

" Text Rendering

" Enable syntax processing
syntax enable

" Avoid wrapping a line in the middle of a word
set linebreak

" Enable line wrapping
set wrap

" The amount of tenths of a second to blink when matching brackets
set mat=2

" ---------------------------------------------------------------------------------------------------------------------

" Text Navigation

" Allow backspace over indentation, line breaks, and insertion start
set backspace=indent,eol,start

" Enable wrapping to new/previous lines with arrow keys
set whichwrap+=<,>,[,]

" ---------------------------------------------------------------------------------------------------------------------

" Spell Checking

" Enable spellcheck
set spell

" Set dictionary
set spelllang=en_gb

" Disable block colour highlighting for both (1) words not recognised, and (2) the wrong spelling for a selected region
hi clear SpellBad
hi clear SpellLocal

" Change highlighting of text error (word not recognised) from a red block to red and underlined text
hi SpellBad cterm=underline ctermfg=red

" Change highlighting of text error (wrong spelling for selected region) from a blue block to blue and underlined text
hi SpellLocal cterm=underline ctermfg=blue

" ---------------------------------------------------------------------------------------------------------------------

" Spaces & Tabs

" Number of visual spaces per TAB
set tabstop=2

" Number of spaces in TAB when editing
set softtabstop=2

" Tabs are spaces
set expandtab

" Indentations are 2 spaces
set shiftwidth=2

" New lines inherit the indentation of previous lines
set autoindent

" Round the indentation to the nearest multiple of shiftwidth
set shiftround

" Insert 'tabstop' number of spaces when the '<TAB>' key is pressed
set smarttab

" ---------------------------------------------------------------------------------------------------------------------

" UI Configuration

" Show line numbers
set number

" Set the window's title to match the current file being edited
set title

" Redraw only when necessary
" set lazyredraw

" Highlight matching curly braces, parentheses and square brackets
set showmatch

" Show (partial) command in the last line of the screen
set showcmd

" Set column colour at the designated column width
set colorcolumn=120

" ---------------------------------------------------------------------------------------------------------------------

" Searching

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

" Ensure that Vim uses the system clipboard when copying and pasting test
set clipboard=unnamedplus

" ---------------------------------------------------------------------------------------------------------------------

" File Type

" Set file format
set fileformat=unix


" Set file encoding type
set encoding=UTF-8

" ---------------------------------------------------------------------------------------------------------------------

" Vim Exit

" Display confirmation dialogue when closing an unsaved dialogue
set confirm

" Enable Vim to resume editing a file from the previous location
autocmd BufWinLeave * mkview
autocmd BufWinEnter * silent loadview

" ---------------------------------------------------------------------------------------------------------------------
