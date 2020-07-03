{ config, lib, pkgs, ... }:

let
  inherit (builtins) fetchTarball;
  inherit (lib) attrNames foldl mapAttrs recursiveUpdate;
  themes = {
    monokai = "https://github.com/sickill/vim-monokai/archive/master.tar.gz";
    anderson = "https://github.com/tlhr/anderson.vim/archive/master.tar.gz";
    synthwave84 = "https://github.com/artanikin/vim-synthwave84/archive/master.tar.gz";
    gruvbox = "https://github.com/morhetz/gruvbox/archive/master.tar.gz";
  };
  tarballs = mapAttrs (_: b: fetchTarball b) themes;
  # Maps a vim theme source to an XDG config file
  toXDGConf = set:
    let
      toXDG = name: value:
        { xdg.configFile."nvim/colors/${name}.vim".source = "${value}/colors/${name}.vim"; };
    in
      foldl (acc: name:
        recursiveUpdate acc (toXDG name set.${name})
      ) { } (attrNames set);
  # Construct an attrset like: xdg.configFile."theme".source = drv/colors/"theme".vim
  configFiles = toXDGConf tarballs;
in
# Merge Themes configuration
recursiveUpdate configFiles {
  # Text-editor
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    extraConfig = ''
      " Default settings
      set nocompatible
      set nobackup

      let mapleader=","

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

      " Plugins
      call plug#begin()
      Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}
      Plug 'LnL7/vim-nix'
      call plug#end()
    '';
  };
}
