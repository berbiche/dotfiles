{ ... }:

{
  my.home = { config, pkgs, ... }: {
    systemd.user.services.gsettingsd = {
      Unit = {
        Description = "xsettingsd daemon for xwayland applications that read and expect an xsettings configuration.";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "dbus";
        BusName = "org.gtk.Settings";
        ExecStart = "${pkgs.gnome3.gnome-settings-daemon}/libexec/gsd-xsettings";
        Restart = "failure";
      };

      Install.WantedBy = [ "wayland-session.target" ];
    };
  };
}
