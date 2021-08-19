{ config, inputs, lib, pkgs, ... }:

{
  my.home = {
    imports = [
      ./coc.nix
      ./plugins.nix
      ./tree-sitter.nix
    ];

    home.packages = [
      pkgs.fzf
      # graphical neovim
      pkgs.neovide
      pkgs.neovim-remote
    ];

    home.sessionVariables = {
      # EDITOR = "${config.programs.neovim.finalPackage}/bin/nvim";
      EDITOR = "${pkgs.neovim-remote}/bin/nvr -s";
    };

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;

      # From neovim-nightly input
      package = pkgs.neovim-nightly;

      extraPackages = with pkgs; [
        nodePackages.bash-language-server
        # For clangd
        clang-tools
        nodePackages.typescript-language-server
        rnix-lsp
        rust-analyzer
        shellcheck
      ];

      extraConfig = ''
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

        " Colors/Theme
        set termguicolors
        set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
              \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
              \,sm:block-blinkwait175-blinkoff150-blinkon175
        au ColorScheme * hi Normal  ctermbg=none guibg=none
        au ColorScheme * hi NonText ctermbg=none guibg=none

        " Use visual bell
        set visualbell

        " Basics
        syntax on
        colorscheme gruvbox

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


        " Disables automatic commenting on newline if previous line is a comment
        " autocmd FileType * setlocal formatoptions-=c formatoptions-=r

        " Highlight trailing whitespace
        highlight TrailingWhitespace ctermbg=red guibg=red
        match TrailingWhitespace /\s\+$/

        " nnoremap <leader>si :set spell!<CR>
        nnoremap <leader>l :set list!<CR>
        nnoremap <leader>S :%s//g<Left><Left>
        nnoremap <leader>m :set number!<CR>
        nnoremap <leader>n :set relativenumber!<CR>

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
          packadd vim-wakatime
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
        nnoremap <leader>, <C-^>
        nnoremap <leader>b, <C-^>
        nnoremap <silent> <leader>bd :BufferClose<CR>
        nnoremap <leader>bn :bnext<CR>
        nnoremap <leader>bN :enew<CR>
        nnoremap <leader>bp :bprevious<CR>
        " Window management
        map <leader>w <C-w>

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
  };
}
