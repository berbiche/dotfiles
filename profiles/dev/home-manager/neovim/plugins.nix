moduleArgs@{ config, lib, pkgs, ... }:

let
  osConfig = moduleArgs.osConfig or { };
in
{
  programs.neovim.plugins = with pkgs.vimPlugins; [ ]
  ++ [
    vim-repeat
    {
      # Notifications display
      plugin = nvim-notify;
      type = "lua";
      config = ''
        local notify = require("notify")
        notify.setup({
          stages = 'fade',
          render = 'minimal',
          background_colour = '#000000',
        })

        vim.notify = notify
      '';
    }
    # {
    #   plugin = desktop-notify-nvim;
    #   config = ''
    #     lua <<EOF
    #       vim.notify = require("desktop_notify").notify_send;
    #     EOF
    #   '';
    # }
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
    vim-signify
    vim-sensible
    # Indent using tabs or spaces based on the content of the file
    vim-sleuth
    {
      plugin = vim-sandwich; # replaces vim-surround
      config = ''
        " Use surround.vim keymaps since the default keymap breaks vim-sneak
        runtime macros/sandwich/keymap/surround.vim
      '';
    }
    # editorconfig support for indent style, etc.
    editorconfig-nvim
    # Highlight TODO:, FIXME, HACK etc.
    {
      plugin = todo-comments-nvim;
      type = "lua";
      config = ''
        require('todo-comments').setup {}
      '';
    }
    # Highlight ranges in the commandline such as :10,20
    {
      plugin = range-highlight-nvim;
      type = "lua";
      config = ''
        require('range-highlight').setup {}
      '';
    }
    # UI configuration
    {
      plugin = dressing-nvim;
      type = "lua";
      config = ''
        require('dressing').setup {}
      '';
    }
    # Automatically close pairs of symbols like {}, [], (), "", etc.
    {
      plugin = nvim-autopairs;
      type = "lua";
      config = ''
        require('nvim-autopairs').setup {
          check_ts = true,
          disable_filetype = { "TelescopePrompt", "NvimTree", "startify", "terminal", "coc-explorer" }
        }
      '';
    }
    # Automatically source the .envrc (integration with direnv)
    direnv-vim
    {
      # Peek lines when typing :30 for instance
      plugin = numb-nvim;
      type = "lua";
      config = ''
        require('numb').setup()
      '';
    }
    {
      # Better wildmenu
      plugin = wilder-nvim;
      type = "viml";
      config = ''
        if !exists('g:vscode')
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
        endif
      '';
    }
    {
      # Displays vertical line for the indentation level
      plugin = indent-blankline-nvim;
      type = "viml";
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
      type = "lua";
    }
    nui-nvim
    {
      plugin = searchbox-nvim;
      type = "lua";
      config = ''
        local map = vim.api.nvim_set_keymap
        map("n", "<leader>sh", "<cmd>lua require('searchbox').replace()<CR>", {noremap=true})
        map("v", "<leader>sh", "<cmd>lua require('searchbox').replace()<CR>", {noremap=true})
      '';
    }
    {
      plugin = BufOnly-vim;
      type = "lua";
      config = ''
        local map = vim.api.nvim_set_keymap
        local opt = { noremap = true }
        map("n", "<leader>bo", "<cmd>BufOnly<CR>", opt)
        map("v", "<leader>bo", "<cmd>BufOnly!<CR>", opt)
      '';
    }
    {
      plugin = registers-nvim;
      type = "lua";
      config = ''
        local registers = require("registers")
        registers.setup({
          show_empty = false,
          hide_only_whitespace = true,

          bind_keys = {
            registers = registers.apply_register({ delay = 0.5 }),
          },

          window = {
            border = "rounded",
          },
        })
      '';
    }

    # Better netrw
    vim-vinegar

    # Git
    diffview-nvim
    {
      # Like emacs' magit
      plugin = neogit;
      type = "lua";
      config = ''
        require('neogit').setup {
          disable_commit_confirmation = true,
          integrations = {
            diffview = true,
          },
        }

        local map = vim.api.nvim_set_keymap
        map("n", "<leader>gg", "<cmd>lua require('neogit').open()<CR>", {noremap=true, silent=true})
      '';
    }
    {
      plugin = gitsigns-nvim;
      type = "lua";
      config = ''
        require('gitsigns').setup()
      '';
    }

    {
      # Show key completion
      plugin = which-key-nvim;
      type = "lua";
      config = ''
        require('which-key').setup { }
      '';
    }
    {
      # Comment lines with commentary.vim
      plugin = kommentary;
      type = "lua";
      config = ''
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
      '';
    }
    {
      # Close buffers/windows/etc.
      plugin = vim-sayonara;
      type = "lua";
      config = ''
        local map = vim.api.nvim_set_keymap
        map("n", "<leader>Q", "<cmd>Sayonara<CR>", {noremap = true, silent = true,})
      '';
    }
    {
      plugin = nvim-hlslens;
      type = "lua";
      config = ''
        require('hlslens').setup()
        
        local bind = vim.api.nvim_set_keymap
        local opts = {noremap = true, silent = true}

        bind('n', 'n',
             [[<cmd>execute('normal! ' . v:count1 . 'n')<CR><cmd>lua require('hlslens').start()<CR>]],
             opts)
        bind('n', 'N',
             [[<cmd>execute('normal! ' . v:count1 . 'N')<CR><cmd>lua require('hlslens').start()<CR>]],
             opts)
        bind('n', '*',
             [[*<cmd>lua require('hlslens').start()<CR>]],
             opts)
        bind('n', '#',
             [[#<cmd>lua require('hlslens').start()<CR>]],
             opts)
        bind('n', 'g*',
             [[g*<cmd>lua require('hlslens').start()<CR>]],
             opts)
        bind('n', 'g#',
             [[g#<cmd>lua require('hlslens').start()<CR>]],
             opts)

        bind('n', '<leader>l', ':noh<CR>', opts)
      '';
    }

    # Jump to matching keyword, supercharged %
    vim-matchup

    popup-nvim
    plenary-nvim
    {
      plugin = sqlite-lua;
      type = "viml";
      config = ''
        let g:sqlite_clib_path = '${lib.getLib pkgs.sqlite}/lib/libsqlite3${pkgs.hostPlatform.extensions.sharedLibrary}'
      '';
    }
    telescope-project-nvim
    telescope-frecency-nvim
    # telescope-fzy-native-nvim
    telescope-fzf-native-nvim
    telescope-file-browser-nvim
    {
      plugin = telescope-nvim;
      type = "viml";
      config = ''
        lua <<EOF
          local ts = require('telescope')
          local actions = require('telescope.actions')
          local fb_actions = require('telescope').extensions.file_browser.actions
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
              file_browser = {
                mappings = {
                  ["i"] = {
                    -- Match completions behavior of accepting with tab
                    ["<Tab>"] = actions.select_default,
                    ["<C-e>"] = fb_actions.create,
                  },
                  ["n"] = {
                    ["<C-e>"] = fb_actions.create,
                  },
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

          -- ts.load_extension('fzy_native')
          ts.load_extension('fzf')
          ts.load_extension('frecency')
          ts.load_extension('project')
          ts.load_extension('file_browser')
          ts.load_extension('notify')

          local map = vim.api.nvim_set_keymap
          local opts = { noremap = true, silent = true }

          map("n", "<space><space>", "<cmd>lua require('telescope.builtin').git_files()<CR>", opts)
          -- map("n", "<leader><.>", "<cmd>lua require('telescope.builtin').find_files({ cwd = vim.fn.expand('%:p:h')})<CR>", opts)

          -- Create new file with <C-e> in file_browser
          map("n", "<leader>.", "<cmd>lua require('telescope').extensions.file_browser.file_browser({ cwd = vim.fn.expand('%:p:h') })<CR>", opts)

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
          \ { 'k': '~/dev/infra/keanu.ovh' },
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
      ## For telescope
      plugin = nvim-web-devicons;
      type = "lua";
      config = ''
        require('nvim-web-devicons').setup {
          default = true,
        }
      '';
    }

    # Statusbar
    lualine-lsp-progress
    {
      plugin = lualine-nvim;
      type = "lua";
      config = ''
        require("lualine").setup {
          options = {
            disabled_filetypes = { "TelescopePrompt", "NvimTree", "startify", "terminal", "coc-explorer" },
            theme = 'seoul256',
          },
          sections = {
            lualine_b = { 'branch', 'diagnostics', 'filename', },
            lualine_c = { 'lsp_progress', },
            lualine_x = { 'encoding', 'fileformat', 'filetype', },
            lualine_y = { },
          },
          inactive_sections = {
            lualine_b = { 'diff', },
            lualine_y = { 'progress', },
          },
        }
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
      type = "lua";
      config = ''
        require('nvim-tree').setup {
          update_focused_file = {
            enable = true,
            ignore_list = {'startify', 'dashboard'},
          },
          git = {
            enable = true,
            ignore = true,
          },
          lsp_diagnostics = enable,
          filters = {
            custom = { '.git', 'result', },
          },
          renderer = {
            add_trailing = true,
            highlight_git = true,
            highlight_opened_files = "icon",
          },
        }

        function _G.tree_toggle()
          local tree = require('nvim-tree')
          local view = require('nvim-tree.view')
          local st = require('bufferline.state')
          tree.toggle()
          if view.is_visible() then
            st.set_offset(30, 'FileTree')
          else
            st.set_offset(0)
          end
        end

        local map = vim.api.nvim_set_keymap
        local opts = { noremap = true, silent = true }

        map('n', '<leader>op', '<cmd>call v:lua.tree_toggle()<CR>', opts)

        -- Since the auto_close option has been removed, this is the only option
        ${lib.optionalString (
          lib.versionAtLeast (builtins.parseDrvName config.programs.neovim.package.name).version
            "0.7.0"
        ) ''
          vim.api.nvim_create_autocmd("BufEnter", {
            nested = true,
            callback = function()
              if #vim.api.nvim_list_wins() == 1 and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil then
                vim.cmd("quit")
              end
            end,
          })
        ''}
      '';
    }

    # Highlight css colors such as #ccc
    {
      plugin = nvim-colorizer-lua;
      type = "lua";
      config = ''
        require('colorizer').setup {
          filetypes = {
            html = { names = true, },
            '!c',
            '!cpp',
            '!erlang',
            '!go',
          },
          user_default_options = {
            names = false,
            mode = 'background',
            css = true,
            css_fn = true,
            tailwind = false,
          },
        }
      '';
    }

    {
      plugin = FTerm-nvim;
      type = "lua";
      config = ''
        require('FTerm').setup {
          border = 'rounded',
        }

        local map = vim.api.nvim_set_keymap
        local opts = { noremap = true, silent = true }

        map('n', '<space>`', '<cmd>lua require("FTerm").toggle()<CR>', opts)
        -- map('t', '<space>`', '<cmd>lua require("FTerm").toggle()<CR>', opts)
      '';
    }
  ]
  ++ lib.optional (osConfig.profiles.dev.wakatime.enable or false) {
    plugin = vim-wakatime;
    optional = true;
    config = ''
      " WakaTime CLI path
      let g:wakatime_OverrideCommandPrefix = ${lib.escapeShellArg pkgs.wakatime}.'/bin/wakatime'
    '';
  };

  programs.neovim.extraConfig = lib.mkAfter ''
    " neovim-remote setup
    if !exists('g:vscode')
      let $GIT_EDITOR = 'nvr -cc split --remote-wait'
      au FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
      command! DisconnectClients
        \  if exists('b:nvr')
        \|   for client in b:nvr
        \|     silent! call rpcnotify(client, 'Exit', 1)
        \|   endfor
        \| endif
    endif
'';
}
