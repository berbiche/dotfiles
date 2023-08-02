{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [
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
  ];
}
