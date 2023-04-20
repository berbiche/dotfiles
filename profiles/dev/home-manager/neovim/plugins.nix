moduleArgs@{ config, lib, pkgs, ... }:

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
    {
      plugin = sonokai; # theme
      type = "lua";
      config = ''
        vim.g.sonokai_style = 'maia'
        vim.g.sonokai_enable_italic = 1
        vim.g.sonokai_transparent_background = 0

        -- Attemps to create a directory in /nix/store/...-sonokai/after
        -- Obviously this doesn't work!
        vim.g.sonokai_better_performance = 0

        vim.cmd.colorscheme('sonokai')
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
      type = "lua";
      config = ''
        -- Use surround.vim keymaps since the default keymap breaks vim-sneak
        vim.cmd([[
          runtime macros/sandwich/keymap/surround.vim
        ]])
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
      type = "lua";
      config = ''
        if vim.g.vscode == nil then
          local wilder = require('wilder')

          wilder.setup({
            modes = {':', '/', '?'},
            next_key = '<C-n>',
            previous_key = '<C-p>',
          })

          wilder.set_option('pipeline', {
            wilder.branch(
              wilder.python_file_finder_pipeline(),
              wilder.cmdline_pipeline({
                language = 'python',
                fuzzy = 1,
              }),
              wilder.python_search_pipeline({
                pattern = wilder.python_fuzzy_delimiter_pattern(),
                sorter = wilder.python_difflib_sorter(),
              })
            )
          })
          wilder.set_option('renderer', wilder.renderer_mux({
            [':'] = wilder.popupmenu_renderer(
              wilder.popupmenu_border_theme({
                border = 'rounded',
                highlights = {
                  border = 'Normal',
                },
                highlighter = wilder.basic_highlighter(),
                min_width = '100%',
                reverse = 1,
                left = {' ', wilder.popupmenu_devicons()},
                right = {' ', wilder.popupmenu_scrollbar()},
              })
            ),
            ['/'] = wilder.wildmenu_renderer({
              highlighter = wilder.basic_highlighter(),
            })
          }))
        end
      '';
    }
    {
      # Displays vertical line for the indentation level
      plugin = indent-blankline-nvim;
      type = "lua";
      config = ''
        require("indent_blankline").setup {
          use_treesitter = true,
          show_current_context = false,
          filetype_exclude = {'help', 'startify'},
          buftype_exclude = {'terminal', 'startify'},
        }
      '';
    }
    {
      # Shows a key sequence to jump to a word/letter letter after typing 's<letter><letter>'
      plugin = lightspeed-nvim;
      type = "lua";
    }
    {
      plugin = nui-nvim;
      type = "lua";
    }
    {
      plugin = searchbox-nvim;
      type = "lua";
      config = ''
        local bind = vim.keymap.set
        bind({"n", "v"}, "<leader>sh", require('searchbox').replace)
        bind("x", "<leader>sh", function() require('searchbox').replace({visual_mode = true}) end)
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
            registers = registers.apply_register({ delay = 1 }),
          },

          window = {
            border = "rounded",
          },
        })
      '';
    }

    # Better netrw
    # vim-vinegar

    # Git
    diffview-nvim
    {
      # Like emacs' magit
      plugin = neogit;
      type = "lua";
      config = ''
        local neogit = require('neogit')
        neogit.setup {
          disable_commit_confirmation = true,
          integrations = {
            diffview = true,
          },
        }

        vim.keymap.set("n", "<leader>gg", neogit.open, {silent = true})
      '';
    }
    {
      plugin = gitsigns-nvim;
      type = "lua";
      config = ''
        require('gitsigns').setup { }
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

        local bind = vim.keymap.set
        bind({'i', 'n'}, "<M-;>", "<Plug>kommentary_line_default")
        bind("v", "<M-;>", "<Plug>kommentary_visual_default")
        bind("n", "<leader>;", "<Plug>kommentary_line_default")
        bind("v", "<leader>;", "<Plug>kommentary_visual_default")
      '';
    }
    {
      # Close buffers/windows/etc.
      plugin = vim-sayonara;
      type = "lua";
      config = ''
        local bind = vim.keymap.set
        bind("n", "<leader>Q", "<cmd>Sayonara<CR>", {silent = true})
      '';
    }
    {
      plugin = nvim-hlslens;
      type = "lua";
      config = ''
        require('hlslens').setup()

        local bind = vim.keymap.set
        local opts = {silent = true}

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
      type = "lua";
      config = ''
        vim.g.sqlite_clib_path = [[${lib.getLib pkgs.sqlite}/lib/libsqlite3${pkgs.hostPlatform.extensions.sharedLibrary}]]
      '';
    }
    telescope-project-nvim
    telescope-frecency-nvim
    # telescope-fzy-native-nvim
    telescope-fzf-native-nvim
    telescope-file-browser-nvim
    telescope-zoxide
    {
      plugin = telescope-nvim;
      type = "lua";
      config = ''
        local ts = require('telescope')
        local actions = require('telescope.actions')
        local fb_actions = ts.extensions.file_browser.actions
        local builtins = require('telescope.builtin')
        -- local themes = require('telescope.themes')

        ts.setup {
          defaults = {
            layout_strategy = 'horizontal',
            mappings = {
              i = {
                ["<esc>"] = actions.close,
                ["C-g"] = actions.close,
              },
              n = {
                ["<esc>"] = actions.close,
                ["C-g"] = actions.close,
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
              hijack_netrw = true,
              mappings = {
                ["i"] = {
                  -- Match completions behavior of accepting with tab
                  ["<Tab>"] = actions.select_default,
                  ["<C-e>"] = fb_actions.create_from_prompt,
                },
                ["n"] = {
                  ["<C-e>"] = fb_actions.create_from_prompt,
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
            spell_suggest = {
              theme = "cursor"
            },
          },
        }

        -- ts.load_extension('fzy_native')
        ts.load_extension('fzf')
        ts.load_extension('frecency')
        ts.load_extension('project')
        ts.load_extension('file_browser')
        ts.load_extension('notify')
        ts.load_extension('zoxide')

        local bind = vim.keymap.set
        local opts = { silent = true }

        bind("n", "<space><space>", builtins.git_files, opts)
        -- bind("n", "<leader><.>", function() builtins.find_files({ cwd = vim.fn.expand('%:p:h')}) end, opts)
        bind("n", "<leader>.", function() ts.extensions.file_browser.file_browser({ cwd = vim.fn.expand('%:p:h') }) end, opts)

        for _, v in pairs({",", "b,", "bi"}) do
          bind("n", "<leader>"..v, builtins.buffers, opts)
        end

        -- List spelling suggestions
        bind("n", "<leader>si", builtins.spell_suggest, opts)
        -- List recent files
        bind("n", "<leader>fr", builtins.oldfiles, opts)
        -- List most open files
        bind("n", "<leader>fF", ts.extensions.frecency.frecency, opts)
        bind("n", "<leader>pp", ts.extensions.project.project, opts)

        -- Finding things
        bind("n", "<leader>ss", builtins.current_buffer_fuzzy_find, opts)
        bind("n", "<leader>sp", builtins.live_grep, opts)

        -- List registers
        bind("n", "<leader>ir", builtins.registers, opts)

        --
        vim.api.nvim_create_autocmd('User', {
          pattern = 'TelescopePreviewerLoaded',
          command = 'setlocal wrap',
        })
      '';
    }

    {
      plugin = vim-startify;
      type = "viml";
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
            theme = 'sonokai',
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
      type = "lua";
      config = ''
        require('barbar').setup {
          icons = {
            button = false,
            modified = {
              button = false,
            },
            filetype = {
              enabled = true,
            },
          },
          sidebar_filetypes = {
            NvimTree = true,
          },
        }

        local bind = vim.keymap.set
        local opts = {silent = true}

        for i=1,9 do
          bind('n', '<A-' .. i .. '>', '<cmd>BufferGoto ' .. i .. '<CR>', opts)
        end
        bind('n', '<A-0>', '<cmd>BufferLast<CR>', opts)

        bind('n', '<leader>bO', '<cmd>BufferCloseAllButCurrent<CR>', opts)
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
            custom = { '^.git$', '^result', },
          },
          renderer = {
            add_trailing = true,
            highlight_git = true,
            highlight_opened_files = "icon",
          },

          actions = {
            change_dir = {
              enable = false,
            },
          },
        }

        local map = vim.keymap.set
        local opts = { noremap = true, silent = true }

        map('n', '<leader>op', require('nvim-tree.api').tree.toggle, opts)

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

        local map = vim.keymap.set
        local opts = { silent = true }

        map('n', '<space>`', require("FTerm").toggle, opts)
        -- map('t', '<space>`', '<cmd>lua require("FTerm").toggle()<CR>', opts)
      '';
    }
  ]
  ++ lib.optional (config.profiles.dev.wakatime.enable) {
    plugin = vim-wakatime;
    type = "lua";
    optional = true;
    config = ''
      -- WakaTime CLI path
      vim.g.wakatime_OverrideCommandPrefix = [[${pkgs.wakatime}/bin/wakatime]]

      if vim.g.vscode == nil then
        vim.cmd([[packadd vim-wakatime]])
      end
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
