{ config, lib, pkgs, ... }:

{
  services.sway-notification-center = {
    settings = {
      positionX = lib.mkDefault "center";
      positionY = "top";
      control-center-height = 600;
      control-center-margin-top = 5;
      control-center-margin-bottom = 5;
      control-center-margin-right = 5;
      control-center-margin-left = 5;
      timeout = 10;
      timeout-low = 10;
      timeout-critical = 10;
      keyboard-shortcuts = false;
      image-visibility = "when-available";
    };

    style = ./style.css;
  };
}
