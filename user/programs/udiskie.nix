{ pkgs, ... }:

{
  systemd.user.services.udiskie = {
    Unit = {
      Description = "Disks automounter";
      Documentation = [ "man:udiskie(8)" ];
      PartOf= [ "graphical-session.target" ];
      Requisite = [ "dbus.service" ];
      After = [ "dbus.service" ];
      StartLimitIntervalSec = 1;
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.udiskie}/bin/udiskie ${builtins.concatStringsSep " " [
        "--no-automount"
        "--tray"
        "--appindicator"
        "--file-manager" "nautilus"
      ]}";
      Restart = "on-failure";
      RestartSec = "1sec";
    };

    Install = {
      # No need on KDE/Gnome
      WantedBy = [ "sway-session.target" ];
    };
  };
}

