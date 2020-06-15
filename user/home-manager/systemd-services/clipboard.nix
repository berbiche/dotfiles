{ pkgs }:

{
  clipboard = {
    Unit = {
      Description = "A custom Wayland clipboard manager";
      PartOf= [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "%h/scripts/clipboard-monitor.sh";
      Restart = "always";
      RestartSec = "5sec";
    };

    #Install = {
    #  WantedBy = [ "sway-session.target" ];
    #};
  };
}
