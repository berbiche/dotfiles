let mapleader=","
set termguicolors
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
      \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
      \,sm:block-blinkwait175-blinkoff150-blinkon175

au ColorScheme * hi Normal  ctermbg=none guibg=none
au ColorScheme * hi NonText ctermbg=none guibg=none


" Basics
  syntax on
  colorscheme monokai
  set termguicolors

  set nocompatible
  set nohlsearch
  filetype plugin on
  set listchars=tab:>-,trail:*
  set tabstop=2 softtabstop=2 shiftwidth=2
  set expandtab
  set number
  set splitbelow splitright

" Enable autocompletion
  set wildmode=longest,list,full

" Disables automatic commenting on newline
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

  nnoremap <leader>s :set spell!<CR>
  nnoremap <leader>l :set list!<CR>
  nnoremap S :%s//g<Left><Left>
  nnoremap <leader>m :set number!<CR>
  nnoremap <leader>n :set relativenumber!<CR>

" Changes for specific file types

call plug#begin()
Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}
call plug#end()

" source $XDG_CONFIG_HOME/nvim/config/coc.vim
