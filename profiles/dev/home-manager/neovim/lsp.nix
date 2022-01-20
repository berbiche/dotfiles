{ config, lib, pkgs, ... }:

{
  # Languages and LSP
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = vim-nix;
      config = ''
        au BufRead,BufNewFile *.nix setf nix
      '';
    }
    lspkind-nvim
    lsp_signature-nvim
    nvim-ts-rainbow
    # Language/grammar parser with multiple practical functionalities
    {
      plugin = nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
      config = ''
        lua <<EOF
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
        EOF
      '';
    }
    {
      # Show code action lightbulb
      plugin = nvim-lightbulb;
      config = ''
        autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()
      '';
    }
    {
      plugin = nvim-lspconfig;
      config = ''
        " autocmd CursorHold * lua vim.diagnostic.open_float()

        lua <<EOF
          local lsp = require('lspconfig')
          local lspkind = require('lspkind')

          lspkind.init()

          local function on_attach(_, buf)
            local map = {
              K = "lua vim.lsp.buf.hover()",
              -- ["<space>d"] = "Trouble lsp_document_diagnostics",
              -- ["<space>e"] = "Trouble lsp_workspace_diagnostics",
              ["<space>bf"] = "lua vim.lsp.buf.formatting()",
              -- ["<space>r"] = "Trouble lsp_references",
              ["[d"] = "lua vim.diagnostic.goto_prev()",
              ["]d"] = "lua vim.diagnostic.goto_next()",
              ga = "lua vim.lsp.buf.code_action()",
              gd = "lua vim.lsp.buf.definition()",
              ge = "lua vim.diagnostic.open_float()",
              gr = "lua vim.lsp.buf.rename()",
              gt = "lua vim.lsp.buf.type_definition()",
            }


            for k, v in pairs(map) do
              vim.api.nvim_buf_set_keymap(
                buf,
                "n",
                k,
                "<cmd>" .. v .. "<cr>",
                { noremap = true }
              )
            end


            vim.api.nvim_buf_set_keymap(
              buf,
              "v",
              "ga",
              "<cmd>lua vim.lsp.buf.range_code_action()<cr>",
              { noremap = true }
            )
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
              filetypes = { 'c', 'cpp', },
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
        EOF
      '';
    }

    # Completion popups
    cmp-nvim-lsp
    cmp-buffer
    cmp-path
    {
      plugin = nvim-cmp;
      config = ''
        lua <<EOF
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
              ["<Tab>"] = cmp.mapping.confirm({ select = true }),
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
          cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = ''' } }))
        EOF
      '';
    }

    {
      plugin = trouble-nvim;
      config = "lua require'trouble'.setup()";
    }


    # Language specific packages
    {
      plugin = zig-vim;
      config = "let g:zig_fmt_autosave = 0";
    }
  ];
}
