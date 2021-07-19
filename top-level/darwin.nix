{ config, pkgs, lib, inputs, ... }:

{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  nix.gc.user = args.username;
  nix.nixPath = [
    "nixpkgs=${pkgs.path}"
    "darwin=${inputs.nix-darwin}"
  ];

  # Disable useless warning about NIX_PATH with a flake configuration
  system.checks.verifyNixPath = false;

  # system.darwinVersion = lib.mkForce (
  #   "darwin" + toString config.system.stateVersion + "." + inputs.nix-darwin.shortRev);
  # system.darwinRevision = inputs.nix-darwin.rev;
  # system.nixpkgsVersion =
  #   "${nixpkgs.lastModifiedDate or nixpkgs.lastModified}.${nixpkgs.shortRev}";
  # system.nixpkgsRelease = lib.version;
  # system.nixpkgsRevision = nixpkgs.rev;
}
