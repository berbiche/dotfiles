{ config, lib, pkgs, ... }:

{
  my.home = {
    services.picom = {
      enable = true;
      backend = "glx";
      experimentalBackends = true;
      vSync = true;
      fade = true;
      shadow = true;
      # These were copied from some website (which one ??)
      shadowExclude = [
        "window_type *= 'menu'"
        "name ~= 'Firefox\$'"
        "focused = 1"
        "n:e:Notification"
        "n:e:Docky"
        "g:e:Synapse"
        "g:e:Conky"
        "n:w:*Firefox*"
        "n:w:*Chromium*"
        "n:w:*dockbarx*"
        "class_g ?= 'Cairo-dock'"
        "class_g ?= 'Xfce4-panel'"
        "class_g ?= 'Xfce4-notifyd'"
        "class_g ?= 'Xfce4-power-manager'"
        "class_g ?= 'Notify-osd'"
        "_GTK_FRAME_EXTENTS@:c"
      ];
      extraOptions = ''
        use-ewmh-active-win = true
      '';
    };

    systemd.user.services.picom.Install.WantedBy = lib.mkForce [ "x11-session.target" ];
  };
}
