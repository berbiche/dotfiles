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

    xdg.configFile."swaylock/config".text = ''
      # -*- mode: conf-unix -*-
      # Swaylock configuration file

      color=000000

      # Integrated display
      image=eDP-1:${cfg.imageFolder}/3840x2160.png
      image=DP-1:${cfg.imageFolder}/3840x2160.png

      # BenQ 4K
      #image="Unknown BenQ EW3270U 74J08749019":${cfg.imageFolder}/3840x2160.png
      image=DP-8:${cfg.imageFolder}/3840x2160.png
      image=DP-7:${cfg.imageFolder}/3840x2160.png

      # 2 x Dell 1K
      #image=Dell Inc. DELL U2414H R9F1P55S45FL:${cfg.imageFolder}/1080x1920.png
      #image="Dell Inc. DELL U2414H R9F1P55S45FL":${cfg.imageFolder}/1080x1920.png
      image=HDMI-A-2:${cfg.imageFolder}/1080x1920.png
      image=DP-4:${cfg.imageFolder}/1080x1920.png

      indicator-caps-lock
      show-keyboard-layout
      ignore-empty-password
      #show-failed-attempts
    '';
  };
}
