{ config, rootPath, ... }:

{
  my.home = { config, lib, pkgs, ... }: let
    swayConfig = config.lib.my.callWithDefaults ./config.nix { inherit config rootPath; };
  in {
    home.packages = with pkgs; [
      xdg-desktop-portal-wlr

      # oblogout alternative
      wlogout
      wl-clipboard
      wdisplays
      # libinput gestures utility
      gebaar-libinput
      # Used in scripts
      brightnessctl
      grim
      slurp
      wofi
      swaylock
    ];

    wayland.windowManager.sway = {
      enable = true;
      package = null;
      # For the sway-session.target
      systemdIntegration = true;
      xwayland = true;

      inherit (swayConfig) config extraConfig;
    };

    # Idle service
    systemd.user.services.sway-idle =
      let
        swaylock = "${pkgs.swaylock}/bin/swaylock";
        swayidle = "${pkgs.swayidle}/bin/swayidle";
        swaymsg  = "${pkgs.sway}/bin/swaymsg";
      in {
        Unit = {
          Description = "Idle manager for Wayland";
          Documentation = "man:swayidle(1)";
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "simple";
          Restart = "always";
          RestartSec = "1sec";
          ExecStart = ''
            ${swayidle} -w \
                timeout 300  "${swaylock} -f" \
                timeout 600  "${swaymsg} 'output * dpms off'" \
                resume       "${swaymsg} 'output * dpms on'" \
                before-sleep "${swaylock} -f"
          '';
        };
        Install.WantedBy = [ "sway-session.target" ];
      };

    systemd.user.services.waybar = {
      Install.WantedBy = lib.mkForce [ "wayland-session.target" ];
    };

    systemd.user.services.volnoti = {
      Unit = {
        Description = "Lightweight volume notification daemon";
        Requisite = [ "dbus.service" ];
        After = [ "dbus.service" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "dbus";
        BusName = "uk.ac.cam.db538.volume-notification";
        ExecStart = "${pkgs.volnoti}/bin/volnoti -n";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install.WantedBy = [ "wayland-session.target" ];
    };
  };
}
