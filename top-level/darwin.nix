{ config, pkgs, lib, inputs, ... }:

let
  nixCfg = config.nix.settings;
in
{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  # This option will never be read on Darwin since sops-nix does not
  # support MacOS and is not loaded
  options.sops = lib.mkSinkUndeclaredOptions { };

  config = lib.mkMerge [
    {
      my.defaults.file-explorer = "";

      system.stateVersion = 4;

      nix.nixPath = [
        "darwin=${inputs.nix-darwin}"
      ];
      nix.settings.extra-sandbox-paths = [
        # Necessary
        "/System/Library/Frameworks"
        # Necessary
        "/System/Library/PrivateFrameworks"
        # Probably necessary
        "/usr/lib"
      ];

      nix.settings.trusted-users = [ "@admin" config.my.username ];
      nix.useDaemon = true;
      services.nix-daemon.enable = true;

      nix.gc.user = "root";

      # Disable useless warning about NIX_PATH with a flake configuration
      system.checks.verifyNixPath = false;

      nix.configureBuildUsers = true;
    }
  ];
}
