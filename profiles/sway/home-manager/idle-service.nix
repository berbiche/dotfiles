{ config, lib, pkgs, ... }:

let
  # lock  = "${pkgs.swaylock}/bin/swaylock --daemonize";
  lock  = "${pkgs.gtklock}/bin/gtklock --daemonize -s ${config.xdg.configHome}/gtklock/style.css";
  swaymsg   = "${pkgs.sway}/bin/swaymsg";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  withPlayerctld = lib.optionalString config.services.playerctld.enable "-p playerctld";
  dunstctl  = "${config.services.dunst.package}/bin/dunstctl";
in
{
  services.swayidle = {
    enable = true;

    idlehint = "5 minutes";

    timeout = [
      {
        timeout = "5 minutes";
        command = [
          "${lock}"
          # "${swaymsg} 'input type:pointer events disabled'"
          "${swaymsg} 'seat default idle_wake keyboard touchpad switch'"
        ];
        resume = [
          # "${swaymsg} 'input type:pointer events enabled'"
          "${swaymsg} 'seat default idle_wake keyboard pointer touchpad touch switch tablet_pad tablet_tool'"
        ];
      }
      {
        timeout = "10 minutes";
        command = [
          "${swaymsg} 'output * dpms off'"
        ];
        resume = [
          "${swaymsg} 'output * dpms on'"
        ];
      }
    ];

    beforeSleep = [
      "${playerctl} ${withPlayerctld} pause"
      "${dunstctl} set-paused true"
      "${lock}"
    ];

    lock = [
      "${dunstctl} set-paused true"
      "${lock}"
    ];

    unlock = [
      "${dunstctl} set-paused false"
    ];
  };
}
