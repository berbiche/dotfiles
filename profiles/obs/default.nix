{ config, lib, pkgs, ... } :

{
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  environment.etc."modprobe.d/v4l2loopback.conf".text = ''
    options v4l2loopback exclusive_caps=1 video_nr=10 card_label="OBS Virtual Output"
  '';

  my.home.programs.obs-studio = {
    enable = true;
    plugins = with pkgs; [ obs-wlrobs obs-v4l2sink /*obs-xdg-portal*/ ];
  };
}
