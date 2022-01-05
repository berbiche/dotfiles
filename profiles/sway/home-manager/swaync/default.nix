{ config, lib, pkgs, ... }:

{
  services.sway-notification-center = {
    settings = {
      positionX = "center";
      positionY = "top";
      timeout = 10;
      timeout-low = 10;
      timeout-critical = 10;
      keyboard-shortcuts = false;
      image-visibility = "when-available";
    };

    style = ./style.css;
  };
}
