{ config, lib, pkgs, ... }:

{
  # Languages and LSP
  programs.neovim.plugins = with pkgs.vimPlugins; [
    lspkind-nvim
    lsp_signature-nvim
    nvim-ts-rainbow2
    nvim-ts-context-commentstring
    nvim-treesitter-endwise
    # Language/grammar parser with multiple practical functionalities
    {
      plugin = nvim-treesitter.withAllGrammars;
      type = "lua";
      config = ''
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
          textobjects = {
            enable = true,
            lsp_interop = { enable = true, },
          },
          indent = { enable = true, },
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
      plugin = nvim-lspconfig;
      type = "lua";
      config = ''
        local lsp = require('lspconfig')
        local lspkind = require('lspkind')
        local cmp_lsp = require('cmp_nvim_lsp')
        local hasnavic, navic = pcall(require, 'nvim-navic')

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
            K = {vim.lsp.buf.hover, 'Lookup documentation'},
            ['<space>bf'] = {vim.lsp.buf.formatting, 'Format'},
            ['[d'] = {vim.diagnostic.goto_prev, 'Goto previous error'},
            [']d'] = {vim.diagnostic.goto_next, 'Goto next error'},
            ['<leader>la'] = {vim.lsp.buf.code_action, 'Code action'},
            ['<leader>ld'] = {vim.lsp.buf.definition, 'Code definition'},
            ['<leader>lD'] = {vim.lsp.buf.declaration, 'Code declaration'},
            ['<leader>li'] = {vim.lsp.buf.implementation, 'Code implementation'},
            ['<leader>le'] = {vim.diagnostic.open_float, 'Open diagnostic'},
            ['<leader>lr'] = {vim.lsp.buf.rename, 'Rename'},
            ['<leader>lt'] = {vim.lsp.buf.type_definition, 'Type definition'},
            ['ga'] = {vim.lsp.buf.code_action, 'Code action'},
            ['gd'] = {vim.lsp.buf.definition, 'Code definition'},
            ['gD'] = {vim.lsp.buf.declaration, 'Code declaration'},
          }

          for key, value in pairs(map) do
            bind('n', key, value[1], { buffer = bufnr }, value[2])
          end

          bind('v', 'ga', vim.lsp.buf.range_code_action, { buffer = bufnr }, 'Code action')

          if client.server_capabilities.documentSymbolProvider then
            if hasnavic then
              navic.attach(client, bufnr)
            end
          end
        end

        local function on_attach_trouble(client, bufnr)
          on_attach(client, bufnr)
          require('lsp_signature').on_attach({
            bind = true,
            handler_opts = { border = 'single', },
          }, bufnr)
        end

        -- cmp-lsp capabilities
        local capabilities = cmp_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

        -- C/CPP
        lsp.clangd.setup {
          default_config = {
            cmd = {
              'clangd', '--background-index', '--pch-storage=memory', '--clang-tidy', '--suggest-missing-includes',
            },
            filetypes = { 'c', },
            root_dir = lsp.util.root_pattern('compile_commands.json', 'compile_flags.txt', '.git'),
          },
          on_attach = on_attach_trouble,
          capabilities = capabilities,
        }
        -- Erlang
        lsp.erlangls.setup {
          on_attach = on_attach_trouble,
          capabilities = capabilities,
        }
        -- Python
        lsp.pyright.setup {
          on_attach = on_attach_trouble,
          capabilities = capabilities,
        }
        -- Rust
        lsp.rust_analyzer.setup {
          on_attach = on_attach_trouble,
          capabilities = capabilities,
        }
        -- Go
        lsp.gopls.setup {
          on_attach = on_attach_trouble,
          capabilities = capabilities,
        }
        -- Terraform
        lsp.terraformls.setup {
          on_attach = on_attach_trouble,
          capabilities = capabilities,
        }
        -- Docker
        lsp.dockerls.setup {
          on_attach = on_attach_trouble,
          capabilities = capabilities,
        }
        -- Zig
        lsp.zls.setup {
          on_attach = function(a, bufnr)
            -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
            on_attach_trouble(a, bufnr)
          end,
          capabilities = capabilities,
        }
        -- YAML
        lsp.yamlls.setup {
          on_attach = on_attach_trouble,
          capabilities = capabilities,
          -- settings = { yaml = { schemas = { ["https://..."] } } },
        }
        -- JSON
        lsp.jsonls.setup {
          on_attach = on_attach_trouble,
          capabilities = capabilities,
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
            }
          }
        }
        --[[ Vim
        lsp.vimls.setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
        --]]
        -- Nix
        lsp.nil_ls.setup {
          on_attach = on_attach_trouble,
          capabilities = capabilities,
        }
        -- Bash
        lsp.bashls.setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
        -- Diagnostic-ls
        lsp.diagnosticls.setup { }
      '';
    }

    # Snippets
    vim-snippets
    {
      plugin = nvim-snippy;
      type = "lua";
      config = ''
        require('snippy').setup {
          mappings = {
            is = {
              ['<Tab>'] = 'expand_or_advance',
              ['<S-Tab>'] = 'previous',
            },
            -- nx = {
            --   ['<leader>x'] = 'cut_text',
            -- },
          },
        }
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
    {
      plugin = vim-nix;
      type = "lua";
      config = ''
        vim.filetype.add({
          extension = {
            nix = 'nix',
          },
        })
      '';
    }
    {
      plugin = SchemaStore-nvim;
    }
  ];
}
