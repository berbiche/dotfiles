let
  sources = import ./nix;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  buildInputs = [ pkgs.niv ];
}
