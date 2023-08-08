{ config, lib, pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    # Show key completion
    {
      plugin = vim-startuptime;
      type = "lua";
      # Use the wrapped neovim to measure startup time
      config = "vim.g.startuptime_exe_path = [[${config.home.profileDirectory}/bin/nvim]]";
    }

    # Sensible default vim/nvim options
    vim-sensible

    # Allows repeating most commands with '.' correctly
    vim-repeat
    {
      # Allows repeating motions with ',' and ';'
      plugin = nvim-next;
      type = "lua";
      config = ''
        local nvim_next_builtins = require('nvim-next.builtins')
        require('nvim-next').setup {
          default_mappings = {
            repeat_style = 'directional',
          },
          items = {
            nvim_next_builtins.f,
            nvim_next_builtins.t,
          }
        }
      '';
    }

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

    # Indent using tabs or spaces based on the content of the file
    vim-sleuth
    # Indent object based on indentation level
    vim-indent-object
    {
      # Indent line to surrounding indentation
      plugin = intellitab-nvim;
      type = "lua";
      config = ''
        bind('i', '<Tab>', function() require('intellitab').indent() end, 'Indent')
      '';
    }

    {
      # Highlight TODO:, FIXME, HACK etc.
      plugin = todo-comments-nvim;
      type = "lua";
      config = ''
        require('todo-comments').setup {}
      '';
    }
    {
      # Automatically close pairs of symbols like {}, [], (), "", etc.
      plugin = nvim-autopairs;
      type = "lua";
      config = ''
        require('nvim-autopairs').setup {
          check_ts = true,
          disable_filetype = default_excluded_filetypes,
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
        -- require('leap').add_repeat_mappings(';', ',', {
        --   relative_directions = true,
        --   modes = {'n', 'x', 'o'}
        -- })
      '';
    }
    {
      plugin = searchbox-nvim;
      type = "lua";
      config = ''
        bind({'n', 'v'}, '<leader>sh', function() require('searchbox').replace() end, 'Replace word')
        bind('x', '<leader>sh', function() require('searchbox').replace({visual_mode = true}) end, 'Replace word')
      '';
    }

    # Git
    {
      plugin = diffview-nvim;
      type = "lua";
      config = ''
        require('diffview').setup {
          default_args = {
            DiffviewOpen = { "--imply-local" },
          }
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
            telescope = true,
          },
          sections = {
            recent = {
              folded = false,
            },
          },
        }

        bind('n', '<leader>gg', function() neogit.open() end, {silent = true}, 'Open neogit')
      '';
    }
    {
      plugin = gitsigns-nvim;
      type = "lua";
      config = ''
        local gs = require('gitsigns')
        local move = require('nvim-next.move')
        gs.setup {
          on_attach = function(bufnr)
            local bind = buf_bind(bufnr)

            local prev_hunk = function()
              if vim.wo.diff then return '[c' end
              vim.schedule(function() gs.prev_hunk() end)
              return '<Ignore>'
            end

            local next_hunk = function()
              if vim.wo.diff then return ']c' end
              vim.schedule(function() gs.next_hunk() end)
              return '<Ignore>'
            end

            local prev_hunk_wrapper, next_hunk_wrapper = move.make_repeatable_pair(prev_hunk, next_hunk)

            -- Navigation
            bind('n', '[c', prev_hunk_wrapper, {expr = true}, 'Previous hunk')
            bind('n', ']c', next_hunk_wrapper, {expr = true}, 'Next hunk')

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
      # Automatically disable search highlighting when moving
      plugin = vim-cool;
      # plugin = auto-hlsearch-nvim;
    }
    {
      plugin = nvim-hlslens;
      type = "lua";
      config = ''
        require('hlslens').setup()

        local opts = {silent = true}

        bind('n', 'n',
             [[<cmd>execute('normal! ' . v:count1 . 'n')<CR><cmd>lua require('hlslens').start()<CR>]],
             opts,
             'Search forward')
        bind('n', 'N',
             [[<cmd>execute('normal! ' . v:count1 . 'N')<CR><cmd>lua require('hlslens').start()<CR>]],
             opts,
             'Search backward')
        bind('n', '*',
             [[*<cmd>lua require('hlslens').start()<CR>]],
             opts,
             'Search word forward')
        bind('n', '#',
             [[#<cmd>lua require('hlslens').start()<CR>]],
             opts,
             'Search word backward')
        bind('n', 'g*',
             [[g*<cmd>lua require('hlslens').start()<CR>]],
             opts,
             'Search word forward')
        bind('n', 'g#',
             [[g#<cmd>lua require('hlslens').start()<CR>]],
             opts,
             'Search word backward')

        bind('n', '<C-l>', ':nohlsearch<CR>', opts, 'Disable search highlighting')
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

    # Close buffers/windows/etc.
    vim-sayonara
    {
      plugin = bufdelete-nvim;
      type = "lua";
      config = ''
        local mbuf = require('bufdelete')

        local function delete_other_buffers(wipeout)
          local current_bufnr = vim.api.nvim_get_current_buf()
          local buffer_list = vim.api.nvim_list_bufs()
          table.remove(buffer_list, current_bufnr)
          if wipeout then
            mbuf.wipeout(buffer_list)
          else
            mbuf.bufdelete(buffer_list)
          end
        end

        local function delete_current_buffer(wipeout)
          local bufnr = vim.api.nvim_get_current_buf()
          if wipeout then
            mbuf.wipeout(bufnr)
          else
            mbuf.bufdelete(bufnr)
          end
        end

        local opts = {silent = true}
        bind('n', '<leader>bd', delete_current_buffer, opts, 'Close buffer')
        bind('n', '<leader>bD', function() delete_current_buffer(true) end, opts, 'Wipeout buffer')
        bind('n', '<leader>bo', delete_other_buffers, opts, 'Close other buffers')
        bind('n', '<leader>bO', function() delete_other_buffers(true) end, opts, 'Wipeout other buffers')
      '';
    }
  ]
  ++ lib.optional (config.profiles.dev.wakatime.enable) (config.lib.neovim.lazy {
    plugin = vim-wakatime;
    type = "lua";
    config = ''
      -- WakaTime CLI path
      vim.g.wakatime_OverrideCommandPrefix = [[${pkgs.wakatime}/bin/wakatime]]

      if vim.g.vscode == nil then
        vim.cmd([[packadd vim-wakatime]])
      end
    '';
  });
}
