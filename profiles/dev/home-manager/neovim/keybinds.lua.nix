{ ... }: ''
local wk = require('which-key')
local mbuf = require('bufdelete')
local ts = require('telescope')
local builtins = require('telescope.builtin')
local themes = require('telescope.themes')

local function wrap(fun, ...)
  return function()
    fun(unpack(arg))
  end
end

local silent = {silent = true}

wk.setup {
  marks = true,
  registers = true,
  spelling = { enabled = false, },
  replace = {
    key = {
      {'<space>', 'SPC'},
      {'<leader>', 'SPC'},
    },
  },
  disable = {
    filetypes = {'neo-tree',},
  },
  -- triggers = {},
  delay = function(ctx)
    return ctx.plugin and 0 or 200
  end,
  -- triggers_nowait = {
  --   -- marks
  --   --'`',
  --   --"'",
  --   --'g`',
  --   --"g'",
  --   -- registers
  --   '"',
  --   '<c-r>',
  --   -- spelling
  --   'z=',
  -- },
  win = {
    border = 'rounded'
  },
}
wk.add({
  {'<leader>',  group = '+leader'},
  {'"<leader>', group = '+marks'},
  {'<leader>b', group = '+buffer'},
  {'<leader>d', group = '+diagnostics'},
  {'<leader>f', group = '+file'},
  {'<leader>g', group = '+git'},
  {'<leader>l', group = '+lsp'},
  {'<leader>o', group = '+open'},
  {'<leader>p', group = '+project'},
  {'<leader>q', group = '+session'},
  {'<leader>s', group = '+search'},
  {'<leader>t', group = '+tabs'},
  {'<leader>w', group = '+window'},
})

-- Remove Ex mode keybind
bind('n', 'Q', ''')
bind('c', '<M-Q>', ''')
bind('c', '<M-q>', ''')

-- Keep selection after indenting in Visual mode
bind('v', '<', '<gv')
bind('v', '>', '>gv')

-- Smart indentation
bind('i', '<Tab>', wrap(require('intellitab').indent), 'Indent')

bind('n', '[o', 'O<Esc>j', 'Insert line above')
bind('n', ']o', 'o<Esc>k', 'Insert line below')
bind('n', 'Y', 'y$', 'Copy till EOL')

bind('n', 'gp',
  [['`['.strpart(getregtype(), 0, 1).'`]']],
  { expr = true, },
  'Select pasted text'
)

-- Buffer management
bind('n', '<leader>bn', '<cmd>bnext<CR>', 'Next buffer')
bind('n', '<leader>bp', '<cmd>bprevious<CR>', 'Previous buffer')
bind('n', '<leader>bN', '<cmd>enew<CR>', 'New buffer')
-- Session management
bind('n', '<leader>qq', '<cmd>quitall<CR>', 'Quit neovim')
bind('n', '<leader>qQ', '<cmd>quitall!<CR>', 'Forcefully quit neovim')

-- Move line below/above
bind('n', '<M-j>', ':m .+1<CR>==', 'Move line below')
bind('n', '<M-k>', ':m .-2<CR>', 'Move line above')
bind('i', '<M-j>', '<Esc>:m .+1<CR>==gi', 'Move line below')
bind('i', '<M-k>', '<Esc>:m .-2<CR>==gi', 'Move line above')
bind('v', '<M-j>', [[:m '>+1<CR>gv=gv]], 'Move line below')
bind('v', '<M-k>', [[:m '<-2<CR>gv=gv]], 'Move line above')

-- Command mode mappings
bind('c', '<C-a>', '<Home>', 'Go to beginning of line')
bind('c', '<C-e>', '<End>', 'Go to end of line')
bind('c', '<M-BS>', '<C-w>', 'Delete word')
-- I asked ChatGPT why I need to use -2 and it believes it's because <C-k>
-- is silently/invisibly inserted
-- Deletes from char until the end of the line
bind('c', '<C-k>', [[<C-\>egetcmdline()[:getcmdpos() - 2]<cr>]], 'Delete till end of line')

-- Fix terminal escape char
bind('t', '<Esc>', [[<C-\><C-n>]])
bind('n', '<leader>ot', function()
  cmd[[botright split]]
  cmd.resize(-10)
  cmd.terminal()
end, silent, 'Open terminal')


-- Searching and replacing stuff
bind({'n', 'v'}, '<leader>sh', wrap(require('searchbox').replace), 'Replace word')
bind('x', '<leader>sh', wrap(require('searchbox').replace, {visual_mode = true}), 'Replace word')


-- Terminal
bind('n', '<space>of', function()
  local fterm = require('FTerm')
  fterm.setup {
    border = 'rounded',
  }
  fterm.toggle()
end, silent, 'Open floating terminal')

-- Open Neogit
bind('n', '<leader>gg', wrap(require('neogit').open), silent, 'Open neogit')

-- Trouble
wk.add({
  {'dx', '<cmd>Trouble<cr>', desc = 'Trouble'},
  {'dw', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics'},
  {'db', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics'},
  {'dl', '<cmd>Trouble loclist toggle<cr>', desc = 'Loclist'},
  {'dq', '<cmd>Trouble quickfix toggle<cr>', desc = 'Quickfix'},
  {'ds', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols'},
}, {
  mode = 'n',
  prefix = '<leader>',
})


-- Nvim-tree
local function open_tree(find_file)
  local api = require('nvim-tree.api')
  local cwd = require('neogit.lib.git.repository').git_root or '''
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
bind('n', '<leader>op', wrap(open_tree, false), silent, 'Open file tree')
bind('n', '<leader>oP', wrap(open_tree, true), silent, 'Focus current file in file tree')

-- Require
bind('n', '<leader>wz', function() require('twilight').toggle() end, 'Toggle presentation mode')


-- Save the current session with startify's commands
-- TODO: use a better session management plugin
bind('n', '<leader>qS', '<cmd>SSave<cr>', 'Save the current session')
-- Load a session
bind('n', '<leader>qL', '<cmd>SLoad<cr>', 'Load a previous session')




-- Buffer management
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

wk.add({
  {'bd', wrap(delete_current_buffer), desc = 'Close buffer'},
  {'bD', wrap(delete_current_buffer, true), desc = 'Wipeout buffer'},
  {'bo', wrap(delete_other_buffers), desc = 'Close other buffers'},
  {'bO', wrap(delete_other_buffers, true), desc = 'Wipeout other buffers'},
}, {prefix = '<leader>'})

-- Switch to most recently used buffer
local function switch_to_last_buffer()
  local last_buffer = vim.fn.bufnr('#')
  if last_buffer ~= -1 and vim.bo[last_buffer].buflisted then
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
      if vim.bo[buf].buflisted then
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
for _, key in ipairs({';', 'b;'}) do
  bind('n', '<leader>'..key, wrap(switch_to_last_buffer), 'Switch to last buffer')
end


--- Telescope keybinds
bind('n', '<space><space>', wrap(builtins.git_files, { show_untracked = true }),
     silent, 'Find file in project')
bind('n', '<leader>.', function()
  local opts = vim.tbl_extend('force', themes.get_ivy(), {
    cwd = vim.fn.expand('%:p:h'),
    select_buffer = true,
    hidden = true
  })
  ts.extensions.file_browser.file_browser(opts)
end, silent, 'Find file in current directory')

for _, v in pairs({',', 'b,', 'bi'}) do
  bind('n', '<leader>'..v, function()
    builtins.buffers(themes.get_ivy({
      -- Scope to "current project"
      cwd = require('neogit.lib.git.repository').git_root or ''',
      -- Theme settings
      layout_config = { height = 10, },
    }))
  end, silent, 'Find buffer')
end

-- List spelling suggestions
bind('n', '<leader>si', wrap(builtins.spell_suggest), silent, 'Show spelling suggestions')
bind('n', 'z=', wrap(builtins.spell_suggest), silent, 'Show spelling suggestions')
-- List recent files
bind('n', '<leader>fr', wrap(builtins.oldfiles), silent, 'Find recent files')
bind('n', '<leader>fF', function()
  ts.extensions.frecency.frecency(themes.get_ivy())
end, silent, 'List most opened files')
bind('n', '<leader>pp', function()
  ts.extensions.workspaces.workspaces(themes.get_dropdown())
end, silent, 'List projects')

-- Finding things
bind('n', '<leader>ss', wrap(builtins.current_buffer_fuzzy_find), silent, 'Search in current buffer')
bind('n', '<leader>sp', wrap(builtins.live_grep), silent, 'Search word in current project')

-- List registers
bind('n', '<leader>ir', wrap(builtins.registers), silent, 'List registers')


-- hls-lens
bind('n', 'n',
     [[<cmd>execute('normal! ' . v:count1 . 'n')<CR><cmd>lua require('hlslens').start()<CR>]],
     silent,
     'Search forward')
bind('n', 'N',
     [[<cmd>execute('normal! ' . v:count1 . 'N')<CR><cmd>lua require('hlslens').start()<CR>]],
     silent,
     'Search backward')
bind('n', '*',
     [[*<cmd>lua require('hlslens').start()<CR>]],
     silent,
     'Search word forward')
bind('n', '#',
     [[#<cmd>lua require('hlslens').start()<CR>]],
     silent,
     'Search word backward')
bind('n', 'g*',
     [[g*<cmd>lua require('hlslens').start()<CR>]],
     silent,
     'Search word forward')
bind('n', 'g#',
     [[g#<cmd>lua require('hlslens').start()<CR>]],
     silent,
     'Search word backward')

bind('n', '<C-l>', ':nohlsearch<CR>', silent, 'Disable search highlighting')


-- Tabs
bind('n', '<leader>tn', ':tabnext<CR>', silent, 'Next tab')
bind('n', '<leader>tp', ':tabprevious<CR>', silent, 'Previous tab')
bind('n', '<leader>tk', ':tabclose<CR>', silent, 'Kill tab')
''
