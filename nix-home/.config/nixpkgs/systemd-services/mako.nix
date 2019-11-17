pkgs:
{
  mako = {
    Unit = {
      Description = "A lightweight Wayland notification daemon";
      Documentation = "man:mako(1)";
      Requisite = [ "dbus.service" ];
      After = [ "dbus.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "always";
      RestartSec = "1sec";
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}

