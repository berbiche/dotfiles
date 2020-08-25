{ lib, pkgs, config, ... }:

with lib;
with builtins;
let
  # { "file": "path", "file2": "path" }
  nixFilesIn = dir:
    mapAttrs (name: _: import (dir + "/${name}"))
             (filterAttrs (name: _: hasSuffix ".nix" name) (readDir dir));

  systemdFiles = if builtins.pathExists ./systemd-services
                 then attrValues (nixFilesIn ./systemd-services)
                 else null;
in
{
  systemd.user.services = lib.mkIf (systemdFiles != null)
    (lib.mkMerge (map (x: x { inherit pkgs; }) systemdFiles));

  #
  systemd.user.tmpfiles.rules = lib.optionals (config.systemd.user.services ? clipboard)
    [ "f+ %C/clipboard 0600 - - -" ];
}
