{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.bat ];
  xdg.configFile."bat/config".source = ./config;
}
