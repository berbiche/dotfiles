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
        }
      '';
    };

    style = mkOption {
      type = types.lines;
      description = "CSS styling for notifications.";
    };
  };

  config = mkIf cfg.enable {

    programs.deadd-notification-center.style = ''
      /* Notification center */

      .blurredBG, #main_window, .blurredBG.low, .blurredBG.normal {
          background: rgba(255, 255, 255, 0.5);
      }

      .noti-center.time {
          font-size: 32px;
      }

      /* Notifications */

      .title {
          font-weight: bold;
          font-size: 16px;
      }

      .appname {
          font-size: 12px;
      }

      .time {
          font-size: 12px;
      }

      .blurredBG.notification {
          background:  rgba(255, 255, 255, 0.4);
      }

      .blurredBG.notification.critical {
          background: rgba(255, 0, 0, 0.5);
      }

      .notificationInCenter.critical {
          background: rgba(155, 0, 20, 0.5);
      }

      /* Labels */

      label {
          color: #322;
      }

      label.notification {
          color: #322;
      }

      label.critical {
          color: #000;
      }
      .notificationInCenter label.critical {
          color: #000;
      }


      /* Buttons */

      button {
          background: transparent;
          color: #322;
          border-radius: 3px;
          border-width: 0px;
          background-position: 0px 0px;
          text-shadow: none;
      }

      button:hover {
          border-radius: 3px;
          background: rgba(0, 20, 20, 0.2);
          border-width: 0px;
          border-top: transparent;
          border-color: #f00;
          color: #fee;
      }


      /* Custom Buttons */

      .userbutton {
          background: rgba(20,0,0, 0.15);
      }

      .userbuttonlabel {
          color: #222;
          font-size: 12px;
      }

      .userbutton:hover {
          background: rgba(20, 0, 0, 0.2);
      }

      .userbuttonlabel:hover {
          color: #111;
      }

      button.buttonState1 {
          background: rgba(20,0,0,0.5);
      }

      .userbuttonlabel.buttonState1 {
          color: #fff;
      }

      button.buttonState1:hover {
          background: rgba(20,0,0, 0.4);
      }

      .userbuttonlabel.buttonState1:hover {
          color: #111;
      }

      button.buttonState2 {
          background: rgba(255,255,255,0.3);
      }

      .userbuttonlabel.buttonState2 {
          color: #111;
      }

      button.buttonState2:hover {
          background: rgba(20,0,0, 0.3);
      }

      .userbuttonlabel.buttonState2:hover {
          color: #000;
      }


      /* Images */

      image.deadd-noti-center.notification.image {
          margin-left: 20px;
      }
    '';

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
