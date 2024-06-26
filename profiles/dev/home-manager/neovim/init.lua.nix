{ config, ... }: ''
-- Compile everything to start faster
vim.loader.enable()

function bind(mode, l, r, opts, desc, bufnr)
  if type(opts) == 'string' then
    opts = { desc = opts }
  else
    opts = opts or {}
  end
  if desc then
    opts.desc = desc
  end
  if buffer then
    opts.buffer = bufnr
  end
  vim.keymap.set(mode, l, r, opts)
end
function buf_bind(bufnr)
  return function(mode, l, r, opts, desc)
    bind(mode, l, r, opts, desc, bufnr)
  end
end

-- Globals
cmd = vim.cmd
autocmd = vim.api.nvim_create_autocmd
myCommandGroup = vim.api.nvim_create_augroup('init.lua', {clear = true})

default_excluded_filetypes = { 'TelescopePrompt', 'NvimTree', 'startify', 'terminal', 'Trouble', 'qf', 'FTerm', 'neo-tree' }

-- Use the wrapped neovim to measure startup time
vim.g.startuptime_exe_path = [[${config.home.profileDirectory}/bin/nvim]]

require('user.settings')
require('user.telescope')
require('user.filetree')
require('user.dashboard')
require('user.lsp')
require('user.cmp')
require('user.keybinds')
require('user.neovide')

-- Enable filetypes plugin and syntax
cmd([[filetype plugin on]])

-----------------------------------------------
-- Disable unnecessary mouse popup entry
cmd([[aunmenu PopUp.How-to\ disable\ mouse]])
cmd([[aunmenu PopUp.-1-]])

autocmd({'TextYankPost'}, {
  group = myCommandGroup,
  callback = function() vim.highlight.on_yank({higroup = 'Visual', timeout = 300}) end,
  desc = 'Briefly highlight yanked text',
})

-- Git commit messages configuration
autocmd({'FileType'}, {
  group = myCommandGroup,
  pattern = {'gitcommit', 'NeogitCommitMessage'},
  callback = function(ev)
    vim.opt_local.textwidth = 68
    vim.opt_local.colorcolumn = '69'
    vim.opt_local.spell = true
    -- Magit-like keybinds to save a commit msg
    bind({'n', 'i'}, '<c-c><c-c>', '<esc><cmd>wq<cr>', {buffer = ev.buf}, 'Commit')
    bind({'n', 'i'}, '<c-c><c-k>', '<esc><cmd>q!<cr>', {buffer = ev.buf}, 'Abort')
  end,
})

-- Set the right commentstring type for json5 files
autocmd({'FileType'}, {
  group = myCommandGroup,
  pattern = 'json5',
  callback = function()
    vim.opt_local.commentstring = '// %s'
  end,
})

-- Check if file has changed on buffer focus
autocmd({'FocusGained'}, {
  group = myCommandGroup,
  command = 'silent! :checktime'
})

-- Close certain buffer types with only 'q'
autocmd({'FileType'}, {
  group = myCommandGroup,
  pattern = {'help', 'checkhealth', 'qf', 'man', 'startuptime'},
  callback = function(ev)
    bind({'n', 'v', 's', 'o'}, 'q', '<cmd>Sayonara<cr>', { buffer = ev.buf, silent = true }, 'Close buffer')
  end,
})

-- Show absolute line numbers in the terminal
autocmd({'TermOpen'}, {
  group = myCommandGroup,
  callback = function()
    vim.opt_local.number = true
    vim.opt_local.relativenumber = false
  end,
})

-- Highlight trailing whitespace
-- g:terminal_color_1 is defined by poimandres-nvim aaaaaaaaaaaaaaaaa
cmd([[
  execute 'highlight TrailingWhitespace guibg=' . g:terminal_color_1
  match TrailingWhitespace /\s\+$/
]])

-- Hide EndOfBuffer mark
-- vim.opt.fillchars = { eob = '~' }
vim.api.nvim_set_hl(0, 'EndOfBuffer', {fg = 'bg'})

-- Language specific settings
vim.g.zig_fmt_autosave = 0

-- cmd.syntax('on')
vim.filetype.add({
  filename = {
    -- Set ft for erlang's rebar config file
    ['rebar.config'] = 'erlang',
  },
  extension = {
    nix = 'nix',
    avsc = 'json',
  },
  pattern = {
    ['.*'] = {
      priority = -math.huge,
      (function()
        local regex = vim.regex([[^#!.*escript]])
        return function(path, bufnr, ext)
          -- Match against shebang
          local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)
          -- TODO: handle nix-shell wrappers
          if s ~= nil and regex:match_str(content) then
            return 'erlang'
          end
        end
      end)(),
    },
  },
})

require('trouble').setup{}

require('Comment').setup{}

require('hlslens').setup{}

require('FTerm').setup {
}
''

