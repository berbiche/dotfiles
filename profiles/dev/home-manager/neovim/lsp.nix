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
        require('nvim-lightbulb').setup {
          autocmd = {
            enabled = true,
            updatetime = 0,
          },
        }
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

        cmp_lsp.setup()
        lspkind.init()

        vim.diagnostic.config({ virtual_text = false })

        -- Display diagnostics only when hovering
        vim.api.nvim_create_autocmd('CursorHold', {
          pattern = '*',
          callback = function ()
            local bufnr, _ = vim.diagnostic.open_float(nil, {focus = false, scope='cursor'})
            -- The buffer should not be listed...
            if bufnr ~= nil then
              -- vim.bo[bufnr].buflisted = false
            end
          end
        })

        local function on_attach(client, bufnr)
          local map = {
            -- Key -> {function, documentation, whether bind to visual mode}
            ['<leader>la'] = {vim.lsp.buf.code_action, 'Code action', true},
            ['<leader>ld'] = {vim.lsp.buf.definition, 'Code definition'},
            ['<leader>lD'] = {vim.lsp.buf.declaration, 'Code declaration'},
            ['<leader>le'] = {vim.diagnostic.open_float, 'Open diagnostic'},
            ['<leader>lf'] = {vim.lsp.buf.format, 'Format'},
            ['<leader>li'] = {vim.lsp.buf.implementation, 'Code implementation'},
            ['<leader>lr'] = {vim.lsp.buf.rename, 'Rename'},
            ['<leader>lt'] = {vim.lsp.buf.type_definition, 'Type definition'},
            ['K'] = {vim.lsp.buf.hover, 'Lookup documentation'},
            ['ga'] = {vim.lsp.buf.code_action, 'Code action', true},
            ['gd'] = {vim.lsp.buf.definition, 'Code definition'},
            ['gD'] = {vim.lsp.buf.declaration, 'Code declaration'},
            ['gr'] = {vim.lsp.buf.references, 'Code references'},
            ['[d'] = {vim.diagnostic.goto_prev, 'Previous diagnostic'},
            [']d'] = {vim.diagnostic.goto_next, 'Next diagnostic'},
          }

          for key, value in pairs(map) do
            if value[1] ~= nil then
              local mode = value[3] and {'n', 'v'} or {'n'}
              bind(mode, key, function() value[1]() end, { buffer = bufnr }, value[2])
            else
              -- Debugging
              vim.notify_once(string.format('Action does not exist for mapping %s -> %s', key, vim.inspect(value)), vim.log.levels.DEBUG, {title = 'LSP'})
            end
          end

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

        local opts = { silent = true, }

        bind('n', '<leader>xx', '<cmd>TroubleToggle<cr>', opts, 'Toggle Trouble')
        bind('n', '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', opts, 'Toggle workspace diagnostics')
        bind('n', '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', opts, 'Toggle document diagnostics')
        bind('n', '<leader>xl', '<cmd>TroubleToggle loclist<cr>', opts, 'Toggle loclist')
        bind('n', '<leader>xq', '<cmd>TroubleToggle quickfix<cr>', opts, 'Toggle quickfix')
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
