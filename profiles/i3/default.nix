{ config, lib, pkgs, ... }:

{
  imports = [ ./gnome-flashback.nix ];

  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
  };

  my.home = {
    imports = [ ./home-manager ];
  };
}
