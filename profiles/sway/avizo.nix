{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.avizo ];

  # wayland.windowManager.sway = {
  #   config.startup = [{
  #     command = "${pkgs.avizo}/bin/avizo-service";
  #   }];
  # };

  systemd.user.services.avizo = {
    Unit = {
      Description = "Lightweight notification daemon for Wayland";
      PartOf = [ "graphical-session.target" ];
      # Requisite = [ "dbus.service" ];
      After = [ "graphical-session.target" # "dbus.service"
              ];
    };

    Service = {
      Type = "dbus";
      BusName = "org.danb.avizo.service";

      # Changed to `Type = simple` to prevent waiting for the busname to appear
      # because Avizo waits for xdg-desktop-portal to start
      # which takes a long time
      # Type = "simple";

      ExecStart = "${pkgs.avizo}/bin/avizo-service";
      Restart = "on-failure";
      RestartSec = 1;
    };

    Install.WantedBy = [ "sway-session.target" ];
  };
}
