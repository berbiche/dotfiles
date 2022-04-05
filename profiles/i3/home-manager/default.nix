{ config, lib, pkgs, ... }:

{
  imports = [
    ./i3-config.nix
    ./keybindings.nix
    ./modes.nix
    ./binaries.nix
  ];

  options.profiles.i3.binaries = lib.mkOption {
    type = lib.types.attrsOf (lib.types.oneOf [ lib.types.str lib.types.package ]);
  };

  config = {
    home.packages = [ pkgs.playerctl ];

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };
  };
}
