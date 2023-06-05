{ config, lib, pkgs, ... }:

{
  # Languages and LSP
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = vim-nix;
      type = "lua";
      config = ''
        vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
          pattern = '*.nix',
          command = 'setf nix',
        })
      '';
    }
    lspkind-nvim
    lsp_signature-nvim
    nvim-ts-rainbow
    nvim-ts-context-commentstring
    # Language/grammar parser with multiple practical functionalities
    {
      plugin = nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
      type = "lua";
      config = ''
        require('nvim-treesitter.configs').setup {
          -- ensure_installed = { 'c', 'cpp', },

          -- highlight = { enable = true, },
          incremental_selection = { enable = true, },
          textobjects = {
            enable = true,
            lsp_interop = { enable = true, },
          },
          indent = { enable = true, },
          matchup = { enable = true, },
          -- With nvim-autopairs
          autopairs = { enable = true, },

          -- With nvim-ts-rainbow
          rainbow = {
            enable = true,
            extended_mode = false,
            max_file_lines = 20000,
          }
        }
      '';
    }
    {
      # Show code action lightbulb
      plugin = nvim-lightbulb;
      type = "lua";
      config = ''
        vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI'}, {
          pattern = '*',
          callback = function ()
            require('nvim-lightbulb').update_lightbulb()
          end
        })
      '';
    }
    {
      plugin = SchemaStore-nvim;
    }
    {
      plugin = nvim-lspconfig;
      type = "lua";
      config = ''
        local lsp = require('lspconfig')
        local lspkind = require('lspkind')

        lspkind.init()

        vim.diagnostic.config({ virtual_text = false })

        -- Display diagnostics only when hovering
        vim.api.nvim_create_autocmd('CursorHold', {
          pattern = '*',
          callback = function ()
            vim.diagnostic.open_float(nil, {focus = false, scope='cursor'})
          end
        })

        local function on_attach(client, bufnr)
          local cmd = function (thing)
            return '<cmd>' .. thing .. '<CR>'
          end
          local map = {
            K = vim.lsp.buf.hover,
            -- ["<space>d"] = cmd("Trouble lsp_document_diagnostics"),
            -- ["<space>e"] = cmd("Trouble lsp_workspace_diagnostics"),
            ["<space>bf"] = vim.lsp.buf.formatting,
            -- ["<space>r"] = cmd("Trouble lsp_references"),
            ["[d"] = vim.diagnostic.goto_prev,
            ["]d"] = vim.diagnostic.goto_next,
            ga = vim.lsp.buf.code_action,
            gd = vim.lsp.buf.definition,
            ge = vim.diagnostic.open_float,
            gr = vim.lsp.buf.rename,
            gt = vim.lsp.buf.type_definition,
          }

          for key, value in pairs(map) do
            vim.keymap.set("n", key, value, { buffer = bufnr })
          end

          vim.keymap.set("v", "ga", vim.lsp.buf.range_code_action, { buffer = bufnr })

          if client.server_capabilities["documentSymbolProvider"] then
            local hasnavic, navic = pcall(require, "nvim-navic")
            if hasnavic then
              navic.attach(client, bufnr)
            end
          end
        end

        local function on_attach_trouble(client, bufnr)
          on_attach(client, bufnr)
          require("lsp_signature").on_attach({
            bind = true,
            handler_opts = { border = "single", },
          }, bufnr)
        end

        -- C/CPP
        lsp.clangd.setup {
          default_config = {
            cmd = {
              'clangd', '--background-index', '--pch-storage=memory', '--clang-tidy', '--suggest-missing-includes',
            },
            filetypes = { 'c', 
            -- 'cpp',
            },
            root_dir = lsp.util.root_pattern('compile_commands.json', 'compile_flags.txt', '.git'),
          },
          on_attach = on_attach_trouble,
        }
        -- Erlang
        lsp.erlangls.setup { on_attach = on_attach_trouble, }
        -- Python
        lsp.pyright.setup { on_attach = on_attach_trouble, }
        -- Rust
        lsp.rust_analyzer.setup { on_attach = on_attach_trouble, }
        -- Go
        lsp.gopls.setup { on_attach = on_attach_trouble, }
        -- Terraform
        lsp.terraformls.setup { on_attach = on_attach_trouble, }
        -- Zig
        lsp.zls.setup {
          on_attach = function(a, bufnr)
            -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
            on_attach_trouble(a, bufnr)
          end,
        }
        -- YAML
        lsp.yamlls.setup {
          on_attach = on_attach_trouble,
          -- settings = { yaml = { schemas = { ["https://..."] } } },
        }
        -- JSON
        lsp.jsonls.setup {
          on_attach = on_attach_trouble,
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
            }
          }
        }
        --[[ Vim
        lsp.vimls.setup {
          on_attach = on_attach,
        }
        --]]
        -- Nix
        lsp.rnix.setup {
          on_attach = on_attach,
        }
        -- Bash
        lsp.bashls.setup {
          on_attach = on_attach,
        }
        -- Diagnostic-ls
        lsp.diagnosticls.setup { }
      '';
    }

    # Completion popups
    cmp-nvim-lsp
    cmp-buffer
    cmp-path
    {
      plugin = nvim-cmp;
      type = "lua";
      config = ''
        local cmp = require("cmp")
        local lspkind = require("lspkind")
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')

        cmp.setup {
          confirmation = { default_behavior = cmp.ConfirmBehavior.Replace },
          formatting = {
            format = function(entry, vim_item)
              vim_item.kind = lspkind.presets.default[vim_item.kind]
              vim_item.menu = ({
                buffer = "[Buffer]",
                nvim_lsp = "[LSP]",
                luasnip = "[LuaSnip]",
                nvim_lua = "[Lua]",
                latex_symbols = "[LaTeX]",
              })[entry.source.name]
              return vim_item
            end,
          },
          mapping = {
            ["<Tab>"] = (function()
              local hasplugin, intellitab = pcall(require, 'intellitab')
              if hasplugin then
                return function (fallback)
                  intellitab.indent()
                end
              else
                return cmp.mapping.confirm({ select = true })
              end
            end)(),
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-c>"] = cmp.mapping.close(),
          },
          sources = {
            { name = "buffer" },
            { name = "nvim_lsp" },
            { name = "path" },
          },
        }
        require("cmp_nvim_lsp").setup()

        -- Automatically insert parenthesis after confirming
        cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))
      '';
    }

    {
      plugin = trouble-nvim;
      type = "lua";
      config = ''
        require('trouble').setup { }
      '';
    }


    # Language specific packages
    {
      plugin = zig-vim;
      type = "lua";
      config = ''
        vim.g.zig_fmt_autosave = 0
      '';
    }
  ];
}
