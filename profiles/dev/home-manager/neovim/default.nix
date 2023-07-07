moduleArgs@{ config, lib, pkgs, inputs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

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
    plugins = lib.mkBefore [{
      plugin = pkgs.runCommandLocal "dummy" { } "mkdir $out";
      type = "lua";
      config = import ./init.lua.nix { };
    }];
  };
}
