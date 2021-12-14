{ config, lib, pkgs, ... }:

{
  services.sway-notification-center = {
    settings = {
      positionX = "center";
      positionY = "top";
      timeout = 10;
      timeout-low = 10;
      keyboard_shortcuts = false;
      image-visibility = "when-available";
    };

    style = ./style.css;
  };
}
