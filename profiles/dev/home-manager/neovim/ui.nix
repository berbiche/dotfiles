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
    {
      plugin = barbar-nvim;
      type = "lua";
      optional = true;
      config = lib.mkIf false ''
        -- Only used for the buffer functions it provides
        vim.g.barbar_auto_setup = false

        local opts = {silent = true}
        for i=1,9 do
          bind('n', '<A-' .. i .. '>', '<cmd>BufferGoto ' .. i .. '<CR>', opts, 'Focus buffer ' .. i)
        end
        bind('n', '<A-0>', '<cmd>BufferLast<CR>', opts, 'Focus last buffer')
        bind('n', '<leader>bd', ':BufferClose<CR>', opts, 'Close buffer')
        bind('n', '<leader>bO', '<cmd>BufferCloseAllButCurrent<CR>', opts, 'Close other buffers')
      '';
    }
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
        -- for i=1,9 do
        --   bind('n', '<A-' .. i .. '>', '<cmd>BufferGoto ' .. i .. '<CR>', opts, 'Focus buffer ' .. i)
        -- end
        bind('n', '<leader>bd', delete_current_buffer, opts, 'Close buffer')
        bind('n', '<leader>bD', function() delete_current_buffer(true) end, opts, 'Wipeout buffer')
        bind('n', '<leader>bo', delete_other_buffers, opts, 'Close other buffers')
        bind('n', '<leader>bO', function() delete_other_buffers(true) end, opts, 'Wipeout other buffers')
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

        local function open_tree(find_file)
          local cwd = require('neogit').get_repo().state.git_root or '''
          local opts = { focus = false }
          if cwd ~= ''' then
            opts['path'] = cwd
            opts['update_root'] = true
          end
          if find_file then
            opts = vim.tbl_extend('force', opts, { open = true, })
            api.tree.find_file(opts)
          else
            api.tree.toggle(opts)
          end
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
            update_root = false,
            ignore_list = {'startify', 'dashboard', },
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

        bind('n', '<leader>op', function() open_tree(false) end, opts, 'Open file tree')
        bind('n', '<leader>oP', function() open_tree(true) end, opts, 'Focus current file in file tree')
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
        bind('n', '<leader>wz', twilight.toggle, 'Toggle presentation mode')
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
