{ config, lib, pkgs, ... }:

let
  gnomeDisabled = !config.services.xserver.desktopManager.gnome.enable;
in
{
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr ]
      ++ lib.optional gnomeDisabled [ xdg-desktop-portal-gtk ];
    gtkUsePortal = lib.mkIf gnomeDisabled true;
  };
  services.pipewire.enable = true;

  environment.systemPackages = with pkgs; [ xdg-desktop-portal-wlr ];

  programs.sway.extraSessionCommands = lib.mkBefore ''
    export XDG_CURRENT_DESKTOP=sway XDG_SESSION_TYPE=wayland XDG_SESSION_DESKTOP=sway
  '';
}
