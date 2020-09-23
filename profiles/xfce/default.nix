{ config, lib, pkgs, ... }:

{
  # Not much to put here right now
  services.xserver.desktopManager.xfce = {
    enable = true;
    noDesktop = true;
    enableXfwm = true;
  };

  home-manager.users.${config.my.username} = { config, ... }: {
    programs.autorandr.enable = false;
    programs.autorandr.profiles = {

    };
  };
}
