{ config, lib, pkgs, ... }:

{
  services.xidlehook = {
    enable = true;
    not-when-fullscreen = true;
    timers = [{
      # 15 minutes
      delay = 60 * 15;
      command = "${pkgs.lightlocker}/bin/light-locker-command -l";
    }];
  };
  systemd.user.services.xidlehook = {
    Install.WantedBy = lib.mkForce [ "x11-session.target" ];
  };

  systemd.user.services.xfce4-notifyd = {
    Unit = {
      Description = "XFCE notification service";
      PartOf = [ "graphical-session.target" ];
      Requires = [ "x11-session.target" ];
      After = [ "x11-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.xfce.xfce4-notifyd}/lib/xfce4/notifyd/xfce4-notifyd";
    };
    Install.WantedBy = [ "x11-session.target" ];
  };
}
