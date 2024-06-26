{ lib, pkgs, ... }: ''

-- Export proper path to sqlite cli for sqlite-lua
vim.g.sqlite_clib_path = [[${lib.getLib pkgs.sqlite}/lib/libsqlite3${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}]]

-- Disable netrw before any other settings
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- I use vim-matchup
vim.g.loaded_matchit = 1

-- Default settings
vim.opt.compatible = false
vim.opt.backup = false
-- Yup, I live on the edge
vim.opt.swapfile = false

-- Update terminal's titlebar
vim.opt.title = true
-- Display tabline at all time
vim.opt.showtabline = 2
-- Hide command line under statusline
vim.opt.cmdheight = 0

-- Use utf-8 by default
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
--vim.opt.termencoding = 'utf-8'

-- For CursorHold autocommand, required by which-key
vim.opt.updatetime = 100

vim.g.mapleader = ' '
-- vim.g.maplocalleader = ','

-- Use visual bell
vim.opt.visualbell = true

-- Basics
vim.opt.termguicolors = true

-- Extra config

vim.opt.hidden = true
vim.opt.hlsearch = true
vim.opt.smartcase = true
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


----------
-- Colorscheme
vim.g.colors_name = 'base16-tomorrow-night-eighties'
require('base16-colorscheme').setup('tomorrow-night-eighties', {
  telescope_borders = true,
})

''

