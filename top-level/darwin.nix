{ config, pkgs, lib, inputs, ... }:

let
  nixCfg = config.nix.settings;
in
{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  # This option will never be read on Darwin since sops-nix does not
  # support MacOS and is not loaded
  options.sops = lib.mkSinkUndeclaredOptions { };

  # Temporary fix
  options.nix.settings = lib.mkOption {
    type = with lib.types; attrsOf (oneOf [ str (listOf str) float int ]);
  };

  config = lib.mkMerge [
    {
      my.defaults.file-explorer = "";

      system.stateVersion = 4;

      nix.nixPath = [
        "darwin=${inputs.nix-darwin}"
      ];
      nix.sandboxPaths = [
        # Necessary
        "/System/Library/Frameworks"
        # Necessary
        "/System/Library/PrivateFrameworks"
        # Probably necessary
        "/usr/lib"
      ];

      nix.trustedUsers = [ "@admin" config.my.username ];
      nix.useDaemon = true;
      services.nix-daemon.enable = true;

      nix.gc.user = "root";

      # Disable useless warning about NIX_PATH with a flake configuration
      system.checks.verifyNixPath = false;

      users.nix.configureBuildUsers = true;
    }
    {
      nix.maxJobs = lib.mkIf (nixCfg ? max-jobs) nixCfg.max-jobs;
      nix.binaryCaches = lib.mkIf (nixCfg ? substituters) nixCfg.substituters;
      nix.binaryCachePublicKeys = lib.mkIf (nixCfg ? trusted-public-keys) nixCfg.trusted-public-keys;
      nix.allowedUsers = lib.mkIf (nixCfg ? allowed-users) nixCfg.allowed-users;
      nix.trustedUsers = lib.mkIf (nixCfg ? trusted-users) nixCfg.trusted-users;
      # nix.autoOptimiseStore = lib.mkIf (nixCfg ? auto-optimise-store) nixCfg.auto-optimise-store;
    }
  ];
}
