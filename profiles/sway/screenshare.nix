{ config, lib, pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
    gtkUsePortal = true;
  };
  services.pipewire.enable = true;

  environment.systemPackages = with pkgs; [ xdg-desktop-portal-wlr ];
}
