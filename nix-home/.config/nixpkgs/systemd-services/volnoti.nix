pkgs:
{
  volnoti = {
    Unit = {
      Description = "Lightweight volume notification daemon";
      Requisite = [ "dbus.service" ];
      After = [ "dbus.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.volnoti}/bin/volnoti -n";
      Restart = "on-failure";
      RestartSec = "1sec";
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
