{ ... }: ''

local blink = require('blink.cmp')
local snippy = require('snippy')
local has_intellitab, intellitab = pcall(require, 'intellitab')

-- Snippets
snippy.setup {
  mappings = {
    is = {
      ['<Tab>'] = 'expand_or_advance',
      ['<S-Tab>'] = 'previous',
    },
  },
}

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

blink.setup {
  cmdline = {
    keymap = {
      ['<Tab>'] = { 'show', 'accept' },
    },
    completion = {
      menu = { auto_show = true },
    },
  },
  completion = {
    trigger = {
      show_on_insert_on_trigger_character = false,
      show_on_keyword = true,
      show_on_x_blocked_trigger_characters = {},
    },
    list = {
      selection = { preselect = false },
    },
  },
  keymap = {
    preset = 'default',
    ['<Tab>'] = {
      function(cmp)
        if cmp.snippet_active() or snippy.can_expand_or_advance() then
           snippy.expand_or_advance()
           -- return cmp.accept()
           return true
        elseif has_words_before() then
          return cmp.insert_next()
        elseif has_intellitab then
          intellitab.indent()
          return true
        else
          return cmp.select_and_accept()
        end
      end,
      'snippet_forward',
      'fallback',
    },
    ['<S-Tab>'] = { 'insert_prev' },
    ['<C-c>'] = { function(cmp) cmp.cancel() end, },
    ['<Esc>'] = { function(cmp) cmp.cancel() end, 'fallback' },
  },
  fuzzy = {
    sorts = {
      'exact',
      -- defaults
      'score',
      'sort_text',
    },
    implementation = 'prefer_rust_with_warning',
  },
  sources = {
    default = {
      'lsp',
      'buffer',
      'path',
      'snippets',
      -- 'copilot',
      -- 'dictionary',
      -- 'emoji',
      'git',
      -- 'spell',
      -- 'ripgrep',
    },
    providers = {
      git = {
        name = 'Git',
        module = 'blink-cmp-git',
        enabled = true,
        score_offset = 100,
        should_show_items = function()
          return vim.o.filetype == 'gitcommit' or vim.o.filetype == 'markdown'
        end,
        opts = {
          git_centers = {
            github = {
              issue = {
                on_error = function(_, _)
                  return true
                end,
              },
            },
          },
        },
      },
      lsp = {
        min_keyword_length = 0, -- Allow LSP completions with no text
      },
      buffer = {
        min_keyword_length = 0, -- Allow buffer completions with no text
      },
      path = {
        min_keyword_length = 0,
      }
    },
  },
  signature = { enabled = true },
}
''
