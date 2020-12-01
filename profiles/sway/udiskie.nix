{ pkgs, lib, ... }:

{
  systemd.user.services.udiskie = {
    Unit = {
      Description = "Disks automounter";
      Documentation = [ "man:udiskie(8)" ];
      PartOf= [ "graphical-session.target" ];
      Requisite = [ "dbus.socket" ];
      After = [ "dbus.socket" "graphical-session.target" ];
      StartLimitIntervalSec = 1;
    };

    Service = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.udiskie}/bin/udiskie \
          --no-automount \
          --tray \
          --appindicator \
          --file-manager nautilus
      '';
      Restart = "on-failure";
      RestartSec = "1sec";
    };

    Install.WantedBy = [ "sway-session.target" ];
  };
}

