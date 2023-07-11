{ config, lib, pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    cmp-snippy

    # Completion popups
    cmp-nvim-lsp
    cmp-nvim-lsp-signature-help
    cmp-buffer
    cmp-path
    {
      plugin = nvim-cmp;
      type = "lua";
      config = ''
        local cmp = require('cmp')
        local lspkind = require('lspkind')
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        local snippy = require('snippy')

        local has_words_before = function()
          unpack = unpack or table.unpack
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
        end

        cmp.setup {
          confirmation = { default_behavior = cmp.ConfirmBehavior.Replace },
          formatting = {
            format = function(entry, vim_item)
              vim_item.kind = lspkind.presets.default[vim_item.kind]
              vim_item.menu = ({
                buffer = '[Buffer]',
                nvim_lsp = '[LSP]',
                luasnip = '[LuaSnip]',
                nvim_lua = '[Lua]',
                latex_symbols = '[LaTeX]',
              })[entry.source.name]
              return vim_item
            end,
          },

          mapping = {
            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                local entry = cmp.get_selected_entry()
                if not entry then
                  cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                else
                  cmp.confirm()
                end
              elseif snippy.can_expand_or_advance() then
                snippy.expand_or_advance()
              elseif has_words_before() then
                cmp.complete()
              else
                local hasplugin, intellitab = pcall(require, 'intellitab')
                if hasplugin then
                  intellitab.indent()
                else
                  fallback()
                end
              end
            end, { 'i', 's', 'c' }),
            ['<C-p>'] = cmp.mapping.select_prev_item(),
            ['<C-n>'] = cmp.mapping.select_next_item(),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-c>'] = cmp.mapping.close(),
          },
          snippet = {
            expand = function(args)
              require('snippy').expand_snippet(args.body)
            end,
          },
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'nvim_lsp_signature_help' },
            { name = 'path' },
            { name = 'snippy' },
          }, {
            {
              name = 'buffer',
              options = {
                -- Don't index buffers larger than 1 MB
                get_bufnrs = function()
                  local buf = vim.api.nvim_get_current_buf()
                  local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
                  if byte_size > 1024 * 1024 then
                    return {}
                  end
                  return { buf }
                end,
              },
            },
          }),
        }

        -- Automatically insert parenthesis after confirming
        cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
      '';
    }
    {
      plugin = pkgs.runCommandLocal "dummy" { } "mkdir $out";
      type = "lua";
      config = ''
        local cmp_lsp = require('cmp_nvim_lsp')
        cmp_lsp.setup {
        }
      '';
    }

    cmp-cmdline-history
    {
      plugin = cmp-cmdline;
      type = "lua";
      config = ''
        -- `/`, `?` cmdline setup.
        for _, cmd_type in pairs({'/', '?'}) do
          cmp.setup.cmdline(cmd_type, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
              { name = 'buffer' },
              { name = 'cmdline_history' },
            },
          })
        end
        -- `:` cmdline setup.
        cmp.setup.cmdline(':', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = 'path' }
          }, {
            {
              name = 'cmdline',
              option = {
                ignore_cmds = { 'Man', '!' },
              },
            },
          }),
        })
        -- `@` cmdline setup
        cmp.setup.cmdline('@', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = 'buffer' },
            { name = 'cmdline_history' },
          },
        })

      '';
    }
    cmp-cmdline
  ];
}
