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
        vim-nix
        coc-nvim
        coc-json
        coc-markdownlint
        coc-python
        coc-html
        coc-go
        coc-explorer
        coc-rust-analyzer
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

        set nohlsearch
        filetype plugin on
        set listchars=tab:>-,trail:*
        set tabstop=2 softtabstop=2 shiftwidth=2
        set expandtab
        set number
        set splitbelow splitright

        " Enable autocompletion
        set wildmode=longest,list,full

        " Live substitution
        set inccommand=nosplit

        " Disables automatic commenting on newline
        autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

        nnoremap <leader>s :set spell!<CR>
        nnoremap <leader>l :set list!<CR>
        nnoremap S :%s//g<Left><Left>
        nnoremap <leader>m :set number!<CR>
        nnoremap <leader>n :set relativenumber!<CR>

        nnoremap <silent> <leader> :WhichKey '<Space>'<CR>


        " Enable rainbow paranthesis globally
        let g:rainbow_active = 1

        " Display all buffers when only one tab is open
        let g:airline#extensions#tabline#enabled = 1


        autocmd! FileType which_key
        autocmd  FileType which_key set laststatus=0 noshowmode noruler
          \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
      '';
    };
  }]);
}
