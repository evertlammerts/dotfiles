call plug#begin()

" Golang
Plug 'fatih/vim-go'
Plug 'Shougo/deoplete.nvim'
Plug 'zchee/deoplete-go', { 'do': 'make'}
Plug 'majutsushi/tagbar'
Plug 'SirVer/ultisnips'
Plug 'fatih/molokai'
Plug 'tpope/vim-dispatch'
Plug 'elzr/vim-json', {'for' : 'json'}
Plug 'ctrlpvim/ctrlp.vim'

" Rust
Plug 'rust-lang/rust.vim'

" Fuzzy Finder (fzf)
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

call plug#end()

set noerrorbells             " No beeps
set number                   " Show line numbers
set showcmd                  " Show me what I'm typing
set noswapfile               " Don't use swapfile
set nobackup                 " Don't create annoying backup files
set splitright               " Split vertical windows right to the current windows
set splitbelow               " Split horizontal windows below to the current windows
set autowrite                " Automatically save before :next, :make etc.
set hidden
set fileformats=unix,dos,mac " Prefer Unix over Windows over OS 9 formats
set noshowmatch              " Do not show matching brackets by flickering
set noshowmode               " We show the mode with airline or lightline
set ignorecase               " Search case insensitive...
set smartcase                " ... but not it begins with upper case 
set completeopt=menu,menuone
set nocursorcolumn           " speed up syntax highlighting
set nocursorline

set pumheight=10             " Completion window max size
set lazyredraw               " Wait to redraw

set background=dark

colorscheme molokai

autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 
autocmd FileType json setlocal expandtab shiftwidth=2 tabstop=2

" Better split switching
" NOTE: to get <C-h> to work, fix the terminfo file:
" https://github.com/neovim/neovim/issues/2048#issuecomment-78045837
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <F8> :TagbarToggle<CR>
inoremap <C-Space> <C-x><C-o>
inoremap <C-@> <C-Space>

" shortcuts for :GoRun :GoTest :GoCoverageToggle
autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>t  <Plug>(go-test)
autocmd FileType go nmap <leader>c  <Plug>(go-coverage-toggle)
" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#cmd#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction
autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>

" Tabs!
set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab

" gofmt to goimports
let g:go_fmt_command = "goimports"

" Python3 !
let g:python3_host_prog = '/usr/local/bin/python3.6'

" deoplete
let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
