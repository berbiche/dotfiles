{ pkgs }:

{
  waybar = {
    Unit = {
      Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
      Documentation = "https://github.com/Alexays/Waybar/wiki";
      PartOf = [ "graphical-session.target" ];
      Requisite = [ "dbus.service" ];
      After = [ "dbus.service" ];
    };

    Service = {
      Type = "dbus";
      BusName = "fr.arouillard.waybar";
      ExecStart = "${pkgs.waybar}/bin/waybar";
      Restart = "on-failure";
      RestartSec = 1;
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
