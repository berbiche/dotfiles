{ config, lib, pkgs, ... }:

let
  gnomeDisabled = !config.services.xserver.desktopManager.gnome.enable
    && config.services.xserver.desktopManager.gnome.flashback.customSessions == [];
in
{
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ]
      ++ lib.optionals gnomeDisabled [ pkgs.xdg-desktop-portal-gtk ];
  };
  services.pipewire.enable = true;

  environment.systemPackages = with pkgs; [ xdg-desktop-portal-wlr ];

  programs.sway.extraSessionCommands = lib.mkBefore ''
    export XDG_CURRENT_DESKTOP=sway XDG_SESSION_TYPE=wayland XDG_SESSION_DESKTOP=sway
  '';
}
