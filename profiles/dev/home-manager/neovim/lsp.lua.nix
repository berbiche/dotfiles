#
# Settings related to the setup of LSP servers, treesitter queries
# and motions based on treesitter.
# Also includes settings related any UI tool performing some LSP task
# i.e. glance-nvim
#
{ pkgs, config, ... }:
let
  inherit (config.my.dev) beamPackages;
in
''

local lsp = require('lspconfig')
local lspkind = require('lspkind')
local cmp_lsp = require('cmp_nvim_lsp')
local glance = require('glance')
local glance_actions = glance.actions
local hasnavic, navic = pcall(require, 'nvim-navic')
local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')
local next_integrations = require("nvim-next.integrations")
local nndiag = next_integrations.diagnostic()

-- Jump to matching keyword, supercharged %
-- With vim-matchup
vim.g.matchup_matchparen_offscreen = { method = 'popup' }


-- vim-illuminate
-- tbl_flatten does a shallow copy of the table :)
local ft = vim.tbl_flatten(default_excluded_filetypes)
table.insert(ft, 'NeogitStatus')
require('illuminate').configure {
  providers = { 'lsp', 'treesitter' },
  filetypes_denylist = ft,
  -- Don't highlight in files with more than 10k lines
  large_file_cutoff = 10000,
}

-- Show action lightbulb in column
require('nvim-lightbulb').setup {
  autocmd = {
    enabled = true,
    updatetime = 0,
  },
}

-- Show LSP diagnostics messages as virtual text
require('fidget').setup{}


-- TODO: https://github.com/ghostbuster91/nvim-next#treesitter-text-objects

require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_file_size = 1000 * 1024 -- 1 MB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      return ok and stats and stats.size > max_file_size
    end,
  },

  incremental_selection = { enable = true, },

  indent = { enable = true, },

  textobjects = {
    enable = true,
    -- lsp_interop = { enable = true, },
    select = {
      enable = true,
      -- Don't jump to next object
      lookahead = false,
      -- Include preceding and succeeding whitespace
      include_surrounding_whitespace = false,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = {query = '@function.outer', desc = 'Select outer function'},
        ['if'] = {query = '@function.inner', desc = 'Select inner function'},
        ['ac'] = {query = '@class.outer', desc = 'Select outer class'},
        ['ia'] = {query = '@parameter.inner', desc = 'Select inner argument'},
        ['aa'] = {query = '@parameter.outer', desc = 'Select outer argument'},
        ['ic'] = {query = '@class.inner', desc = 'Select inner part of a class region'},
      },
      selection_modes = {
        ['@parameter.outer'] = 'v',
        ['@function.outer'] = 'V',
        ['@class.outer'] = '<C-v>',
      },
      lsp_interop = {enable = true},
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        [']a'] = {query = '@parameter.inner', desc = 'Next argument'},
        [']M'] = {query = '@function.outer', desc = 'Jump to next function'},
      },
      goto_previous_start = {
        ['[a'] = {query = '@parameter.inner', desc = 'Previous argument'},
        ['[m'] = {query = '@function.outer', desc = 'Jump to beginning of function'},
      },
      goto_previous_end = {
        ['[M'] = {query = '@function.outer', desc = 'Jump to previous function'},
      },
      goto_next_end = {
        [']m'] = {query = '@function.outer', desc = 'Jump to end of function'},
      },
    },
  },

  -- With vim-matchup
  matchup = { enable = true, },

  -- With nvim-autopairs
  autopairs = { enable = true, },

  -- With nvim-treesitter-endwise
  endwise = { enable = true, },

  -- With nvim-ts-rainbow
  rainbow = {
    enable = true,
    extended_mode = false,
    max_file_lines = 20000,
  }
}


glance.setup {
  border = {
    enable = true,
  },
  hooks = {
    before_open = function(results, open, jump, method)
      -- Don't open glance when there is only one result and it is located in the current buffer
      local uri = vim.uri_from_bufnr(0)
      if #results == 1 then
        local target_uri = results[1].uri or results[1].targetUri

        if target_uri == uri then
          jump(results[1])
        else
          open(results)
        end
      else
        open(results)
      end
    end,
  },
  mappings = {
    list = {
      ['<C-n>'] = glance_actions.next,
      ['<C-p>'] = glance_actions.previous,
    },
    preview = {
      ['q'] = glance_actions.close,
      ['<C-n>'] = glance_actions.next_location,
      ['<C-p>'] = glance_actions.previous_location,
    },
  },
  use_trouble_qf = true,
}


-- cmp-lsp capabilities
cmp_lsp.setup()
lspkind.init()
local capabilities = cmp_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Display a border around floating popups
vim.diagnostic.config({ virtual_text = false, float = { border = 'rounded' }, })
-- Same for these handlers
local handlers = {
  ['textDocument/hover'] =  vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded'}),
  ['textDocument/signatureHelp'] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = 'rounded'}),
}

local function attach_autocmd(buffer)
  -- Display diagnostics when "hovering"
  vim.api.nvim_create_autocmd('CursorHold', {
    buffer = buffer,
    group = myCommandGroup,
    callback = function ()
      vim.diagnostic.open_float(nil, {
        focusable = false,
        close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
        prefix = ' ',
        scope = 'cursor',
        source = 'if_many',
      })
    end,
  })
end

local function on_attach(client, bufnr)
  local map = {
    -- Key -> {condition, function, documentation, whether to bind to visual mode}
    ['<leader>la'] = {
      client.supports_method('textDocument/codeAction'),
      vim.lsp.buf.code_action,
      'Code action',
      true
    },
    ['<leader>ld'] = {
      client.supports_method('textDocument/definition'),
      function() glance_actions.open('definitions') end,
      'Code definition'
    },
    ['<leader>lD'] = {
      client.supports_method('textDocument/references'),
      function() glance_actions.open('references') end,
      'Code references'
    },
    ['<leader>le'] = {
      true,
      vim.diagnostic.open_float,
      'Open diagnostic'
    },
    ['<leader>lf'] = {
      client.supports_method('textDocument/formatting'),
      vim.lsp.buf.format,
      'Format'
    },
    ['<leader>li'] = {
      client.supports_method('textDocument/declaration') or client.supports_method('textDocument/implementation'),
      function() glance_actions.open('implementations') end,
      'Code implementation'
    },
    ['<leader>lr'] = {
      client.supports_method('textDocument/rename'),
      vim.lsp.buf.rename,
      'Rename'
    },
    ['<leader>lt'] = {
      client.supports_method('textDocument/typeDefinition'),
      vim.lsp.buf.type_definition,
      'Type definition'
    },
    ['K'] = {
      client.supports_method('textDocument/hover'),
      vim.lsp.buf.hover,
      'Lookup documentation'
    },
    ['[d'] = {
      true,
      nndiag.goto_prev,
      'Previous diagnostic'
    },
    [']d'] = {
      true,
      nndiag.goto_next,
      'Next diagnostic'
    },
  }
  map['ga'] = map['<leader>la']
  map['gd'] = map['<leader>ld']
  map['gD'] = map['<leader>lD']
  map['gI'] = map['<leader>li']

  for key, value in pairs(map) do
    if value[1] then
      local mode = value[4] and {'n', 'v'} or {'n'}
      bind(mode, key, function() value[2]() end, { buffer = bufnr }, value[3])
    else
      local mode = value[4] and {'n', 'v'} or {'n'}
      bind(mode, key, '<nop>', { buffer = bufnr }, 'Unsupported: ' .. value[3])
      -- Debugging
      vim.notify_once(
        ('Action does not exist for mapping %s -> %s'):format(key, vim.inspect(value)),
        vim.log.levels.DEBUG,
        {title = 'LSP'}
      )
    end
  end

  if client.supports_method('textDocument/documentSymbol') then
    if hasnavic then
      navic.attach(client, bufnr)
    end
  end

  attach_autocmd(bufnr)
end

local function on_attach_trouble(client, bufnr)
  on_attach(client, bufnr)
  require('lsp_signature').on_attach({
    bind = true,
    handler_opts = { border = 'rounded', },
  }, bufnr)
end

local servers = {
  -- Bash
  'bashls',
  -- C/CPP
  clangd = {
    default_config = {
      cmd = {
        'clangd', '--background-index', '--pch-storage=memory', '--clang-tidy', '--suggest-missing-includes',
      },
      filetypes = { 'c', },
      root_dir = lsp.util.root_pattern('compile_commands.json', 'compile_flags.txt', '.git'),
    },
  },
  -- diagnosticls = false,
  -- Docker
  'dockerls',
  -- Erlang
  'erlangls',
  -- Elixir
  elixirls = {
    cmd = { [[${beamPackages.elixir-ls}/lib/language_server.sh]] },
  },
  -- Go
  'gopls',
  -- JSON
  jsonls = {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  },
  -- Nix
  'nil_ls',
  -- Python
  'pyright',
  -- Rust
  'rust_analyzer',
  -- Terraform
  'terraformls',
  -- Zig
  'zls',
  -- YAML
  yamlls = {
    settings = {
      yaml = {
        schemaStore = { enable = false, url = ''' },
        schemas = require('schemastore').yaml.schemas(),
      },
    },
  },
}
for server, override in pairs(servers) do
  local opts = {
    on_attach = on_attach_trouble,
    capabilities = capabilities,
    handlers = handlers,
  }
  if type(server) == 'number' then
    server = override
    override = {}
  end
  if type(override) == 'boolean' and not override then
    lsp[server].setup()
  else
    opts = vim.tbl_extend('force', opts, override)
    lsp[server].setup(opts)
  end
end
''
