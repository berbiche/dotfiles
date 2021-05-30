{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.deadd-notification-center;

  generator = pkgs.formats.ini { };
in
{
  options.programs.deadd-notification-center = {
    enable = mkEnableOption "deadd notification center";

    package = mkOption {
      type = types.package;
      default = pkgs.deadd-notification-center;
      defaultText = "pkgs.deadd-notification-center";
      description = ''
        Package to use. Binary is expected to be called "deadd-notification-center".
      '';
    };

    systemd.enable = mkEnableOption "deadd notification center systemd service";

    settings = mkOption {
      default = { };
      type = generator.type;
      description = ''
        Settings for the notification center.
        More information about the settings can be found on the project's homepage.
      '';
      example = literalExample ''
        {
          notification-center = {
            marginTop = 30;
            width = 500;
          };
          notification-center-notification-popup = {
            width = 300;
            shortenBody = 3;
          };
          colors = {
            background = "rgba(29, 27, 20, 0.7)";
            notiBackground = "rgba(9, 0, 0, 0.6)";
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."deadd/deadd.conf".source = generator.generate "deadd.conf" cfg.settings;

    systemd.user.services.deadd-notification-center = mkIf cfg.systemd.enable {
      Unit = {
        Description = "Deadd Notification Center";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        X-Restart-Triggers = [ "${config.xdg.configFile."deadd/deadd.conf".source}" ];
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        # We need locale from glibc
        # See https://github.com/phuhl/linux_notification_center/issues/63
        Environment = [ "PATH=${lib.makeBinPath [ pkgs.glibc ]}:$PATH" ];
        ExecStart = "${cfg.package}/bin/deadd-notification-center";
        Restart = "always";
        RestartSec = "1sec";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
