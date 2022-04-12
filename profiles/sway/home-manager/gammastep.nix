{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.gammastep ];

  services.gammastep = {
    enable = true;
    tray = true;

    provider = "manual";
    latitude = config.my.location.latitude;
    longitude = config.my.location.longitude;

    temperature.day = 6500;
    temperature.night = 4500;
  };

  services.gammastep.settings = {
    general = {
      fade = 1;
      gamma-day = "0.8:0.7:0.8";
      gamma-night = 0.7;
      # adjustment-method = "wayland";
    };
  };
}
