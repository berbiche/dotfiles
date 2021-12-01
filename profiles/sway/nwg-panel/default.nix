{ config, lib, pkgs, ... }:

{
  options.programs.nwg-panel.enable = lib.mkEnableOption "nwg-panel";

  config = lib.mkIf config.programs.nwg-panel.enable {
    home.packages = [ pkgs.nwg-panel pkgs.nwg-menu ];

    xdg.configFile."nwg-panel/config" = { source = ./config; force = true; };
    xdg.configFile."nwg-panel/menu-start.css" = { source = ./menu-start.css; force = true; };
    xdg.configFile."nwg-panel/style.css" = { source = ./style.css; force = true; };

    systemd.user.services.nwg-panel = {
      Unit = {
        Description = "Customizable Wayland bar for Sway";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        X-Restart-Triggers = [
          ./config
          ./menu-start.css
          ./style.css
        ];
      };
      Service = {
        Type = "simple";
        ExecStart = pkgs.writeShellScript "nwg-panel-wrapper" ''
          export PATH=${lib.makeBinPath [ pkgs.playerctl pkgs.curl pkgs.gnome.nautilus ]}:''${PATH:+':'}$PATH
          exec ${pkgs.nwg-panel}/bin/nwg-panel "$@"
        '';
        Restart = "on-failure";
        RestartSec = "1sec";
        KillMode = "mixed";
      };
      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
