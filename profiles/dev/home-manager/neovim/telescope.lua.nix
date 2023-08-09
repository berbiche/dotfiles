{ ... }: ''

local ts = require('telescope')
local actions = require('telescope.actions')
local fb_actions = ts.extensions.file_browser.actions
local replacer = require('replacer')
local hastrouble, trouble = pcall(require, 'trouble.providers.telescope')

require('workspaces').setup {
  cd_type = 'tab'
}


-- replacer-nvim
replacer.setup {
  rename_files = false,
  save_on_write = false,
}
autocmd({'FileType'}, {
  group = myCommandGroup,
  pattern = {'qf'},
  callback = function(ev)
    local opts = { silent = true, buffer = ev.buf }
    bind('n', '<C-c>', ''')
    bind('n', '<C-c><C-l>', function() replacer.run() end, opts, 'Occur-mode')
    bind('n', '<C-c><C-c>', function() replacer.save({rename_files = false}) end, opts, 'Save')
    bind('n', '<C-c><C-k>', '<cmd>Sayonara<cr>' , opts, 'Close')
  end,
})


-- TODO: Make smart_send_to_qflist support entering 'occur-mode' (replacer.nvim)
local caca = require('telescope.actions.mt').transform_mod({
  run_replacer = function(prompt_bufnr)
    if vim.fn.getwininfo(vim.api.nvim_get_current_win())[0]['quickfix'] == 1 then
    -- if vim.fn.getqflist({winid = 0}).winid ~= 0 then
      require('replacer').run()
    end
  end,
})

ts.setup {
  defaults = {
    layout_strategy = 'horizontal',
    results_title = false,
    mappings = {
      i = {
        ['<esc>'] = actions.close,
        ['<C-g>'] = actions.close,
        -- ['<C-c>'] = nil,
        ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
        ['<C-e>'] = hastrouble and trouble.open_with_trouble or nil,
      },
      n = {
        ['<esc>'] = actions.close,
        ['<C-g>'] = actions.close,
        -- ['<C-c>'] = nil,
        ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
        ['<C-e>'] = hastrouble and trouble.open_with_trouble or nil,
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = false,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
    project = {
      display_type = 'full',
      base_dirs = {
        {'~/dev', max_depth = 3},
      },
    },
    file_browser = {
      hijack_netrw = false,
      mappings = {
        i = {
          -- Match completions behavior of accepting with tab
          ['<Tab>'] = actions.select_default,
          ['<C-e>'] = fb_actions.create_from_prompt,
        },
        n = {
          ['<C-e>'] = fb_actions.create_from_prompt,
          ['<C-h>'] = fb_actions.toggle_hidden,
        },
      },
    },
  },
  pickers = {
    buffers = {
      sort_lastused = true,
      sort_mru = true,
      theme = 'ivy',
      previewer = false,
      ignore_current_buffer = true,
    },
    commands = {
      theme = 'ivy',
    },
    git_files = {
      theme = 'ivy',
      previewer = true,
    },
    oldfiles = {
      theme = 'ivy',
    },
    registers = {
      theme = 'ivy'
    },
    spell_suggest = {
      theme = 'cursor'
    },
  },
}

ts.load_extension('fzf')
ts.load_extension('frecency')
-- ts.load_extension('project')
ts.load_extension('file_browser')
ts.load_extension('notify')
ts.load_extension('workspaces')

--
autocmd('User', {
  group = myCommandGroup,
  pattern = 'TelescopePreviewerLoaded',
  callback = function()
    vim.opt_local.wrap = true
  end,
})
''
