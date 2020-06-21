let
  sources = import ../nix/sources.nix;
  nixpkgs-mozilla = import sources.nixpkgs-mozilla;
in
nixpkgs-mozilla
