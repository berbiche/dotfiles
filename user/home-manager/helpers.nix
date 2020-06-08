{ config, lib, pkgs, ... }:

with lib;
with builtins;
{
  # { "file": "path", "file2": "path" }
  nixFilesIn = dir: mapAttrs (name: _: import (dir + "/${name}"))
    (filterAttrs (name: _: hasSuffix ".nix" name) (readDir dir));
}
