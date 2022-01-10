{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.avizo;

  iniFormat = pkgs.formats.ini { };
in
{
  options.services.avizo = {
    enable = mkEnableOption "volume/brightness notification daemon. Note that avizo needs to be invoked by it's client <command>avizo-client</command> to display any notifications";

    package = mkOption {
      type = types.package;
      default = pkgs.avizo;
      defaultText = literalExpression "pkgs.avizo";
      description = "Package providing <command>avizo-service</command>.";
    };

    settings = mkOption {
      type = iniFormat.type;
      default = { };
      defaultText = literalExpression "{ }";
      example = ''
        {
          default = {
            width = 200;
            height = 150;
            padding = 24;
            background = "rgba(255, 255, 255, 0)";
          };
        }
      '';
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      defaultText = literalExpression "[ ]";
      description = "Extra arguments to pass to <command>avizo-service</command>";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."avizo/config.ini".source = iniFormat.generate "avizo-config.ini" cfg.settings;

    systemd.user.services.avizo = {
      Unit = {
        Description = "Lightweight notification daemon for Wayland";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "dbus";
        BusName = "org.danb.avizo.service";
        ExecStart = "${cfg.package}/bin/avizo-service ${escapeShellArgs cfg.extraArgs}";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
