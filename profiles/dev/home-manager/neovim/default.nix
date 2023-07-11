moduleArgs@{ config, lib, pkgs, inputs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  dummy = pkgs.runCommandLocal "dummy" { } "mkdir $out";

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
    ./plugins.nix
    ./lsp.nix
    ./ui.nix
    ./cmp.nix
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
    plugins = lib.mkMerge [
      (lib.mkBefore [{
        plugin = dummy;
        type = "lua";
        config = import ./init.lua.nix { };
      }])
      (lib.mkAfter [{
        plugin = dummy;
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

            local function DisconnectClients()
              if vim.b.nvr then
                for _, client in pairs(vim.b.nvr) do
                  -- Call rpcnotify to exit the client
                  vim.rpcnotify(client, 'Exit', 1)
                end
              end
            end

            vim.cmd('command! DisconnectClients lua DisconnectClients()')
          end
        '';
      }])
    ];
  };
}
