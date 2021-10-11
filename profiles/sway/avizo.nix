{ lib, pkgs, ... }:

{
  my.home = {
    home.packages = [ pkgs.avizo ];

    systemd.user.services.avizo = {
      Unit = {
        Description = "Lightweight notification daemon for Wayland";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "dbus";
        BusName = "org.danb.avizo.service";
        ExecStart = "${pkgs.avizo}/bin/avizo-service";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
