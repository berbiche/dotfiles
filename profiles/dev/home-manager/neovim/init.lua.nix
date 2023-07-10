{...}:
''

local function bind(mode, l, r, opts, desc)
  if type(opts) == 'string' then
    opts = { desc = opts }
  else
    opts = opts or {}
  end
  if desc then
    opts.desc = desc
  end
  vim.keymap.set(mode, l, r, opts)
end
local autocmd = vim.api.nvim_create_autocmd
local myCommandGroup = vim.api.nvim_create_augroup('init.lua', {})

-- Default settings
vim.opt.compatible = false
vim.opt.backup = false
-- Yup, I live on the edge
vim.opt.swapfile = false

-- Update terminal's titlebar
vim.opt.title = true

-- Use utf-8 by default
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
vim.opt.termencoding = 'utf-8'

-- For CursorHold autocommand, required by which-key
vim.opt.updatetime = 100

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Use visual bell
vim.opt.visualbell = true

-- Basics
vim.cmd.syntax('on')

if vim.fn.has('termguicolors') == 1 then
  vim.opt.termguicolors = true
end

-- Extra config

vim.opt.hidden = true
vim.opt.hlsearch = true
vim.opt.smartcase = true
vim.cmd([[filetype plugin on]])
vim.opt.listchars = [[tab:>-,trail:*]]

-- Indentation stuff
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.expandtab = true
-- Reuse indentation from previous line
vim.opt.autoindent = true

-- Show line numbers with relative numbering
vim.opt.number = true
vim.opt.relativenumber = true

-- Always show 5 lines of context when scrolling (e.g. with <C-e> or <C-y>)
vim.opt.scrolloff = 5

-- Do not redraw the screen while executing a macro
vim.opt.lazyredraw = true

-- Split below first, then right
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Enable mouse usage except in insert mode
vim.opt.mouse = 'nv'

-- Highlight line with cursor
vim.opt.cursorline = true

-- Wrapping stuff
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = [[↳ ]]

--[[
j: Remove comment leader when joining lines
q: Allow formatting of comments with gq
t: Auto-wrap text: Vim will automatically wrap text when you exceed the textwidth limit
--]]
vim.opt.formatoptions = { j = true, q = true, t = true, }

-- Completion in menu
vim.opt.wildmenu = true
vim.opt.wildmode = 'longest:full,full'
vim.opt.wildignorecase = true

-- Hide the statusline because I use a plugin
vim.opt.showmode = false

-- Live substitution
vim.opt.incsearch = true
vim.opt.inccommand = 'nosplit'

-- Don't pass messages to |ins-completion-menu|
-- Hide "search hit TOP, ..."
vim.opt.shortmess:append({c = true, s = true, q = false,})


-----------------------------------------------
autocmd({'TextYankPost'}, {
  group = myCommandGroup,
  callback = function() vim.highlight.on_yank() end,
  desc = 'Briefly highlight yanked text'
})

-- Git commit messages configuration
autocmd({'FileType'}, {
  group = myCommandGroup,
  pattern = 'gitcommit',
  callback = function()
    vim.opt_local.textwidth = 68
    vim.opt_local.colorcolumn = '69'
    vim.opt_local.spell = true
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
  pattern = {'help', 'checkhealth', 'qf', 'man'},
  callback = function()
    bind({'n', 'v', 's', 'o'}, 'q', '<cmd>Sayonara<cr>', { buffer = true, silent = true }, 'Close buffer')
  end,
})

-- Set ft for erlang
vim.filetype.add({
  filename = {
    ['rebar.config'] = 'erlang',
  },
})

-- Magit-like keybinds to save a commit msg
autocmd({'BufEnter'}, {
  group = myCommandGroup,
  pattern = {'COMMIT_EDITMSG'},
  callback = function()
    bind({'n', 'i'}, '<c-c><c-c>', '<esc><cmd>wq<cr>', {buffer = true}, 'Commit')
    bind({'n', 'i'}, '<c-c><c-k>', '<esc><cmd>q!<cr>', {buffer = true}, 'Abort')
  end,
})

----- Keymaps

-- Remove Ex mode keybind
bind('n', 'Q', ''')

-- Keep selection after indenting in Visual mode
bind('v', '<', '<gv')
bind('v', '>', '>gv')

bind('n', '[o', 'O<Esc>j', 'Insert line above')
bind('n', ']o', 'o<Esc>k', 'Insert line below')
bind('n', 'Y', 'y$', 'Copy till EOL')
bind('n', 'gp', [['`['.strpart(getregtype(), 0, 1).'`]']],
  { expr = true, },
  'Select pasted text'
)
-- Buffer management
autocmd({'VimEnter'}, {
  callback = function()
    bind({'n', 'v'}, '<leader>b', ''', {buffer = true})
  end,
})
bind('n', '<leader>bd', ':BufferClose<CR>', {silent = true}, 'Close buffer')
bind('n', '<leader>bn', ':bnext<CR>', 'Next buffer')
bind('n', '<leader>bp', ':bprevious<CR>', 'Previous buffer')
bind('n', '<leader>bN', ':enew<CR>', 'New buffer')
-- Window management
bind('n', '<leader>w', '<C-w>', '+window')
bind('n', '<leader>qq', '<cmd>quitall<CR>', 'Quit neovim')
bind('n', '<leader>qQ', '<cmd>quitall!<CR>', 'Forcefully quit neovim')

-- Move line below/above
bind('n', '<A-j>', ':m .+1<CR>==', 'Move line below')
bind('n', '<A-k>', ':m .-2<CR>', 'Move line above')
bind('i', '<A-j>', '<Esc>:m .+1<CR>==gi', 'Move line below')
bind('i', '<A-k>', '<Esc>:m .-2<CR>==gi', 'Move line above')
bind('v', '<A-j>', [[:m '>+1<CR>gv=gv]], 'Move line below')
bind('v', '<A-k>', [[:m '<-2<CR>gv=gv]], 'Move line above')

-- Command mode mappings
bind('c', '<C-a>', '<Home>', 'Go to beginning of line')
bind('c', '<C-e>', '<End>', 'Go to end of line')
bind('c', '<M-BS>', '<C-w>', 'Delete word')
-- I asked ChatGPT why I need to use -2 and it believes it's because <C-k>
-- is silently/invisibly inserted
-- Deletes from char until the end of the line
bind('c', '<C-k>', [[<C-\>egetcmdline()[:getcmdpos() - 2]<cr>]], 'Delete till end of line')

-- Highlight trailing whitespace
-- g:terminal_color_1 is defined by poimandres-nvim
vim.cmd([[
  execute 'highlight TrailingWhitespace guibg=' . g:terminal_color_1
  match TrailingWhitespace /\s\+$/
]])

-- Fix terminal escape char
bind('t', '<Esc>', [[<C-\><C-n>]])
bind('n', '<leader>ot', function()
  vim.cmd.botright('split')
  vim.cmd.resize(-10)
  vim.cmd.terminal()
end, {silent = true}, 'Open terminal')

-- Switch to most recently used buffer
local function switch_to_last_buffer()
  local last_buffer = vim.fn.bufnr('#')
  if last_buffer ~= -1 and vim.fn.buflisted(last_buffer) == 1 then
    vim.cmd.buffer(last_buffer)
  else
    -- If no last accessed buffer or it is unloaded, find the most recently used open buffer
    local buffer_list = vim.api.nvim_list_bufs()
    local most_recent_buffer = nil
    local most_recent_time = 0

    if #buffer_list > 1 then
      table.remove(buffer_list, vim.api.nvim_get_current_buf())
    end

    for _, buf in ipairs(buffer_list) do
      if vim.fn.buflisted(buf) == 1 then
        local lastused = vim.fn.getbufinfo(buf).lastused or 0
        if lastused > most_recent_time then
          most_recent_buffer = buf
          most_recent_time = timestamp
        end
      end
    end

    if most_recent_buffer then
      vim.cmd.buffer(most_recent_buffer)
    end
  end
end
for _, key in pairs({'`', 'b`'}) do
  bind('n', '<leader>'..key, switch_to_last_buffer, 'Switch to last buffer')
end
''
