pkgs:
{
  udiskie = {
    Unit = {
      Description = "Disks automounter";
      Documentation = [ "man:udiskie(8)" ];
      PartOf= [ "graphical-session.target" ];
      Requisite = [ "dbus.service" ];
      StartLimitIntervalSec = 1;
    };
    
    Service = {
      Type = "simple";
      ExecStart = builtins.concatStringsSep " " [
        ''"${pkgs.udiskie}/bin/udiskie"''
        "--use-udisks2" "--no-automount" "--tray"
        "--appindicator" "--file-manager" "nautilus"
      ];
      Restart = "on-failure";
      RestartSec = "1sec";
    };

    Install = {
      # WantedBy = [ "graphical-session.target" ];
    };
  };
}

