{ pkgs, lib, ... }:

with lib;
let
  overlays-dir = ./overlays;
  nix-files = pipe (builtins.readDir overlays-dir) [
    (filterAttrs (f: v: v == "regular" && hasSuffix ".nix" f && f != "default.nix"))
    (mapAttrsToList (f: _: import (overlays-dir + "/${f}")))
  ];
in
{
  nixpkgs.overlays = nix-files;
}
