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
          disable_filetype = default_excluded_filetypes,
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
        require('diffview').setup { }
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
        gs.setup {
          on_attach = function(bufnr)
            local bind = buf_bind(bufnr)

            -- Navigation
            bind('n', ']c', function()
              if vim.wo.diff then return ']c' end
              vim.schedule(function() gs.next_hunk() end)
              return '<Ignore>'
            end, {expr=true}, 'Next hunk')

            bind('n', '[c', function()
              if vim.wo.diff then return '[c' end
              vim.schedule(function() gs.prev_hunk() end)
              return '<Ignore>'
            end, {expr=true}, 'Previous hunk')

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
