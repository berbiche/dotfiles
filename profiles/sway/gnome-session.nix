/*
  Implementation of https://github.com/Drakulix/sway-gnome

  From my very very brief testing, I couldn't tell what
  having gnome-session running achieved.
*/
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.sway;
  swayPackage = pkgs.sway.override {
    extraSessionCommands = cfg.extraSessionCommands;
    extraOptions = cfg.extraOptions;
    withBaseWrapper = cfg.wrapperFeatures.base;
    withGtkWrapper = cfg.wrapperFeatures.gtk;
    isNixOS = true;
    xdgCurrentDesktop = "GNOME";
  };

  desktopSession = pkgs.makeDesktopItem {
    name = "sway-gnome";
    desktopName = "sway-gnome";
    comment = "Sway Wayland window manager as a systemd service";
    exec = "${swayPackage}/bin/sway";
    type = "Application";
  };
in
{
  services.xserver.displayManager.sessionPackages = [
    (
      pkgs.runCommandLocal "sway-gnome-desktop-session" {
        passthru.providedSessions = [ "sway-gnome" ];
      } ''
        mkdir -p "$out/share/wayland-sessions"
        for f in "${desktopSession}"/share/applications/*; do
          cp "$f" "$out/share/wayland-sessions"
        done
      ''
    )
  ];

  systemd.packages = [
    pkgs.gnome.gnome-session
    pkgs.gnome.gnome-settings-daemon
  ];

  my.home = {
    systemd.user.targets.sway-session.Unit = rec {
      Wants = [
        "gsd-a11y-settings.target"
        "gsd-color.target"
        "gsd-datetime.target"
        "gsd-housekeeping.target"
        "gsd-keyboard.target"
        "gsd-media-keys.target"
        "gsd-power.target"
        "gsd-print-notifications.target"
        "gsd-rfkill.target"
        "gsd-screensaver-proxy.target"
        "gsd-sharing.target"
        "gsd-smartcard.target"
        "gsd-sound.target"
        "gsd-wacom.service"
        "gsd-wwan.target"
        "gsd-xsettings.target"
      ];
      After = Wants;
    };
    systemd.user.services."gnome-session-manager@sway-gnome" = {
      Unit = {
        Description = "GNOME Session Manager (session: %i)";
        PartOf = [ "graphical-session.target" ];
        BindsTo = [ "sway-session.target" ];
        Requisite = [ "sway-session.target" ];
        After = [
          "sway-session.target"
        ];
        RefuseManualStart = false;
        RefuseManualStop = false;
        OnFailure = "gnome-session-shutdown.target";
        OnFailureJobMode = "replace-irreversibly";
        CollectMode = "inactive-or-failed";
      };

      Service = {
        Type = "notify";
        Environment = [ "XDG_CURRENT_DESKTOP=gnome" ];
        ExecStart = "${pkgs.gnome.gnome-session}/libexec/gnome-session-binary --systemd-service --session=%i";
        ExecStopPost = "-${pkgs.gnome.gnome-session-ctl}/libexec/gnome-session-ctl --shutdown";
      };

      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
