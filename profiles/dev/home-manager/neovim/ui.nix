{ config, lib, pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    ### THEMES ###
    base16-nvim

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
        local notify = require('notify')
        notify.setup({
          stages = 'fade',
          render = 'minimal',
          background_colour = '#000000',
        })

        vim.notify = notify
      '';
    }



    {
      # Displays vertical line for the indentation level (indent guides)
      plugin = indent-blankline-nvim;
      type = "lua";
      config = ''
        require('ibl').setup {
          scope = {
            enabled = false,
          },
          exclude = {
            filetypes = default_excluded_filetypes,
            buftypes = {'terminal', 'prompt'},
          },
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

    # Show keymaps when pressing <leader> after a small delay
    which-key-nvim

    # Start screen
    vim-startify

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

    # Display LSP server messages as virtual text in bottom
    fidget-nvim

    # Breadcrumbs (fil d'Ariane) for the winbar
    nvim-navic
    {
      # Statusline + winbar (at the moment)
      plugin = lualine-nvim;
      type = "lua";
      config = ''
        local colors = require('base16-colorscheme').colors
        local ignored_fts = vim.tbl_flatten(default_excluded_filetypes)
        table.insert(ignored_fts, 'Glance')

        require('lualine').setup {
          options = {
            theme = 'base16',
            globalstatus = true,
            disabled_filetypes = {
              statusline = {'startify'},
            },
            ignore_focus = ignored_fts,
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

    {
      # Tab-bar
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

    nvim-tree-lua

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
      '';
    }

    {
      # Like emacs' magit
      plugin = neogit;
      type = "lua";
      config = ''
        require('neogit').setup {
          use_magit_keybindings = true,
          auto_show_console = false,
          console_timeout = 5000,
          disable_commit_confirmation = true,
          disable_insert_on_commit = false,
          integrations = {
            diffview = true,
            telescope = true,
          },
          sections = {
            recent = {
              folded = false,
            },
          },
        }
      '';
    }
    {
      plugin = gitsigns-nvim;
      type = "lua";
      config = ''
        local gs = require('gitsigns')
        local move = require('nvim-next.move')
        local nngs = require('nvim-next.integrations').gitsigns(gs)
        gs.setup {
          on_attach = function(bufnr)
            local bind = buf_bind(bufnr)

            local prev_hunk = function()
              if vim.wo.diff then return '[c' end
              vim.schedule(function() nngs.prev_hunk() end)
              return '<Ignore>'
            end

            local next_hunk = function()
              if vim.wo.diff then return ']c' end
              vim.schedule(function() nngs.next_hunk() end)
              return '<Ignore>'
            end

            -- local prev_hunk_wrapper, next_hunk_wrapper = move.make_repeatable_pair(prev_hunk, next_hunk)

            -- Navigation
            bind('n', '[c', prev_hunk, {expr = true}, 'Previous hunk')
            bind('n', ']c', next_hunk, {expr = true}, 'Next hunk')

            -- Actions
            -- bind('n', '<leader>gb', function() gs.blame_line{full=true} end, 'Blame line')
            bind('n', '<leader>gb', gs.toggle_current_line_blame, 'Toggle blame line')
            bind('n', '<leader>gd', gs.diffthis, 'Diff')
            bind('n', '<leader>gD', function() gs.diffthis('~') end, 'Diff ???')
            bind('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')
            bind('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
            bind('v', '<leader>gr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, 'Reset hunk')
            bind('n', '<leader>gR', gs.reset_buffer, 'Reset buffer')
            bind('n', '<leader>gs', gs.stage_hunk, 'Stage hunk')
            bind('v', '<leader>gs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, 'Stage hunk')
            bind('n', '<leader>gS', gs.stage_buffer, 'Stage buffer')
            bind('n', '<leader>gu', gs.undo_stage_hunk, 'Unstage hunk')
            bind('n', '<leader>gx', gs.toggle_deleted, 'Toggle deleted??')

            -- Text object
            bind({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
          end,
        }
      '';
    }
  ];
}
