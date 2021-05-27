{ config, inputs, lib, pkgs, ... }:

let
  toPlugin = n: v: pkgs.vimUtils.buildVimPluginFrom2Nix { name = n; src = v; };

  myPlugins = lib.mapAttrsToList toPlugin {
    anderson = inputs.vim-theme-anderson;
    gruvbox = inputs.vim-theme-gruvbox;
    monokai = inputs.vim-theme-monokai;
    synthwave84 = inputs.vim-theme-synthwave84;
    # https://github.com/neovim/neovim/issues/12587
    "FixCursorHold.nvim" = pkgs.fetchFromGitHub {
      owner = "antoinemadec";
      repo = "FixCursorHold.nvim";
      rev = "d932d56b844f6ea917d3f7c04ff6871158954bc0";
      hash = "sha256-Kqk3ZdWXCR7uqE9GJ+zaDMs0SeP/0/8bTxdoDiRnRTo=";
    };
  };
in
{
  my.home = {
    home.packages = [ pkgs.fzf ];

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;

      # From neovim-nightly input
      package = pkgs.neovim-nightly;

      plugins = myPlugins ++ (with pkgs.vimPlugins; [
        vim-sensible
        vim-commentary
        vim-indent-guides
        ## Language
        vim-nix
        #vim-addon-nix
        vim-polyglot
        ale
        ## LSP
        coc-explorer
        coc-go
        coc-html
        coc-json
        coc-markdownlint
        coc-nvim
        coc-python
        coc-rust-analyzer
        ## coc-sh
        coc-vimlsp
        ## Git
        vim-fugitive
        ## Shows symbol with LSP
        vista-vim
        ## Rainbow paranthesis, brackets
        rainbow
        ## Statusbar
        vim-airline
        vim-airline-themes
        ## File lookup
        fzf-vim
        fzf-lsp-nvim
        ## File tree
        # defx-nvim
        ## Show key completion
        vim-which-key
        ## Buffer
        vim-buffergator
        #
        vim-indent-object
        #
        ## Gutter with  mode
        vim-signify
      ]
      ++ lib.optional config.profiles.dev.wakatime.enable vim-wakatime);

      extraConfig = ''
        " Default settings
        set nocompatible
        set nobackup
        " Yup, I live on the edge
        set noswapfile
        set updatetime=100

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
        colorscheme gruvbox
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
        " set wildmode=longest,list,full
        set wildmode=longest,full

        " Live substitution
        set inccommand=nosplit

        " Disables automatic commenting on newline
        autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

        " Quick exit with `:Q`
        command Q qa

        nnoremap <leader>si :set spell!<CR>
        nnoremap <leader>l :set list!<CR>
        nnoremap <leader>S :%s//g<Left><Left>
        nnoremap <leader>m :set number!<CR>
        nnoremap <leader>n :set relativenumber!<CR>

        nnoremap <silent> <leader> :WhichKey '<Space>'<CR>

        " FZF
        let g:fzf_command_prefix = 'Fzf'
        let g:fzf_buffers_jump = 1
        nnoremap <C-t> :FzfFiles!
        nnoremap <leader><space> :FzfFiles<CR>
        nnoremap <leader>. :FzfFiles %:p:h<CR>


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
        nnoremap <leader>, <C-^>
        nnoremap <leader>b, <C-^>
        nnoremap <leader>bd :bd<CR>
        nnoremap <leader>bn :bnext<CR>
        nnoremap <leader>bN :enew<CR>
        nnoremap <leader>bp :bprevious<CR>
        nnoremap <leader>bi :FzfBuffers<CR>
        " Window management
        nnoremap <leader>w <C-w>

        " Finding things
        nnoremap <leader>ss :FzfBLines<CR>
        nnoremap <leader>sp :FzfRg<CR>

        " Git
        nnoremap <silent> <leader>gg :Git<CR>
        nnoremap <silent> <leader>gd :Gdiff<CR>
        nnoremap <silent> <leader>gc :Gcommit<CR>
        nnoremap <silent> <leader>gb :Gblame<CR>
        nnoremap <silent> <leader>ge :Gedit<CR>

        " Enable rainbow paranthesis globally
        let g:rainbow_active = 1

        " Display all buffers when only one tab is open
        "let g:airline#extensions#tabline#enabled = 1

        " Polyglot
        let g:polyglot_disabled = ['markdown']

        " Vista
        let g:vista_fzf_preview = ['right:30%']
        let g:vista#renderer#enable_icon = 1
        let g:vista#renderer#icons = {
        \   "function": "\uf794",
        \   "variable": "\uf71b",
        \  }

        ${lib.optionalString config.profiles.dev.wakatime.enable ''
          " WakaTime CLI path
          let g:wakatime_OverrideCommandPrefix = '${pkgs.wakatime}/bin/wakatime'
        ''}

        autocmd! FileType which_key
        autocmd  FileType which_key set laststatus=0 noshowmode noruler
          \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

        au FileType gitcommit setlocal tw=68 colorcolumn=69 spell
      '';
    };
  };
}
