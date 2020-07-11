{ pkgs }:

{
  nm-applet = {
    Unit = {
      Description = "Network manager applet";
      Documentation = "man:swayidle(1)";
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
      Restart = "always";
      RestartSec = "1sec";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
