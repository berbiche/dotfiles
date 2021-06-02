{ config, lib, pkgs, ... }:

{
  my.home = { config, ... }: {
    home.packages = [ pkgs.gammastep ];

    systemd.user.services.gammastep = {
      Unit = {
        Description = "Display colour temperature adjustment";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        X-Restart-Triggers = [ "${config.xdg.configFile."gammastep/config.ini".source}" ];
      };
      Service = {
        ExecStart = "${pkgs.gammastep}/bin/gammastep-indicator";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "sway-session.target" ];
    };

    xdg.configFile."gammastep/config.ini".text = ''
      [general]
      temp-day=6500
      temp-night=4000
      fade=1
      gamma-day=0.8:0.7:0.8
      gamma-night=0.6
      location-provider=manual
      adjustment-method=wayland

      [manual]
      lat=45.50
      lon=-73.56
    '';
  };
}
