" View colorschemes at http://code.google.com/p/vimcolorschemetest/
set t_Co=256
if &t_Co >= 256 || has("gui_running")
    colorscheme desert
    if exists("##mustang")
        colorscheme mustang
    endif
endif
if &t_Co > 2 || has("gui_running")
    " switch syntax highlighting on, when the terminal has colors
    syntax on
endif

" If you end your settings with double trailing // then vim will automatically
" use the full path to the file so editing /etc/X11/x.org and ~/x.org won't
" clobber each other in your swap directory.
set backupdir=~/.vim/backup//
set directory=~/.vim/swp//
set nocompatible
set hidden
set encoding=utf8
set expandtab
set textwidth=0
set softtabstop=4
set wildmenu
set nobackup
set noswapfile
set commentstring=\ #\ %s
set clipboard+=unnamed
set history=1000
set undolevels=1000
set wildignore=*.swp,*.bak,*.pyc,*.class
set whichwrap=b,s,h,l,<,>,[,]   " move freely between files
set ruler         " show the cursor position all the time
set title         " change terminal's title
set ttyfast       " smoother changes
set modeline      " last lines in document sets vim mode
set modelines=3   " number lines checked for modelines
set shortmess=atI " Abbreviate messages
set nostartofline " don't jump to first character when paging
set visualbell    " don't beep
set noerrorbells  " don't beep
set nowrap        " don't wrap lines
set tabstop=4     " a tab is four spaces
set backspace=indent,eol,start
                  " allow backspacing over everything in insert mode
set autoindent    " always set autoindenting on
set copyindent    " copy the previous indentation on autoindenting
set number        " always show line numbers
set shiftwidth=4  " number of spaces to use for autoindenting
set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch     " set show matching parenthesis
set showcmd       " display incomplete commands
set ignorecase    " ignore case when searching
set smartcase     " ignore case if search pattern is all lowercase,
                  "  case-sensitive otherwise
set smarttab      " insert tabs on the start of a line according to
                  "  shiftwidth, not tabstop
set hlsearch      " highlight search terms
set incsearch     " show search matches as you type
set ls=2          " allways show status line

" Use pathogen to easily modify the runtime path to include all
" plugins under the ~/.vim/bundle directory
call pathogen#helptags()
call pathogen#runtime_append_all_bundles() 
" change the mapleader from \ to ,
let mapleader=","
" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>
" Set file type specific settings
filetype plugin indent on
if has('autocmd')
    autocmd filetype python set expandtab
endif
" whitespace highlighting
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.
autocmd filetype html,xml set listchars-=tab:>.
set pastetoggle=<F2>
" enable the mouse
set mouse=a
" remap shortcuts
nnoremap ; :
" Use Q for formatting current paragaph or selection
vmap Q gq
vmap Q gqap
" Alter line jumping behavior for long lines
nnoremap j gj
nnoremap k gk
" Easier window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
" set ,/ to clear search highlighting
nmap <silent> ,/ :nohlsearch<CR>
" allow sudo to be reactively invoked with w!!
cmap w!! w !sudo tee % >/dev/null

