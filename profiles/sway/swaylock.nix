{ config, lib, pkgs, ... }:

let
  cfg = config.programs.swaylock;
in
{
  options.programs.swaylock = {
    enable = lib.mkEnableOption "swaylock";
    imageFolder = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swaylock ];

    xdg.configFile."swaylock/config".text = ''
      # Swaylock configuration file
      color=173f3f

      # Integrated display
      image=eDP-1:${cfg.imageFolder}/current
      image=DP-1:${cfg.imageFolder}/current
      image=:${cfg.imageFolder}/current

      indicator-caps-lock
      show-keyboard-layout
      ignore-empty-password
      #show-failed-attempts
    '';
  };
}
