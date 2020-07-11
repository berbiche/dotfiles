{ config, lib, pkgs, ... }:

{
  programs.mako = {
    enable = true;
    # Display in center
    anchor = "top-right";
    # Show on my primary output
    output = "DP-1";

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
    # restartTriggers = [ config.xdg.configFile."mako/config" ];

    Unit = {
      Description = "A lightweight Wayland notification daemon";
      Documentation = "man:mako(1)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      ExecReload = "${pkgs.mako}/bin/makoctl reload";
      Restart = "always";
      RestartSec = "1sec";
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };

  home.activation.reloadMako = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if systemctl --user is-active mako.service; then
      echo "Reloading Mako"
      $DRY_RUN_CMD systemctl --user reload mako.service
    fi
  '';
}
