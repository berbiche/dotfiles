{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.sway-notification-center;

  generator = pkgs.formats.json { };
in
{
  options.services.sway-notification-center = {
    enable = mkEnableOption "sway notification center";

    package = mkOption {
      type = types.package;
      default = pkgs.swaynotificationcenter;
      defaultText = "pkgs.swaynotificationcenter";
      description = ''
        Package to use. Binary is expected to be called "swaync".
      '';
    };

    settings = mkOption {
      type = generator.type;
      default = { };
      description = ''
        Settings for the notification center.
        More information about the settings can be found on the project's homepage.
      '';
      example = literalExpression ''
        {
          positionX = "center";
          positionY = "top";
          timeout = 10;
          timeout-low = 5;
          keyboard_shortcuts = false;
          image-visibility = "always";
        }
      '';
    };

    style = mkOption {
      type = types.nullOr (types.either types.lines types.path);
      description = "CSS styling for notifications. Accepts a path to a CSS file.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."swaync/config.json" = mkIf (cfg.settings != { }) ({
      source = generator.generate "swaync-config.json" cfg.settings;
      onChange = "${cfg.package}/bin/swaync-client --reload-config --skip-wait || true";
    });

    xdg.configFile."swaync/style.css" = let
      config = if builtins.isPath cfg.style || lib.isStorePath cfg.style
        then { source = cfg.style; }
        else { text = cfg.style; };
    in mkIf (cfg.style != null) (config // {
      onChange = "${cfg.package}/bin/swaync-client --reload-config --skip-wait || true";
    });

    systemd.user.services.swaync = {
      Unit = {
        Description = "SwayNotificationCenter";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        # We don't pass the path to the nix store configuration file to allow reloading
        # without restarting the service
        ExecStart = "${cfg.package}/bin/swaync";
        ExecReload = "${cfg.package}/bin/swaync-client -R";
        Restart = "on-failure";
        RestartSec = "1sec";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
