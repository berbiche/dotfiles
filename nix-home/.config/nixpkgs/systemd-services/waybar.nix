pkgs:
{
  waybar = {
    Unit = {
      Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
      Documentation = "https://github.com/Alexays/Waybar/wiki";
      Requisite = [ "dbus.service" ];
      After = [ "dbus.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    
    Service = {
      Type = "dbus";
      BusName = "fr.arouillard.waybar";
      ExecStart = "${pkgs.waybar}/bin/waybar";
      Restart = "always";
      RestartSec = "1sec";
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
