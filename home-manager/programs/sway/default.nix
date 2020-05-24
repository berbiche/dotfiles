{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ sway swayidle ];
  xdg.configFile."sway/config".source = ./config;
  xdg.configFile."sway/window-rules.d".source = ./window-rules.d;
  xdg.configFile."sway/config.d".source = ./config.d;
}
