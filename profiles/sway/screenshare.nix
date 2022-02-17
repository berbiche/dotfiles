{ config, lib, pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
    gtkUsePortal = true;
  };
  services.pipewire.enable = true;

  environment.systemPackages = with pkgs; [ xdg-desktop-portal-wlr ];

  programs.sway.extraSessionCommands = lib.mkBefore ''
    export XDG_CURRENT_DESKTOP=sway XDG_SESSION_TYPE=wayland XDG_SESSION_DESKTOP=sway
  '';
}
