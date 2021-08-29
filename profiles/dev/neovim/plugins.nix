{ config, nixosConfig, lib, pkgs, ... }:

let
  toPlugin = n: v: pkgs.vimUtils.buildVimPluginFrom2Nix { name = n; src = v; };

  myPlugins = lib.mapAttrsToList toPlugin {
  };

  vim-sayonara = pkgs.vimPlugins.vim-sayonara.overrideAttrs (_: {
    src = pkgs.fetchFromGitHub {
      owner = "mhinz";
      repo = "vim-sayonara";
      rev = "7e774f58c5865d9c10d40396850b35ab95af17c5";
      hash = "sha256-QDBK6ezXuLpAYh6V1fpwbJkud+t34aPBu/uR4pf8QlQ=";
    };
  });

  fterm-nvim = toPlugin "fterm.nvim" (pkgs.fetchFromGitHub {
    owner = "numToStr";
    repo = "FTerm.nvim";
    rev = "024c76c577718028c4dd5a670552117eef73e69a";
    sha256 = "sha256-Ooan02z82m6hFmwSJDP421QuUqOfjH55X7OwJ5Pixe0=";
  });

  telescope-project-nvim = toPlugin "telescope-project.nvim" (pkgs.fetchFromGitHub {
    owner = "nvim-telescope";
    repo = "telescope-project.nvim";
    rev = "6f63c15efc4994e54c3240db8ed4089c926083d8";
    sha256 = "0mda6cak1qqa5h9j5xng8wq81aqfypizmxpfdfqhzjsswwpa9bjy";
  });

  kommentary = toPlugin "kommentary" (pkgs.fetchFromGitHub {
    owner = "b3nj5m1n";
    repo = "kommentary";
    rev = "a5d7cd90059ad99b5e80a1d40d655756d86b5dad";
    sha256 = "1bgi9dzzlw09llyq09jgnyg7n64s1nk5s5knlkhijrhsw0jmxjkk";
  });
in
{
  programs.neovim.plugins = with pkgs.vimPlugins; [ ]
  ++ myPlugins
  ++ [
    {
      # Notifications display
      plugin = nvim-notify;
      config = ''lua vim.notify = require("notify")'';
    }
    # https://github.com/neovim/neovim/issues/12587
    FixCursorHold-nvim
    {
      plugin = sonokai; # theme
      config = ''
        let g:sonokai_style = 'maia'
        let g:sonokai_enable_italic = 1
        let g:sonokai_transparent_background = 1
      '';
    }
    gruvbox-nvim # theme
    vim-indent-object
    vim-surround
    vim-signify
    vim-sensible
    # Highlight TODO:, FIXME, HACK etc.
    todo-comments-nvim
    # Automatically close pairs of symbols like {}, [], (), "", etc.
    {
      plugin = nvim-autopairs;
      config = "lua require('nvim-autopairs').setup { check_ts = true, }";
    }
    # Automatically source the .envrc (integration with direnv)
    direnv-vim
    {
      # Peek lines when typing :30 for instance
      plugin = numb-nvim;
      config = "lua require('numb').setup()";
    }
    {
      plugin = wilder-nvim;
      config = ''
        call wilder#setup({'modes': [':', '/', '?']})
        call wilder#set_option('pipeline', [
          \ wilder#branch(
          \   wilder#cmdline_pipeline({'fuzzy': 1, 'language': 'python'}),
          \   wilder#python_search_pipeline(),
          \ ),
          \ ])
        call wilder#set_option('renderer', wilder#popupmenu_renderer({
          \ 'highlighter': [wilder#basic_highlighter()],
          \ 'left': [wilder#popupmenu_devicons()],
          \ }))
      '';
    }
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
      # Shows a key sequence to jump to a word/letter letter after typing 's<letter><letter>'
      plugin = lightspeed-nvim;
      config = ''
        " let g:sneak#prompt = 'sneak> '
        " let g:sneak#label = 1
        " let g:sneak#map_netrw = 0
      '';
    }
    {
      plugin = registers-nvim;
      config = ''
        let g:registers_delay = 500 " milliseconds
        let g:registers_show_empty_registers = 0
        let g:registers_hide_only_whitespace = 1
        let g:registers_window_border = 'rounded'
      '';
    }

    # Better netrw
    vim-vinegar

    # Git
    diffview-nvim
    {
      # Kinda like emacs' magit
      plugin = neogit;
      config = ''
        lua <<EOF
          require('neogit').setup {
            disable_commit_confirmation = true,
            integrations = {
              diffview = true,
            },
          }
        EOF

        nnoremap <silent> <leader>gg :lua require('neogit').open()<CR>
      '';
    }
    {
      plugin = gitsigns-nvim;
      config = ''lua require('gitsigns').setup()'';
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
      config = ''
        lua <<EOF
          local k = require('kommentary.config')

          k.use_extended_mappings()
          k.configure_language("default", {
            prefer_single_line_comments = true,
          })

          local map = vim.api.nvim_set_keymap
          map("i", "<M-;>", "<Plug>kommentary_line_default", {noremap = true})
          map("n", "<M-;>", "<Plug>kommentary_line_default", {})
          map("v", "<M-;>", "<Plug>kommentary_visual_default", {})
          map("n", "<leader>;", "<Plug>kommentary_line_default", {})
          map("v", "<leader>;", "<Plug>kommentary_visual_default", {})
        EOF
      '';
    }
    {
      # Close buffers/windows/etc.
      plugin = vim-sayonara; 
      config = ''
        nnoremap <silent><leader>Q <cmd>Sayonara<CR>
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
      plugin = nvim-hlslens;
      config = ''
        noremap <silent> n <cmd>execute('normal! ' . v:count1 . 'n')<CR>
                    \<cmd>lua require('hlslens').start()<CR>
        noremap <silent> N <cmd>execute('normal! ' . v:count1 . 'N')<CR>
                    \<cmd>lua require('hlslens').start()<CR>
        noremap * *<cmd>lua require('hlslens').start()<CR>
        noremap # #<cmd>lua require('hlslens').start()<CR>
        noremap g* g*<cmd>lua require('hlslens').start()<CR>
        noremap g# g#<cmd>lua require('hlslens').start()<CR>

        " use : instead of <cmd>
        nnoremap <silent> <leader>l :noh<CR>
      '';
    }

    # Jump to matching keyword, supercharged %
    vim-matchup

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
                  ["C-c"] = actions.close,
                },
                n = {
                  ["<esc>"] = actions.close,
                  ["C-c"] = actions.close,
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
                sort_lastused = true,
                sort_mru = true,
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

          local map = vim.api.nvim_set_keymap
          local opts = { noremap = true, silent = true }

          map("n", "<space><space>", "<cmd>lua require('telescope.builtin').git_files()<CR>", opts)
          -- map("n", "<leader><.>", "<cmd>lua require('telescope.builtin').find_files({ cwd = vim.fn.expand('%:p:h')})<CR>", opts)

          -- Create new file with <C-e> in file_browser
          map("n", "<leader>.", "<cmd>lua require('telescope.builtin').file_browser({ cwd = vim.fn.expand('%:p:h') })<CR>", opts)

          for _, v in pairs({",", "b,", "bi"}) do
            map("n", "<leader>"..v, "<cmd>lua require('telescope.builtin').buffers()<CR>", opts)
          end

          -- List
          map("n", "<leader>si", "<cmd>lua require('telescope.builtin').spell_suggest()<CR>", opts)
          -- List recent files
          map("n", "<leader>fr", "<cmd>lua require('telescope.builtin').oldfiles()<CR>", opts)
          -- List most open files
          map("n", "<leader>fF", "<cmd>lua require('telescope').extensions.frecency.frecency()<CR>", opts)
          map("n", "<leader>pp", "<cmd>lua require('telescope').extensions.project.project()<CR>", opts)

          -- Finding things
          map("n", "<leader>ss", "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>", opts)
          map("n", "<leader>sp", "<cmd>lua require('telescope.builtin').live_grep()<CR>", opts)
        EOF

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

    # Statusbar
    {
      plugin = lualine-nvim;
      config = ''
      lua <<EOF
        require("lualine").setup {
          options = {
            disabled_filetypes = { "NvimTree", "startify", "terminal", "coc-explorer" },
            theme = 'auto',
          },
        }
      EOF
      '';
    }
    {
      # Tab-bar
      plugin = barbar-nvim;
      config = ''
        let bufferline = get(g:, 'bufferline', {})
        let bufferline.closable = v:false

        " autocmd User CocExplorerOpenPre lua require'bufferline.state'.set_offset(30, 'FileTree')
        " autocmd User CocExplorerQuitPre lua require'bufferline.state'.set_offset(0)
      '';
    }
    {
      # Filetree
      plugin = nvim-tree-lua;
      config = ''
        let g:nvim_tree_auto_close = 1
        let g:nvim_tree_auto_ignore_ft = ['startify', 'dashboard']
        let g:nvim_tree_add_trailing = 1
        let g:nvim_tree_follow = 1
        let g:nvim_tree_gitignore = 1
        let g:nvim_tree_git_hl = 1
        let g:nvim_tree_highlight_opened_files = 1
        let g:nvim_tree_ignore = ['.git', 'result']
        let g:nvim_tree_lsp_diagnostics = 1

        lua <<EOF
          function _G.tree_toggle()
            local tree = require('nvim-tree')
            local view = require('nvim-tree.view')
            local st = require('bufferline.state')
            tree.toggle()
            if view.win_open() then
              st.set_offset(31, 'FileTree')
            else
              st.set_offset(0)
            end
          end
        EOF

        nnoremap <silent> <leader>op :call v:lua.tree_toggle()<CR>
      '';
    }

    # Highlight css colors such as #ccc
    {
      plugin = nvim-colorizer-lua;
      config = ''
        lua <<EOF
          require('colorizer').setup {
            ['*'] = {
              names = false,
              mode = 'background',
            },
            css = { css = true, css_fn = true, },
            html = { names = true, },
            '!c',
            '!cpp',
            '!erlang',
            '!go',
          }
        EOF
      '';
    }

    {
      plugin = fterm-nvim;
      config = ''
        lua <<EOF
          require('FTerm').setup {
            border = 'rounded',
          }

          local map = vim.api.nvim_set_keymap
          local opts = { noremap = true, silent = true }

          map('n', '<space>`', '<cmd>lua require("FTerm").toggle()<CR>', opts)
          -- map('t', '<space>`', '<cmd>lua require("FTerm").toggle()<CR>', opts)
        EOF
      '';
    }
  ]
  ++ lib.optional nixosConfig.profiles.dev.wakatime.enable {
    plugin = vim-wakatime;
    optional = true;
    config = ''
      " WakaTime CLI path
      let g:wakatime_OverrideCommandPrefix = ${lib.escapeShellArg pkgs.wakatime}.'/bin/wakatime'
    '';
  };

  programs.neovim.extraConfig = lib.mkAfter ''
    " neovim-remote setup
    let $GIT_EDITOR = 'nvr -cc split --remote-wait'
    au FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
    command! DisconnectClients
      \  if exists('b:nvr')
      \|   for client in b:nvr
      \|     silent! call rpcnotify(client, 'Exit', 1)
      \|   endfor
      \| endif
'';
}
