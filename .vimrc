set termguicolors
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'git://git.wincent.com/command-t.git'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}

Plugin 'Valloric/YouCompleteMe'
Plugin 'scrooloose/nerdtree'
Plugin 'sheerun/vim-polyglot'
Plugin 'jiangmiao/auto-pairs'

Plugin 'dracula/vim'
Plugin 'joshdick/onedark.vim'
Plugin 'gruvbox-community/gruvbox'
Plugin 'chriskempson/base16-vim'
Plugin 'drewtempelmeyer/palenight.vim'
Plugin 'sindresorhus/pure'
Plugin 'KeitaNakamura/neodark.vim'
Plugin 'lifepillar/vim-solarized8'
Plugin 'romainl/apprentice'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Python
let python_highlight_all = 1


set noswapfile
syntax on
set number
set showmatch
set cursorline

set autoindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set bg=dark
colorscheme apprentice 
" hi Normal guibg=NONE ctermbg=NONE


