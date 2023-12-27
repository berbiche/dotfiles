moduleArgs@{ config, lib, pkgs, ... }:

let
  luaConfigLocation = "nvim/lua/user";
  shellAliases = rec {
    # The `-s` or `--remote` flag has to be specified last
    # The `mktemp -u` flag will not create the file (otherwise neovim will refuse to replace it)
    nvim = toString (pkgs.writeShellScript "neovim-alias" ''
      # Pick up the nvim command from the current environment
      # This allows updating the neovim configuration without reloading
      # all shells to use the new alias
      nvim=$(command -v nvim)
      if [[ -z "$NVIM_LISTEN_ADDRESS" ]]; then
        if [[ -z "$nvim" ]]; then
          exec -a nvim ${config.programs.neovim.finalPackage}/bin/nvim "$@"
        else
          exec -a nvim "$nvim" "$@"
        fi
      else
        exec -a nvim ${pkgs.neovim-remote}/bin/nvr -s "$@"
      fi
    '');
    n = nvim;
  };
in
{
  imports = [
    ./utils.nix
    ./ui.nix
  ];

  home.packages = [
    pkgs.fzf
    pkgs.neovim-remote
    # graphical neovim
    pkgs.neovide
  ];

  # programs.neovim.defaultEditor = true;
  home.sessionVariables = {
    EDITOR = shellAliases.nvim;
  };

  home.shellAliases = shellAliases;

  xdg.configFile = {
    "${luaConfigLocation}/cmp.lua".text = import ./cmp.lua.nix moduleArgs;
    "${luaConfigLocation}/dashboard.lua".text = import ./dashboard.lua.nix moduleArgs;
    "${luaConfigLocation}/filetree.lua".text = import ./filetree.lua.nix moduleArgs;
    "${luaConfigLocation}/keybinds.lua".text = import ./keybinds.lua.nix moduleArgs;
    "${luaConfigLocation}/lsp.lua".text = import ./lsp.lua.nix moduleArgs;
    "${luaConfigLocation}/neovide.lua".text = import ./neovide.lua.nix moduleArgs;
    "${luaConfigLocation}/settings.lua".text = import ./settings.lua.nix moduleArgs;
    "${luaConfigLocation}/telescope.lua".text = import ./telescope.lua.nix moduleArgs;
  };

  # TODO: things to remember
  # https://github.com/rhysd/clever-f.vim

  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    withPython3 = true;
    withRuby = false;

    # From neovim-nightly input
    # package = inputs.neovim-nightly.packages.${pkgs.system}.neovim;
    package = pkgs.neovim-unwrapped;

    # Language servers are configured in profies/dev/home-manager/lsp.nix
    extraPackages = with pkgs; [ ];

    # Configuration that is set at the beginning of my configuration!
    plugins = with pkgs.vimPlugins; lib.mkMerge [
      (lib.mkBefore [{
        plugin = config.lib.dummyPackage;
        type = "lua";
        config = import ./init.lua.nix moduleArgs;
      }])
      (lib.mkAfter [{
        plugin = config.lib.dummyPackage;
        type = "lua";
        config = ''
          -- neovim-remote setup
          if vim.g.vscode == nil then
            vim.env.GIT_EDITOR = 'nvr -cc split --remote-wait'

            autocmd({'FileType'}, {
              group = myCommandGroup,
              pattern = {'gitcommit', 'gitrebase', 'gitconfig'},
              callback = function()
                vim.opt_local.bufhidden = 'delete'
              end,
            })

            local function disconnect_clients()
              if vim.b.nvr then
                for _, client in pairs(vim.b.nvr) do
                  -- Call rpcnotify to exit the client
                  vim.rpcnotify(client, 'Exit', 1)
                end
              end
            end

            vim.api.nvim_create_user_command('DisconnectClients', disconnect_clients, {bang = true})
          end
        '';
      }])
      [

        # Show startup time with :StartupTime
        vim-startuptime

        # Sensible default vim/nvim options
        vim-sensible

        # Allows repeating most commands with '.' correctly
        vim-repeat
        {
          # Allows repeating motions with ',' and ';'
          plugin = nvim-next;
          type = "lua";
          config = ''
            local nvim_next_builtins = require('nvim-next.builtins')
            require('nvim-next').setup {
              default_mappings = {
                repeat_style = 'directional',
              },
              items = {
                nvim_next_builtins.f,
                nvim_next_builtins.t,
              }
            }

          '';
        }
        # {
        #   # Better #* motions
        #   plugin = vim-asterisk;
        #   type = "lua";
        #   config = ''
        #     local mode = {'n', 'v', 'o'}
        #     bind(mode, '*', '<Plug>(asterisk-z*)', 'Search word forward')
        #     bind(mode, '#', '<Plug>(asterisk-z#)', 'Search word backward')
        #     bind(mode, 'g*', '<Plug>(asterisk-gz*)', 'Search word forward')
        #     bind(mode, 'g#', '<Plug>(asterisk-gz#)', 'Search word backward')
        #     bind(mode, 'z*', '<Plug>(asterisk-z*)', 'Search word forward')
        #     bind(mode, 'gz*', '<Plug>(asterisk-gz*)', 'Search word forward')
        #     bind(mode, 'z#', '<Plug>(asterisk-z#)', 'Search word backward')
        #     bind(mode, 'gz#', '<Plug>(asterisk-gz#)', 'Search word backward')
        #   '';
        # }

        {
          plugin = vim-sandwich; # replaces vim-surround
          type = "lua";
          config = ''
            vim.g['sandwich#recipes'] = vim.deepcopy(vim.g['sandwich#default_recipes'])
            local sandwich_recipes = {

            }
            for _, recipe in ipairs(sandwich_recipes) do
              table.insert(vim.g['sandwich#recipes'], recipe)
            end
            -- Use surround.vim keymaps since the default keymap breaks vim-sneak
            vim.cmd([[
              runtime macros/sandwich/keymap/surround.vim
            ]])
          '';
        }

        # Indent using tabs or spaces based on the content of the file
        vim-sleuth
        # Indent object based on indentation level (>ii)
        vim-indent-object
        # Indent line to surrounding indentation
        intellitab-nvim

        {
          # Highlight TODO:, FIXME, HACK etc.
          plugin = todo-comments-nvim;
          type = "lua";
          config = ''
            require('todo-comments').setup {}
          '';
        }
        {
          # Automatically close pairs of symbols like {}, [], (), "", etc.
          plugin = nvim-autopairs;
          type = "lua";
          config = ''
            require('nvim-autopairs').setup {
              check_ts = true,
              disable_filetype = default_excluded_filetypes,
            }
          '';
        }
        {
          # Shows a key sequence to jump to a word/letter letter after typing 's<letter><letter>'
          plugin = leap-nvim;
          type = "lua";
          config = ''
            -- Hijacks {x, X}
            require('leap').add_default_mappings()
            -- require('leap').add_repeat_mappings(';', ',', {
            --   relative_directions = true,
            --   modes = {'n', 'x', 'o'}
            -- })
          '';
        }
        searchbox-nvim

        # Git
        {
          plugin = diffview-nvim;
          type = "lua";
          config = ''
            require('diffview').setup {
              default_args = {
                DiffviewOpen = { "--imply-local" },
              }
            }
          '';
        }
        {
          plugin = comment-nvim;
          type = "lua";
          config = ''
          '';
        }

        # Automatically disable search highlighting when moving
        vim-cool
        nvim-hlslens

        # Floating terminal
        FTerm-nvim

        # Close buffers/windows/etc.
        vim-sayonara
        bufdelete-nvim

        # Snippets
        vim-snippets
        nvim-snippy

        # Completion popups
        cmp-nvim-lsp
        cmp-nvim-lsp-signature-help
        cmp-buffer
        cmp-path
        cmp-snippy
        # cmdline completion
        cmp-cmdline
        cmp-cmdline-history
        nvim-cmp


        # Languages and LSP
        SchemaStore-nvim
        # Jump to matching delimiter
        vim-matchup
        # Illuminate currently selected word
        vim-illuminate
        # Show code action lightbulb
        nvim-lightbulb
        lspkind-nvim
        lsp_signature-nvim
        # Highlight nested paranthesis and other block delimiters with different colors
        nvim-ts-rainbow2
        nvim-ts-context-commentstring
        # Auto-insert 'end' to specific construct (e.g. `do .. end`)
        nvim-treesitter-endwise
        # Textobjects for motions and selections (e.g. `]a` to go to next argument)
        nvim-treesitter-textobjects
          # Language/grammar parser with multiple practical functionalities
        nvim-treesitter.withAllGrammars
        # Show preview for jump-to definition/implementation/reference
        glance-nvim
        nvim-lspconfig
        trouble-nvim
        # Language specific packages
        zig-vim
        vim-nix


        ##### Telescope
        plenary-nvim
        sqlite-lua
        workspaces-nvim

        # Enables something like occur-mode in Emacs with the quickfix buffer
        replacer-nvim

        # telescope-project-nvim
        telescope-frecency-nvim
        telescope-fzf-native-nvim
        telescope-file-browser-nvim
        telescope-nvim
      ]

      (lib.mkIf (config.profiles.dev.wakatime.enable) [(config.lib.neovim.lazy {
        plugin = vim-wakatime;
        type = "lua";
        config = ''
          -- WakaTime CLI path
          vim.g.wakatime_OverrideCommandPrefix = [[${pkgs.wakatime}/bin/wakatime]]

          if vim.g.vscode == nil then
            vim.cmd([[packadd vim-wakatime]])
          end
        '';
      })])
    ];
  };
}
