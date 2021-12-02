{ config, lib, pkgs, ... }:

{
  systemd.user.services.gsettingsd = {
    Unit = {
      Description = "xsettingsd daemon for xwayland applications that read and expect an xsettings configuration.";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      # ConditionEnvironment = [ "XDG_CURRENT_DESKTOP=sway" ];
    };

    Service = {
      Type = "dbus";
      BusName = "org.gtk.Settings";
      ExecStart = "${pkgs.gnome3.gnome-settings-daemon}/libexec/gsd-xsettings";
      Restart = "on-failure";
    };

    Install.WantedBy = [ "sway-session.target" ];
  };
}
