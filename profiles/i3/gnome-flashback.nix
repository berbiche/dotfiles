{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.i3.flashback;
  i3Cfg = config.services.xserver.windowManager.i3;
in
{
  options.profiles.i3.flashback.enable = lib.mkEnableOption "custom i3 session with Gnome Flashback";

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = config.services.xserver.windowManager.i3.enable;
      message = ''
        The option 'services.xserver.windowManager.i3.enable' must be set to true
        to enable support for Gnome Flashback with i3.
      '';
    }];

    services.xserver.displayManager.job.executeUserXsession = false;

    services.xserver.desktopManager.gnome.flashback.customSessions = [rec {
      wmName = "i3-flashback";
      wmLabel = "i3-flashback";
      wmCommand = toString (pkgs.writeShellScript "i3-flashback" ''
        if [ -n "$DESKTOP_AUTOSTART_ID" ]; then
            ${pkgs.dbus.out}/bin/dbus-send --print-reply --session --dest=org.gnome.SessionManager "/org/gnome/SessionManager" org.gnome.SessionManager.RegisterClient "string:${wmLabel}" "string:$DESKTOP_AUTOSTART_ID"
        fi

        ${i3Cfg.extraSessionCommands}
        if [ -f "$HOME/.xsession" -a -x "$HOME/.xsession" ]; then
          "$HOME/.xsession"
        else
          ${i3Cfg.package}/bin/i3
        fi

        if [ -n "$DESKTOP_AUTOSTART_ID" ]; then
          ${pkgs.dbus.out}/bin/dbus-send --print-reply --session --dest=org.gnome.SessionManager "/org/gnome/SessionManager" org.gnome.SessionManager.Logout "uint32:1"
        fi
      '');
      enableGnomePanel = true;
    }];

    my.home = {
      dconf.settings = {
        "org/gnome/gnome-flashback" = {
          desktop = false;
          root-background = true;
        };
        "org/gnome/gnome-flashback/desktop" = {
          show-icons = false;
        };
      };
      profiles.i3-sway.notifications = lib.mkDefault "none";
    };
  };
}
