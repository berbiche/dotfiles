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
      example = literalExpression ''
        {
          notification-center = {
            marginTop = 30;
            width = 500;
          };
          notification-center-notification-popup = {
            width = 300;
            shortenBody = 3;
          };
        }
      '';
    };

    style = mkOption {
      type = types.lines;
      description = "CSS styling for notifications.";
    };
  };

  config = mkIf cfg.enable {

    xdg.configFile."deadd/deadd.conf".source = generator.generate "deadd.conf" cfg.settings;

    xdg.configFile."deadd/deadd.css".text = cfg.style;

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
        # We need locale from glibc (and to inherit the $PATH)
        # See https://github.com/phuhl/linux_notification_center/issues/63
        ExecStart = "${pkgs.runtimeShell} -l -c ${cfg.package}/bin/deadd-notification-center";
        Restart = "always";
        RestartSec = "1sec";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
