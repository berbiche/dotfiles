{ config, lib, pkgs, ... }:

let
  cfg = config.programs.swaylock;
in
{
  options.programs.swaylock = {
    enable = lib.mkEnableOption "swaylock";
    imageFolder = lib.mkOption {
      type = with lib.types; (oneOf [str path]);
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swaylock ];
    xdg.configFile."swaylock/config" = {
      source = pkgs.substituteAll {
        src = ./config;
        inherit (cfg) imageFolder;
      };
    };
  };
}
