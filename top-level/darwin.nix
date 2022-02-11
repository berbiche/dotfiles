{ config, pkgs, lib, inputs, ... }:

let
  inherit (lib) types;
  nixCfg = config.nix.settings;
in
{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  options.sops = lib.mkSinkUndeclaredOptions { };

  # Temporary fix
  options.nix.settings = lib.mkOption {
    type = types.attrsOf (types.oneOf [ types.str (types.listOf types.str) types.float types.int ]);
  };

  config = lib.mkMerge [
    {
      my.defaults.file-explorer = "";

      nix.nixPath = [
        "nixpkgs=${pkgs.path}"
        "darwin=${inputs.nix-darwin}"
      ];
      nix.sandboxPaths = [
        # Necessary
        "/System/Library/Frameworks"
        # Necessary
        "/System/Library/PrivateFrameworks"
        # Probably necessary
        "/usr/lib"
        # Likely necessary
        # "/private/tmp"
        # Likely necessary
        # "/private/var/tmp"
        # This seems very impure
        # "/usr/bin/env"
      ];

      nix.trustedUsers = [ "@admin" config.my.username ];
      nix.useDaemon = true;
      services.nix-daemon.enable = true;

      nix.gc.user = "root";

      # Disable useless warning about NIX_PATH with a flake configuration
      system.checks.verifyNixPath = false;

      users.nix.configureBuildUsers = true;

      # system.darwinVersion = lib.mkForce (
      #   "darwin" + toString config.system.stateVersion + "." + inputs.nix-darwin.shortRev);
      # system.darwinRevision = inputs.nix-darwin.rev;
      # system.nixpkgsVersion =
      #   "${nixpkgs.lastModifiedDate or nixpkgs.lastModified}.${nixpkgs.shortRev}";
      # system.nixpkgsRelease = lib.version;
      # system.nixpkgsRevision = nixpkgs.rev;
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
