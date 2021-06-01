# Displays a graphical prompt for superuser stuff
# in some cases.
# See https://wiki.archlinux.org/index.php/Polkit
{ ... }:

{
  my.home = { config, pkgs, ... }: {
    systemd.user.services.polkit-agent-gnome = {
      Unit = {
        Description = "Polkit GNOME agent";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = [ "XDG_CURRENT_DESKTOP=sway" ];
      };
      Service = {
        # Type = "dbus";
        # BusName = "org.freedesktop.PolicyKit1";
        #PolicyKitBusName = "org.gnome.PolicyKit1.AuthenticationAgent";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "abort";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
