{ config, lib, pkgs, ... }:

let
in
{
  my.home = { config, ... }: {
    options.programs.nwg-panel.enable = lib.mkEnableOption "nwg-panel";

    config = lib.mkIf config.programs.nwg-panel.enable {
      home.packages = [ pkgs.my-nur.nwg-panel pkgs.my-nur.nwg-menu ];

      xdg.configFile."nwg-panel/config" = { source = ./config; force = true; };
      xdg.configFile."nwg-panel/menu-start.css" = { source = ./menu-start.css; force = true; };
      xdg.configFile."nwg-panel/style.css" = { source = ./style.css; force = true; };

      systemd.user.services.nwg-panel = {
        Unit = {
          Description = "Customizable Wayland bar for Sway";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          X-Restart-Triggers = map (x: toString config.xdg.configFile."${x}".source) [
            "nwg-panel/config"
            "nwg-panel/menu-start.css"
            "nwg-panel/style.css"
          ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.my-nur.nwg-panel}/bin/nwg-panel";
          Environment = [
            "PATH=${lib.makeBinPath (with pkgs; [ playerctl curl gnome.nautilus curl ])}:$PATH"
          ];
          Restart = "on-failure";
          RestartSec = "1sec";
          KillMode = "mixed";
        };
        Install.WantedBy = [ "sway-session.target" ];
      };
    };
  };
}
