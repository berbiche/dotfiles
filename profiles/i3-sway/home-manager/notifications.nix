{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.i3-sway.notifications;

  enableDunst = cfg == "dunst";
  enableSwaync = cfg == "swaync";
  enableDeadd = cfg == "linux-notification-center";
in
{
  options.profiles.i3-sway.notifications = lib.mkOption {
    type = lib.types.enum [ "none" "swaync" "linux-notification-center" "dunst" ];
    default = "swaync";
  };

  config = lib.mkIf (cfg != "none") {
    services.dunst.enable = enableDunst;
    services.sway-notification-center.enable = enableSwaync;
    programs.deadd-notification-center.enable = enableDeadd;
  };
}
