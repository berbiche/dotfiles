{...}:
''

local bind = vim.keymap.set
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
vim.opt.expandtab = true
-- Reuse indentation from previous line
vim.opt.autoindent = true

-- Show relative numbering for line number
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
vim.opt.wildmode = 'longest:full,full'
vim.opt.wildignorecase = true

-- Hide the statusline because I use a plugin
vim.opt.showmode = false

-- Live substitution
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
  pattern = {'help', 'checkhealth', 'qf'},
  callback = function()
    bind({'n', 'v', 's', 'o'}, 'q', '<cmd>close<cr>', { buffer = true, silent = true, })
  end,
})

-- Set ft for erlang
vim.filetype.add({
  filename = {
    ['rebar.config'] = 'erlang',
  },
})
-- autocmd({'BufRead', 'BufNewFile'}, {
--   group = myCommandGroup,
--   pattern = '*/rebar.config',
--   command = 'setfiletype erlang',
-- })


----- Keymaps

-- Remove Ex mode keybind
bind('n', 'Q', ''', {})

-- Keep selection after indenting in Visual mode
bind('v', '<', '<gv', {})
bind('v', '>', '>gv', {})

bind('n', '[o', 'O<Esc>j', {desc = 'Insert line above'})
bind('n', ']o', 'o<Esc>k', {desc = 'Insert line below'})
bind('n', 'Y', 'y$', {desc = 'Copy till EOL'})
bind('n', 'gp', [['`['.strpart(getregtype(), 0, 1).'`]']], {
  expr = true,
  desc = 'Selected pasted text',
})
-- Buffer management
autocmd({'VimEnter'}, {
  callback = function()
    bind({'n', 'v'}, '<leader>b', ''', {buffer = true})
  end,
})
bind('n', '<leader>bd', ':BufferClose<CR>', {silent = true, desc = 'Close buffer'})
bind('n', '<leader>bn', ':bnext<CR>', {desc = 'Next buffer'})
bind('n', '<leader>bp', ':bprevious<CR>', {desc = 'Previous buffer'})
bind('n', '<leader>bN', ':enew<CR>', {desc = 'New buffer'})
-- Window management
bind(''', '<leader>w', '<C-w>', {})
bind('n', '<leader>qq', '<cmd>quitall<CR>', {desc = 'Quit neovim'})

-- Move line below/above
bind('n', '<A-j>', ':m .+1<CR>==', {desc = 'Move line below'})
bind('n', '<A-k>', ':m .-2<CR>', {desc = 'Move line above'})
bind('i', '<A-j>', '<Esc>:m .+1<CR>==gi', {desc = 'Move line below'})
bind('i', '<A-k>', '<Esc>:m .-2<CR>==gi', {desc = 'Move line above'})
bind('v', '<A-j>', [[:m '>+1<CR>gv=gv]], {desc = 'Move line below'})
bind('v', '<A-k>', [[:m '<-2<CR>gv=gv]], {desc = 'Move line above'})

-- Command mode mappings
bind('c', '<C-a>', '<Home>', {desc = 'Go to beginning of line'})
bind('c', '<C-e>', '<End>', {desc = 'Go to end of line'})
bind('c', '<M-BS>', '<C-w>', {desc = 'Delete word'})
-- I asked ChatGPT why I need to use -2 and it believes it's because <C-k>
-- is silently/invisibly inserted
-- Deletes from char until the end of the line
bind('c', '<C-k>', [[<C-\>egetcmdline()[:getcmdpos() - 2]<cr>]], {desc = 'Delete till end of line'})

-- Highlight trailing whitespace
vim.cmd([[
  highlight TrailingWhitespace ctermbg=red guibg=red
  match TrailingWhitespace /\s\+$/
]])

-- Fix terminal escape char
bind('t', '<Esc>', [[<C-\><C-n>]], {})
bind('n', '<leader>ot', function()
  vim.cmd.botright('split')
  vim.cmd.resize(-10)
  vim.cmd.terminal()
end, {silent = true, desc = 'Open terminal'})
''
