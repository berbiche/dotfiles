{ pkgs, ... }:

let
  redshiftOverlay = (import ./nixpkgs-wayland/default.nix);
in
{
  allowUnfree = true;

  environment.systemPackages = [ pkgs.redshift-wayland ];

  nixpkgs.overlays = [ redshiftOverlay ];
}
