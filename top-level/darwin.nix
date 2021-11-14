{ config, pkgs, lib, inputs, ... }:

{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

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
