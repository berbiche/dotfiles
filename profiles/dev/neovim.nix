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

  toLua = x: ''lua <<EOF
    ${x}
  EOF'';
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

      extraPackages = with pkgs; [
        nodePackages.bash-language-server
        nodePackages.typescript-language-server
        rnix-lsp
        rust-analyzer
        shellcheck
      ];

      plugins = myPlugins ++ (with pkgs.vimPlugins; [
        {
          plugin = pkgs.runCommandLocal "null-plugin" { } "touch $out";
          config = ''
            let g:mapleader = "\<Space>"
            let g:maplocalleader = ','

            " Default settings
            set nocompatible
            set nobackup
            " Yup, I live on the edge
            set noswapfile
            " Update terminal's titlebar
            set title
            " Use utf-8 by default
            set encoding=utf-8

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

            set wrap
            set linebreak
            set breakindent
            let &showbreak = '↳ '


            set formatoptions+=j   " remove a comment leader when joining lines.
            set formatoptions+=o   " insert the comment leader after hitting 'o'

            " Enable autocompletion
            " set wildmode=longest,list,full
            set wildmode=longest,full

            " I already use vim-airline
            set noshowmode

            " Live substitution
            set inccommand=nosplit

            " Don't pass messages to |ins-completion-menu|
            set shortmess+=c
          '';
        }

        vim-buffergator
        vim-indent-object
        vim-surround
        vim-signify
        vim-sensible
        auto-pairs
        vim-indent-guides

        {
          ## Git
          plugin = vim-fugitive;
          config = ''
            nnoremap <silent> <leader>gg :Git<CR>
            nnoremap <silent> <leader>gd :Gdiff<CR>
            nnoremap <silent> <leader>gc :Gcommit<CR>
            nnoremap <silent> <leader>gb :Gblame<CR>
            nnoremap <silent> <leader>ge :Gedit<CR>
          '';
        }
        {
          ## Show key completion
          plugin = vim-which-key;
          config = ''
            let g:which_key_map = {}
            let g:which_key_map.q = { 'name': 'Close buffer' }
            let g:which_key_map.Q = { 'name': 'Close buffer/window' }
            " The floating window is ugly, disable it
            let g:which_key_use_floating_win = 0

            " For CursorHold autocommand, required by which-key
            set updatetime=100

            au VimEnter * call which_key#register('<Space>', "g:which_key_map")
            au VimEnter * call which_key#register(',', "g:which_key_map")

            nnoremap <silent> <leader>      :<C-u>WhichKey '<Space>'<CR>
            nnoremap <silent> <localleader> :<C-u>WhichKey ','<CR>
            vnoremap <silent> <leader>      :<C-u>WhichKeyVisual '<Space>'<CR>
            vnoremap <silent> <localleader> :<C-u>WhichKeyVisual ','<CR>
            autocmd! FileType which_key
            autocmd  FileType which_key set laststatus=0 noshowmode noruler
              \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
          '';
        }
        {
          # Comment lines with commentary.vim
          plugin = vim-commentary;
          config = ''
            inoremap <silent> <M-;> <C-o>:Commentary<CR>
            nmap <silent> <M-;> gcc
            vmap <silent> <M-;> gc
            nmap <silent> <leader>; gcc
            vmap <silent> <leader>; gc
          '';
        }
        {
          plugin = vim-sayonara;
          config = ''
            nnoremap <silent><leader>Q <cmd>Sayonara<CR>
            nnoremap <silent><leader>q <cmd>Sayonara!<CR>
          '';
        }
        {
          ## Shows symbol with LSP
          plugin = vista-vim;
          config = ''
            let g:vista_fzf_preview = ['right:30%']
            let g:vista#renderer#enable_icon = 1
            let g:vista#renderer#icons = {
            \   "function": "\uf794",
            \   "variable": "\uf71b",
            \  }
          '';
        }
        {
          # Rainbow paranthesis, brackets
          plugin = rainbow;
          config = ''
            " Enable rainbow paranthesis globally
            let g:rainbow_active = 1
          '';
        }
        {
          plugin = fzf-vim;
          config = ''
            let g:fzf_command_prefix = 'Fzf'
            let g:fzf_nvim_statusline = 0
            let g:fzf_buffers_jump = 1
            let g:fzf_full_preview_toggle_key = '<C-s>'
            nnoremap <C-t> :FzfFiles!
            nnoremap <leader><space> :FzfFiles<CR>
            nnoremap <leader>. :FzfFiles %:p:h<CR>

            " Finding things
            nnoremap <leader>ss :FzfBLines<CR>
            nnoremap <leader>sp :FzfRg<CR>
          '';
        }
        fzf-lsp-nvim

        {
          plugin = vim-startify;
          config = ''
            let g:startify_use_env = 0
            let g:startify_files_number = 10
            let g:startify_session_autoload = 0
            let g:startify_relative_path = 0

            let g:startify_custom_header = []
            let g:startify_custom_footer = []

            let g:startify_skiplist = [
              \ 'COMMIT_EDITMSG',
              \ '^/nix/store',
              \ ]
            let g:startify_bookmarks = [
              \ { 'd': '~/dotfiles' },
              \ ]

            autocmd User Startified setlocal cursorline
          '';
        }

        ## Languages and LSP
        vim-nix
        # vim-addon-nix
        {
          plugin = coc-nvim;
          config = ''
            inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"
            inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
            inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

            set signcolumn=number

            autocmd CursorHold * silent call CocActionAsync('highlight')

            command! -nargs=0 Format :call CocAction('format')

            nnoremap <leader>gf :<C-u>Format
            xmap     <leader>=  <Plug>(coc-format-selected)

            nmap <silent> gd <Plug>(coc-definition)
            nmap <silent> gy <Plug>(coc-type-definition)
            nmap <silent> gi <Plug>(coc-implementation)
            nmap <silent> gr <Plug>(coc-references)
          '';
        }
        coc-explorer
        coc-go
        coc-html
        coc-json
        coc-markdownlint
        coc-python
        # coc-rust-analyzer
        # coc-sh
        coc-vimlsp

        {
          # Statusbar
          plugin = vim-airline;
          config = ''
            " Display all buffers when only one tab is open
            "let g:airline#extensions#tabline#enabled = 1
          '';
        }
        {
          # Statusbar themes
          plugin = vim-airline-themes;
          config = "let g:airline_theme = 'bubblegum'";
        }

      ]
      ++ lib.optional config.profiles.dev.wakatime.enable {
        plugin = vim-wakatime;
        config = ''
          ${lib.optionalString config.profiles.dev.wakatime.enable ''
            " WakaTime CLI path
            let g:wakatime_OverrideCommandPrefix = '${pkgs.wakatime}/bin/wakatime'
          ''}
        '';
      });

      extraConfig = ''
        " Disables automatic commenting on newline if previous line is a comment
        autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

        " Highlight trailing whitespace
        highlight TrailingWhitespace ctermbg=red guibg=red
        match TrailingWhitespace /\s\+$/

        " Quick exit with `:Q`
        command Q qa

        nnoremap <leader>si :set spell!<CR>
        nnoremap <leader>l :set list!<CR>
        nnoremap <leader>S :%s//g<Left><Left>
        nnoremap <leader>m :set number!<CR>
        nnoremap <leader>n :set relativenumber!<CR>

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
        nnoremap <leader>bd :bd<CR>
        nnoremap <leader>bn :bnext<CR>
        nnoremap <leader>bN :enew<CR>
        nnoremap <leader>bp :bprevious<CR>
        nnoremap <leader>bi :FzfBuffers<CR>
        " Window management
        nnoremap <leader>w <C-w>

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

    # Stolen from legendofmiracles' dotnix
    home.file.".config/nvim/after/queries/nix/injections.scm".text = ''
      (
          (app [
              ((identifier) @_func)
              (select (identifier) (attrpath (attr_identifier) @_func . ))
          ]) (indented_string) @bash
          (#match? @_func "(writeShellScript(Bin)?)")
          ; #!/bin/sh shebang highlighting
          ((indented_string) @bash @_code
            (#lua-match? @_code "\s*#!\s*/bin/sh"))
          ; Bash strings
          ((indented_string) @bash @_code
            (#lua-match? @_code "\s*## Syntax: bash"))
          ; Lua strings
          ((indented_string) @lua @_code
            (#lua-match? @_code "\s*\\-\- Syntax: lua"))
      )
    '';

    home.file.".config/nvim/coc-settings.json".source = (pkgs.formats.json { }).generate "coc-settings.json" {
      diagnostic = {
        enable = true;
        errorSign = ">>";
        warningSign = "⚠";
      };
      languageserver = {
        bash = {
          command = "bash-language-server";
          args = [ "start" ];
          filetypes = [ "sh" "bash" ];
          ignoredRootPaths = [ "~" ];
        };
        nix = {
          command = "rnix-lsp";
          filetypes = [ "nix" ];
        };
      };
    };
  };
}
