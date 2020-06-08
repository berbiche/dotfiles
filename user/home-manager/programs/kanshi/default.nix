{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.kanshi ];
  xdg.configFile."kanshi/config".source = ./config;
}
