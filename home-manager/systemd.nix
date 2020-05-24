{ lib, pkgs, config, ... }:

with lib;
with builtins;
let
  # { "file": "path", "file2": "path" }
  nixFilesIn = dir: mapAttrs (name: _: import (dir + "/${name}"))
                            (filterAttrs (name: _: hasSuffix ".nix" name) (readDir dir));

  systemdFiles = attrValues (nixFilesIn ./systemd-services);
in
{
  # #### mkMerge . map $ flip import pkgs $ [  ]
  systemd.user.services = lib.mkMerge (map (x: x pkgs) systemdFiles);

  #
  systemd.user.tmpfiles.rules = lib.optionals (config.systemd.user.services ? clipboard)
    [ "f+ %C/clipboard 0600 - - -" ];
}
