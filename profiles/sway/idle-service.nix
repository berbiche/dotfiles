{ lib, pkgs, ... }:

{
  my.home = { config, ... }: let
    swaylock  = "${pkgs.swaylock}/bin/swaylock";
    swaymsg   = "${pkgs.sway}/bin/swaymsg";
    playerctl = "${pkgs.playerctl}/bin/playerctl";
    withPlayerctld = lib.optionalString config.services.playerctld.enable "-p playerctld";
    dunstctl  = "${config.services.dunst.package}/bin/dunstctl";
  in {
    services.swayidle = {
      enable = true;

      idlehint = "5 minutes";

      timeout = [
        {
          timeout = "5 minutes";
          command = "${swaylock} -f";
        }
        {
          timeout = "10 minutes";
          command = "${swaymsg} 'output * dpms off'";
          resume = "${swaymsg} 'output * dpms on'";
        }
      ];

      before-sleep = [
        "${playerctl} ${withPlayerctld} pause"
        "${dunstctl} set-paused true"
        "${swaylock} -f"
      ];

      lock = [
        "${dunstctl} set-paused true"
        "${swaylock} -f"
      ];

      unlock = [
        "${dunstctl} set-paused false"
      ];
    };
  };
}
