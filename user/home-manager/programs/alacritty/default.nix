{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.alacritty ];
  xdg.configFile."alacritty/alacritty.yml".source = ./alacritty.yml;
}
