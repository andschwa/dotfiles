" Andrew Schwartzmeyer's vimrc file.

" This must be first, because it changes other options as a side effect.
set nocompatible

" Download vim-plug if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

""" Plugins
call plug#begin('~/.vim/plugged')
Plug 'airblade/vim-gitgutter'                           " Git hunks
Plug 'andschwa/vim-colors-solarized'                    " Best colors ever
Plug 'bling/vim-airline'                                " Status line
Plug 'ctrlpvim/ctrlp.vim'                               " Fuzzy finder
Plug 'easymotion/vim-easymotion'                        " Movements
Plug 'ledger/vim-ledger'                                " Ledger
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }      " Edits graph
Plug 'ntpeters/vim-better-whitespace'                   " Whitespace
Plug 'PProvost/vim-ps1'                                 " PowerShell
Plug 'rking/ag.vim', { 'on': 'Ag' }                     " The Silver Searcher
Plug 'scrooloose/syntastic'                             " Syntax checker
Plug 'tpope/vim-commentary'                             " Comments
Plug 'tpope/vim-eunuch'                                 " UNIX commands
Plug 'tpope/vim-fugitive'                               " Git interface
Plug 'tpope/vim-repeat'                                 " Repeat for plugins
Plug 'tpope/vim-rsi'                                    " Readline bindings
Plug 'tpope/vim-scriptease'                             " VimL REPL
Plug 'tpope/vim-sensible'                               " Sensible defaults
Plug 'tpope/vim-sleuth'                                 " Adaptive indentation
Plug 'tpope/vim-surround'                               " Surrounding
Plug 'tpope/vim-vinegar'                                " File explorer
call plug#end()

""" Plugin configurations
" appearance
silent! colorscheme solarized
set background=dark
let g:gitgutter_override_sign_column_highlight = 0

let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_clear_cache_on_exit = 0

" just use :StripWhitespace
let g:better_whitespace_enabled = 0

""" Other configurations
set title       " terminal title
set hidden      " multiple buffers
set ignorecase  " ignore case in searches
set smartcase   " match case once specified
set smarttab    " delete tabs
set visualbell  " no sound
set lazyredraw  " better performance

if has("persistent_undo")
  set undodir=~/.vim/undodir/
  silent call system('mkdir -p ' . &undodir)
  set undofile
endif

if has('mouse')
  set mouse=a
endif

""" Bindings
let mapleader = " "

nnoremap <silent> <Leader>ev :split $MYVIMRC<CR>

" Don't use Ex mode, use Q for formatting
map Q gq

""" Auto-commands
" spell check commits
autocmd FileType gitcommit setlocal spell

" recognize all Markdown files
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

" Load local configurations if available
silent! source ~/.vim/local.vim
