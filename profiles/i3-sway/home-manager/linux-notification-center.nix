{ config, lib, pkgs, ... }:

let
  toggle-notification-center = pkgs.writeScript "toggle-deadd" ''
    ${pkgs.systemd}/bin/systemctl --user kill -s USR1 deadd-notification-center
  '';
in
{
  programs.deadd-notification-center = {
    systemd.enable = true;
    settings = {
      notification-center = {
        # marginTop = 30;
        # Show a maximum of 5 lines in the notification center
        shortenBody = 5;
        parseHtmlEntities = true;
      };

      notification-center-notification-popup = {
        notiDefaultTimeout = 10000;
        distanceTop = 35;
        distanceRight = 15;
        # Show on display with the current cursor
        # followMouse = true;
        # Show a maximum of 3 lines in the notification popup
        shortenBody = 3;
      };
    };

    # Override bad new default color settings
    style = ''
      /* Use old default color */
      label {
          color: #EFF;
      }

      label.notification {
          color: #FFF;
      }

      label.critical {
          color: #FFF;
      }
      .notificationInCenter label.critical {
          color: #FFF;
      }
      .blurredBG, #main_window, .blurredBG.low, .blurredBG.normal {
        background: rgba(29, 27, 20, 0.9)
      }
      .blurredBG.notification {
        background: rgba(9, 0, 0, 0.7)
      }
      .blurredBG.notification.critical {
        background: rgba(255, 0, 50, 0.7)
      }
      .notificationInCenter.critical {
        background: rgba(155, 0, 20, 0.7)
      }

      /* Limit image size */
      image.deadd-noti-center.notification.image {
        margin-left: 10px;
        /* How to set the width? */
      }
    '';
  };

  systemd.user.services.deadd-notification-center = lib.mkIf config.programs.deadd-notification-center.enable {
    # Force running as an XWayland client since I don't need to position
    # the popups manually and that it works fine
    # ConditionEnvironment = [ "!XDG_CURRENT_DESKTOP=sway" ];
    Service.UnsetEnvironment = [ "WAYLAND_DISPLAY" ];
    # Install.WantedBy = lib.mkForce [ "sway-session.target" ];
  };


  xsession.windowManager.i3.config.keybindings = {
    "${config.profiles.i3-sway.modifier}+a" = "exec ${toggle-notification-center}";
  };
}
