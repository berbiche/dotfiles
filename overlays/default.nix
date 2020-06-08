{ pkgs, lib, ... }:

let
  inherit (lib) hasSuffix filterAttrs mapAttrsToList;
  nix-files = mapAttrsToList (f: _: import (./. + "/${f}"))
                             (filterAttrs (f: v: v == "regular" && hasSuffix ".nix" f && f != "default.nix")
                                          (builtins.readDir ./.));
in
{
  nixpkgs.overlays = nix-files;
}
