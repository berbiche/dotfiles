# Displays a graphical prompt for superuser stuff in some cases.
# See https://wiki.archlinux.org/index.php/Polkit
args@{ config, lib, pkgs, ... }:

let
  # flashbackDisabled = !(args.osConfig.profiles.i3.flashback.enable or false);
in
{
  systemd.user.services.polkit-agent-gnome = {
    Unit = {
      Description = "Polkit GNOME agent";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
      ConditionEnvironment = [ "XDG_CURRENT_DESKTOP=sway" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-abort";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
