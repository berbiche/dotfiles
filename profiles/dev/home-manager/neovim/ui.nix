{ config, lib, pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; lib.mkMerge [
    (lib.mkOrder 5 [
      ### THEMES ###
      {
        plugin = nvim-base16;
        type = "lua";
        config = ''
          require('base16-colorscheme').setup(
            'tomorrow-night-eighties',
            { telescope_borders = true, }
          )
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
          filetype_exclude = default_excluded_filetypes,
          buftype_exclude = {'terminal', 'startify'},
        }
      '';
    }
    {
      # Highlight ranges in the commandline such as :10,20
      plugin = range-highlight-nvim;
      type = "lua";
      config = ''
        require('range-highlight').setup {}
      '';
    }

    {
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
          ['<leader>x'] = { name = '+diagnostics' },
        })
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
        -- Disable changing to the file's directory
        vim.g.startify_change_to_dir = 0

        vim.g.startify_custom_header = {}
        vim.g.startify_custom_footer = {}

        vim.g.startify_lists = {
          { type = 'dir',       header = {'   MRU ' .. vim.fn.getcwd()} },
          { type = 'files',     header = {'   MRU'} },
          { type = 'sessions',  header = {'   Sessions'} },
          { type = 'bookmarks', header = {'   Bookmarks'} },
          { type = 'commands',  header = {'   Commands'} },
        }

        vim.g.startify_skiplist = { 'COMMIT_EDITMSG', '^/nix/store', '^/tmp', '^/private/var/tmp/', '^/run', }
        vim.g.startify_bookmarks = {
          { D = '~/dotfiles' },
          { I = '~/dev/infra/infrastructure', },
        }

        autocmd({'User'}, {
          group = myCommandGroup,
          pattern = 'Startified',
          command = 'setlocal cursorline',
        })

        -- Save the current session
        bind('n', '<leader>qS', '<cmd>SSave', 'Save the current session')
        -- Load a session
        bind('n', '<leader>qL', '<cmd>SLoad', 'Load a previous session')

        -- Open Startify when there's no other buffer in the current tab
        if vim.g.vscode == nil then
          autocmd({'BufDelete'}, {
            group = myCommandGroup,
            callback = function()
              -- List of buffers in the windows of the current tab
              local buffer_list = vim.fn.tabpagebuflist()

              -- Find whether all buffers are listed
              -- A new list is created for debugging purposes
              local filtered_bl = {}
              for _, bufnr in ipairs(buffer_list) do
                -- Somehow, the diagnostics hover buffer prevents Startify from opening...
                if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
                  table.insert(filtered_bl, bufnr)
                end
              end

              local bufnr = vim.api.nvim_get_current_buf()
              local is_nameless_buffer = vim.api.nvim_buf_get_name(bufnr) == '''
              local is_buftype_empty = vim.api.nvim_buf_get_option(bufnr, 'buftype') == '''

              if #filtered_bl > 0 and is_nameless_buffer and is_buftype_empty then
                vim.cmd.Startify()
              end
            end,
          })
        end

        -- Open nvim-tree automatically
        autocmd('User', {
          group = myCommandGroup,
          nested = true,
          pattern = 'StartifyBufferOpened',
          callback = function(ev)
            local nvim_tree = require('nvim-tree.api')
            if not nvim_tree.tree.is_visible() then
              nvim_tree.tree.open()
              -- Unfocus
              vim.cmd('noautocmd wincmd p')
            end
          end,
        })

        -- Automatically close when its last buffer/window
        autocmd('QuitPre', {
          group = myCommandGroup,
          callback = function()
            local tree_wins = {}
            local floating_wins = {}
            local wins = vim.api.nvim_list_wins()
            for _, w in ipairs(wins) do
              local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
              if bufname:match('NvimTree_') ~= nil then
                table.insert(tree_wins, w)
              end
              if vim.api.nvim_win_get_config(w).relative ~= ''' then
                table.insert(floating_wins, w)
              end
            end
            -- If only one window with only nvim-tree then quit
            if 1 == #wins - #floating_wins - #tree_wins then
              for _, w in ipairs(tree_wins) do
                vim.api.nvim_win_close(w, true)
              end
            end
          end,
        })
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
    # Breadcrumbs (fil d'Ariane) for the winbar
    nvim-navic
    {
      # Statusline + winbar (at the moment)
      plugin = lualine-nvim;
      type = "lua";
      config = ''
        local colors = require('base16-colorscheme').colors
        require('lualine').setup {
          options = {
            theme = 'base16',
            globalstatus = true,
            disabled_filetypes = {
              statusline = {'startify'},
            },
            ignore_focus = default_excluded_filetypes,
          },
          sections = {
            lualine_a = { 'mode', },
            lualine_b = { 'branch', 'diagnostics', 'filename', },
            lualine_c = {
              {'searchcount', color = { fg = colors.base0A }, }
            },
            lualine_x = { },
            lualine_y = { 'encoding', 'fileformat', 'filetype', },
          },
          inactive_sections = {
            lualine_b = { 'diff', },
            lualine_y = { 'progress', },
          },
          winbar = {
            lualine_c = {
              {'navic', draw_empty = true, color_correction = 'dynamic', navic_opts = nil},
            },
          },
          extensions = { 'trouble', 'quickfix', 'man' },
        }
      '';
    }

    # Tab-bar
    {
      plugin = tabby-nvim;
      type = "lua";
      config = ''
        require('tabby.tabline').use_preset('active_wins_at_tail', {
          nerdfont = true,
          tab_name = {
            -- name_fallback = function(tabid)
            --   return 'Fallback name'
            -- end,
          },
          buf_name = {
            mode = 'shorten',
          },
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
        bind('n', '<leader>wz', function() twilight.toggle() end, 'Toggle presentation mode')
      '';
    }


    # Neovide specific settings
    {
      plugin = config.lib.dummyPackage;
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
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.10
          end, opts, 'Increase font size')
          bind('n', '<C-ScrollWheelDown', function()
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.10
          end, opts, 'Decrease font size')
        end
      '';
    }
    ]
  ];
}
