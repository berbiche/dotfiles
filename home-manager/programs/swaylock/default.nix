{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ swaylock ];
  xdg.configFile."swaylock/config".source = ./config;
}
