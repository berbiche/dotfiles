moduleArgs@{ config, lib, pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      # Show key completion
      plugin = which-key-nvim;
      type = "lua";
      config = ''
        local wk = require('which-key')
        wk.setup {
          marks = true,
          registers = true,
          spelling = { enabled = false, },
          key_labels = {
            ['<space>'] = 'SPC',
          },
          trigggers = {},
          window = {
            border = 'single'
          },
        }

        wk.register({
          ["<leader>'"] = { name = '+marks' },
          ['<leader>b'] = { name = '+buffer' },
          ['<leader>f'] = { name = '+file' },
          ['<leader>g'] = { name = '+git' },
          ['<leader>l'] = { name = '+lsp' },
          ['<leader>o'] = { name = '+open' },
          ['<leader>p'] = { name = '+project' },
          ['<leader>q'] = { name = '+session' },
          ['<leader>w'] = { name = '+window' },
        })
      '';
    }
    vim-repeat
    vim-indent-object
    vim-sensible
    # Indent using tabs or spaces based on the content of the file
    vim-sleuth
    # Close buffers/windows/etc.
    vim-sayonara
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
    {
      plugin = intellitab-nvim;
      type = "lua";
      config = ''
        bind('i', '<Tab>', function() require('intellitab').indent() end, 'Indent')
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
    # Automatically close pairs of symbols like {}, [], (), "", etc.
    {
      plugin = nvim-autopairs;
      type = "lua";
      config = ''
        require('nvim-autopairs').setup {
          check_ts = true,
          disable_filetype = { 'TelescopePrompt', 'NvimTree', 'startify', 'terminal', 'coc-explorer' }
        }
      '';
    }
    {
      plugin = vim-illuminate;
      type = "lua";
      config = ''
        require('illuminate').configure {
          providers = { 'lsp', 'treesitter' },
          filetypes_denylist = default_excluded_filetypes,
        }
      '';
    }
    {
      # Shows a key sequence to jump to a word/letter letter after typing 's<letter><letter>'
      plugin = leap-nvim;
      type = "lua";
      config = ''
        -- Hijacks {x, X}
        require('leap').add_default_mappings()
      '';
    }
    {
      plugin = searchbox-nvim;
      type = "lua";
      config = ''
        bind({'n', 'v'}, '<leader>sh', require('searchbox').replace, 'Replace word')
        bind('x', '<leader>sh', function() require('searchbox').replace({visual_mode = true}) end, 'Replace word')
      '';
    }

    # Git
    {
      plugin = diffview-nvim;
      type = "lua";
      config = ''
        require('diffview').setup {

        }
      '';
    }
    {
      # Like emacs' magit
      plugin = neogit;
      type = "lua";
      config = ''
        local neogit = require('neogit')
        neogit.setup {
          use_magit_keybindings = true,
          auto_show_console = false,
          console_timeout = 5000,
          disable_commit_confirmation = true,
          disable_insert_on_commit = false,
          integrations = {
            diffview = true,
          },
        }

        bind('n', '<leader>gg', neogit.open, {silent = true}, 'Open neogit')
      '';
    }
    {
      plugin = gitsigns-nvim;
      type = "lua";
      config = ''
        -- TODO: setup keybinds
        require('gitsigns').setup { }
      '';
    }
    {
      plugin = comment-nvim;
      type = "lua";
      config = ''
        local c = require('Comment')

        c.setup {
          -- extra = {
          --   line = {'<leader>;', '<M-;>'},
          -- },
        }
      '';
    }

    {
      plugin = auto-hlsearch-nvim;
      type = "lua";
      config = ''
        require('auto-hlsearch').setup()
      '';
    }
    {
      plugin = nvim-hlslens;
      type = "lua";
      config = ''
        require('hlslens').setup()

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

        bind('n', '<localleader>l', ':nohlsearch<CR>', opts)
      '';
    }

    # Jump to matching keyword, supercharged %
    vim-matchup

    plenary-nvim
    {
      plugin = sqlite-lua;
      type = "lua";
      config = ''
        vim.g.sqlite_clib_path = [[${lib.getLib pkgs.sqlite}/lib/libsqlite3${pkgs.hostPlatform.extensions.sharedLibrary}]]
      '';
    }

    {
      plugin = workspaces-nvim;
      type = "lua";
      config = ''
        require('workspaces').setup {
          cd_type = 'tab',
        }
      '';
    }

    # telescope-project-nvim
    telescope-frecency-nvim
    telescope-fzy-native-nvim
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
            fzy_native = {
              override_generic_sorter = false,
              override_file_sorter = true,
            },
            project = {
              display_type = 'full',
              base_dirs = {
                {'~/dev', max_depth = 3},
              },
            },
            file_browser = {
              hijack_netrw = false,
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

        ts.load_extension('fzy_native')
        -- ts.load_extension('fzf')
        ts.load_extension('frecency')
        -- ts.load_extension('project')
        ts.load_extension('file_browser')
        ts.load_extension('notify')
        ts.load_extension('zoxide')
        ts.load_extension('workspaces')

        local opts = { silent = true }

        bind('n', '<space><space>', builtins.git_files, opts, 'Find file in project')
        bind('n', '<leader>.',
          function() ts.extensions.file_browser.file_browser({ cwd = vim.fn.expand('%:p:h'), select_buffer = true, }) end,
          opts,
          'Find file in current directory')

        for _, v in pairs({',', 'b,', 'bi'}) do
          bind('n', '<leader>'..v, builtins.buffers, opts, 'Find buffer')
        end

        -- List spelling suggestions
        bind('n', '<leader>si', builtins.spell_suggest, opts, 'Show spelling suggestions')
        bind('n', 'z=', builtins.spell_suggest, opts, 'Show spelling suggestions')
        -- List recent files
        bind('n', '<leader>fr', builtins.oldfiles, opts, 'Find recent files')
        -- List most open files
        bind('n', '<leader>fF', ts.extensions.frecency.frecency, opts, 'List most opened files')
        -- bind('n', '<leader>pp', ts.extensions.project.project, opts)
        bind('n', '<leader>pp', ts.extensions.workspaces.workspaces, opts, 'List projects')

        -- Finding things
        bind('n', '<leader>ss', builtins.current_buffer_fuzzy_find, opts, 'Search in current buffer')
        bind('n', '<leader>sp', builtins.live_grep, opts, 'Search word in current project')
        -- bind('n', '<leader>sd', function() builtins. end,)

        -- List registers
        bind('n', '<leader>ir', builtins.registers, opts, 'List registers')

        --
        autocmd('User', {
          group = myCommandGroup,
          pattern = 'TelescopePreviewerLoaded',
          callback = function()
            vim.opt_local.wrap = true
          end,
        })
      '';
    }

    {
      plugin = FTerm-nvim;
      type = "lua";
      config = ''
        require('FTerm').setup {
          border = 'rounded',
        }

        local opts = { silent = true }
        bind('n', '<space>of', require('FTerm').toggle, opts, 'Open floating terminal')
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
}
