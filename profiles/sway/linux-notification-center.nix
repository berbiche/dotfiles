{ config, inputs, lib, pkgs, ... }:

let
  mod = config.wayland.windowManager.sway.config.modifier;

  toggle-notification-center = pkgs.writeScript "toggle-deadd" ''
    ${pkgs.systemd}/bin/systemctl --user kill -s USR1 deadd-notification-center
  '';
in
{
  programs.deadd-notification-center = {
    enable = true;
    systemd.enable = true;
    package = pkgs.my-nur.deadd-notification-center;
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

      colors = {
        background = "rgba(29, 27, 20, 0.9)";
        notiBackground = "rgba(9, 0, 0, 0.7)";
        critical = "rgba(255, 0, 50, 0.7)";
        criticalInCenter = "rgba(155, 0, 20, 0.7)";
      };
    };
  };

  systemd.user.services.deadd-notification-center = {
    # Force running as an XWayland client since I don't need to position
    # the popups manually and that it works fine
    Service.Environment = [ "WAYLAND_DISPLAY=" ];
    Unit.After = [ "wayland-session.target" ];
    Unit.Requires = [ "wayland-session.target" ];
    Install.WantedBy = lib.mkForce [ "wayland-session.target" ];
  };


  wayland.windowManager.sway.config = {
    # window.commands = [{
    #   criteria = { app_id = "deadd-notification-center"; };
    #   command = lib.concatStringsSep "; " [
    #     "no_focus"
    #     "floating enable"
    #     "border none"
    #     "exec ${move-to-corner}"
    #   ];
    # }];
    keybindings = {
      "--no-warn --no-repeat ${mod}+a" = "exec ${toggle-notification-center}";
    };
  };
}
