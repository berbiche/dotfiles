{ config, pkgs, ... }:

{
  services.xserver.windowManager.herbstluftwm.enable = true;

  my.home = {
    xsession.windowManager.herbstluftwm = {
      enable = true;
    };
  };
}
