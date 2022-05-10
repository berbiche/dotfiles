{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.qtile.flashback;
  qtileCfg = config.services.xserver.windowManager.qtile;
in
{
  options.profiles.qtile.flashback.enable = lib.mkEnableOption "custom qtile session with Gnome Flashback";

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = config.services.xserver.windowManager.qtile.enable;
      message = ''
        The option 'services.xserver.windowManager.qtile.enable' must be set to true
        to enable support for Gnome Flashback with qtile.
      '';
    }];

    services.xserver.displayManager.job.executeUserXsession = false;

    services.xserver.desktopManager.gnome.flashback.customSessions = [rec {
      wmName = "qtile-flashback";
      wmLabel = "qtile-flashback";
      wmCommand = toString (pkgs.writeShellScript "qtile-flashback" ''
        if [ -n "$DESKTOP_AUTOSTART_ID" ]; then
            ${pkgs.dbus.out}/bin/dbus-send --print-reply --session --dest=org.gnome.SessionManager "/org/gnome/SessionManager" org.gnome.SessionManager.RegisterClient "string:${wmLabel}" "string:$DESKTOP_AUTOSTART_ID"
        fi

        if [ -f "$HOME/.xsession" -a -x "$HOME/.xsession" ]; then
          "$HOME/.xsession"
        else
          ${qtileCfg.package}/bin/qtile
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
