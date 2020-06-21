let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  nixops = (import sources.nixops).default;
in
pkgs.mkShell {
  buildInputs = [ nixops ];
}
