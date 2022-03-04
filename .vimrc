call plug#begin('~/.confs/vim/bundle/plugged')

Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'vim-airline/vim-airline'
Plug 'pineapplegiant/spaceduck', { 'branch': 'main' }
Plug 'scrooloose/syntastic'
Plug 'frazrepo/vim-rainbow'
"Plug 'Valloric/YouCompleteMe'

call plug#end()

if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" Syntastic recommended settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_check_on_w = 1

"vim-rainbow settings
let g:rainbow_active = 1


" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","

" Fast saving
nmap <leader>w :w!<cr>

" remove annoying beep
set belloff=all

set background=dark
if exists('+termguicolors')
      let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
      let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
      set termguicolors
    endif

   colorscheme spaceduck
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on


set encoding=utf-8 fileencodings=
syntax on
set showmatch " Shows matching brackets

set mouse=a

set number
" set relativenumber
set cc=80
" set colorcolumn

set autoindent
set smartindent
"set wrap
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4
set wildmenu
set wildmode=list:longest,full

set autowriteall " write the contents of the file if it has been modified
"if you go from one file to another i.e. :edit or :quit
"
set autoread
" set to auto read when a file is changed from the outside
"
set so=1
"scroll offset, pads files with virtual lines on top and on the bottom
set sidescrolloff=5
set ruler
set history=500
"set spell
set hlsearch
"highlight search
set incsearch
"incremental search, basically searches after every new char
set foldcolumn=0
" add a bit extra margin to the left
"
" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
map <space> /
map <C-space> ?

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>t :tabnext<cr>

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=expand("%:p:h")<cr>/

" Move a line of text using ALT+[jk] or Command+[jk] on mac
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

" Delete trailing white space on save, useful for some filetypes ;)
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

if has("autocmd")
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee,*.c,*.cc :call CleanExtraSpaces()
endif

" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

autocmd Filetype make setlocal noexpandtab

set list listchars=tab:»\ ,trail:·

set nofoldenable
setlocal foldmethod=syntax
set noswapfile
let &t_SI = "\<esc>[6 q"  " solid I-beam in insert mode
let &t_SR = "\<esc>[4 q"  " solid underline in replace mode
let &t_EI = "\<esc>[2 q"  " default cursor solid block otherwise

" reduce latency when escaping
set ttimeoutlen=10

" Auto generate tags file on file write of *.c and *.h files
" autocmd BufWritePost *.c,*.h silent! !ctags . &

" per .git vim configs
" just `git config vim.settings "expandtab sw=4 sts=4"` in a git repository
" change syntax settings for this repository
let git_settings = system("git config --get vim.settings")
if strlen(git_settings)
    exe "set" git_settings
endif
