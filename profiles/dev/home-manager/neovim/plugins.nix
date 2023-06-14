moduleArgs@{ config, lib, pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    vim-repeat
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
    {
      plugin = intellitab-nvim;
      type = "viml";
      config = ''
        inoremap <Tab> <CMD>lua require("intellitab").indent()<CR>
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
          disable_filetype = { "TelescopePrompt", "NvimTree", "startify", "terminal", "coc-explorer" }
        }
      '';
    }
    # Automatically source the .envrc (integration with direnv)
    direnv-vim
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
      # Shows a key sequence to jump to a word/letter letter after typing 's<letter><letter>'
      plugin = lightspeed-nvim;
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
          window = {
            border = "double",
          },
        })
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
      plugin = comment-nvim;
      type = "lua";
      config = ''
        local c = require('Comment')

        c.setup {
          extra = {
            line = {'<leader>;', '<M-;>'},
          },
        }
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
        -- bind("n", "<leader>sd", function() builtins. end,)

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
