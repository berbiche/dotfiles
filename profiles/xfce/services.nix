#
# Services
#
# - Redshift: color, brightness and gamma adjustement for dark environment (night)
# - Flameshot: screenshot tool, though I use the XFCE-one in my i3 configuration
# - xfce4-notifyd: a notification daemon and service
# - random-background: self-explanatory, a service to rotate my backgrounds automatically
# - wallutils: background rotation
# - xidlehook: idle management daemon for X11
#
{ ... }:

{
  my.home = { config, lib, pkgs, ... }: with lib; {
    services.redshift = {
      enable = true;
      tray = true;
      provider = "geoclue2";
      temperature.day = 6500;
      temperature.night = 4000;
    };
    systemd.user.services.redshift = {
      Install.WantedBy = mkForce [ "x11-session.target" ];
    };

    services.flameshot.enable = false;
    systemd.user.services.flameshot = mkIf config.services.flameshot.enable {
      Install.WantedBy = mkForce [ "x11-session.target" ];
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

    services.wallutils = {
      enable = true;
      package = pkgs.wallutils.overrideAttrs(old: {
        buildInputs = old.buildInputs or [] ++ [ pkgs.makeWrapper ];
        postInstall = old.postInstall or "" + ''
          for f in $out/bin/*; do
            wrapProgram $f --prefix PATH : ${makeBinPath [ pkgs.feh ]} \
              --set GDM_SESSION "i3" \
              --set XDG_SESSION_DESKTOP "i3" \
              --set DESKTOP_SESSION "i3"
          done
        '';
      });
      timed.enable = false;
      timed.theme = "${pkgs.gnome3.gnome-backgrounds}/share/backgrounds/gnome/adwaita-timed.xml";
      static.enable = true;
      static.image = "${config.home.homeDirectory}/Pictures/wallpaper/current";
    };

    systemd.user.services.wallutils.Install.WantedBy = mkForce [ "x11-session.target" ];
    systemd.user.services.wallutils-timed.Install.WantedBy = mkForce [ "x11-session.target" ];

    services.xidlehook = {
      enable = true;
      not-when-fullscreen = true;
      timers = [{
        delay = 60 * 15;
        command = "${pkgs.lightlocker}/bin/light-locker-command -l";
      }];
    };
    systemd.user.services.xidlehook = {
      Install.WantedBy = mkForce [ "x11-session.target" ];
    };
  };
}
