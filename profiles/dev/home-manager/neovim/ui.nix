moduleArgs@{ config, lib, pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; lib.mkMerge [
    (lib.mkOrder 5 [
      ### THEMES ###
      gruvbox-nvim
      {
        plugin = sonokai; # theme
        type = "lua";
        optional = true;
        config = ''
          vim.g.sonokai_style = 'maia'
          vim.g.sonokai_enable_italic = 1
          vim.g.sonokai_transparent_background = 0

          -- Attemps to create a directory in /nix/store/...-sonokai/after
          -- Obviously this doesn't work!
          vim.g.sonokai_better_performance = 0

          -- vim.cmd.colorscheme('sonokai')
        '';
      }
      {
        plugin = poimandres-nvim;
        type = "lua";
        config = ''
          require('poimandres').setup {
            disable_italics = true,
          }
          vim.cmd.colorscheme('poimandres')
        '';
      }
    ])
    [
    # Toolkits
    popup-nvim
    nui-nvim
    # Replaces vim.ui components
    {
      plugin = dressing-nvim;
      type = "lua";
      config = ''
        require('dressing').setup {}
      '';
    }



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
    # Highlight ranges in the commandline such as :10,20
    {
      plugin = range-highlight-nvim;
      type = "lua";
      config = ''
        require('range-highlight').setup {}
      '';
    }



    # Start screen
    {
      plugin = vim-startify;
      type = "lua";
      config = ''
        vim.g.startify_use_env = 0
        vim.g.startify_files_number = 10
        vim.g.startify_session_autoload = 0
        vim.g.startify_relative_path = 0

        vim.g.startify_custom_header = {}
        vim.g.startify_custom_footer = {}

        vim.g.startify_lists = {
          { type = 'dir',       header = {'   MRU ' .. vim.fn.getcwd()} },
          { type = 'files',     header = {'   MRU'} },
          { type = 'sessions',  header = {'   Sessions'} },
          { type = 'bookmarks', header = {'   Bookmarks'} },
          { type = 'commands',  header = {'   Commands'} },
        }

        vim.g.startify_skiplist = { 'COMMIT_EDITMSG', '^/nix/store', }
        vim.g.startify_bookmarks = {{ d = '~/dotfiles' }, { k = '~/dev/infra/infrastructure', }},

        autocmd({'User'}, {
          group = myCommandGroup,
          pattern = 'Startified',
          command = 'setlocal cursorline',
        })

        -- Save the current session
        bind('n', '<leader>qS', '<cmd>SSave', {desc = 'Save the current session'})
        -- Load a session
        bind('n', '<leader>qL', '<cmd>SLoad', {desc = 'Load a previous session'})

        -- Open Startify when it's the last remaining buffer
        if vim.g.vscode == nil then
          autocmd({'BufDelete'}, {
            group = myCommandGroup,
            callback = function()
              local buffer_list = vim.fn.tabpagebuflist(vim.api.nvim_get_current_tabpage())

              if type(buffer_list) ~= 'table' then
                return
              end

              -- Find whether all buffers are listed
              local exists_unlisted_buffer = false
              for _, bufnr in pairs(buffer_list) do
                if vim.fn.buflisted(bufnr) ~= 1 then
                  exists_unlisted_buffer = true
                  break
                end
              end

              local bufnr = vim.api.nvim_get_current_buf()
              local is_nameless_buffer = vim.api.nvim_buf_get_name(bufnr) == '''
              local is_buftype_empty = vim.api.nvim_buf_get_option(bufnr, 'buftype') == '''

              if not exists_unlisted_buffer and is_nameless_buffer and is_buftype_empty then
                vim.cmd.Startify()
              end
            end,
          })
        end
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
    {
      plugin = fidget-nvim;
      type = "lua";
      config = ''
        require('fidget').setup {}
      '';
    }
    {
      plugin = lualine-nvim;
      type = "lua";
      config = ''
        require("lualine").setup {
          options = {
            disabled_filetypes = { 'TelescopePrompt', 'NvimTree', 'startify', 'terminal', 'coc-explorer' },
            -- theme = 'sonokai',
            theme = 'poimandres',
          },
          sections = {
            lualine_b = { 'branch', 'diagnostics', 'filename', },
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

    # Tab-bar
    {
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

        local opts = {silent = true}

        for i=1,9 do
          bind('n', '<A-' .. i .. '>', '<cmd>BufferGoto ' .. i .. '<CR>', opts)
        end
        bind('n', '<A-0>', '<cmd>BufferLast<CR>', opts)

        bind('n', '<leader>bO', '<cmd>BufferCloseAllButCurrent<CR>', opts, 'Close other buffers')
      '';
    }

    # "Winbar" (breadcrumbs / fil d'Ariane)
    nvim-navic
    {
      plugin = barbecue-nvim;
      type = "lua";
      config = ''
        require('barbecue').setup({
          attach_navic = false,
          create_autocmd = false,
          exclude_filetypes = default_excluded_filetypes,
        })
        autocmd({
          'WinResized',
          'BufWinEnter',
          'CursorHold',
          'InsertLeave',
          'BufModifiedSet',
        }, {
          group = vim.api.nvim_create_augroup('barbecue.updater', {}),
          callback = function()
            require('barbecue.ui').update()
          end,
        })
      '';
    }

    # Filetree
    {
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

        local opts = { noremap = true, silent = true }

        bind('n', '<leader>op', require('nvim-tree.api').tree.toggle, opts, 'Open file tree')

        -- Since the auto_close option has been removed, this is the only option
        autocmd('BufEnter', {
          nested = true,
          callback = function()
            if #vim.api.nvim_list_wins() == 1 and vim.api.nvim_buf_get_name(0):match('NvimTree_') ~= nil then
              vim.cmd.quit()
            end
          end,
        })
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
      plugin = twilight-nvim;
      type = "lua";
      config = ''
        local twilight = require('twilight')
        twilight.setup {
          dimming = {
            inactive = true,
          },
        }
        bind('n', '<leader>wz', twilight.toggle, 'Toggle focus-mode')
      '';
    }


    # Neovide specific settings
    {
      plugin = pkgs.runCommandLocal "dummy" { } "mkdir $out";
      type = "lua";
      config = ''
        if vim.g.neovide then
          vim.o.guifont = 'Source Code Pro:h14'
          vim.g.neovide_input_use_logo = false
          vim.g.neovide_input_macos_alt_is_meta = true
          vim.g.neovide_cursor_animation_length = 0

          vim.g.neovide_scale_factor = 1.0

          -- Keybinds
          local opts = { silent = true, }

          bind('n', '<C-ScrollWheelUp', function()
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.25
          end, opts, 'Increase font size')
          bind('n', '<C-ScrollWheelDown', function()
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.25
          end, opts, 'Decrease font size')
        end
      '';
    }
  ]];
}
