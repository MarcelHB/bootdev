set nocp
filetype off
set history=10000
set laststatus=2

set clipboard=unnamed

set directory=~/.config/nvim/swaps
set backupdir=~/.config/nvim/backups

let mapleader=","

set rtp+=~/.config/nvim/bundle/Vundle.vim

call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

Plugin 'airblade/vim-gitgutter'
Plugin 'bling/vim-airline'
Plugin 'chrisbra/csv.vim'
Plugin 'craigemery/vim-autotag'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'ervandew/supertab'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'rking/ag.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'jamessan/vim-gnupg'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'scrooloose/syntastic'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-markdown'
Plugin 'vim-scripts/ZoomWin'
Plugin 'tpope/vim-repeat'
Plugin 'ggandor/leap.nvim'

for f in split(glob('~/.config/nvim/vundle_plugins/*.vim'), '\n')
    exe 'source' f
endfor

call vundle#end()

lua require('leap').add_default_mappings()

set background=light
colorscheme delek

syntax enable
set encoding=utf-8
set showcmd
filetype plugin indent on
set number

hi CursorLine cterm=NONE term=NONE

set mouse=a

set nowrap
set tabstop=2 shiftwidth=2
set expandtab
set backspace=indent,eol,start
set autoindent
set list
set listchars=tab:▸▸,trail:•
hi NonText ctermfg=250 guifg=ivory3

set hlsearch
set incsearch
set ignorecase
set smartcase
nnoremap <cr> :nohlsearch<cr>

set wildignore+=vendor/*,build/*
set wildmode=longest,list
set wildmenu

cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%
map <leader>f :CtrlP<cr>
map <leader>F :CtrlP %%<cr>
map <leader>N :NERDTreeToggle<cr>

let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g "" --ignore-dir=.git --ignore-dir=build'
let g:ctrlp_use_caching=1

let g:syntastic_cpp_compiler_options = ' -std=c++17'

let g:gitgutter_enabled=1
set signcolumn=yes
highlight clear SignColumn

let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction
map <leader>n :call RenameFile()<cr>

fun! StripTrailingWhitespaces()
  let line = line(".")
  let col = col(".")
  let search = @/

  keepjumps %s/\s\+$//e

  let @/=search
  call cursor(line, col)
endfun
nnoremap <Leader>ws :call StripTrailingWhitespaces()<CR>

function s:setupWrapping()
  set wrap
  set wrapmargin=2
  set textwidth=72
endfunction

function! SearchAndReplaceInAllFiles(from, to)
  let last_buffer = expand('%')
  execute 'Ag '.a:from
  execute 'cfdo s/'.a:from.'/'.a:to.'/g | update | close'
  if last_buffer != ''
    execute 'e '.last_buffer
    execute 'cclose'
  endif
endfunction

command! -nargs=+ GSR call SearchAndReplaceInAllFiles(<f-args>)

if has("autocmd")
  "  In Makefiles, use real tabs, not tabs expanded to spaces
  au FileType make set noexpandtab

  " Make sure all markdown files have the correct filetype set and setup wrapping
  au BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn,txt} setf markdown | call s:setupWrapping()

  " cap files are just rake files
  au BufNewFile,BufRead *.cap set ft=ruby

  " Treat JSON files like JavaScript
  au BufNewFile,BufRead *.json set ft=javascript

  " make Python follow PEP8 ( http://www.python.org/dev/peps/pep-0008/ )
  au FileType python set softtabstop=4 tabstop=4 shiftwidth=4 textwidth=79

  " Simplified Help
  au filetype help nnoremap <buffer><cr> <c-]>
  au filetype help nnoremap <buffer><bs> <c-T>
  au filetype help nnoremap <buffer>q :q<CR>
  au filetype help set nonumber

  " Remember last location in file, but not for commit messages.
  au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g`\"" | endif

  " Close NERDTree if it's the last open window
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
endif
