{ pkgs, ... }:

{
  my.home = {
    # To use with `volnoti-show` to display a transparent window with the volume level
    systemd.user.services.volnoti = {
      Unit = {
        Description = "Lightweight volume notification daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "dbus";
        BusName = "uk.ac.cam.db538.volume-notification";
        ExecStart = "${pkgs.volnoti}/bin/volnoti -n";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
