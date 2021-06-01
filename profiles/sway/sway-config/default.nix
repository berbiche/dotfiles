{ rootPath, ... }:

{
  my.home = { config, options, lib, pkgs, ... }: let
    swayConfig = config.lib.my.callWithDefaults ./config.nix { inherit config options rootPath; };
  in {
    home.packages = with pkgs; [
      # oblogout alternative
      wlogout
      wl-clipboard
      wdisplays
      brightnessctl
      grim
      slurp
      wofi
      swaylock
    ];

    wayland.windowManager.sway = {
      enable = true;
      # I don't need Home Manager's Sway, only the configuration
      package = null;

      # We handle the on-startup ourselves now
      systemdIntegration = false;
      xwayland = true;

      inherit (swayConfig) config extraConfig;
    };

    systemd.user.services.waybar = {
      Install.WantedBy = lib.mkForce [ "sway-session.target" ];
    };

    # To use with `volnoti-show` to display a transparent window with the volume level
    systemd.user.services.volnoti = {
      Unit = {
        Description = "Lightweight volume notification daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "dbus";
        BusName = "uk.ac.cam.db538.volume-notification";
        ExecStart = "${pkgs.volnoti}/bin/volnoti -n";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
