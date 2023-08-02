{ config, lib, pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [
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
    telescope-fzf-native-nvim
    telescope-file-browser-nvim
    {
      plugin = telescope-nvim;
      type = "lua";
      config = ''
        local ts = require('telescope')
        local themes = require('telescope.themes')
        local actions = require('telescope.actions')
        local fb_actions = ts.extensions.file_browser.actions
        local builtins = require('telescope.builtin')
        local hastrouble, trouble = pcall(require, 'trouble.providers.telescope')

        ts.setup {
          defaults = {
            layout_strategy = 'horizontal',
            results_title = false,
            mappings = {
              i = {
                ['<esc>'] = actions.close,
                ['<C-g>'] = actions.close,
                ['<C-e>'] = hastrouble and trouble.open_with_trouble or nil,
              },
              n = {
                ['<esc>'] = actions.close,
                ['<C-g>'] = actions.close,
                ['<C-e>'] = hastrouble and trouble.open_with_trouble or nil,
              },
            },
          },
          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = false,
              override_file_sorter = true,
              case_mode = 'smart_case',
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
                i = {
                  -- Match completions behavior of accepting with tab
                  ['<Tab>'] = actions.select_default,
                  ['<C-e>'] = fb_actions.create_from_prompt,
                },
                n = {
                  ['<C-e>'] = fb_actions.create_from_prompt,
                },
              },
            },
          },
          pickers = {
            buffers = {
              sort_lastused = true,
              sort_mru = true,
              theme = 'ivy',
              previewer = false,
              ignore_current_buffer = true,
            },
            commands = {
              theme = 'ivy',
            },
            git_files = {
              theme = 'ivy',
              previewer = true,
            },
            oldfiles = {
              theme = 'ivy',
            },
            registers = {
              theme = 'ivy'
            },
            spell_suggest = {
              theme = 'cursor'
            },
          },
        }

        ts.load_extension('fzf')
        ts.load_extension('frecency')
        -- ts.load_extension('project')
        ts.load_extension('file_browser')
        ts.load_extension('notify')
        ts.load_extension('workspaces')

        local opts = { silent = true }

        bind('n', '<space><space>', function()
          builtins.git_files({
            show_untracked = true,
          })
        end, opts, 'Find file in project')
        bind('n', '<leader>.', function()
          local opts = vim.tbl_extend('force', themes.get_ivy(), {
            cwd = vim.fn.expand('%:p:h'),
            select_buffer = true,
            hidden = true
          })
          ts.extensions.file_browser.file_browser(opts)
        end, opts, 'Find file in current directory')

        for _, v in pairs({',', 'b,', 'bi'}) do
          bind('n', '<leader>'..v, function()
            -- _G.list_buffers(themes.get_dropdown())
            builtins.buffers(themes.get_ivy({
              -- Scope to "current project"
              cwd = require('neogit').get_repo().state.git_root or ''',
              -- Theme settings
              layout_config = { height = 10, },
            }))
          end, opts, 'Find buffer')
        end

        -- List spelling suggestions
        bind('n', '<leader>si', builtins.spell_suggest, opts, 'Show spelling suggestions')
        bind('n', 'z=', builtins.spell_suggest, opts, 'Show spelling suggestions')
        -- List recent files
        bind('n', '<leader>fr', builtins.oldfiles, opts, 'Find recent files')
        bind('n', '<leader>fF', function()
          ts.extensions.frecency.frecency(themes.get_ivy())
        end, opts, 'List most opened files')
        bind('n', '<leader>pp', function()
          ts.extensions.workspaces.workspaces(themes.get_dropdown())
        end, opts, 'List projects')

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

  ];
}
