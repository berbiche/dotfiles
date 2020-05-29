{ config
, pkgs
, image-folder ? config.xdg.userDirs.pictures
, ... }:

let
  imageFolder = config.xdg.userDirs.pictures + "/wallpaper";
  config-swaylock = pkgs.substituteAll {
    src = ./config;
    inherit imageFolder;
  };
in
{
  home.packages = [ pkgs.swaylock ];
  xdg.configFile."swaylock/config" = {
    source = config-swaylock;
  };
}
