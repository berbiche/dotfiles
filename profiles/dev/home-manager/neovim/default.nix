moduleArgs@{ config, lib, pkgs, inputs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  osConfig = moduleArgs.osConfig or { };

  shellAliases = rec {
    # The `-s` or `--remote` flag has to be specified last
    # The `mktemp -u` flag will not create the file (otherwise neovim will refuse to replace it)
    nvim = toString (pkgs.writeShellScript "neovim-alias" ''
      # Pick up the nvim command from the current environment
      # This allows updating the neovim configuration without reloading
      # all shells to use the new alias
      nvim=$(command -v nvim)
      if [[ -z "$NVIM_LISTEN_ADDRESS" ]]; then
        if [[ -z "$nvim" ]]; then
          exec -a nvim ${config.programs.neovim.finalPackage}/bin/nvim "$@"
        else
          exec -a nvim "$nvim" "$@"
        fi
      else
        exec -a nvim ${pkgs.neovim-remote}/bin/nvr -s "$@"
      fi
    '');
    n = nvim;
    vim = nvim;
    vi = nvim;
  };
in
{
  imports = [
    ./plugins.nix
    ./tree-sitter.nix
    ./lsp.nix
  ];

  home.packages = [
    pkgs.fzf
    pkgs.neovim-remote
  ]
  # graphical neovim
  ++ lib.optional isLinux pkgs.neovide;

  # programs.neovim.defaultEditor = true;
  home.sessionVariables = {
    EDITOR = shellAliases.nvim;
  };

  home.shellAliases = shellAliases;

  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    withPython3 = true;
    withRuby = false;

    # From neovim-nightly input
    # package = inputs.neovim-nightly.packages.${pkgs.system}.neovim;
    package = pkgs.neovim-unwrapped;

    # Language servers are configured in profies/dev/home-manager/lsp.nix
    extraPackages = with pkgs; [ ];

    # Configuration that is set at the beginning of my configuration!
    plugins = lib.mkBefore [{
      plugin = pkgs.runCommandLocal "dummy" { } "mkdir $out";
      type = "viml";
      config = ''
        " Default settings
        set nocompatible
        set nobackup
        " Yup, I live on the edge
        set noswapfile
        " Update terminal's titlebar
        set title
        " Use utf-8 by default
        set enc=utf-8
        set fenc=utf-8
        set termencoding=utf-8
        set encoding=utf-8

        " For CursorHold autocommand, required by which-key
        set updatetime=100

        let g:mapleader = "\<Space>"
        let g:maplocalleader = ','

        " Use visual bell
        set termguicolors
        set visualbell

        " Basics
        syntax on
      '';
    }];

    extraConfig = ''
      " Color/theme : sonokai
      colorscheme sonokai

      set hidden      " Allows hidden buffer
      set hlsearch    " Highlight search result
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
      set cursorline              " Highlight line with cursor

      " Reuse indentation from previous line
      set autoindent

      set wrap
      set linebreak
      set breakindent
      let &showbreak = '↳ '


      set formatoptions+=j   " remove a comment leader when joining lines.
      set formatoptions-=c
      set formatoptions-=r
      " set formatoptions+=o   " insert the comment leader after hitting 'o'

      " Enable autocompletion
      " set wildmode=longest,list,full
      set wildmode=longest:full,full
      set wildignorecase

      " I already use vim-airline
      set noshowmode

      " Live substitution
      set inccommand=nosplit

      " Don't pass messages to |ins-completion-menu|
      set shortmess+=c


      " Remove Ex mode keybind
      :nnoremap Q <nop>


      " Highlight yanked text
      au TextYankPost * silent! lua vim.highlight.on_yank()


      " Disables automatic commenting on newline if previous line is a comment
      " autocmd FileType * setlocal formatoptions-=c formatoptions-=r

      " Highlight trailing whitespace
      highlight TrailingWhitespace ctermbg=red guibg=red
      match TrailingWhitespace /\s\+$/

      " Fix terminal escape char
      tnoremap <Esc> <C-\><C-n>
      function OpenTerm()
        :bo split
        :res -10
        :terminal
      endfunction
      map <silent> <leader>ot :call OpenTerm()<CR>

      " Removes the trailing space highlighting
      function RemoveTrailingHighlight()
        let l:tr = map(filter(getmatches(), 'get(v:val, "group", 0) == "TrailingWhitespace"'), 'get(v:val, "id")')
        if get(l:tr, 0, 'false') != 'false'
          matchdelete(l:tr[0], win_getid())
        endif
      endfunction

      if !exists('g:vscode')
        " autocmd TermOpen * silent call RemoveTrailingHighlight()
        ${lib.optionalString (osConfig.profiles.dev.wakatime.enable or false) ''
            packadd vim-wakatime
          ''}
      endif

      " Insert line above
      nnoremap [o O<Esc>j
      " Insert line below
      nnoremap ]o o<Esc>k
      " Copy till eol
      nnoremap Y y$
      " Select pasted text
      nnoremap <expr> gp '`['.strpart(getregtype(), 0, 1).'`]'
      " Buffer management
      autocmd VimEnter * silent! nunmap <leader>b
      nnoremap <silent> <leader>bd :BufferClose<CR>
      nnoremap <leader>bn :bnext<CR>
      nnoremap <leader>bN :enew<CR>
      nnoremap <leader>bp :bprevious<CR>
      " Window management
      map <leader>w <C-w>
      nnoremap <leader>qq <cmd>quitall<CR>

      " Move line below
      nnoremap <A-j> :m .+1<CR>==
      " Move line above
      nnoremap <A-k> :m .-2<CR>
      inoremap <A-j> <Esc>:m .+1<CR>==gi
      inoremap <A-k> <Esc>:m .-2<CR>==gi
      vnoremap <A-j> :m '>+1<CR>gv=gv
      vnoremap <A-k> :m '<-2<CR>gv=gv

      au FileType gitcommit setlocal tw=68 colorcolumn=69 spell
    '';
  };
}
