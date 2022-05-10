{ config, lib, pkgs, ... }:

{
  imports = [ ./gnome-flashback.nix ];

  services.xserver.windowManager.qtile = {
    enable = true;
    package = pkgs.qtile;
  };

  my.home = {
    imports = [ ./home-manager ];
  };
}
