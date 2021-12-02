{ config, lib, pkgs, ... }:

let
  cfg = config.programs.swaylock;
in
{
  options.programs.swaylock = {
    enable = lib.mkEnableOption "swaylock";
    imagePath = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swaylock ];

    xdg.configFile."swaylock/config".text = let
      removeHash = lib.replaceChars [ "#" ] [ "" ];
      color1 = removeHash config.my.colors.color11;
      color2 = removeHash config.my.colors.color12;
    in ''
      # Swaylock configuration file
      # color=173f3f

      # Integrated display
      image=eDP-1:${cfg.imagePath}
      image=DP-1:${cfg.imagePath}
      image=:${cfg.imagePath}

      indicator-caps-lock
      show-keyboard-layout
      ignore-empty-password
      indicator-idle-visible
      #show-failed-attempts

      ring-color=${color1}
      ring-caps-lock-color=${color1}
      ring-clear-color=${color1}
      key-hl-color=${color2}
      inside-color=00000000
      inside-clear-color=00000000
      text-color=FFFFFF
      text-caps-lock-color=FFFFFF
      text-clear-color=FFFFFF
    '';
  };
}
