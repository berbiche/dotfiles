{ config, inputs, lib, pkgs, ... }:

let
  toPlugin = n: v: pkgs.vimUtils.buildVimPluginFrom2Nix { name = n; src = v; };

  myPlugins = lib.mapAttrsToList toPlugin {
  };

  telescope-project-nvim = toPlugin "telescope-project.nvim" (pkgs.fetchFromGitHub {
    owner = "nvim-telescope";
    repo = "telescope-project.nvim";
    rev = "e02e9b7ea7f4a1dba841521d8ba3eeae6eeca810";
    hash = "sha256-LBCLafSAwW7vgYcBRhvOP9sm2YJMZ7x7/rqt9klKysw=";
  });

  kommentary = toPlugin "kommentary" (pkgs.fetchFromGitHub {
    owner = "b3nj5m1n";
    repo = "kommentary";
    rev = "f5b088a0e6a4cfeee6f1902141acbc47a75af5ed";
    hash = "sha256-wzXxdLx3x/L4JD9M+SEorIhXlCFIfUh+Pr+dbY95Crk=";
  });
in
{
  my.home = {
    imports = [
      ./coc.nix
      ./tree-sitter.nix
    ];

    home.packages = [
      pkgs.fzf
      # graphical neovim
      pkgs.neovide
    ];

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

      plugins = with pkgs.vimPlugins; [
        {
          plugin = pkgs.runCommandLocal "null-plugin" { } "touch $out";
          config = ''
            let g:mapleader = "\<Space>"
            let g:maplocalleader = ','
          '';
        }
      ]
      ++ myPlugins
      ++ [
        # https://github.com/neovim/neovim/issues/12587
        FixCursorHold-nvim
        gruvbox-nvim
        vim-indent-object
        vim-surround
        vim-signify
        vim-sensible
        nvim-autopairs
        {
          # Displays vertical line for the indentation level
          plugin = indent-blankline-nvim;
          config = ''
            let g:indent_blankline_use_treesitter = v:true
            let g:indent_blankline_show_current_context = v:false

            let g:indent_blankline_filetype_exclude = ['help', 'startify']
            let g:indent_blankline_buftype_exclude = ['terminal', 'startify']
          '';
        }
        {
          plugin = vim-sneak;
          config = ''
            let g:sneak#prompt = 'sneak> '
            let g:sneak#label = 1
            " let g:sneak#map_netrw = 0
          '';
        }
        registers-nvim

        # Better netrw
        vim-vinegar

        {
          # Tab-bar
          plugin = barbar-nvim;
          config = ''
            let bufferline = get(g:, 'bufferline', {})
            let bufferline.closable = v:false

            autocmd User CocExplorerOpenPre lua require'bufferline.state'.set_offset(30, 'FileTree')
            autocmd User CocExplorerQuitPre lua require'bufferline.state'.set_offset(0)
          '';
        }

        # Git
        diffview-nvim
        # {
        #   plugin = neogit;
        #   config = ''
        #     lua <<EOF
        #       require('neogit').setup {
        #         disable_commit_confirmation = true,
        #         integrations = {
        #           diffview = true,
        #         },
        #       }
        #     EOF

        #     " nnoremap <silent> <leader>gg lua require('neogit').open()<CR>
        #     " nnoremap <silent> <leader>gc lua require('neogit').open({ 'commit' })<CR>
        #   '';
        # }
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
          plugin = which-key-nvim;
          config = ''
            lua <<EOF
              require('which-key').setup { }
            EOF
          '';
        }
        {
          # Comment lines with commentary.vim
          plugin = kommentary;
          # config = ''
          #   inoremap <silent> <M-;> <C-o>:Commentary<CR>
          #   nmap <silent> <M-;> gcc
          #   vmap <silent> <M-;> gc
          #   nmap <silent> <leader>; gcc
          #   vmap <silent> <leader>; gc
          # '';
          config = ''
            lua <<EOF
              local k = require('kommentary.config')

              k.use_extended_mappings()
              k.configure_language("default", {
                prefer_single_line_comments = true,
              })

              vim.api.nvim_set_keymap("i", "<M-;>", "<Plug>kommentary_line_default", {noremap = true})
              vim.api.nvim_set_keymap("n", "<M-;>", "<Plug>kommentary_line_default", {})
              vim.api.nvim_set_keymap("v", "<M-;>", "<Plug>kommentary_visual_default", {})
              vim.api.nvim_set_keymap("n", "<leader>;", "<Plug>kommentary_line_default", {})
              vim.api.nvim_set_keymap("v", "<leader>;", "<Plug>kommentary_visual_default", {})
            EOF
          '';
        }
        {
          # Close buffers/windows/etc.
          plugin = vim-sayonara;
          config = ''
            nnoremap <silent><leader>Q <cmd>Sayonara<CR>
            nnoremap <silent><leader>q <cmd>Sayonara!<CR>
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
          plugin = nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
          config = ''
            lua <<EOF
              require('nvim-treesitter.configs').setup {
                ensure_installed = { 'c', 'cpp', },
                highlight = {
                  enable = true,
                },
                incremental_selection = { enable = true, },
                textobjects = { enable = true, },
                indent = {
                  enable = true,
                },
              }
            EOF
          '';
        }

        {
          # Show code action lightbulb
          plugin = nvim-lightbulb;
          config = ''
            autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()
          '';
        }


        popup-nvim
        plenary-nvim
        sql-nvim
        telescope-project-nvim
        telescope-frecency-nvim
        telescope-fzy-native-nvim
        {
          plugin = telescope-nvim;
          config = ''
            lua <<EOF
              local ts = require('telescope')
              local actions = require('telescope.actions')
              ts.setup {
                defaults = {
                  layout_strategy = 'horizontal',
                  mappings = {
                    i = {
                      ["esc"] = actions.close,
                    },
                    n = {
                      ["esc"] = actions.close,
                    },
                  },
                },
                extensions = {
                  fzf = {
                    fuzzy = true,
                    override_generic_sorter = false,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                  },
                  project = {
                    display_type = 'full',
                    base_dirs = {
                      {'~/dev', max_depth = 3},
                    },
                  },
                },
                pickers = {
                  buffers = {
                    theme = "dropdown",
                    previewer = false,
                  },
                  find_files = {
                    theme = "dropdown",
                  },
                },
              }

              ts.load_extension('fzy_native')
              ts.load_extension('frecency')
              ts.load_extension('project')
            EOF

            nnoremap <silent> <leader><space> :lua require('telescope.builtin').git_files()<CR>
            nnoremap <silent> <leader>. :lua require('telescope.builtin').find_files({ cwd = vim.fn.expand('%:p:h') })<CR>
            nnoremap <silent> <leader>bi :lua require('telescope.builtin').buffers()<CR>
            nnoremap <silent> <leader>si :lua require('telescope.builtin').spell_suggest()<CR>
            nnoremap <silent> <leader>fF :lua require('telescope').extensions.frecency.frecency()<CR>
            nnoremap <silent> <leader>pp :lua require('telescope').extensions.project.project{}<CR>

            " Finding things
            nnoremap <silent> <leader>ss :lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>
            nnoremap <silent> <leader>sp :lua require('telescope.builtin').live_grep()<CR>

            autocmd! User TelescopePreviewerLoaded setlocal wrap
          '';
        }

        {
          plugin = vim-startify;
          config = ''
            let g:startify_use_env = 0
            let g:startify_files_number = 10
            let g:startify_session_autoload = 0
            let g:startify_relative_path = 0

            let g:startify_custom_header = []
            let g:startify_custom_footer = []

            let g:startify_lists = [
              \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
              \ { 'type': 'files',     'header': ['   MRU']            },
              \ { 'type': 'sessions',  'header': ['   Sessions']       },
              \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
              \ { 'type': 'commands',  'header': ['   Commands']       },
              \ ]

            let g:startify_skiplist = [
              \ 'COMMIT_EDITMSG',
              \ '^/nix/store',
              \ ]
            let g:startify_bookmarks = [
              \ { 'd': '~/dotfiles' },
              \ ]

            autocmd User Startified setlocal cursorline

            " Save the current session
            nnoremap <leader>qS :SSave
            " Load a session
            nnoremap <leader>qL :SLoad

            " Open Startify when it's the last remaining buffer
            " autocmd BufEnter * if line2byte('.') == -1 && len(tabpagebuflist()) == 1 && empty(expand('%')) && empty(&l:buftype) && &l:modifiable | Startify | endif
            if !exists('g:vscode')
              autocmd BufDelete * if empty(filter(tabpagebuflist(), '!buflisted(v:val)')) && empty(expand('%')) && empty(&l:buftype) | Startify | endif
            endif
          '';
        }

        ## Languages and LSP
        vim-nix
        # vim-clang-format
        {
          plugin = nvim-lspconfig;
          config = ''
            lua <<EOF
              local lsp = require('lspconfig')

              -- lsp.clangd.setup {
              --   default_config = {
              --     cmd = {
              --       'clangd', '--background-index', '--pch-storage=memory', '--clang-tidy', '--suggest-missing-includes',
              --     },
              --     filetypes = { 'c', 'cpp', },
              --     root_dir = lsp.util.root_pattern('compile_commands.json', 'compile_flags.txt', '.git'),
              --   },
              -- }

              lsp.rust_analyzer.setup {}
            EOF
          '';
        }
        # vim-addon-nix
        coc-clangd
        {
          plugin = coc-nvim;
          config = ''
            inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"
            inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
            inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
            inoremap <silent><expr> <c-space> coc#refresh()

            set signcolumn=number

            autocmd CursorHold * silent call CocActionAsync('highlight')

            command! -nargs=0 Format :call CocAction('format')

            nnoremap <leader>gf :<C-u>Format<CR>
            xmap     <leader>=  <Plug>(coc-format-selected)

            nmap <silent> [g <Plug>(coc-diagnostic-prev)
            nmap <silent> ]g <Plug>(coc-diagnostic-next)
            nmap <silent> gd <Plug>(coc-definition)
            nmap <silent> gy <Plug>(coc-type-definition)
            nmap <silent> gi <Plug>(coc-implementation)
            nmap <silent> gr <Plug>(coc-references)
          '';
        }
        {
          ## For coc-explorer
          plugin = vim-devicons;
          config = ''
            let g:webdevicons_enable = 1
            let g:webdevicons_enable_airline_statusline = 1
            let g:webdevicons_enable_startify = 1
            let g:DevIconsEnableFoldersOpenClose = 1
          '';
        }
        {
          ## For telescope
          plugin = nvim-web-devicons;
          config = ''
            lua <<EOF
              require('nvim-web-devicons').setup {
                default = true,
              }
            EOF
          '';
        }
        {
          plugin = coc-explorer;
          config = ''
            let g:indent_guides_exclude_filetypes = get(g:, 'indent_guides_exclude_filetypes', [])
            let g:indent_guides_exclude_filetypes += [ 'coc-explorer' ]
            let g:indent_blankline_filetype_exclude = get(g:, 'indent_blankline_filetype_exclude', [])
            let g:indent_blankline_filetype_exclude += ['coc-explorer']
            function! RevealCurrentFile()
            CocCommand explorer --width 30
            " call CocAction('runCommand', 'explorer.doAction', 'closest', ['reveal:0'], [['reveal', 0, 'file']])
            endfunction
            nnoremap <silent> <leader>e :call RevealCurrentFile()<CR>
          '';
        }
        coc-go
        coc-html
        coc-json
        coc-markdownlint
        coc-python
        # coc-rust-analyzer
        # coc-sh
        coc-vimlsp

        direnv-vim

        # Statusbar
        {
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
        optional = true;
        config = ''
          " WakaTime CLI path
          let g:wakatime_OverrideCommandPrefix = ${lib.escapeShellArg pkgs.wakatime}.'/bin/wakatime'
        '';
      };

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
        set formatoptions+=o   " insert the comment leader after hitting 'o'

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
        autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

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
  };
}
