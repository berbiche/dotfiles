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
        local pa = require('plenary.async')
        local api = require('nvim-tree.api')

        local path_separator = package.config:sub(1, 1)

        local function path_add_trailing(path)
          if path:sub(-1) == path_separator then
            return path
          else
            return path .. path_separator
          end
        end

        local function get_containing_folder(node)
          if node.nodes ~= nil then
            return path_add_trailing(node.absolute_path)
          else
            return node.absolute_path:sub(0, -#(node.name or ''') - 1)
          end
        end

        local function make_file(new_file)
          if new_file == nil or #new_file < 1 then
            return
          end

          new_file = path_add_trailing(new_file)

          local err, _ = pa.uv.fs_stat(new_file)
          if err ~= nil then
            -- Directory exists?
            return nil
          end

          -- It could inherit the shell's umask...
          local err, _ = pa.uv.fs_mkdir(new_file, 493) -- 0o755
          if err ~= nil then
            return err
          end
        end

        local function create_directory()
          local node = api.tree.get_node_under_cursor()
          local containing_folder = get_containing_folder()

          -- See :command-completion for options
          local prompt = { prompt = "Create directory ", default = containing_folder, completion = "dir" }
          vim.ui.input(prompt, function(new_file)
            local err = make_file(new_file)
            if err ~= nil then
              vim.schedule(function()
                vim.notify(
                  string.format('Cannot create directory: %s', err),
                  vim.log.levels.WARN,
                  { title = 'NvimTree' }
                )
              end)
            end
          end)
        end

        require('nvim-tree').setup {
          git = {
            enable = true,
            ignore = true,
          },
          live_filter = {
            always_show_folders = false,
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
          -- Uses vim.ui.{input,select}
          select_prompts = true,
          update_focused_file = {
            enable = true,
            ignore_list = {'startify', 'dashboard'},
          },

          -- Attach keybinds
          on_attach = function(bufnr)
            local original_bind = bind
            local function bind(mode, key, fn, desc)
              local opts = {
                buffer = bufnr,
                silent = true,
                nowait = true,
              }
              if fn then
                original_bind(mode, key, fn, opts, desc)
              else
                vim.notify_once(string.format('Unknown binding for key: %s', key), vim.log.levels.WARN)
              end
            end

            -- Don't use default mappings
            -- api.config.mappings.default_on_attach(bufnr)

            -- Custom mappings that resembles treemacs
            bind('n', '?', api.tree.toggle_help, 'Show keybinds')
            bind('n', '<C-?>', api.tree.toggle_help, 'Show keybinds')
            bind('n', 'r', api.fs.reload, 'Reload')
            bind('n', 'q', api.tree.close, 'Close')

            -- Opening
            bind('n', '<2-LeftMouse>', api.node.open.edit, 'Open')
            bind('n', '<CR>', api.node.open.edit, 'Open')
            bind('n', 'l', api.node.open.edit, 'Open')
            -- Select the window in which to open the buffer
            bind('n', 'op', api.node.open.preview, 'Open: preview')
            bind('n', 'os', api.node.open.horizontal, 'Open: horizontal split')
            bind('n', 'ot', api.node.open.tab, 'Open: new tab')
            bind('n', 'ov', api.node.open.vertical, 'Open: vertical split')

            -- Navigation
            bind('n', '<C-n>', 'j', 'Next item')
            bind('n', '<C-p>', 'k', 'Previous item')
            bind('n', 'u', api.node.navigate.parent, 'Go to parent')
            bind('n', 'H', api.tree.change_root_to_parent, 'Change root to parent folder')
            bind('n', '<A-j>', api.node.navigate.sibling.next, 'Next Sibling')
            bind('n', '<A-k>', api.node.navigate.sibling.prev, 'Previous Sibling')

            -- Copying and other operations
            bind('n', 'ya', api.fs.copy.absolute_path, 'Copy absolute path')
            bind('n', 'yf', api.fs.copy.node, 'Copy file')
            bind('n', 'yn', api.fs.copy.filename, 'Copy name')
            bind('n', 'yp', api.fs.copy.relative_path, 'Copy relative path')

            -- Finding things
            bind('n', 'f/', api.live_filter.start, 'Filter')
            bind('n', 'fc', api.live_filter.clear, 'Clean filter')
            bind('n', 'fh', api.tree.toggle_hidden_filter, 'Toggle dotfiles')
            bind('n', 'fi', api.tree.toggle_gitignore_filter, 'Toggle Git ignore')
            bind('n', 'fs', api.tree.search_node, 'Search')

            -- Other useful stuff
            bind('n', '<C-]>', api.tree.change_root_to_node, 'CD')
            bind('n', '<C-k>', api.node.show_info_popup, 'Info')
            -- While the below keybind can also be used to create directories or file,
            -- the cf and cd maps are kept for similarity with treemacs
            bind('n', 'cf', api.fs.create, 'Create file')
            bind('n', 'cd', create_directory, 'Create directory')
            bind('n', 'd', api.fs.remove, 'Delete')
            if vim.fn.has('unix') == 1 then
              -- Uses Gio to trash the file
              bind('n', 'D', api.fs.trash, 'Trash')
            end
            bind('n', 'R', api.fs.rename, 'Rename')
            -- bind('n', 'e', api.fs.rename_basename, 'Rename: basename')
            bind('n', '!', api.node.run.cmd, 'Run command')
            -- bind('n', 's', api.node.run.system, 'Run system')
            bind('n', 't', api.marks.toggle, 'Toggle bookmark')

            bind('n', 'bmv', api.marks.bulk.move, 'Move bookmarked')
            bind('n', 'E', api.tree.expand_all, 'Expand all')
            bind('n', 'W', api.tree.collapse_all, 'Collapse')
            bind('n', ']e', api.node.navigate.diagnostics.next, 'Next diagnostic')
            bind('n', '[e', api.node.navigate.diagnostics.prev, 'Prev diagnostic')
            bind('n', 'J', api.node.navigate.sibling.last, 'Last sibling')
            bind('n', 'K', api.node.navigate.sibling.first, 'First sibling')
            bind('n', 'p', api.fs.paste, 'Paste')
            bind('n', 'x', api.fs.cut, 'Cut')
          end
        }

        local opts = { silent = true }

        bind('n', '<leader>op', api.tree.toggle, opts, 'Open file tree')
        bind('n', '<leader>oP', function()
          api.tree.find_file({ open = true, update_root = false, })
        end, opts, 'Focus current file in file tree')
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
