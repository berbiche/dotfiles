{ config, lib, pkgs, ... }:

{
  programs.mako = {
    enable = true;
    # Display in center
    anchor = "top-right";
    # Show on my primary output
    output = "DP-1";

    font = "Ubuntu 16";
    width = 400 /*px*/;
    height = 200 /*px*/;

    icons = true;
    markup = true;
    actions = true;
    defaultTimeout = 10000;
    ignoreTimeout = true;

    # Color settings
    # backgroundColor = "#f4a742F0";
    # textColor = "#000000";
    # borderColor = "#f4a742";
    borderRadius = 5;

    # Wofi styling
    backgroundColor = "#282C34";
    textColor = "#808080";
  };

  systemd.user.services.mako = {
    Unit = {
      Description = "A lightweight Wayland notification daemon";
      Documentation = "man:mako(1)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      X-Restart-Triggers = [ "${config.xdg.configFile."mako/config".source}" ];
    };

    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      ExecReload = "${pkgs.mako}/bin/makoctl reload";
      Restart = "always";
      RestartSec = "1sec";
    };

    Install.WantedBy = [ "wayland-session.target" ];
  };
}
