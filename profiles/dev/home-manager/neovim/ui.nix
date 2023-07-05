moduleArgs@{ config, lib, pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [
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


    ### THEMES ###
    gruvbox-nvim
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
    # {
    #   # Peek lines when typing :30 for instance
    #   plugin = numb-nvim;
    #   type = "lua";
    #   config = ''
    #     require('numb').setup()
    #   '';
    # }

    {
      # Show key completion
      plugin = which-key-nvim;
      type = "lua";
      config = ''
        require('which-key').setup { }
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
            -- theme = 'sonokai',
            theme = 'poimandres',
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

        local bind = vim.keymap.set
        local opts = {silent = true}

        for i=1,9 do
          bind('n', '<A-' .. i .. '>', '<cmd>BufferGoto ' .. i .. '<CR>', opts)
        end
        bind('n', '<A-0>', '<cmd>BufferLast<CR>', opts)

        bind('n', '<leader>bO', '<cmd>BufferCloseAllButCurrent<CR>', opts)
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
          exclude_filetypes = { "TelescopePrompt", "NvimTree", "startify", "terminal", "coc-explorer" },
        })
        vim.api.nvim_create_autocmd({
          "WinResized",
          "BufWinEnter",
          "CursorHold",
          "InsertLeave",
          "BufModifiedSet",
        }, {
          group = vim.api.nvim_create_augroup("barbecue.updater", {}),
          callback = function()
            require("barbecue.ui").update()
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

        local bind = vim.keymap.set
        local opts = { noremap = true, silent = true }

        bind('n', '<leader>op', require('nvim-tree.api').tree.toggle, opts)

        -- Since the auto_close option has been removed, this is the only option
        vim.api.nvim_create_autocmd("BufEnter", {
          nested = true,
          callback = function()
            if #vim.api.nvim_list_wins() == 1 and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil then
              vim.cmd("quit")
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


    # Neovide specific settings
    {
      plugin = pkgs.runCommandLocal "dummy" { } "mkdir $out";
      type = "lua";
      config = ''
        if vim.g.neovide then

          vim.o.guifont = "Source Code Pro:h14"
          vim.g.neovide_input_use_logo = false
          vim.g.neovide_input_macos_alt_is_meta = true
          vim.g.neovide_cursor_animation_length = 0

          vim.g.neovide_scale_factor = 1.0


          -- Keybinds
          local bind = vim.keymap.set
          local opts = { silent = true, }

          bind('n', '<C-ScrollWheelUp', function()
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.25
          end, opts)
          bind('n', '<C-ScrollWheelDown', function()
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.25
          end, opts)
        end
      '';
    }
  ];
}
