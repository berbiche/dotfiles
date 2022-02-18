{ config, lib, pkgs, ... }:

{
  services.avizo = {
    enable = true;

    settings.default = {
      time = 5.0;
      width = 200;
      height = 150;
      padding = 20;
      block-height = 20;
      block-spacing = 0;
      background = "rgba(66, 66, 66, 0.9)";
      foreground = "rgba(255, 255, 255, 1)";
      bar-bg-color = "rgba(0, 0, 0, 1)";
      y-offset = 0.95;
      border-radius = 20; # px
    };
  };
}
