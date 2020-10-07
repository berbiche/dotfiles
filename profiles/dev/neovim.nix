{ config, inputs, lib, pkgs, ... }:

let
  # Infinite recursion :(
  # themes = lib.filterAttrs (n: v: lib.hasPrefix "vim-theme" n) inputs;
  themes = {
    anderson = inputs.vim-theme-anderson;
    gruvbox = inputs.vim-theme-gruvbox;
    monokai = inputs.vim-theme-monokai;
    synthwave84 = inputs.vim-theme-synthwave84;
  };

  toXDG = name: value:
    { xdg.configFile."nvim/colors/${name}.vim".source = "${value}/colors/${name}.vim"; };
  themeFiles = lib.mapAttrsToList toXDG themes;
in
{
  home-manager.users.${config.my.username} = { ... }: lib.mkMerge (themeFiles ++ [{
    home.packages = [ pkgs.fzf ];

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;

      plugins = with pkgs.vimPlugins; [
        sensible
        commentary
        vim-indent-guides
        # Language
        vim-nix
        polyglot
        # LSP
        coc-nvim
        coc-json
        coc-markdownlint
        coc-python
        coc-html
        coc-go
        coc-explorer
        coc-rust-analyzer
        # Git
        fugitive
        # Shows symbol with LSP
        vista-vim
        # Rainbow paranthesis, brackets
        rainbow
        # Statusbar
        vim-airline
        vim-airline-themes
        # File lookup
        fzf-vim
        # File tree
        defx-nvim
        # Show key completion
        vim-which-key
        # Buffer
        vim-buffergator
        #
        # vim-indent-object
      ];

      extraConfig = ''
        " Default settings
        set nocompatible
        set nobackup

        let g:mapleader = "\<Space>"
        let g:maplocalleader = ','

        " Colors/Theme
        set termguicolors
        set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
              \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
              \,sm:block-blinkwait175-blinkoff150-blinkon175
        au ColorScheme * hi Normal  ctermbg=none guibg=none
        au ColorScheme * hi NonText ctermbg=none guibg=none

        " Basics
        syntax on
        colorscheme monokai
        let g:airline_theme = 'bubblegum'

        set hidden      " Allows hidden buffer
        set hlsearch
        set smartcase
        filetype plugin on
        set listchars=tab:>-,trail:*
        set tabstop=2 softtabstop=2 shiftwidth=2
        set expandtab
        set number
        set relativenumber
        set scrolloff=5             " keep 5 lines of context when scrolling
        set lazyredraw              " do not redraw screen while executing a macro
        set splitbelow splitright
        set mouse=nv                " Enable mouse usage except in insert mode

        set formatoptions+=j   " remove a comment leader when joining lines. 
        set formatoptions+=o   " insert the comment leader after hitting 'o'

        " Enable autocompletion
        set wildmode=longest,list,full

        " Live substitution
        set inccommand=nosplit

        " Disables automatic commenting on newline
        autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

        nnoremap <leader>s :set spell!<CR>
        nnoremap <leader>l :set list!<CR>
        nnoremap S :%s//g<Left><Left>
        nnoremap <leader>S :%s//g<Left><Left>
        nnoremap <leader>m :set number!<CR>
        nnoremap <leader>n :set relativenumber!<CR>

        nnoremap <silent> <leader> :WhichKey '<Space>'<CR>

        " FZF
        let g:fzf_command_prefix = 'Fzf'
        let g:fzf_buffers_jump = 1
        nnoremap <C-t> :FzfFiles!
        nnoremap <leader><space> :FzfFiles!<CR>


        " Insert line above
        nnoremap [o O<Esc>j
        " Insert line below
        nnoremap ]o o<Esc>k
        " Copy till eol
        nnoremap Y y$
        " Comment lines with commentary.vim
        inoremap <silent> <M-;> <C-o>:Commentary<CR>
        nmap <silent> <M-;> gcc
        vmap <silent> <M-;> gc
        nmap <silent> <leader>; gcc
        vmap <silent> <leader>; gc
        " Buffer management
        autocmd VimEnter * silent! nunmap <leader>b
        nnoremap <leader>bi :BuffergatorOpen<CR>
        nnoremap <leader>bc :BuffergatorClose<CR>
        nnoremap <leader>bd :bd<CR>
        nnoremap <leader>bn :bnext<CR>
        nnoremap <leader>bN :enew<CR>
        nnoremap <leader>bp :bprevious<CR>
        nnoremap <leader>bs :FzfBuffers<CR>
        " Window management
        nnoremap <leader>w <C-w>
        " Other
        nnoremap <leader>ss :FzfLines<CR>

        " Git
        nnoremap <silent> <leader>gg :Gstatus<CR>
        nnoremap <silent> <leader>gd :Gdiff<CR>
        nnoremap <silent> <leader>gc :Gcommit<CR>
        nnoremap <silent> <leader>gb :Gblame<CR>
        nnoremap <silent> <leader>ge :Gedit<CR>

        " Enable rainbow paranthesis globally
        let g:rainbow_active = 1

        " Display all buffers when only one tab is open
        let g:airline#extensions#tabline#enabled = 1

        " Polyglot
        let g:polyglot_disabled = ['markdown']

        " Vista
        let g:vista_fzf_preview = ['right:30%']
        let g:vista#renderer#enable_icon = 1
        let g:vista#renderer#icons = {
        \   "function": "\uf794",
        \   "variable": "\uf71b",
        \  }


        autocmd! FileType which_key
        autocmd  FileType which_key set laststatus=0 noshowmode noruler
          \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

        au FileType gitcommit setlocal tw=68 colorcolumn=69 spell
      '';
    };
  }]);
}
