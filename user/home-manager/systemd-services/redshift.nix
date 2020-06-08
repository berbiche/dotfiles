pkgs:
{
  redshift = {
    Unit = {
      Description = "Adjusts the color temperature of your screen according to your surroundings";
      Documentation = [ "man:udiskie(1)" ];
      PartOf= [ "graphical-session.target" ];
      Requisite = [ "dbus.service" ];
      StartLimitIntervalSec = 1;
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.redshift-wayland}/bin/redshift -m wayland";
      Restart = "always";
      RestartSec = "5sec";
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
