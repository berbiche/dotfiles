let
  sources = import ../nix/sources.nix;
  nixpkgs-wayland = import sources.nixpkgs-wayland;
in
nixpkgs-wayland
